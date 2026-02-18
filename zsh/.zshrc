export MANPAGER='nvim +Man!'
export GEM_HOME="$HOME/.local/share/gem/ruby/3.4.0"
export PATH="$GEM_HOME/bin:$PATH"

alias lw='librewolf'
alias vim='nvim'
alias vi='nvim'

PROMPT='%n@%m:%~ '

HISTSIZE=100000
SAVEHIST=200000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

