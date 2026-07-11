# Dotfiles

Configuração pessoal para uma instalação Fedora, gerenciada com GNU Stow.

## Instalação

Clone este repositório no diretório padrão e execute o instalador como usuário normal:

```bash
git clone <URL-DO-REPOSITORIO> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

O script solicitará `sudo` para instalar pacotes, grupos do DNF, repositórios e Flatpaks. Ele também instala o mise, aplica os dotfiles e instala as ferramentas declaradas.

O instalador pode ser executado novamente: etapas já concluídas são identificadas e ignoradas.

Arquivos conflitantes são preservados em `~/.dotfiles-backup/` antes da criação dos links.

Depois da instalação, conclua as tarefas descritas em [MANUAL_SETUP.md](MANUAL_SETUP.md).

## Comandos úteis

```bash
just install
just check
```
