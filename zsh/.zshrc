export ZSH="$HOME/.oh-my-zsh"
. "$HOME/.cargo/env" 
export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
fpath=($ZSH_CUSTOM/completions $fpath)

ZSH_THEME="bira"

plugins=(
    git
    sudo
    extract
    docker
    docker-compose
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

if [ -f "$HOME/.aliases" ]; then
    source "$HOME/.aliases"
fi

source <(fzf --zsh)

if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
    case "$TERM" in
        dumb) ;;
        *)
            if tmux has-session 2>/dev/null; then
                exec tmux attach-session
            else
                exec tmux new-session
            fi
            ;;
    esac
fi
