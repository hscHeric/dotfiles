# Dotfiles

Setup pessoal para Fedora com automacao de ambiente, instalacao de ferramentas e aplicacao de configuracoes via GNU Stow.

## O que este repositorio cobre

- Terminal e shell com `zsh`, Oh My Zsh, plugins e aliases
- `tmux`
- `alacritty`
- `mise` para runtimes e CLIs
- Base de Neovim com LazyVim starter e plugins locais em `nvim-plugins`
- Apps desktop via Flatpak
- Configuracao inicial de Git e chave SSH

## Estrutura

- `install.sh`: instalador principal
- `alacritty/`: configuracoes do terminal
- `zsh/`: `.zshrc` e aliases
- `tmux/`: configuracao do tmux
- `mise/`: configuracao global do mise
- `nvim-plugins/`: plugins locais sobre o starter do LazyVim

## Requisitos

- Fedora Linux
- `sudo`
- acesso a internet
- `git`
- `bash`

O instalador valida a estrutura do repositorio antes de executar alteracoes no sistema.

## Como usar

Clone o repositorio:

```bash
git clone https://github.com/hscHeric/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Rode uma auditoria local sem instalar nada:

```bash
./install.sh --check
```

Execute o setup com confirmacao por etapa:

```bash
./install.sh
```

Execute tudo sem perguntas interativas:

```bash
./install.sh --yes
```

Veja a ajuda:

```bash
./install.sh --help
```

## O que o instalador faz

1. Valida que o sistema e Fedora e que a estrutura esperada do repositorio existe.
2. Mantem o `sudo` ativo durante a execucao.
3. Aplica ajustes no DNF e atualiza o sistema.
4. Instala Alacritty via `dnf`.
5. Instala pacotes base de desenvolvimento e uso diario.
6. Configura Git global e gera chave SSH Ed25519, se necessario.
7. Instala Oh My Zsh e plugins comunitarios.
8. Instala e configura `mise`, incluindo completions no Zsh.
9. Instala o starter do LazyVim em `~/.config/nvim`, quando necessario.
10. Instala aplicativos Flatpak a partir do Flathub.
11. Aplica os dotfiles com GNU Stow.
12. Opcionalmente define `zsh` como shell padrao.
13. Executa verificacoes finais para conferir o estado dos links e arquivos principais.

## Pos-instalacao

Depois da execucao, ainda e recomendavel:

- adicionar a chave SSH publica na conta do GitHub
- instalar uma Nerd Font
- reiniciar a sessao para recarregar shell, plugins e completions

## Observacoes

- O instalador foi escrito para ser idempotente nas etapas principais, mas ainda faz alteracoes reais no sistema.
- Se `~/.config/nvim` ja existir e nao parecer ser o starter do LazyVim, o script nao sobrescreve esse diretorio.
- Os pacotes aplicados via Stow dependem da estrutura do repositorio atual.
