# Dotfiles

Configuração pessoal para uma instalação Fedora, gerenciada com GNU Stow.

## Instalação

Clone este repositório no diretório padrão e execute o instalador como usuário normal:

```bash
git clone https://github.com/hscHeric/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

O script solicitará `sudo` para configurar o DNF, atualizar o Fedora e os Flatpaks, instalar pacotes, grupos, repositórios e aplicativos. Ele também instala o mise, aplica os dotfiles, instala as ferramentas declaradas e configura preferências do GNOME.

O instalador pode ser executado novamente: etapas já concluídas são identificadas e ignoradas.

Arquivos conflitantes são preservados em `~/.dotfiles-backup/` antes da criação dos links.

Depois da instalação, conclua as tarefas descritas em [MANUAL_SETUP.md](MANUAL_SETUP.md).

## Comandos úteis

```bash
just install
just check
```
