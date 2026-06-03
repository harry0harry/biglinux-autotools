#!/usr/bin/env python3
import os
import subprocess
import sys
import time

def verificar_root():
    """Garante que o script está sendo executado como root (sudo)."""
    if os.geteuid() != 0:
        print("\nErro: Este script precisa de privilégios administrativos.")
        print("Execute novamente usando: sudo python3 setup.py\n")
        sys.exit(1)

def instalar_pacotes():
    pacotes = [
        "7zip",
        "ark",
        "btop",
        "dolphin",
        "dolphin-plugins",
        "fastfetch",
        "firefox",
        "flatpak",
        "gwenview",
        "kamoso",
        "kate",
        "kdeconnect",
        "konsole",
        "libreoffice-fresh-pt-br",
        "nano",
        "nano-syntax-highlighting",
        "otf-font-awesome",
        "partitionmanager",
        "python-pip",
        "python-requests",
        "zapzap",
        "qbittorrent",
        "qbittorrent-nox"
    ]

    print("==================================================")
    print("    INICIANDO INSTALAÇÃO DOS SEUS APLICATIVOS     ")
    print("==================================================")
    print(f"tualizando base de dados e instalando {len(pacotes)} pacotes...")

    try:
        comando = ["pamac", "install", "--no-confirm"] + pacotes
        subprocess.run(comando, check=True)
        print("\nTodos os aplicativos foram instalados com sucesso!")
    except subprocess.CalledProcessError:
        print("\nOcorreu um erro durante a instalação de um ou mais pacotes.")
        print("O script continuará para as próximas configurações.")

def configurar_zapzap_ptbr():
    """Corrige o atalho do ZapZap para forçar o idioma PT-BR (Flatpak ou Local)."""
    print("\nConfigurando idioma PT-BR para o ZapZap...")
    
    # Caminhos possíveis do arquivo de atalho (.desktop)
    atalho_sistema = "/usr/share/applications/com.rtmrosario.zapzap.desktop"
    atalho_flatpak = "/var/lib/flatpak/exports/share/applications/com.rtmrosario.zapzap.desktop"
    
    configurado = False

    # Testa qual dos atalhos existe no sistema e aplica a correção
    for caminho in [atalho_sistema, atalho_flatpak]:
        if os.path.exists(caminho):
            try:
                # Modifica o arquivo para incluir a variável de idioma LANG=pt_BR.UTF-8
                comando_sed = f"sed -i 's/Exec=zapzap/Exec=env LANG=pt_BR.UTF-8 zapzap/g' {caminho} 2>/dev/null"
                # Caso seja a versão flatpak pura
                comando_sed_flatpak = f"sed -i 's/Exec=flatpak run com.rtmrosario.zapzap/Exec=env LANG=pt_BR.UTF-8 flatpak run com.rtmrosario.zapzap/g' {caminho} 2>/dev/null"
                
                os.system(comando_sed)
                os.system(comando_sed_flatpak)
                configurado = True
            except Exception:
                pass

    if configurado:
        print("[ZapZap configurado em Português com sucesso!")
    else:
        # Se for um Flatpak a nível de usuário, aplica a configuração global do Flatpak para garantir
        print("Aplicando configuração de idioma via Flatpak...")
        os.system("flatpak override --user --env=LANG=pt_BR.UTF-8 com.rtmrosario.zapzap 2>/dev/null")
        os.system("flatpak override --system --env=LANG=pt_BR.UTF-8 com.rtmrosario.zapzap 2>/dev/null")

def finalizar_e_reiniciar():
    """Limpa a tela, mostra o fastfetch, faz contagem de 7 segundos e reinicia."""
    # 1. Limpa a tela do terminal
    os.system('clear')
    
    # 2. Executa o fastfetch
    try:
        subprocess.run(["fastfetch"])
    except FileNotFoundError:
        print("Fastfetch não encontrado.")

    print("\n==================================================")
    print("----- Sistema configurado! Pronto para o uso! -----")
    print("==================================================\n")
    
    # 3. Contagem regressiva de 7 a 1 segundo(s)
    print("\nO sistema será reiniciado automaticamente em:")
    for i in range(7, 0, -1):
        print(f" Reiniciando em {i} segundo(s)...", end="\r", flush=True)
        time.sleep(1)
    
    print("\n\nReiniciando agora...")
    
    # 4. Dá reboot no sistema
    subprocess.run(["reboot"])

def main():
    verificar_root()
    instalar_pacotes()
    configurar_zapzap_ptbr()  # Nova função adicionada aqui
    finalizar_e_reiniciar()

if __name__ == "__main__":
    main()
