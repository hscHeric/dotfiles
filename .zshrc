export PATH=$HOME/.cargo/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"

plugins=(git ssh-agent pip ssh pipenv poetry python rsync zsh-syntax-highlighting tmux ansible command-not-found docker docker-compose zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# ASDF 
. "$HOME/.asdf/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit

. "$HOME/.cargo/env" #rust
eval "$(zoxide init zsh)" #zoxide
source <(fzf --zsh) #fzf

#aliases
alias ls="eza --icons=always"
alias cd="z"

