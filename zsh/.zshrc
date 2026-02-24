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

# Add in snippets -----------------------
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::command-not-found

# Aliases -------------------------------
alias lw='librewolf'
alias vim='nvim'
alias vi='nvim'
alias p='sudo pacman'
alias ls='ls --color'
alias ll='ls -l --color'
alias lt='ls -alt --color'
alias nb='newsboat'

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

# Show random Pokémon on new shell -------
if command -v pokemon-colorscripts >/dev/null 2>&1; then
  pokemon-colorscripts -r
fi

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Add in zsh plugins ---------------------
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Load completions -----------------------
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
