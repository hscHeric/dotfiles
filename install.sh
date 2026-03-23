#!/usr/bin/env bash

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
MISE_CONFIG_SRC="$REPO_DIR/mise/.config/mise/config.toml"
SCRIPT_NAME="$(basename "$0")"

SYSTEM_PACKAGES=(
  git
  stow
  zsh
  curl
  wget
  util-linux-user
  dnf-plugins-core
  flatpak
  bat
  fd-find
  ripgrep
  readline-devel
  ncurses-devel
  libtermcap-devel
  btop
  gnome-tweaks
  fuse
  fuse-libs
  tmux
  gcc
  gcc-c++
  make
  patch
  openssl-devel
  zlib-devel
  libyaml-devel
  libffi-devel
  rust
  cargo
)

FLATPAK_APPS=(
  com.mattjakeman.ExtensionManager
  io.github.getnf.embellish
  ca.desrt.dconf-editor
  org.localsend.localsend_app
  it.mijorus.gearlever
  com.discordapp.Discord
)

REQUIRED_REPO_PATHS=(
  "$REPO_DIR/alacritty/.config/alacritty/alacritty.toml"
  "$REPO_DIR/mise/.config/mise/config.toml"
  "$REPO_DIR/tmux/.tmux.conf"
  "$REPO_DIR/zsh/.zshrc"
  "$REPO_DIR/nvim-plugins/.config/nvim/lua/plugins"
)

PROMPT_ALL=false
CHECK_ONLY=false

if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'
  BLUE=$'\033[0;34m'
  YELLOW=$'\033[1;33m'
  RED=$'\033[0;31m'
  BOLD=$'\033[1m'
  NC=$'\033[0m'
else
  GREEN=""
  BLUE=""
  YELLOW=""
  RED=""
  BOLD=""
  NC=""
fi

TEMP_DIR="$(mktemp -d)"
SUDO_KEEPALIVE_PID=""

log() {
  local level="$1"
  local color="$2"
  shift 2
  printf '%s%s[%s]%s %s\n' "$color" "$BOLD" "$level" "$NC" "$*"
}

info() { log "INFO" "$BLUE" "$*"; }
success() { log "OK" "$GREEN" "$*"; }
warn() { log "AVISO" "$YELLOW" "$*"; }
error() { log "ERRO" "$RED" "$*"; }

cleanup() {
  rm -rf "$TEMP_DIR"

  if [[ -n "$SUDO_KEEPALIVE_PID" ]] && kill -0 "$SUDO_KEEPALIVE_PID" 2>/dev/null; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
}

on_error() {
  local line="$1"
  error "Falha na linha ${line}. Revise a saída acima para identificar a etapa que quebrou."
  exit 1
}

trap 'on_error "$LINENO"' ERR
trap cleanup EXIT

usage() {
  cat <<EOF
Uso: $SCRIPT_NAME [opcoes]

Opcoes:
  --yes, -y     Executa todas as etapas sem confirmacao interativa
  --check       Valida a estrutura do repositorio e dependencias locais sem instalar nada
  --help, -h    Exibe esta ajuda
EOF
}

parse_args() {
  while (($# > 0)); do
    case "$1" in
      --yes|-y)
        PROMPT_ALL=true
        ;;
      --check)
        CHECK_ONLY=true
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        error "Opcao invalida: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

confirm_step() {
  local message="$1"

  if [[ "$PROMPT_ALL" == true ]]; then
    info "$message"
    return 0
  fi

  printf '\n%s%s>>%s %s%s%s\n' "$YELLOW" "$BOLD" "$NC" "$BOLD" "$message" "$NC"
  read -r -p "Deseja prosseguir? [y/N]: " choice
  [[ "$choice" =~ ^[Yy]$ ]]
}

require_command() {
  local command_name="$1"
  command -v "$command_name" >/dev/null 2>&1 || error "Comando obrigatorio ausente: $command_name"
}

prompt_value() {
  local label="$1"
  local current_value="$2"
  local input=""

  if [[ "$PROMPT_ALL" == true && -n "$current_value" ]]; then
    printf '%s' "$current_value"
    return 0
  fi

  if [[ -n "$current_value" ]]; then
    read -r -p "$label [$current_value]: " input
    printf '%s' "${input:-$current_value}"
    return 0
  fi

  while true; do
    read -r -p "$label: " input
    if [[ -n "$input" ]]; then
      printf '%s' "$input"
      return 0
    fi
    warn "Valor obrigatorio."
  done
}

ensure_fedora() {
  [[ -f /etc/fedora-release ]] || error "Este instalador foi preparado para Fedora Linux."
}

refresh_sudo() {
  info "Validando permissao administrativa..."
  sudo -v

  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPALIVE_PID="$!"
}

stow_packages() {
  find "$REPO_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".git" -printf '%f\n' | sort
}

check_repo_layout() {
  local missing=0
  local path=""

  info "Validando a estrutura do repositorio..."
  for path in "${REQUIRED_REPO_PATHS[@]}"; do
    if [[ -e "$path" ]]; then
      success "Encontrado: ${path#$REPO_DIR/}"
    else
      error "Caminho obrigatorio ausente: ${path#$REPO_DIR/}"
      missing=1
    fi
  done

  if [[ "$missing" -ne 0 ]]; then
    exit 1
  fi
}

check_local_dependencies() {
  local optional_commands=(git bash find mktemp)
  local recommended_commands=(stow flatpak curl sudo dnf)
  local command_name=""

  info "Checando dependencias locais para execucao do script..."
  for command_name in "${optional_commands[@]}"; do
    require_command "$command_name"
  done

  for command_name in "${recommended_commands[@]}"; do
    if command -v "$command_name" >/dev/null 2>&1; then
      success "Disponivel: $command_name"
    else
      warn "Nao encontrado no ambiente atual: $command_name"
    fi
  done
}

append_line_if_missing() {
  local target_file="$1"
  local expected_line="$2"

  sudo touch "$target_file"
  if ! sudo grep -Fqx "$expected_line" "$target_file"; then
    printf '%s\n' "$expected_line" | sudo tee -a "$target_file" >/dev/null
  fi
}

configure_dnf() {
  local dnf_conf="/etc/dnf/dnf.conf"

  info "Aplicando ajustes de performance no DNF..."
  append_line_if_missing "$dnf_conf" "fastestmirror=True"
  append_line_if_missing "$dnf_conf" "max_parallel_downloads=15"
  append_line_if_missing "$dnf_conf" "deltarpm=True"

  info "Atualizando o sistema..."
  sudo dnf upgrade --refresh -y
  success "Sistema atualizado."
}

install_system_packages() {
  info "Instalando dependencias base..."
  sudo dnf install -y "${SYSTEM_PACKAGES[@]}"
  success "Pacotes base instalados."
}

install_alacritty() {
  info "Instalando Alacritty..."
  sudo dnf install -y alacritty
  success "Alacritty instalado."
}

configure_git_and_ssh() {
  local current_name=""
  local current_email=""
  local git_name=""
  local git_email=""

  current_name="$(git config --global --get user.name || true)"
  current_email="$(git config --global --get user.email || true)"

  git_name="$(prompt_value "Nome para o Git" "$current_name")"
  git_email="$(prompt_value "Email para o Git" "$current_email")"

  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
  git config --global init.defaultBranch main
  success "Git global configurado."

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
    info "Gerando chave SSH Ed25519..."
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
    success "Chave SSH criada em ~/.ssh/id_ed25519."
  else
    warn "Chave SSH ja existe em ~/.ssh/id_ed25519."
  fi

  if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    printf '\n%sChave publica SSH:%s\n' "$BOLD" "$NC"
    cat "$HOME/.ssh/id_ed25519.pub"
    printf '\n'
  fi
}

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Instalando Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    info "Oh My Zsh ja instalado."
  fi

  mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/completions"

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  else
    info "Plugin zsh-autosuggestions ja instalado."
  fi

  if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  else
    info "Plugin zsh-syntax-highlighting ja instalado."
  fi

  success "Ambiente Zsh preparado."
}

install_mise() {
  local mise_bin="$HOME/.local/bin/mise"

  if [[ ! -x "$mise_bin" ]]; then
    info "Instalando mise..."
    curl https://mise.run | sh
  else
    info "mise ja instalado."
  fi

  export PATH="$HOME/.local/bin:$PATH"

  [[ -f "$MISE_CONFIG_SRC" ]] || error "Config do mise nao encontrada em $MISE_CONFIG_SRC"

  mkdir -p "$HOME/.config/mise" "$ZSH_CUSTOM/completions"
  cp "$MISE_CONFIG_SRC" "$HOME/.config/mise/config.toml"

  info "Instalando runtimes definidos no mise..."
  "$mise_bin" install
  "$mise_bin" completion zsh >"$ZSH_CUSTOM/completions/_mise"
  success "mise configurado."
}

install_lazyvim() {
  local nvim_dir="$HOME/.config/nvim"

  if [[ ! -d "$nvim_dir" ]]; then
    info "Clonando LazyVim starter em ~/.config/nvim..."
    git clone https://github.com/LazyVim/starter "$nvim_dir"
    rm -rf "$nvim_dir/.git"
    success "LazyVim starter instalado."
    return 0
  fi

  if [[ ! -f "$nvim_dir/init.lua" ]]; then
    warn "~/.config/nvim existe, mas nao parece ser o starter do LazyVim."
    warn "Mantendo o diretorio atual sem sobrescrever."
    return 0
  fi

  info "LazyVim ja presente em ~/.config/nvim. Mantendo instalacao atual."
}

install_flatpaks() {
  info "Configurando Flathub..."
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

  local app=""
  for app in "${FLATPAK_APPS[@]}"; do
    info "Instalando $app..."
    flatpak install flathub "$app" -y
  done

  success "Aplicativos Flatpak instalados."
}

apply_dotfiles() {
  local package=""

  cd "$REPO_DIR"
  while IFS= read -r package; do
    info "Aplicando dotfiles de $package..."
    stow --restow "$package"
  done < <(stow_packages)

  success "Dotfiles aplicados com GNU Stow."
}

set_default_shell() {
  local current_shell=""
  local zsh_path=""

  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  zsh_path="$(command -v zsh)"

  if [[ "$current_shell" != "$zsh_path" ]]; then
    sudo chsh -s "$zsh_path" "$USER"
    success "Shell padrao alterado para zsh."
  else
    info "Zsh ja e o shell padrao."
  fi
}

run_post_checks() {
  local package=""
  local failed=0

  info "Executando verificacoes finais..."

  for package in $(stow_packages); do
    if stow --simulate --restow "$package" >/dev/null 2>&1; then
      success "Stow validado para $package"
    else
      error "Conflito detectado pelo stow em $package"
      failed=1
    fi
  done

  if [[ -f "$HOME/.config/mise/config.toml" ]]; then
    success "Config do mise presente em ~/.config/mise/config.toml"
  else
    warn "Config do mise ainda nao encontrada em ~/.config/mise/config.toml"
  fi

  if [[ -f "$HOME/.zshrc" ]]; then
    success "~/.zshrc disponivel"
  else
    warn "~/.zshrc nao foi encontrado"
  fi

  if [[ -f "$HOME/.tmux.conf" ]]; then
    success "~/.tmux.conf disponivel"
  else
    warn "~/.tmux.conf nao foi encontrado"
  fi

  if [[ "$failed" -ne 0 ]]; then
    error "Verificacoes finais encontraram problemas."
    exit 1
  fi
}

show_summary() {
  printf '\n%s=======================================================%s\n' "$BLUE" "$NC"
  printf '%s%sChecklist Final%s\n' "$YELLOW" "$BOLD" "$NC"
  printf '%s=======================================================%s\n' "$BLUE" "$NC"
  printf '1. Adicione a chave SSH publica na sua conta do GitHub.\n'
  printf '2. Instale uma Nerd Font pelo Embellish antes de usar o terminal.\n'
  printf '3. Reinicie a sessao para carregar shell, plugins e completions.\n'
  printf '%s=======================================================%s\n' "$BLUE" "$NC"
  success "Instalacao concluida."
}

run_check_mode() {
  check_repo_layout
  check_local_dependencies
  success "Auditoria local concluida."
}

main() {
  parse_args "$@"

  if [[ "$CHECK_ONLY" == true ]]; then
    run_check_mode
    return 0
  fi

  check_repo_layout
  ensure_fedora
  refresh_sudo

  confirm_step "Otimizar DNF e atualizar o sistema" && configure_dnf
  confirm_step "Instalar Alacritty" && install_alacritty
  confirm_step "Instalar pacotes base do sistema" && install_system_packages
  confirm_step "Configurar Git global e chave SSH" && configure_git_and_ssh
  confirm_step "Instalar Oh My Zsh e plugins" && install_oh_my_zsh
  confirm_step "Instalar mise e runtimes" && install_mise
  confirm_step "Instalar LazyVim starter em ~/.config/nvim" && install_lazyvim
  confirm_step "Instalar aplicativos Flatpak" && install_flatpaks
  confirm_step "Aplicar os dotfiles com GNU Stow" && apply_dotfiles
  confirm_step "Definir zsh como shell padrao" && set_default_shell

  run_post_checks
  show_summary
}

main "$@"
