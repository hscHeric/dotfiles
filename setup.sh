#!/bin/bash

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo dnf update -y

# Instalar pacotes essenciais
echo "Instalando pacotes essenciais..."
sudo dnf install -y git vim curl wget zsh htop openssh-server pandoc paraview texstudio steam

# Instalar pacotes para LaTeX e TeX
echo "Instalando pacotes LaTeX e TeX..."
sudo dnf install -y latexmk texlive-scheme-medium texlive-minted \
  texlive-collection-fontsrecommended \
  texlive-collection-fontsextra \
  texlive-collection-fontutils \
  texlive-scheme-full

# Instalar ferramentas de desenvolvimento
echo "Instalando ferramentas de desenvolvimento..."
sudo dnf group install -y c-development container-management development-tools
sudo dnf install -y make automake gcc gcc-c++ kernel-devel cmake

# Instalar Python e Node.js
echo "Instalando Python e Node.js..."
sudo dnf install -y python3 python3-devel python3-pip nodejs

#echo asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.1
