#!/usr/bin/env bash

# --- Cores para o Terminal ---
VERDE='\033[1;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[1;31m'
AZUL='\033[1;34m'
NC='\033[0m' # Sem cor

# --- Variáveis Globais ---
HOME_DIR="$HOME"
HIDDEN_DIR="$HOME_DIR/.python_master"
VENV_DIR="$HIDDEN_DIR/venv"
VENV_PIP="$VENV_DIR/bin/pip"
RELATORIO="$HOME_DIR/Resumo_Instalacao.md"
INSTALAR_PYTHON="n" # Padrão é não instalar
INSTALAR_OBS="n"    # Padrão é não instalar

# Listas para o relatório final
declare -a RELATORIO_SUCESSOS=()
declare -a RELATORIO_FALHAS=()
declare -a RELATORIO_AVISOS=()

verificar_nao_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${VERMELHO}[❌] Erro: Não execute este script com 'sudo'!${NC}"
        echo -e "Execute apenas como usuário normal: ${AMARELO}./setup.sh${NC}"
        echo -e "O script pedirá sua senha automaticamente quando for necessário.\n"
        exit 1
    fi
}

perguntar_python() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}         AMBIENTE DE DESENVOLVIMENTO PYTHON       ${NC}"
    echo -e "${AZUL}==================================================${NC}"
    echo -e "Deseja instalar todas as bibliotecas de Python (Nativas e via PIP)?"
    echo -e "${AMARELO}Aviso: Isso pode demorar um tempo. Fique de olho no terminal caso sua senha SUDO seja solicitada.${NC}\n"
    
    read -p "Instalar o ambiente Python Master? (s/n): " resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        INSTALAR_PYTHON="s"
        echo -e "${VERDE}Perfeito! O ambiente Python será instalado.${NC}"
    else
        echo -e "${AMARELO}Instalação do Python ignorada.${NC}"
        RELATORIO_AVISOS+=("- A instalação do Ambiente Python Master foi ignorada pelo usuário.")
    fi
}

perguntar_obs() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}             INSTALAÇÃO DO OBS STUDIO             ${NC}"
    echo -e "${AZUL}==================================================${NC}"
    
    read -p "Deseja baixar e instalar o OBS Studio e seus plugins? (s/n): " resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        INSTALAR_OBS="s"
        echo -e "${VERDE}O OBS Studio será instalado.${NC}"
    else
        echo -e "${AMARELO}Instalação do OBS Studio ignorada.${NC}"
        RELATORIO_AVISOS+=("- A instalação do OBS Studio foi ignorada pelo usuário.")
    fi
}

instalar_grupo() {
    local NOME_GRUPO=$1
    shift
    local PACOTES=("$@")

    echo -e "\n${AZUL}[*] Instalando grupo: ${AMARELO}$NOME_GRUPO${NC} (${#PACOTES[@]} pacotes)..."
    
    if pamac install --no-confirm "${PACOTES[@]}" > /dev/null 2>&1; then
        echo -e "  ${VERDE}[✔] Todos os pacotes de $NOME_GRUPO instalados com sucesso!${NC}"
        for pkg in "${PACOTES[@]}"; do
            RELATORIO_SUCESSOS+=("- $pkg (Pacman/AUR)")
        done
    else
        echo -e "  ${VERMELHO}[!] Erro ao instalar o lote. Tentando instalação individual...${NC}"
        RELATORIO_AVISOS+=("- O lote **$NOME_GRUPO** precisou ser instalado individualmente.")
        
        for pkg in "${PACOTES[@]}"; do
            echo -ne "  -> Instalando $pkg... "
            if pamac install --no-confirm "$pkg" > /dev/null 2>&1; then
                echo -e "${VERDE}OK${NC}"
                RELATORIO_SUCESSOS+=("- $pkg (Pacman/AUR)")
            else
                echo -e "${VERMELHO}FALHOU${NC}"
                RELATORIO_FALHAS+=("- $pkg (Pacman/AUR - Pacote quebrado ou não encontrado)")
            fi
        done
    fi
}

instalar_pacotes() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}    INICIANDO INSTALAÇÃO DE PACOTES VIA PAMAC     ${NC}"
    echo -e "${AZUL}==================================================${NC}"

    # Firefox removido da lista abaixo
    APPS_GERAIS=(
        "7zip" "ark" "btop" "dolphin" "dolphin-plugins" "fastfetch"
        "flatpak" "gwenview" "kamoso" "kate" "kdeconnect"
        "konsole" "libreoffice-fresh-pt-br" "nano" "nano-syntax-highlighting"
        "otf-font-awesome" "partitionmanager" "qbittorrent" "qbittorrent-nox"
    )

    instalar_grupo "Aplicativos Gerais" "${APPS_GERAIS[@]}"

    # Instala o OBS apenas se o usuário aceitou
    if [ "$INSTALAR_OBS" == "s" ]; then
        APPS_OBS=(
            "obs-studio" "obs-backgroundremoval" "obs-gstreamer" "obs-vkcapture"
        )
        instalar_grupo "OBS Studio e Plugins" "${APPS_OBS[@]}"
    fi

    # Instala o Python via Pamac apenas se o usuário aceitou
    if [ "$INSTALAR_PYTHON" == "s" ]; then
        PYTHON_DEPENDENCIAS=(
            "python-pip" "python-virtualenv" "python-setuptools" "python-wheel"
            "sdl2" "sdl2_image" "sdl2_mixer" "sdl2_ttf" "freetype2" "libjpeg-turbo" "libpng" "zlib"
        )

        PYTHON_LIBS_NATIVAS=(
            "python-pygame" "python-pyglet" "python-pillow" "python-opencv"
            "python-pyqt5" "python-pyside6" "python-kivy" "python-wxpython"
            "python-requests" "python-beautifulsoup4" "python-selenium" "python-flask"
            "python-django" "python-fastapi" "python-scrapy" "python-httpx" "python-aiohttp"
            "python-numpy" "python-pandas" "python-matplotlib" "python-seaborn" "python-scipy"
            "python-scikit-learn" "jupyter-notebook"
            "python-openpyxl" "python-docx" "python-dotenv" "python-schedule" "python-watchdog" "python-paramiko"
            "python-sqlalchemy" "python-psycopg2" "python-pymongo" "python-redis"
            "python-pytest" "python-black" "python-flake8" "python-mypy"
            "python-pydantic" "python-passlib" "python-stripe"
            "python-rich" "python-click" "python-colorama" "python-tqdm" "python-prompt_toolkit"
            "python-boto3" "python-google-cloud-storage" "python-azure-storage-blob" "python-docker" "python-kubernetes"
            "python-cryptography" "python-pycryptodome" "python-jwt" "python-qrcode" "python-telegram-bot"
        )

        instalar_grupo "Dependências Python do Sistema" "${PYTHON_DEPENDENCIAS[@]}"
        instalar_grupo "Bibliotecas Python Nativas" "${PYTHON_LIBS_NATIVAS[@]}"
    fi
}

configurar_ambiente_python() {
    # Pula a função inteira se o usuário disse não na pergunta inicial
    if [ "$INSTALAR_PYTHON" != "s" ]; then
        return
    fi

    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}    CONFIGURANDO AMBIENTE VIRTUAL PYTHON (PIP)    ${NC}"
    echo -e "${AZUL}==================================================${NC}"

    mkdir -p "$HIDDEN_DIR"

    if [ ! -d "$VENV_DIR" ]; then
        echo "Criando ambiente virtual isolado em $VENV_DIR..."
        if python3 -m venv "$VENV_DIR"; then
            RELATORIO_SUCESSOS+=("- Ambiente Virtual criado em \`$VENV_DIR\`")
        else
            RELATORIO_FALHAS+=("- Falha ao criar Ambiente Virtual")
        fi
    fi

    echo "Atualizando PIP, Setuptools e Wheel..."
    "$VENV_PIP" install --upgrade pip setuptools wheel > /dev/null 2>&1

    PIP_PKGS=(
        "pytmx" "arcade" "moviepy" "dearpygui" "customtkinter"
        "tensorflow" "torch" "pdfplumber" "mysql-connector-python"
        "python-jose" "pydub" "playsound" "pywhatkit" "discord.py"
    )

    echo "Instalando ${#PIP_PKGS[@]} bibliotecas Python adicionais..."
    for pkg in "${PIP_PKGS[@]}"; do
        echo -ne " -> Instalando $pkg... "
        if "$VENV_PIP" install "$pkg" > /dev/null 2>&1; then
            echo -e "${VERDE}OK${NC}"
            RELATORIO_SUCESSOS+=("- $pkg (PIP Venv)")
        else
            echo -e "${VERMELHO}FALHOU${NC}"
            RELATORIO_FALHAS+=("- $pkg (PIP Venv - Falha na compilação ou download)")
        fi
    done

    echo -e "\n${VERDE}[SUCESSO] Ambiente Python Master atualizado!${NC}"
}

gerar_relatorio() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}        GERANDO RELATÓRIO DE INSTALAÇÃO           ${NC}"
    echo -e "${AZUL}==================================================${NC}"
    
    echo "# 📋 Resumo da Instalação - BigLinux Autotools" > "$RELATORIO"
    echo "**Data e Hora:** $(date '+%d/%m/%Y às %H:%M:%S')" >> "$RELATORIO"
    echo "---" >> "$RELATORIO"

    if [ ${#RELATORIO_FALHAS[@]} -gt 0 ]; then
        echo "## ❌ O que NÃO funcionou (Falhas)" >> "$RELATORIO"
        for falha in "${RELATORIO_FALHAS[@]}"; do
            echo "$falha" >> "$RELATORIO"
        done
        echo "" >> "$RELATORIO"
    else
        echo "## ✅ Sucesso Total!" >> "$RELATORIO"
        echo "Nenhum erro crítico ocorreu durante a instalação dos pacotes." >> "$RELATORIO"
        echo "" >> "$RELATORIO"
    fi

    if [ ${#RELATORIO_AVISOS[@]} -gt 0 ]; then
        echo "## ⚠️ Avisos do Sistema" >> "$RELATORIO"
        for aviso in "${RELATORIO_AVISOS[@]}"; do
            echo "$aviso" >> "$RELATORIO"
        done
        echo "" >> "$RELATORIO"
    fi

    echo "## 🟢 O que FOI instalado e configurado com sucesso" >> "$RELATORIO"
    for sucesso in "${RELATORIO_SUCESSOS[@]}"; do
        echo "$sucesso" >> "$RELATORIO"
    done

    echo -e "Relatório salvo em: ${AMARELO}$RELATORIO${NC}"
}

finalizar_e_reiniciar() {
    clear
    
    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    else
        echo "Fastfetch não encontrado."
    fi

    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}----- Sistema configurado! Pronto para o uso! -----${NC}"
    echo -e "${AZUL}==================================================${NC}\n"
    
    echo -e "📄 Um relatório completo foi salvo em: ${AMARELO}$RELATORIO${NC}\n"

    echo "O sistema será reiniciado automaticamente em:"
    for i in {7..1}; do
        echo -ne " Reiniciando em $i segundo(s)...\r"
        sleep 1
    done
    
    echo -e "\n\nReiniciando agora..."
    sudo reboot
}

# --- Fluxo Principal ---
verificar_nao_root
perguntar_python
perguntar_obs
instalar_pacotes
configurar_ambiente_python
gerar_relatorio
finalizar_e_reiniciar
