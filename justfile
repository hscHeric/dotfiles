dotfiles_dir := justfile_directory()

# Executa a configuração completa do computador.
install:
    "{{ dotfiles_dir }}/install.sh"

# Valida os arquivos de automação sem modificar o sistema.
check:
    bash -n "{{ dotfiles_dir }}/install.sh"
    bash -n "{{ dotfiles_dir }}/bash/.bashrc" "{{ dotfiles_dir }}"/bash/.bashrc.d/*.sh
    shellcheck "{{ dotfiles_dir }}/install.sh" "{{ dotfiles_dir }}/bash/.bashrc" "{{ dotfiles_dir }}/bash/.bash_profile" "{{ dotfiles_dir }}"/bash/.bashrc.d/*.sh
    git -C "{{ dotfiles_dir }}" diff --check
