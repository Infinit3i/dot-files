#!/usr/bin/env python3
import json, subprocess, time, shutil, sys, os

HYPRCTL = shutil.which("hyprctl") or "/usr/bin/hyprctl"
EMPTY_ICON = ""
HIDE = "\u200B"      # zero-width space to keep names unique
POLL = 0.5
LOG = "/tmp/ws_icons.log"

ICON_MAP = [
    (["alacritty","kitty","wezterm","foot","terminal"], ""),
    (["firefox","brave","chromium","google-chrome","vivaldi","zen"], ""),  # ← added zen
    (["code","code-oss","vscode","vscodium","jetbrains","idea","pycharm","clion"], ""),
    (["discord","element","slack","telegram","signal"], ""),
    (["spotify"], ""),
    (["steam"], ""),
    (["thunar","nautilus","dolphin","nemo","pcmanfm"], ""),
    (["obsidian","notion","notion-app-enhanced"], ""),
    (["libreoffice","writer","calc","impress"], ""),
    (["gimp","krita","inkscape"], ""),
    (["mpv","vlc"], ""),
    (["virt-manager","qemu","virtualbox"], ""),
    (["docker","podman","lazydocker"], ""),
    (["github-desktop","gitkraken","git"], ""),
]

def log(msg):
    try:
        with open(LOG, "a", encoding="utf-8") as f:
            f.write(msg + "\n")
    except Exception:
        pass

def jrun(args):
    return json.loads(subprocess.check_output([HYPRCTL, "-j", *args], text=True))

def icon_for(app):
    a = (app or "").lower()
    for keys, ic in ICON_MAP:
        if any(k in a for k in keys):
            return ic
    return ""

def best_client(clients, wid):
    best, score_best = None, (-1, -1)
    for c in clients:
        ws = c.get("workspace", {})
        if ws.get("id") != wid:
            continue
        score = (1 if c.get("fullscreen", False) else 0, c.get("focusHistoryID") or 0)
        if score > score_best:
            score_best, best = score, c
    return best

def rename_workspace(wid, newname):
    # Your hyprctl expects: renameworkspace <numeric_id> <newname>
    r = subprocess.run(
        [HYPRCTL, "dispatch", "renameworkspace", str(wid), newname],
        text=True, capture_output=True
    )
    if r.returncode != 0:
        log(f"rename fail id={wid} rc={r.returncode} stderr={r.stderr.strip()}")
        return False
    return True

def main():
    log("ws-icons: starting")
    last = {}
    while True:
        try:
            clients = jrun(["clients"])
            workspaces = jrun(["workspaces"])
        except Exception as e:
            log(f"hyprctl error: {e}")
            time.sleep(POLL); continue

        for w in workspaces:
            wid = w.get("id")
            if wid is None or wid < 0:
                continue

            c = best_client(clients, wid)
            icon = icon_for(c.get("class") or c.get("initialClass") or c.get("title") or "") if c else EMPTY_ICON

            newname = f"{icon}{HIDE * wid}"  # icon-only; uniqueness via ZWSP
            if w.get("name") == newname or last.get(wid) == newname:
                continue

            if rename_workspace(wid, newname):
                last[wid] = newname
                log(f"renamed {wid} -> {newname.encode('unicode_escape').decode()}")
            else:
                log(f"rename failed for {wid}")

        time.sleep(POLL)

if __name__ == "__main__":
    os.environ.setdefault("LANG","C.UTF-8")
    sys.exit(main())
