# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k

# Keybinding ----------------------------
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Exports -------------------------------
export MANPAGER='nvim +Man!'
export GEM_HOME="$HOME/.local/share/gem/ruby/3.4.0"
export PATH="$GEM_HOME/bin:$PATH"

# Completion styling --------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# Aliases -------------------------------
alias lw='librewolf'
alias vim='nvim'
alias vi='nvim'
alias p='sudo pacman'
alias ls='ls --color'
alias ll='ls -l --color'
alias lt='ls -alt --color'
alias nb='newsboat'
alias searxng='librewolf http://localhost:8080'

# Shell integrations --------------------
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

autoload -U colors && colors
PROMPT='%F{9}%n%f@%F{238}%m%f:%F{80}%~%f %# '

# History -------------------------------
HISTSIZE=100000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# Scrub sensitive commands from history -
# Patterns that indicate secrets (case-insensitive partial matches)
_sensitive_patterns=(
  password
  passwd
  secret
  token
  api_key
  apikey
  api-key
  private_key
  privatekey
  credential
  auth_token
  access_key
  accesskey
  secret_key
  secretkey
  ssh-keygen
  openssl
  AWS_SECRET
  AWS_ACCESS
  ANTHROPIC_API_KEY
  OPENAI_API_KEY
)

# Build a single regex from the patterns
_sensitive_regex="($(IFS='|'; echo "${_sensitive_patterns[*]}"))"

# Hook that runs before each command is added to history
# Returning 1 from zshaddhistory prevents the line from being saved
zshaddhistory() {
  local cmd="${1%%$'\n'}"
  if [[ "${cmd:l}" =~ "${_sensitive_regex:l}" ]]; then
    return 1
  fi
  return 0
}

# One-time cleanup: scrub existing history file of sensitive entries
scrub_history() {
  local histfile="${HISTFILE:-$HOME/.zsh_history}"
  if [[ ! -f "$histfile" ]]; then
    echo "No history file found at $histfile"
    return 1
  fi
  local count=0
  local tmpfile=$(mktemp)
  while IFS= read -r line; do
    local dominated=false
    for pat in "${_sensitive_patterns[@]}"; do
      if [[ "${line:l}" == *"${pat:l}"* ]]; then
        dominated=true
        ((count++))
        break
      fi
    done
    if ! $dominated; then
      echo "$line" >> "$tmpfile"
    fi
  done < "$histfile"
  mv "$tmpfile" "$histfile"
  echo "Scrubbed $count sensitive entries from history."
  fc -R  # reload history
}

# Add in snippets -----------------------
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Add in zsh plugins ---------------------
zinit ice wait
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Load completions -----------------------
autoload -Uz compinit
compinit -C

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.local/bin:$PATH"
