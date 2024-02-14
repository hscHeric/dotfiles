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

