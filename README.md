# Dotfiles

Configuração pessoal para uma instalação Fedora, gerenciada com GNU Stow.

## Instalação

Clone este repositório no diretório padrão e execute o instalador como usuário normal:

```bash
git clone https://github.com/hscHeric/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

O script solicitará `sudo` para configurar o DNF, atualizar o Fedora e os Flatpaks, instalar pacotes, grupos, repositórios e aplicativos. Ele também instala o mise, aplica os dotfiles, instala as ferramentas declaradas, configura preferências do GNOME e instala o Doom Emacs ao final.

O instalador pode ser executado novamente. Etapas já concluídas são identificadas e ignoradas, com exceção do LazyVim Starter, que é reinstalado para garantir uma base limpa.

Arquivos conflitantes são preservados em `~/.dotfiles-backup/` antes da criação dos links.

A configuração anterior do Neovim é preservada no diretório de backup e o LazyVim Starter é clonado novamente em `~/.config/nvim`, mesmo que a instalação existente tenha sido modificada. O `.git` interno é removido e o Stow aplica os arquivos pessoais mantidos neste repositório. Todos os scripts ficam em `~/.config/nvim/lua/hscheric` e são carregados automaticamente pelo arquivo-ponte `lua/plugins/hscheric.lua`.

Depois da instalação, conclua as tarefas descritas em [MANUAL_SETUP.md](MANUAL_SETUP.md).

## Comandos úteis

```bash
just install
just check
```
