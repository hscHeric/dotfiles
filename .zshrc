# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
source ~/vulkan/1.3.296.0/setup-env.sh
export ZSH="$HOME/.oh-my-zsh"
export KERL_BUILD_DOCS=yes

ZSH_THEME="bira"

plugins=( git ssh-agent pip ssh pipenv poetry python rsync zsh-syntax-highlighting tmux ansible command-not-found docker docker-compose zsh-autosuggestions )

source $ZSH/oh-my-zsh.sh

. "$HOME/.asdf/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit


. ~/.asdf/plugins/java/set-java-home.zsh #configure javahome

. "$HOME/.cargo/env" #rust
eval "$(zoxide init zsh)" #zoxide
source <(fzf --zsh) #fzf

alias ls="eza --icons=always"
alias cd="z"
alias cat='batcat --paging=never'
if [ "$TMUX" = "" ]; then tmux; fi
. ~/.asdf/plugins/golang/set-env.zsh
