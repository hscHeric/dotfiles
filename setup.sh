#!/bin/bash

set -e # Encerra o script se qualquer comando falhar

# Função para exibir mensagens
function mensagem() {
  echo -e "\n#### $1 ####\n"
}

# Atualização do sistema
mensagem "Iniciando o processo de atualização do sistema..."
sudo dnf update -y

# Instalar pacotes essenciais com DNF
pacotes=(
  stow gcc make neovim tmux btop zsh git fzf zoxide bat fd-find alacritty
  ripgrep python3-neovim go curl wget gnome-tweaks htop bzip2-devel libffi-devel
  sqlite-devel tk-devel clang-format clang-tidy readline-devel util-linux-user
  gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel
  openssl-devel libffi-devel xz-devel tk-devel ncurses-devel gdbm-devel
  libuuid-devel libnsl2-devel wget tar lutris texlive-scheme-basic texlive-scheme-medium
  texlive-scheme-full
)

mensagem "Instalando pacotes com DNF..."
sudo dnf install -y "${pacotes[@]}"

# Instalação do Oh My Zsh
mensagem "Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh já está instalado."
fi

# Instalar plugins do Zsh
mensagem "Instalando plugins do Zsh..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"

# Instalar fontes
mensagem "Instalando fontes..."
mkdir -p ~/.local/share/fonts
cp -r "$HOME/.dotfiles/fonts/FiraCode" ~/.local/share/fonts/
fc-cache -f -v

# Instalar Flatpak e aplicativos
mensagem "Instalando Flatpak e aplicativos..."
if ! command -v flatpak &>/dev/null; then
  sudo dnf install -y flatpak
fi

flatpak install -y flathub org.nickvision.tubeconverter
flatpak install -y flathub com.github.tchx84.Flatseal

# Instalar ASDF e linguagens
mensagem "Instalando ASDF e linguagens..."
go install github.com/asdf-vm/asdf/cmd/asdf@v0.18.0

# Instalar plugins de ASDF
asdf plugin add lua
asdf install lua 5.1.5
asdf set -u lua 5.1.5

asdf plugin add python
asdf install python 3.13.9
asdf set -u python 3.13.9

# Instalar Rust
mensagem "Instalando Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
echo "Lembrete: adicione o cargo no env."

# Instalar LazyGit
mensagem "Instalando LazyGit..."
sudo dnf copr enable dejan/lazygit
sudo dnf install lazygit

# Instalar Lutris (para jogos)
mensagem "Instalando Lutris..."
sudo dnf install lutris

# Aplicar stow para configurar os arquivos
mensagem "Aplicando stow para configurar os arquivos..."
stow alacritty
stow git
stow nvim
stow tmux
stow zsh

mensagem "Configurações aplicadas com sucesso!"

mensagem "Instalando TPM - Tmux Package Manager"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Lembretes de configurações manuais
mensagem "Lembretes importantes:"
echo "- Lembrete 1: Habilite o clique com o botão esquerdo no GNOME manualmente."
echo "- Lembrete 2: Configure a personalização de volume no GNOME (se você estiver usando GNOME)."
echo "- Lembrete 3: Instalar o Google Chrome manualmente, caso necessário."
echo "- Lembrete 4: Após instalar o Rust, adicione o Cargo ao seu PATH."
echo "- Lembrete 5: Após configurar o Git, adicione sua chave SSH ao GitHub/GitLab."

# Finalizando instalação
mensagem "Instalação e configuração concluídas com sucesso!"
