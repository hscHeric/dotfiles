#!/bin/bash

# ==============================================================================
# HSCHERIC - FEDORA ULTIMATE SETUP (PROFESSIONAL VERSION)
# ==============================================================================
# Configurações de Instalação
# ==============================================================================

# Pacotes nativos via DNF
SYSTEM_PACKAGES=(
  git stow zsh curl wget util-linux-user
  dnf-plugins-core flatpak eza bat fd-find ripgrep readline-devel
)

# Ferramentas gerenciadas pelo Mise
MISE_TOOLS=(
  "neovim@latest"
  "lua@5.1.5"
  "go@latest"
  "python@latest"
  "node@latest"
  "cmake@latest"
  "make@latest"
)

# Aplicativos via Flatpak (Flathub)
FLATPAK_APPS=(
  "com.mattjakeman.ExtensionManager"
  "io.github.getnf.embellish"
  "ca.desrt.dconf-editor"
)

# ==============================================================================
# Estilização e UI
# ==============================================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[AVISO]${NC} $1"; }
error() {
  echo -e "${RED}${BOLD}[ERRO]${NC} $1"
  exit 1
}

confirm_step() {
  echo -e "\n${YELLOW}${BOLD}>>${NC} ${BOLD}$1${NC}"
  read -p "Deseja prosseguir? [y/N]: " choice
  [[ "$choice" == "y" || "$choice" == "Y" ]] && return 0 || return 1
}

# ==============================================================================
# Início do Script
# ==============================================================================
clear
echo -e "${BLUE}${BOLD}"
echo "      __  __________  __________  ___________  ________"
echo "     / / / / ___/ / / / ____/ __ \/  _/ ____/ / / / __ \\"
echo "    / /_/ /\__ \ /_/ / __/ / /_/ // // /   / /_/ / /_/ /"
echo "   / __  /___/ / __ / /___/ _, _// // /___/ __  / ____/ "
echo "  /_/ /_//____/_/ /_/_____/_/ |_/___/\____/_/ /_/_/      "
echo -e "                   SETUP AUTOMATION (FEDORA)${NC}\n"

# Verificação de OS
[[ ! -f /etc/fedora-release ]] && error "Este sistema não é Fedora Linux."

# Manter Sudo Ativo
info "Solicitando autorização..."
sudo -v
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# 1. Sistema e DNF
if confirm_step "Otimizar DNF e Atualizar Sistema"; then
  info "Acelerando downloads do DNF..."
  sudo tee -a /etc/dnf/dnf.conf >/dev/null <<EOT
fastestmirror=True
max_parallel_downloads=15
deltarpm=True
EOT
  sudo dnf upgrade --refresh -y
  success "Sistema atualizado."
fi

# 2. Dependências Nativas
if confirm_step "Instalar Pacotes do Sistema"; then
  info "Executando dnf install..."
  sudo dnf install -y "${SYSTEM_PACKAGES[@]}"
  success "Dependências instaladas."
fi

# 3. Git e Chave SSH
if confirm_step "Configurar Git e Gerar Chave SSH"; then
  read -p "Nome (Global): " git_name
  read -p "Email (Global): " git_email

  # Git Config
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  git config --global init.defaultBranch main

  # SSH Key Generation
  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    info "Gerando nova chave SSH (ed25519)..."
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
    success "Chave SSH gerada com sucesso."
    echo -e "${BLUE}Sua chave pública:${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
  else
    warn "Chave SSH já existe em ~/.ssh/id_ed25519. Pulando geração."
  fi
fi

# 4. Zsh e Plugins
if confirm_step "Configurar Oh My Zsh e Plugins"; then
  [[ ! -d "$HOME/.oh-my-zsh" ]] && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  success "Shell configurado."
fi

# 5. Mise e Ferramentas Dev
if confirm_step "Instalar Mise e Ferramentas (Com Autocomplete)"; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"

  info "Configurando completions..."
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$ZSH_CUSTOM/completions"
  mise use -g usage
  mise completion zsh >"$ZSH_CUSTOM/completions/_mise"

  for tool in "${MISE_TOOLS[@]}"; do
    if confirm_step "Mise: Instalar $tool?"; then
      mise use --global "$tool"
    fi
  done
  success "Ambiente de desenvolvimento pronto."
fi

# 6. LazyVim Starter
if confirm_step "Instalar LazyVim Starter (se necessário)"; then
  REPO_DIR="$(dirname "$(realpath "$0")")"
  NVIM_DOT_DIR="$REPO_DIR/nvim"
  mkdir -p "$NVIM_DOT_DIR"

  if [[ ! -f "$NVIM_DOT_DIR/init.lua" ]]; then
    info "Clonando LazyVim starter..."
    git clone https://github.com/LazyVim/starter "$NVIM_DOT_DIR"
    rm -rf "$NVIM_DOT_DIR/.git"
    sed -i '1i -- Mise Integration\nvim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH\n' "$NVIM_DOT_DIR/init.lua"
    success "LazyVim configurado nos dotfiles."
  else
    warn "LazyVim já presente nos dotfiles."
  fi
fi

# 7. Aplicativos Flatpak
if confirm_step "Instalar Aplicativos Flatpak"; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  for app in "${FLATPAK_APPS[@]}"; do
    flatpak install flathub "$app" -y
  done
  success "Flatpaks instalados."
fi

# 8. GNU Stow
if confirm_step "Aplicar Dotfiles via Stow"; then
  REPO_DIR="$(dirname "$(realpath "$0")")"
  cd "$REPO_DIR"
  rm -rf "$HOME/.config/nvim" "$HOME/.zshrc" "$HOME/.aliases"
  stow zsh
  stow nvim
  success "Configurações linkadas."
fi

# 9. Troca de Shell
if confirm_step "Definir Zsh como shell padrão"; then
  sudo chsh -s $(which zsh) $USER
  success "Shell alterado."
fi

# ==============================================================================
# Tarefas Manuais
# ==============================================================================
echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${YELLOW}${BOLD}            AÇÕES MANUAIS RESTANTES                    ${NC}"
echo -e "${BLUE}=======================================================${NC}"
echo -e "1. ${BOLD}Som:${NC} Ajustes > Geral > Aumentar Volume Máximo"
echo -e "2. ${BOLD}Touchpad:${NC} Configurações > Touchpad > Habilitar 'Tocar para Clicar'"
echo -e "3. ${BOLD}GitHub:${NC} Adicione a chave pública exibida acima ao seu GitHub."
echo -e "${BLUE}=======================================================${NC}"

success "SETUP CONCLUÍDO COM SUCESSO! REINICIE O SISTEMA."
