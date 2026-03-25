#!/bin/bash
#
# vt-watcher.sh — Watch ~/Downloads for new files, hash them,
# check against VirusTotal, and quarantine until verified.
#

WATCH_DIR="$HOME/Downloads"
QUARANTINE_DIR="$HOME/Downloads/.quarantine"
CONFIG_DIR="$HOME/.config/vt-watcher"
API_KEY_FILE="$CONFIG_DIR/api_key"
LOG_FILE="$HOME/.local/share/vt-watcher.log"
HASH_LOG="$HOME/.local/share/vt-watcher-hashes.log"
VT_API="https://www.virustotal.com/api/v3/files"

# Rate limiting: VT free tier = 4 requests/min
RATE_LIMIT_DELAY=16
CLEAN_CACHE="$CONFIG_DIR/clean_cache"

mkdir -p "$QUARANTINE_DIR" "$CONFIG_DIR"
touch "$CLEAN_CACHE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

notify() {
    local urgency="$1"
    local title="$2"
    local body="$3"
    notify-send -u "$urgency" "$title" "$body" 2>/dev/null
}

# Check dependencies
for cmd in inotifywait sha256sum curl jq notify-send; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: Missing dependency: $cmd"
        exit 1
    fi
done

# Check API key
if [[ ! -f "$API_KEY_FILE" ]]; then
    log "ERROR: No API key found. Place your VirusTotal API key in $API_KEY_FILE"
    notify "critical" "VT Watcher" "No API key found at $API_KEY_FILE"
    exit 1
fi

API_KEY="$(cat "$API_KEY_FILE" | tr -d '[:space:]')"
if [[ -z "$API_KEY" ]]; then
    log "ERROR: API key file is empty"
    exit 1
fi

is_partial_download() {
    local file="$1"
    local basename
    basename="$(basename "$file")"
    # Browser partial download extensions
    case "$basename" in
        *.part|*.crdownload|*.download|*.tmp|*.partial|.*)
            return 0
            ;;
    esac
    return 1
}

wait_for_write_complete() {
    local file="$1"
    local prev_size=-1
    local curr_size=0
    local stable_count=0

    while [[ $stable_count -lt 3 ]]; do
        if [[ ! -f "$file" ]]; then
            return 1
        fi
        curr_size=$(stat --format=%s "$file" 2>/dev/null || echo -1)
        if [[ "$curr_size" == "$prev_size" ]]; then
            ((stable_count++))
        else
            stable_count=0
        fi
        prev_size=$curr_size
        sleep 1
    done
    return 0
}

check_virustotal() {
    local hash="$1"
    local response
    local http_code

    response=$(curl -s -w "\n%{http_code}" \
        --max-time 30 \
        -H "x-apikey: $API_KEY" \
        "$VT_API/$hash")

    http_code=$(echo "$response" | tail -1)
    local body
    body=$(echo "$response" | sed '$d')

    case "$http_code" in
        200)
            local malicious harmless suspicious undetected
            malicious=$(echo "$body" | jq -r '.data.attributes.last_analysis_stats.malicious // 0')
            suspicious=$(echo "$body" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0')
            harmless=$(echo "$body" | jq -r '.data.attributes.last_analysis_stats.harmless // 0')
            undetected=$(echo "$body" | jq -r '.data.attributes.last_analysis_stats.undetected // 0')

            if [[ "$malicious" -gt 0 || "$suspicious" -gt 0 ]]; then
                echo "MALICIOUS:${malicious}:${suspicious}:${harmless}:${undetected}"
            else
                echo "CLEAN:${malicious}:${suspicious}:${harmless}:${undetected}"
            fi
            ;;
        404)
            echo "UNKNOWN"
            ;;
        429)
            log "WARN: Rate limited by VirusTotal, waiting..."
            sleep 60
            echo "RATE_LIMITED"
            ;;
        *)
            log "ERROR: VT API returned HTTP $http_code"
            echo "ERROR:$http_code"
            ;;
    esac
}

process_file() {
    local file="$1"
    local filename
    filename="$(basename "$file")"

    # Skip partial downloads
    if is_partial_download "$file"; then
        log "SKIP: Partial download detected: $filename"
        return
    fi

    # Skip if file disappeared
    if [[ ! -f "$file" ]]; then
        return
    fi

    # Wait for file to finish writing
    if ! wait_for_write_complete "$file"; then
        log "SKIP: File disappeared while waiting: $filename"
        return
    fi

    # Skip directories and empty files
    if [[ -d "$file" || ! -s "$file" ]]; then
        return
    fi

    log "NEW: Processing $filename"

    # Compute SHA256
    local hash
    hash=$(sha256sum "$file" | awk '{print $1}')

    # Skip if already verified clean
    if grep -qF "$hash" "$CLEAN_CACHE" 2>/dev/null; then
        log "CACHED: $filename already verified clean — skipping"
        return
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $hash | $filename" >> "$HASH_LOG"
    log "HASH: $filename -> $hash"

    # Quarantine immediately: move and remove execute permission
    local quarantine_path="$QUARANTINE_DIR/$filename"
    if ! mv "$file" "$quarantine_path" 2>/dev/null; then
        log "ERROR: Failed to quarantine $filename"
        return
    fi
    chmod -x "$quarantine_path" 2>/dev/null

    notify "normal" "VT Watcher" "Scanning: $filename"

    # Rate limit
    sleep "$RATE_LIMIT_DELAY"

    # Check VirusTotal
    local result
    result=$(check_virustotal "$hash")
    local status="${result%%:*}"

    case "$status" in
        CLEAN)
            local stats="${result#CLEAN:}"
            log "CLEAN: $filename ($stats) — releasing from quarantine"
            echo "$hash" >> "$CLEAN_CACHE"
            mv "$quarantine_path" "$file"
            notify "low" "VT Watcher ✓" "$filename is clean\n$stats"
            ;;
        MALICIOUS)
            local stats="${result#MALICIOUS:}"
            IFS=':' read -r mal susp harm undet <<< "$stats"
            log "DANGER: $filename — malicious:$mal suspicious:$susp"
            notify "critical" "VT Watcher ✗ MALICIOUS" "$filename\nMalicious: $mal | Suspicious: $susp\nFile quarantined at:\n$quarantine_path"
            ;;
        UNKNOWN)
            log "UNKNOWN: $filename — hash not found in VirusTotal database"
            notify "normal" "VT Watcher ?" "$filename\nNot found in VirusTotal database.\nQuarantined at:\n$quarantine_path"
            ;;
        RATE_LIMITED)
            # Retry once after rate limit wait
            result=$(check_virustotal "$hash")
            status="${result%%:*}"
            if [[ "$status" == "CLEAN" ]]; then
                mv "$quarantine_path" "$file"
                log "CLEAN (retry): $filename — released"
                notify "low" "VT Watcher ✓" "$filename is clean (after retry)"
            else
                log "HELD: $filename — could not verify after rate limit"
                notify "normal" "VT Watcher" "$filename held in quarantine (rate limited)"
            fi
            ;;
        ERROR*)
            log "ERROR: Could not check $filename — held in quarantine"
            notify "normal" "VT Watcher" "$filename held in quarantine (API error)"
            ;;
    esac
}

# --- Main Loop ---
log "START: Watching $WATCH_DIR for new downloads"
notify "low" "VT Watcher" "Watching ~/Downloads"

inotifywait -m -r \
    -e close_write \
    -e moved_to \
    --exclude '\.quarantine' \
    --format '%w%f' \
    "$WATCH_DIR" | while read -r file; do
        process_file "$file" &
    done
