export ZSH="$HOME/.oh-my-zsh"

#Configurações das linguagens 
. "$HOME/.cargo/env" # Rust 
export PATH=${PATH}:`go env GOPATH`/bin # Golang
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH" #ASDF

ZSH_THEME="bira"

plugins=(
  git
  you-should-use
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
)

#Shell
eval "$(zoxide init zsh)"
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

#aliases
alias cd="z"

autoload -Uz compinit && compinit
source $ZSH/oh-my-zsh.sh

if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [[ -o interactive ]]; then
  tmux new-session -A -s main
fi
