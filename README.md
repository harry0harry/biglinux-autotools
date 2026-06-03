# biglinux-autotools

Conjunto de scripts em Python desenvolvidos para automatizar o pós-instalação e a manutenção periódica do sistema operacional BigLinux.

---

## 📋 Sobre o Projeto

O **biglinux-autotools** nasceu da necessidade de evitar tarefas repetitivas ao configurar o sistema após uma formatação e ao realizar a manutenção do dia a dia. Com este projeto, você centraliza a instalação de programas essenciais e a limpeza profunda do sistema com apenas um comando no terminal.

O repositório é composto por dois scripts principais:
* **`setup.py`**: Focado no pós-instalação. Ele baixa seus aplicativos favoritos (incluindo o OBS Studio e plugins, navegadores e utilitários), ajusta configurações regionais do ZapZap para PT-BR e reinicia o computador.
* **`atualizar_sistema.py`**: Focado na manutenção frequente. Ele sincroniza os repositórios oficiais, atualiza pacotes do AUR/Flatpak e elimina arquivos inúteis.

---

## 🛠️ Explicação Técnica Simplificada

Os scripts utilizam a biblioteca nativa `subprocess` do Python para interagir diretamente com o terminal do BigLinux de forma segura e organizada.

* **Gerenciamento Híbrido de Pacotes**: O script utiliza o `pamac` (gerenciador nativo do BigLinux) por ser capaz de lidar tanto com os repositórios oficiais da base Arch quanto com o **AUR** (Arch User Repository) de forma automatizada.
* **Isolamento de Privilégios**: O script de atualização roda como usuário comum e só invoca o `sudo` internamente para tarefas que realmente exigem permissão administrativa (como limpar logs do sistema com `journalctl` ou pacotes órfãos com `pacman`). Isso impede que o gerenciador do AUR seja bloqueado por segurança.
* **Tratamento de Strings e Arquivos**: O script do setup localiza e modifica arquivos de configuração `.desktop` do sistema (utilizando comandos como `sed`) ou aplica overrides de ambiente para forçar o idioma `LANG=pt_BR.UTF-8`, garantindo correções de interface e idioma para aplicativos específicos como o ZapZap.

---

## 🚀 Como Baixar e Executar

Abra o seu terminal e siga os passos abaixo:

### 1. Clonar o repositório e acessar a pasta
```bash
git clone [https://github.com/Harry-Ribeiro-Hub/biglinux-autotools.git](https://github.com/Harry-Ribeiro-Hub/biglinux-autotools.git)
cd biglinux-autotools

```

### 2. Executar o Instalador (`setup.py`)

> **Nota:** Use este comando apenas após formatar o sistema, pois ele reinstalará os pacotes e reiniciará a máquina ao final. Ele precisa ser rodado como root.

Dar permissão de execução:

```bash
chmod +x setup.py

```

Rodar o script:

```bash
sudo ./setup.py

```

### 3. Executar o Faxineiro (`atualizar_sistema.py`)

> **Nota:** Use este comando no seu dia a dia (semanalmente ou a cada 15 dias) para manter o sistema limpo. **Não** use `sudo` para iniciá-lo.

Dar permissão de execução:

```bash
chmod +x atualizar_sistema.py

```

Rodar o script:

```bash
python3 atualizar_sistema.py

```

---

## 🤝 Agradecimentos

Agradeço à maravilhosa comunidade do **BigLinux** e aos desenvolvedores por criarem uma distribuição tão robusta, rápida e simplificada, que abre espaço para que os usuários possam criar e rodar suas próprias ferramentas de automação com facilidade.

---

## 📬 Contato

Se você tiver dúvidas, sugestões de melhoria ou quiser trocar uma ideia sobre desenvolvimento e Linux, pode me encontrar em:

* **E-mail:** harry.ribeiro.dev@gmail.com
* **Instagram:** [@hazzy.dev](https://www.instagram.com/hazzy.dev?igsh=MTcwNXk1cjd0cjNrNw==)

```

```
