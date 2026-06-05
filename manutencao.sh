#!/usr/bin/env bash

# --- Cores para o Terminal ---
VERDE='\033[1;32m'
AMARELO='\033[1;33m'
VERMELHO='\033[1;31m'
AZUL='\033[1;34m'
NC='\033[0m' # Sem cor

# --- 0. Verificação de Segurança ---
# O Pamac lida com o AUR e não permite ser executado como root diretamente.
if [ "$EUID" -eq 0 ]; then
    echo -e "\n${VERMELHO}[❌] Erro: Não execute este script com 'sudo'!${NC}"
    echo -e "Execute apenas como usuário normal: ${AMARELO}./manutencao.sh${NC}"
    echo -e "O script pedirá sua senha automaticamente quando for necessário.\n"
    exit 1
fi

echo -e "${AZUL}==================================================${NC}"
echo -e "${VERDE}      INICIANDO MANUTENÇÃO DO BIGLINUX            ${NC}"
echo -e "${AZUL}==================================================${NC}\n"

# --- 1. Atualização do Sistema e AUR ---
echo -e "${AMARELO}--- 1. Sincronizando Repositórios e Atualizando Sistema (Pacman/AUR) ---${NC}"
if pamac upgrade --no-confirm; then
    echo -e "${VERDE}[✔] Sistema, KDE e AUR atualizados com sucesso!\n${NC}"
else
    echo -e "${VERMELHO}[✖] Houve um problema ao atualizar os pacotes.\n${NC}"
fi

# --- 2. Gerenciamento de Flatpaks ---
echo -e "${AMARELO}--- 2. Verificando e Atualizando Flatpaks ---${NC}"
if ! command -v flatpak >/dev/null 2>&1; then
    echo "Flatpak não encontrado. Instalando..."
    if sudo pacman -S --noconfirm flatpak; then
        echo -e "${VERDE}[✔] Flatpak instalado com sucesso!${NC}"
    else
        echo -e "${VERMELHO}[✖] Falha ao instalar o Flatpak.${NC}"
    fi
fi

if flatpak update -y; then
    echo -e "${VERDE}[✔] Flatpaks atualizados com sucesso!\n${NC}"
else
    echo -e "${VERMELHO}[✖] Falha ao atualizar os Flatpaks.\n${NC}"
fi

# --- 3. Limpeza de Pacotes Órfãos ---
echo -e "${AMARELO}--- 3. Removendo Pacotes Órfãos (Lixo do Sistema) ---${NC}"
# Executa pacman -Qtdq. Se encontrar algo, a variável recebe os pacotes e entra no IF
if PACOTES_ORFAOS=$(pacman -Qtdq 2>/dev/null); then
    # Conta quantas linhas (pacotes) foram encontradas
    QTD_ORFAOS=$(echo "$PACOTES_ORFAOS" | wc -l)
    echo -e "Encontrados ${VERMELHO}${QTD_ORFAOS}${NC} pacotes órfãos. Removendo..."
    
    # O Bash expande a variável PACOTES_ORFAOS naturalmente separada por espaços
    if sudo pacman -Rns --noconfirm $PACOTES_ORFAOS; then
        echo -e "${VERDE}[✔] Pacotes órfãos removidos com sucesso!\n${NC}"
    else
        echo -e "${VERMELHO}[✖] Erro ao remover pacotes órfãos.\n${NC}"
    fi
else
    echo -e "${VERDE}[✔] Nenhum pacote órfão encontrado para remover.\n${NC}"
fi

# --- 4. Limpeza de Caches e Logs ---
echo -e "${AMARELO}--- 4. Limpando Caches e Logs Antigos ---${NC}"
echo "Limpando cache do Pacman/Pamac..."
if pamac clean --keep 2 --no-confirm; then
    echo -e "${VERDE}[✔] Cache do Pamac limpo!${NC}"
else
    echo -e "${VERMELHO}[✖] Erro ao limpar cache do Pamac.${NC}"
fi

echo -e "\nOtimizando logs do sistema (Journalctl)..."
if sudo journalctl --vacuum-time=7d; then
    echo -e "${VERDE}[✔] Logs antigos limpos com sucesso!\n${NC}"
else
    echo -e "${VERMELHO}[✖] Erro ao limpar logs do sistema.\n${NC}"
fi

# --- 5. Finalização (Fastfetch) ---
# Limpa a tela
clear

# Se o fastfetch existir, executa
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
else
    echo -e "${VERMELHO}Fastfetch não encontrado para exibição final.${NC}"
fi

echo -e "\n${AZUL}==================================================${NC}"
echo -e "${VERDE}------ Sistema atualizado, limpo e otimizado! ------${NC}"
echo -e "${AZUL}==================================================${NC}\n"
