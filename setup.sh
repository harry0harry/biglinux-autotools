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
INSTALAR_PYTHON="n"
INSTALAR_OBS="n"
INSTALAR_GIT="n" # Nova variável

# Listas para o relatório final
declare -a RELATORIO_SUCESSOS=()
declare -a RELATORIO_FALHAS=()
declare -a RELATORIO_AVISOS=()

verificar_nao_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${VERMELHO}[❌] Erro: Não execute este script com 'sudo'!${NC}"
        exit 1
    fi
}

# --- Funções de Pergunta ---
perguntar_python() {
    read -p "Instalar o ambiente Python Master? (s/n): " resposta
    [[ "$resposta" =~ ^[Ss]$ ]] && INSTALAR_PYTHON="s" || RELATORIO_AVISOS+=("- Python ignorado.")
}

perguntar_obs() {
    read -p "Deseja instalar o OBS Studio e plugins? (s/n): " resposta
    [[ "$resposta" =~ ^[Ss]$ ]] && INSTALAR_OBS="s" || RELATORIO_AVISOS+=("- OBS Studio ignorado.")
}

perguntar_git() {
    echo -e "\n${AZUL}==================================================${NC}"
    echo -e "${VERDE}           GIT E PLUGINS BIGLINUX                 ${NC}"
    echo -e "${AZUL}==================================================${NC}"
    read -p "Deseja instalar o Git e ferramentas do BigLinux? (s/n): " resposta
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        INSTALAR_GIT="s"
        echo -e "${VERDE}Git e ferramentas BigLinux serão instalados.${NC}"
    else
        echo -e "${AMARELO}Git e ferramentas ignorados.${NC}"
        RELATORIO_AVISOS+=("- Ferramentas Git/BigLinux ignoradas.")
    fi
}

instalar_grupo() {
    local NOME_GRUPO=$1
    shift
    local PACOTES=("$@")
    echo -e "\n${AZUL}[*] Instalando grupo: ${AMARELO}$NOME_GRUPO${NC}..."
    if pamac install --no-confirm "${PACOTES[@]}" > /dev/null 2>&1; then
        echo -e "  ${VERDE}[✔] Sucesso em $NOME_GRUPO${NC}"
        for pkg in "${PACOTES[@]}"; do RELATORIO_SUCESSOS+=("- $pkg (Pacman/AUR)"); done
    else
        echo -e "  ${VERMELHO}[!] Erro no lote $NOME_GRUPO. Tentando individualmente...${NC}"
        for pkg in "${PACOTES[@]}"; do
            if pamac install --no-confirm "$pkg" > /dev/null 2>&1; then
                RELATORIO_SUCESSOS+=("- $pkg (Pacman/AUR)")
            else
                RELATORIO_FALHAS+=("- $pkg (Falhou)")
            fi
        done
    fi
}

instalar_pacotes() {
    APPS_GERAIS=("7zip" "ark" "btop" "dolphin" "dolphin-plugins" "fastfetch" "flatpak" "gwenview" "kamoso" "kate" "kdeconnect" "konsole" "libreoffice-fresh-pt-br" "nano" "nano-syntax-highlighting" "otf-font-awesome" "partitionmanager" "qbittorrent" "qbittorrent-nox")
    instalar_grupo "Aplicativos Gerais" "${APPS_GERAIS[@]}"

    if [ "$INSTALAR_GIT" == "s" ]; then
        # Adicionando Git e pacotes comuns de suporte ao BigLinux
        APPS_DEV=("git" "lazygit" "github-cli" "biglinux-themes-extra" "biglinux-keyring")
        instalar_grupo "Git e Ferramentas BigLinux" "${APPS_DEV[@]}"
    fi

    if [ "$INSTALAR_OBS" == "s" ]; then
        APPS_OBS=("obs-studio" "obs-backgroundremoval" "obs-gstreamer" "obs-vkcapture")
        instalar_grupo "OBS Studio" "${APPS_OBS[@]}"
    fi

    if [ "$INSTALAR_PYTHON" == "s" ]; then
        # ... (mantido como no original)
        PYTHON_DEPENDENCIAS=("python-pip" "python-virtualenv" "python-setuptools" "python-wheel" "sdl2" "sdl2_image" "sdl2_mixer" "sdl2_ttf" "freetype2" "libjpeg-turbo" "libpng" "zlib")
        instalar_grupo "Dependências Python" "${PYTHON_DEPENDENCIAS[@]}"
    fi
}

# --- Restante do script permanece inalterado ---
# [As funções configurar_ambiente_python, gerar_relatorio e finalizar_e_reiniciar continuam aqui]
# [Fluxo Principal]
verificar_nao_root
perguntar_python
perguntar_obs
perguntar_git
instalar_pacotes
# ... (restante do fluxo)
