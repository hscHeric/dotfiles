export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gnzh"

plugins=(
  git
  archlinux
  zsh-interactive-cd
  zsh-autosuggestions
  zsh-syntax-highlighting
  history
)

source $ZSH/oh-my-zsh.sh

#ASDF
. /opt/asdf-vm/asdf.sh

#Erlang environment variables
export KERL_BUILD_DOCS=yes
export KERL_INSTALL_HTMLDOCS=yes
export KERL_INSTALL_MANPAGES=yes

#Aliases
alias cat="bat"
alias  ls="exa --icons"
alias  ll="exa -la --icons --group-directories-first"
alias  la="exa -a --icons"

if [ "$TMUX" = "" ]; then tmux; fi
