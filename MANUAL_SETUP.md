# Configurações manuais

Após executar o script de instalação, conclua as etapas abaixo manualmente.

## Acesso ao GitHub por SSH

- [ ] Gere uma nova chave SSH do tipo Ed25519, utilizando o endereço de e-mail associado à conta do GitHub.
- [ ] Defina uma senha segura para proteger a chave privada.
- [ ] Adicione a chave privada ao agente SSH da sessão.
- [ ] Copie o conteúdo da chave pública, localizada em `~/.ssh/id_ed25519.pub`.
- [ ] Cadastre a chave pública nas configurações de chaves SSH da conta do GitHub.
- [ ] Valide a autenticação executando `ssh -T git@github.com`.
- [ ] Altere o remoto dos dotfiles para SSH executando `git -C ~/.dotfiles remote set-url origin git@github.com:hscHeric/dotfiles.git`.
- [ ] Confirme que apenas a chave pública foi compartilhada e que a chave privada permanece protegida no computador.

## Extensão Bitwarden no Brave

- [ ] Abra o navegador Brave.
- [ ] Instale a extensão oficial Bitwarden Password Manager pela loja de extensões do navegador.
- [ ] Entre na conta do Bitwarden e conclua qualquer verificação de segurança solicitada.
- [ ] Fixe a extensão Bitwarden na barra de ferramentas para facilitar o acesso.
- [ ] Confirme que o preenchimento automático e o bloqueio do cofre estão configurados conforme a sua preferência.
