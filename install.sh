#!/bin/bash

# ==============================================================================
# HSCHERIC - FEDORA ULTIMATE SETUP (PROFESSIONAL EDITION)
# ==============================================================================
# Descrição: Automação completa para pós-instalação do Fedora Workstation.
# Funcionalidades:
#   - Otimização de pacotes (DNF) e Instalação do Ghostty (COPR)
#   - Gerenciamento de Runtimes (Mise) com Autocomplete CLI
#   - Editor Neovim configurado com LazyVim Starter
#   - Gestão de Dotfiles via GNU Stow
#   - Segurança (Git Global Config + SSH Ed25519)
#   - Apps Flatpak e Ajustes finos de Interface (Tweaks)
# ==============================================================================

# --- CONFIGURAÇÕES DE EXIBIÇÃO ---
SHOW_OMARCHY_SHORTCUTS=true # Defina como 'false' para ocultar o guia de atalhos no fim

# --- CONFIGURAÇÕES DE INSTALAÇÃO (VARIÁVEIS GLOBAIS) ---

# Pacotes nativos via DNF (Repositórios oficiais)
SYSTEM_PACKAGES=(
  git stow zsh curl wget util-linux-user
  dnf-plugins-core flatpak bat fd-find ripgrep
  readline-devel btop gnome-tweaks
)

# Ferramentas gerenciadas pelo Mise (Runtimes de desenvolvimento)
MISE_TOOLS=(
  "neovim@latest"
  "lua@5.1.5" # Versão fixa para compatibilidade com plugins Neovim
  "go@latest"
  "python@latest"
  "node@latest"
  "cmake@latest"
  "make@latest"
)

# Aplicativos via Flatpak (Flathub)
FLATPAK_APPS=(
  "com.mattjakeman.ExtensionManager" # Gestão de extensões GNOME
  "io.github.getnf.embellish"        # Instalador de Nerd Fonts
  "ca.desrt.dconf-editor"            # Editor avançado de configurações
  "org.localsend.localsend_app"      # Localsend para compartilhar arquivos com o celular
  "it.mijorus.gearlever"             # Gerenciador de AppImages
)

# --- ESTILIZAÇÃO E UI ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Funções de log formatado
info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[AVISO]${NC} $1"; }
error() {
  echo -e "${RED}${BOLD}[ERRO]${NC} $1"
  exit 1
}

# Função de Checkpoint para execução modular
confirm_step() {
  echo -e "\n${YELLOW}${BOLD}>>${NC} ${BOLD}$1${NC}"
  read -p "Deseja prosseguir? [y/N]: " choice
  [[ "$choice" == "y" || "$choice" == "Y" ]] && return 0 || return 1
}

# --- INÍCIO DA EXECUÇÃO ---
clear
echo -e "${BLUE}${BOLD}"
echo "░▒▓█▓▒░░▒▓█▓▒░░▒▓███████▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓███████▓▒░░▒▓█▓▒░░▒▓██████▓▒░  "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        "
echo "░▒▓████████▓▒░░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓████████▓▒░▒▓██████▓▒░ ░▒▓███████▓▒░░▒▓█▓▒░▒▓█▓▒░        "
echo "░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        "
echo "░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ "
echo "░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓██████▓▒░  "
echo -e "                   SETUP (FEDORA)${NC}\n"

# Verificação de compatibilidade
[[ ! -f /etc/fedora-release ]] && error "Este sistema não foi identificado como Fedora Linux."

# Solicitação de privilégios administrativa (Sudo)
info "Validando permissões de administrador..."
sudo -v
# Manter o token de sudo ativo enquanto o script estiver rodando
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2>/dev/null &

# --- BLOCO 1: SISTEMA E DNF ---
if confirm_step "Otimizar DNF e Atualizar Sistema"; then
  info "Aplicando flags de performance em /etc/dnf/dnf.conf..."
  sudo tee -a /etc/dnf/dnf.conf >/dev/null <<EOT
fastestmirror=True
max_parallel_downloads=15
deltarpm=True
EOT
  info "Iniciando upgrade geral de pacotes..."
  sudo dnf upgrade --refresh -y
  success "Sistema atualizado."
fi

# --- BLOCO 2: GHOSTTY (TERMINAL) ---
if confirm_step "Instalar Ghostty Terminal (via COPR)"; then
  info "Habilitando repositório scottames/ghostty..."
  sudo dnf copr enable scottames/ghostty -y
  sudo dnf install -y ghostty
  success "Ghostty instalado."
fi

# --- BLOCO 3: PACOTES DO SISTEMA ---
if confirm_step "Instalar Pacotes do Sistema (Dependências base)"; then
  info "Instalando lista de pacotes SYSTEM_PACKAGES..."
  sudo dnf install -y "${SYSTEM_PACKAGES[@]}"
  success "Instalação concluída."
fi

# --- BLOCO 4: IDENTIDADE E SEGURANÇA ---
if confirm_step "Configurar Git e Gerar Chave SSH"; then
  read -p "Digite seu Nome para o Git: " git_name
  read -p "Digite seu Email para o Git: " git_email

  info "Configurando Git Global..."
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  git config --global init.defaultBranch main

  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    info "Gerando nova chave SSH Ed25519..."
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
    success "Chave gerada."
    echo -e "${BLUE}Chave Pública (Copie para o GitHub):${NC}"
    cat "$HOME/.ssh/id_ed25519.pub"
  else
    warn "Chave SSH já existente em ~/.ssh/id_ed25519."
  fi
fi

# --- BLOCO 5: AMBIENTE ZSH ---
if confirm_step "Configurar Oh My Zsh e Plugins"; then
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Baixando Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  fi

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  info "Instalando plugins comunitários..."
  [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  success "Shell configurado."
fi

# --- BLOCO 6: MISE (TOOL MANAGER) ---
if confirm_step "Instalar Mise e Ferramentas (Com Autocomplete)"; then
  info "Instalando Mise-en-place..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"

  info "Configurando Shell Completions..."
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$ZSH_CUSTOM/completions"
  mise use -g usage
  mise completion zsh >"$ZSH_CUSTOM/completions/_mise"

  for tool in "${MISE_TOOLS[@]}"; do
    if confirm_step "Mise: Instalar $tool?"; then
      mise use --global "$tool"
    fi
  done
  success "Ambiente Mise pronto."
fi

# --- BLOCO 7: NEovim (LAZYVIM) ---
if confirm_step "Instalar LazyVim Starter (se necessário)"; then
  REPO_DIR="$(dirname "$(realpath "$0")")"
  NVIM_DOT_DIR="$REPO_DIR/nvim"
  mkdir -p "$NVIM_DOT_DIR"

  if [[ ! -f "$NVIM_DOT_DIR/init.lua" ]]; then
    info "Clonando LazyVim starter..."
    git clone https://github.com/LazyVim/starter "$NVIM_DOT_DIR"
    rm -rf "$NVIM_DOT_DIR/.git"
    # Injeta o PATH do Mise no topo do init.lua
    sed -i '1i -- Mise Integration\nvim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH\n' "$NVIM_DOT_DIR/init.lua"
    success "LazyVim configurado nos dotfiles."
  else
    warn "LazyVim já detectado."
  fi
fi

# --- BLOCO 8: FLATPAKS ---
if confirm_step "Instalar Aplicativos Flatpak (Flathub)"; then
  info "Verificando repositório Flathub..."
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  for app in "${FLATPAK_APPS[@]}"; do
    info "Instalando $app..."
    flatpak install flathub "$app" -y
  done
  success "Flatpaks ok."
fi

# --- BLOCO 9: GNU STOW (DOTFILES) ---
if confirm_step "Aplicar Dotfiles via Stow"; then
  REPO_DIR="$(dirname "$(realpath "$0")")"
  cd "$REPO_DIR"
  info "Limpando conflitos no diretório HOME..."
  rm -rf "$HOME/.config/nvim" "$HOME/.zshrc" "$HOME/.aliases" "$HOME/.config/ghostty"

  info "Criando links simbólicos..."
  stow zsh
  stow nvim
  stow ghostty
  success "Links sincronizados."
fi

# --- BLOCO 10: SHELL PADRÃO ---
if confirm_step "Definir Zsh como shell padrão"; then
  sudo chsh -s $(which zsh) $USER
  success "Shell alterado."
fi

# --- BLOCO 11: RESUMO E CONFIGURAÇÕES MANUAIS ---
echo -e "\n${BLUE}=======================================================${NC}"
echo -e "${YELLOW}${BOLD}            AÇÕES MANUAIS RESTANTES                    ${NC}"
echo -e "${BLUE}=======================================================${NC}"
echo -e "1. ${BOLD}Som:${NC} Ajustes (Tweaks) > Geral > Aumentar Volume Máximo (>100%)"
echo -e "2. ${BOLD}Fonte:${NC} Diminua o tamanho da fonte (ex: 10 ou 11) no gnome-tweaks"
echo -e "3. ${BOLD}Touchpad:${NC} Configurações > Touchpad > Habilitar 'Tocar para Clicar'"
echo -e "4. ${BOLD}GitHub:${NC} Adicione sua chave pública SSH ao GitHub."

echo -e "${BLUE}=======================================================${NC}"
success "SETUP CONCLUÍDO COM SUCESSO! REINICIE O SISTEMA."
