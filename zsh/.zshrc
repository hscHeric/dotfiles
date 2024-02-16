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

#Inicializa o TMUX
#if command -v tmux &> /dev/null; then
#   tmux
#else
#	echo "Error: Unable to find tmux. Please ensure tmux is installed on your system to utilize this feature. For installation instructions, refer to the official tmux documentation or your system's package manager."
#fi
if [ "$TMUX" = "" ]; then tmux; fi
