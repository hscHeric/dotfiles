#!/usr/bin/env bash

set -Eeuo pipefail

readonly DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
readonly MISE_BIN="$HOME/.local/bin/mise"
backup_created=false

info() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

warn() {
    printf '\033[1;33mAviso: %s\033[0m\n' "$*" >&2
}

die() {
    printf '\033[1;31mErro: %s\033[0m\n' "$*" >&2
    exit 1
}

read_list() {
    local file="$1"
    sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$file"
}

backup_conflict() {
    local source="$1"
    local target="$2"
    local relative="${target#"$HOME"/}"

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return
    fi

    if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        return
    fi

    mkdir -p -- "$BACKUP_DIR/$(dirname -- "$relative")"
    mv -- "$target" "$BACKUP_DIR/$relative"
    backup_created=true
    warn "$target foi movido para $BACKUP_DIR/$relative"
}

require_fedora() {
    [[ -r /etc/os-release ]] || die "Não foi possível identificar o sistema operacional."
    # shellcheck disable=SC1091
    source /etc/os-release
    [[ "${ID:-}" == "fedora" ]] || die "Este instalador foi desenvolvido para Fedora. Sistema detectado: ${ID:-desconhecido}."
    [[ $EUID -ne 0 ]] || die "Execute este script como usuário normal; ele solicitará sudo quando necessário."
}

set_dnf_option() {
    local key="$1"
    local value="$2"
    local config='/etc/dnf/dnf.conf'

    if grep -Eqi "^[[:space:]]*${key}[[:space:]]*=[[:space:]]*${value}[[:space:]]*$" "$config"; then
        printf 'Ignorando %s: opção do DNF já configurada como %s.\n' "$key" "$value"
    elif grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$config"; then
        sudo sed -Ei "s|^[[:space:]]*${key}[[:space:]]*=.*|${key}=${value}|" "$config"
    else
        printf '%s=%s\n' "$key" "$value" | sudo tee -a "$config" >/dev/null
    fi
}

configure_dnf() {
    info "Configurando o DNF"
    set_dnf_option fastestmirror True
    set_dnf_option max_parallel_downloads 15
}

install_dnf_content() {
    local -a repos=() packages=() groups=() missing_packages=() missing_groups=()

    info "Validando acesso administrativo"
    sudo -v

    configure_dnf

    info "Atualizando o sistema Fedora"
    sudo dnf upgrade --refresh -y

    info "Instalando suporte do DNF para repositórios adicionais"
    if rpm -q --quiet dnf-plugins-core; then
        printf 'Ignorando dnf-plugins-core: pacote já instalado.\n'
    else
        sudo dnf install -y dnf-plugins-core
    fi

    mapfile -t repos < <(read_list "$DOTFILES_DIR/packages/dnf-repos.txt")
    for repo in "${repos[@]}"; do
        local repo_file="/etc/yum.repos.d/${repo##*/}"
        if [[ -f "$repo_file" ]]; then
            printf 'Repositório já configurado: %s\n' "$repo_file"
        else
            sudo dnf config-manager addrepo --from-repofile="$repo"
        fi
    done

    info "Instalando pacotes do DNF"
    mapfile -t packages < <(read_list "$DOTFILES_DIR/packages/dnf.txt")
    for package in "${packages[@]}"; do
        if rpm -q --quiet "$package"; then
            printf 'Ignorando %s: pacote já instalado.\n' "$package"
        else
            missing_packages+=("$package")
        fi
    done
    if ((${#missing_packages[@]} > 0)); then
        sudo dnf install -y "${missing_packages[@]}"
    else
        printf 'Todos os pacotes do DNF já estão instalados.\n'
    fi

    info "Instalando grupos de desenvolvimento do DNF"
    mapfile -t groups < <(read_list "$DOTFILES_DIR/packages/dnf-groups.txt")
    for group in "${groups[@]}"; do
        if dnf group info --installed "$group" >/dev/null 2>&1; then
            printf 'Ignorando %s: grupo do DNF já instalado.\n' "$group"
        else
            missing_groups+=("$group")
        fi
    done
    if ((${#missing_groups[@]} > 0)); then
        sudo dnf group install -y "${missing_groups[@]}"
    else
        printf 'Todos os grupos do DNF já estão instalados.\n'
    fi
}

install_mise() {
    info "Instalando mise"
    if [[ ! -x "$MISE_BIN" ]]; then
        curl --fail --show-error --silent https://mise.run | sh
    else
        printf 'mise já está instalado: %s\n' "$($MISE_BIN --version)"
    fi
}

install_lazyvim() {
    local nvim_dir="$HOME/.config/nvim"
    local origin=""

    info "Instalando LazyVim"
    if [[ -d "$nvim_dir/.git" ]]; then
        origin="$(git -C "$nvim_dir" remote get-url origin 2>/dev/null || true)"
    fi

    if [[ "$origin" == *"github.com/LazyVim/starter"* ]]; then
        printf 'Ignorando clone do LazyVim: repositório oficial já existe.\n'
    else
        if [[ -e "$nvim_dir" || -L "$nvim_dir" ]]; then
            backup_conflict "$DOTFILES_DIR" "$nvim_dir"
        fi
        git clone https://github.com/LazyVim/starter "$nvim_dir"
    fi
}

stow_dotfiles() {
    local needs_stow=false
    local -a links=(
        "$DOTFILES_DIR/bash/.bashrc|$HOME/.bashrc"
        "$DOTFILES_DIR/bash/.bash_profile|$HOME/.bash_profile"
        "$DOTFILES_DIR/bash/.bashrc.d|$HOME/.bashrc.d"
        "$DOTFILES_DIR/mise/.config/mise|$HOME/.config/mise"
        "$DOTFILES_DIR/nvim/.config/nvim/lua/hscheric|$HOME/.config/nvim/lua/hscheric"
        "$DOTFILES_DIR/nvim/.config/nvim/lua/plugins/hscheric.lua|$HOME/.config/nvim/lua/plugins/hscheric.lua"
        "$DOTFILES_DIR/git/.gitconfig|$HOME/.gitconfig"
        "$DOTFILES_DIR/emacs/.local/share/applications/emacs.desktop|$HOME/.local/share/applications/emacs.desktop"
    )

    info "Aplicando dotfiles com Stow"
    for link in "${links[@]}"; do
        local source="${link%%|*}"
        local target="${link#*|}"
        if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
            printf 'Ignorando %s: link já está correto.\n' "$target"
        else
            backup_conflict "$source" "$target"
            needs_stow=true
        fi
    done

    if [[ "$needs_stow" == true ]]; then
        stow --dir="$DOTFILES_DIR" --target="$HOME" --restow bash mise nvim git emacs
    else
        printf 'Todos os links do Stow já estão configurados.\n'
    fi
}

install_mise_tools() {
    info "Instalando ferramentas declaradas no mise"
    if [[ -n "$($MISE_BIN ls --missing 2>/dev/null)" ]]; then
        "$MISE_BIN" install
    else
        printf 'Ignorando ferramentas do mise: todas já estão instaladas.\n'
    fi

    info "Gerando autocompletion do mise para Bash"
    if [[ -s "$HOME/.local/share/bash-completion/completions/mise" ]]; then
        printf 'Ignorando autocompletion: arquivo já existe.\n'
    else
        mkdir -p -- "$HOME/.local/share/bash-completion/completions"
        "$MISE_BIN" completion bash --include-bash-completion-lib \
            >"$HOME/.local/share/bash-completion/completions/mise"
    fi
}

install_flatpaks() {
    local -a apps=() installed_apps=() missing_apps=()

    info "Configurando Flathub"
    if ! flatpak remotes --system --columns=name | grep -Fxq flathub; then
        sudo flatpak remote-add --system --if-not-exists flathub \
            https://dl.flathub.org/repo/flathub.flatpakrepo
    fi

    info "Instalando aplicativos Flatpak"
    sudo flatpak update --system --noninteractive -y
    mapfile -t apps < <(read_list "$DOTFILES_DIR/packages/flatpak.txt")
    mapfile -t installed_apps < <(flatpak list --system --app --columns=application)
    for app in "${apps[@]}"; do
        if printf '%s\n' "${installed_apps[@]}" | grep -Fxq "$app"; then
            printf 'Ignorando %s: Flatpak já instalado.\n' "$app"
        else
            missing_apps+=("$app")
        fi
    done
    if ((${#missing_apps[@]} > 0)); then
        sudo flatpak install --system --noninteractive -y flathub "${missing_apps[@]}"
    else
        printf 'Todos os aplicativos Flatpak já estão instalados.\n'
    fi
}

configure_gnome() {
    info "Configurando preferências do GNOME"
    if ! gsettings list-schemas | grep -Fxq org.gnome.desktop.sound; then
        warn "Schema de som do GNOME não encontrado; limite de volume não foi configurado."
    elif [[ "$(gsettings get org.gnome.desktop.sound allow-volume-above-100-percent)" == "true" ]]; then
        printf 'Ignorando limite de volume: opção acima de 100%% já está habilitada.\n'
    else
        gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
    fi

}

install_doom_emacs() {
    local emacs_dir="$HOME/.emacs.d"
    local origin=""

    info "Instalando Doom Emacs"
    if [[ -d "$emacs_dir/.git" ]]; then
        origin="$(git -C "$emacs_dir" remote get-url origin 2>/dev/null || true)"
    fi

    if [[ "$origin" == *"github.com/hlissner/doom-emacs"* ]]; then
        printf 'Ignorando clone do Doom Emacs: repositório já existe.\n'
    else
        if [[ -e "$emacs_dir" || -L "$emacs_dir" ]]; then
            backup_conflict "$DOTFILES_DIR" "$emacs_dir"
        fi
        git clone https://github.com/hlissner/doom-emacs "$emacs_dir"
    fi

    if [[ -f "$HOME/.doom.d/init.el" && -d "$emacs_dir/.local" ]]; then
        printf 'Ignorando doom install: Doom Emacs já está configurado.\n'
    else
        "$emacs_dir/bin/doom" install
    fi
}

finish() {
    info "Instalação concluída"
    if [[ "$backup_created" == true ]]; then
        printf 'Arquivos anteriores foram preservados em: %s\n' "$BACKUP_DIR"
    fi
    printf 'Abra um novo terminal ou execute: source ~/.bashrc\n'
    printf '\nAs etapas abaixo exigem configuração manual:\n\n'
    cat "$DOTFILES_DIR/MANUAL_SETUP.md"
}

main() {
    require_fedora
    install_dnf_content
    install_mise
    install_lazyvim
    stow_dotfiles
    install_mise_tools
    install_flatpaks
    configure_gnome
    install_doom_emacs
    finish
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
