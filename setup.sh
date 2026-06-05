#!/usr/bin/env bash

# --- Cores para o Terminal ---
VERDE='\033[1;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[1;31m'
AZUL='\033[1;34m'
NC='\033[0m' # Sem cor

# --- Variáveis Globais ---
REAL_USER=${SUDO_USER:-$(logname)}
HOME_DIR=$(eval echo ~"$REAL_USER")
HIDDEN_DIR="$HOME_DIR/.python_master"
VENV_DIR="$HIDDEN_DIR/venv"
VENV_PIP="$VENV_DIR/bin/pip"

verificar_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${VERMELHO}Erro: Este script precisa de privilégios administrativos.${NC}"
        echo -e "Execute novamente usando: ${AMARELO}sudo ./setup.sh${NC}\n"
        exit 1
    fi
}

instalar_pacotes() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}    INICIANDO INSTALAÇÃO DE PACOTES VIA PAMAC     ${NC}"
    echo -e "${AZUL}==================================================${NC}"

    # Lista consolidada (Apps + OBS + Python OS)
    PACOTES=(
        # Aplicativos Originais
        "7zip" "ark" "btop" "dolphin" "dolphin-plugins" "fastfetch"
        "firefox" "flatpak" "gwenview" "kamoso" "kate" "kdeconnect"
        "konsole" "libreoffice-fresh-pt-br" "nano" "nano-syntax-highlighting"
        "otf-font-awesome" "partitionmanager" "qbittorrent" "qbittorrent-nox"
        
        # OBS Studio e Plugins
        "obs-studio" "obs-backgroundremoval" "obs-gstreamer" "obs-vkcapture"
        
        # Dependências Base Python
        "python-pip" "python-virtualenv" "python-setuptools" "python-wheel"
        "sdl2" "sdl2_image" "sdl2_mixer" "sdl2_ttf" "freetype2" "libjpeg-turbo" "libpng" "zlib"
        
        # Bibliotecas Python Nativas
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

    echo "Atualizando base de dados e instalando ${#PACOTES[@]} pacotes..."
    
    # Executa a instalação. Se falhar parcialmente, o script avisa e continua.
    if pamac install --no-confirm "${PACOTES[@]}"; then
        echo -e "${VERDE}\nTodos os pacotes de sistema foram instalados com sucesso!${NC}"
    else
        echo -e "${VERMELHO}\n[AVISO] Ocorreu um erro na instalação de um ou mais pacotes via pamac.${NC}"
        echo "O script continuará para as próximas configurações."
    fi
}

configurar_ambiente_python() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}    CONFIGURANDO AMBIENTE VIRTUAL PYTHON (PIP)    ${NC}"
    echo -e "${AZUL}==================================================${NC}"

    if [ "$REAL_USER" == "root" ]; then
        echo -e "${VERMELHO}Aviso: Não foi possível determinar o usuário real. Pulando VENV.${NC}"
        return
    fi

    # Cria diretório oculto diretamente como o usuário real (mais seguro que root + chown)
    sudo -u "$REAL_USER" mkdir -p "$HIDDEN_DIR"

    if [ ! -d "$VENV_DIR" ]; then
        echo "Criando ambiente virtual isolado em $VENV_DIR..."
        sudo -u "$REAL_USER" python3 -m venv "$VENV_DIR"
    fi

    echo "Atualizando PIP, Setuptools e Wheel..."
    sudo -u "$REAL_USER" "$VENV_PIP" install --upgrade pip setuptools wheel > /dev/null 2>&1

    PIP_PKGS=(
        "pytmx" "arcade" "moviepy" "dearpygui" "customtkinter"
        "tensorflow" "torch" "pdfplumber" "mysql-connector-python"
        "python-jose" "pydub" "playsound" "pywhatkit" "discord.py"
    )

    echo "Instalando ${#PIP_PKGS[@]} bibliotecas Python adicionais..."
    for pkg in "${PIP_PKGS[@]}"; do
        echo " -> Instalando $pkg..."
        sudo -u "$REAL_USER" "$VENV_PIP" install "$pkg" > /dev/null 2>&1
    done

    echo -e "\n${VERDE}[SUCESSO] Ambiente Python Master criado!${NC}"
}

configurar_zapzap_ptbr() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}       CONFIGURANDO ZAPZAP PARA PORTUGUÊS         ${NC}"
    echo -e "${AZUL}==================================================${NC}"
    
    ATALHO_SISTEMA="/usr/share/applications/com.rtmrosario.zapzap.desktop"
    ATALHO_FLATPAK="/var/lib/flatpak/exports/share/applications/com.rtmrosario.zapzap.desktop"
    CONFIGURADO=0

    for caminho in "$ATALHO_SISTEMA" "$ATALHO_FLATPAK"; do
        if [ -f "$caminho" ]; then
            sed -i 's/Exec=zapzap/Exec=env LANG=pt_BR.UTF-8 zapzap/g' "$caminho" 2>/dev/null
            sed -i 's/Exec=flatpak run com.rtmrosario.zapzap/Exec=env LANG=pt_BR.UTF-8 flatpak run com.rtmrosario.zapzap/g' "$caminho" 2>/dev/null
            CONFIGURADO=1
        fi
    done

    if [ $CONFIGURADO -eq 1 ]; then
        echo -e "${VERDE}ZapZap configurado em Português com sucesso (atalho modificado)!${NC}"
    else
        echo "Aplicando configuração de idioma via Flatpak global..."
        flatpak override --user --env=LANG=pt_BR.UTF-8 com.rtmrosario.zapzap 2>/dev/null
        flatpak override --system --env=LANG=pt_BR.UTF-8 com.rtmrosario.zapzap 2>/dev/null
        echo -e "${VERDE}ZapZap configurado via overrides do Flatpak.${NC}"
    fi
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
    
    echo "O sistema será reiniciado automaticamente em:"
    for i in {7..1}; do
        echo -ne " Reiniciando em $i segundo(s)...\r"
        sleep 1
    done
    
    echo -e "\n\nReiniciando agora..."
    reboot
}

# --- Fluxo Principal ---
verificar_root
instalar_pacotes
configurar_ambiente_python
configurar_zapzap_ptbr
finalizar_e_reiniciar
