

# BIGLINUX-AUTOTOOLS

Conjunto de scripts em Shell (Bash) desenvolvidos para automatizar o pós-instalação e a manutenção periódica do sistema operacional BigLinux.

---

## 📋 Sobre o Projeto

O **biglinux-autotools** nasceu da necessidade de evitar tarefas repetitivas ao configurar o sistema após uma formatação e ao realizar a manutenção do dia a dia. Com este projeto, você centraliza a instalação de programas essenciais e a limpeza profunda do sistema com apenas um comando no terminal.

O repositório é composto por dois scripts principais:

* **`setup.sh`**: Focado no pós-instalação. Ele baixa seus aplicativos favoritos (incluindo o OBS Studio e plugins, navegadores e utilitários), configura automaticamente um ambiente virtual seguro para bibliotecas Python, ajusta configurações regionais do ZapZap para PT-BR, **gera um relatório detalhado de instalação** e reinicia o computador.
* **`manutencao.sh`**: Focado na manutenção frequente. Ele sincroniza os repositórios oficiais, atualiza pacotes do AUR/Flatpak e elimina arquivos e caches inúteis.

---

## 🛠️ Explicação Técnica Simplificada

Os scripts foram otimizados para **Shell Script puro**, garantindo execução instantânea e integração nativa com o sistema operacional, seguindo as melhores práticas de segurança do Linux:

* **Princípio do Menor Privilégio**: **Nenhum dos scripts deve ser iniciado como root (`sudo`)**. Eles são executados como usuário comum, impedindo que pastas pessoais sejam criadas incorretamente, e solicitam a senha automaticamente apenas nos comandos que exigem alteração no sistema.
* **Tolerância a Falhas e Relatórios**: Durante a instalação, se um pacote específico (como do AUR) falhar, o script não cancela o resto. Ele entra em modo de segurança individual e, ao final, gera um arquivo `Resumo_Instalacao.md` na pasta principal do usuário com todo o histórico de sucessos e falhas.
* **Gerenciamento Híbrido de Pacotes**: O script utiliza o `pamac` (gerenciador nativo do BigLinux) por ser capaz de lidar tanto com os repositórios oficiais da base Arch quanto com o **AUR** (Arch User Repository) de forma automatizada e sem bloqueios de segurança.
* **Tratamento de Strings e Arquivos**: O script localiza e modifica arquivos de configuração `.desktop` do sistema (utilizando ferramentas nativas como `sed`) e aplica overrides de ambiente para forçar o idioma `LANG=pt_BR.UTF-8`, garantindo correções de interface de forma transparente.

---

## 🚀 Como Baixar e Executar

Abra o seu terminal e siga os passos abaixo:

### 1. Clonar o repositório e acessar a pasta
```bash
git clone https://github.com/Harry-Ribeirio-Hub/biglinux-autotools.git
cd biglinux-autotools

```

### 2. Executar o Instalador (`setup.sh`)

> **Nota:** Use este comando apenas após formatar o sistema, pois ele instalará dezenas de pacotes e reiniciará a máquina ao final.

Dê permissão de execução e rode o script **sem sudo**:

```bash
chmod +x setup.sh
./setup.sh

```

### 3. Executar o Faxineiro (`manutencao.sh`)

> **Nota:** Use este comando no seu dia a dia (semanalmente ou a cada 15 dias) para manter o sistema limpo, leve e atualizado.

Dê permissão de execução e rode o script **sem sudo**:

```bash
chmod +x manutencao.sh
./manutencao.sh

```

---

## 🤝 Agradecimentos

Agradeço à maravilhosa comunidade do **BigLinux** e aos desenvolvedores por criarem uma distribuição tão robusta, rápida e simplificada, que abre espaço para que os usuários possam criar e rodar suas próprias ferramentas de automação com facilidade.

---

## 📬 Contato

Se você tiver dúvidas, sugestões de melhoria, uma versão de setup personalizada ou apenas quiser trocar uma ideia sobre desenvolvimento e Linux, pode me encontrar em:

* **E-mail:** harry.ribeiro.dev@gmail.com
* **LinkTree:** [CLICK AQUI](https://linktr.ee/harry.ribeiro.dev)
