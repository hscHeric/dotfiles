#!/bin/bash

# Este script é para configurar o sistema no Pop!_OS 22.04 LTS

# Atualiza o sistema e instala pacotes essenciais
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
    build-essential \
    zlib1g-dev \
    libffi-dev \
    libbz2-dev \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libgdbm-dev \
    libgdbm-compat-dev \
    libtk8.6 \
    tk-dev \
    uuid-dev \
    libx11-dev \
    libxext-dev \
    libexpat1-dev \
    zsh cmake gettext ca-certificates curl ripgrep fd-find linux-headers-$(uname -r)

# Instala o Rust via rustup (gerenciador de versões do Rust)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clona o repositório do Neovim e faz o build
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo

# Cria o pacote .deb e instala
cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

# Instala o Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instala o asdf-vm (gerenciador de versões universal)
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1

# Adiciona as configurações do asdf ao arquivo .zshrc
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
echo 'fpath=(${ASDF_DIR}/completions $fpath)' >> ~/.zshrc
echo 'autoload -Uz compinit && compinit' >> ~/.zshrc

# Recarrega o .zshrc
source ~/.zshrc

# Atualiza o asdf
asdf update

# Remover pacotes Docker existentes, se houver
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y $pkg
done

# Adiciona a chave GPG oficial do Docker
sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Adiciona o repositório oficial do Docker aos sources do Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza os repositórios após adicionar o Docker
sudo apt-get update

# Cria o grupo docker e adiciona o usuário ao grupo
sudo groupadd docker
sudo usermod -aG docker $USER

# Habilita os serviços do Docker para iniciar automaticamente
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# INSTRUÇÕES PARA O ASDF

# Adiciona as linguagens no asdf
echo "Para instalar as versões das linguagens que você precisa, use o asdf para as seguintes linguagens:"

echo "1. Lua:"
echo "  asdf plugin-add lua"
echo "  asdf install lua latest"
echo "  asdf global lua latest"

echo "2. Erlang:"
echo "  asdf plugin-add erlang"
echo "  asdf install erlang latest"
echo "  asdf global erlang latest"

echo "3. Elixir:"
echo "  asdf plugin-add elixir"
echo "  asdf install elixir latest"
echo "  asdf global elixir latest"

echo "4. LazyGit:"
echo "  asdf plugin-add lazygit https://github.com/TechEddie/asdf-lazygit.git"
echo "  asdf install lazygit latest"
echo "  asdf global lazygit latest"

echo "5. Node.js:"
echo "  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git"
echo "  asdf install nodejs latest"
echo "  asdf global nodejs latest"
