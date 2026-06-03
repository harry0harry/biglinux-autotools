#!/usr/bin/env python3
import os
import subprocess
import sys

def verificar_nao_root():
    """Garante que o script NÃO está sendo executado diretamente como sudo/root,
    pois o pamac/AUR bloqueia o root por segurança."""
    if os.geteuid() == 0:
        print("\n[❌] Erro: Não execute este script com 'sudo python3 ...'")
        print("Execute apenas como usuário normal: python3 atualizar_sistema.py")
        print("O script pedirá sua senha quando for necessário.\n")
        sys.exit(1)

def executar_comando(comando, mensagem_sucesso, mensagem_erro, shell=False):
    """Executa um comando no terminal e trata o status de saída."""
    try:
        resultado = subprocess.run(comando, shell=shell, check=True)
        if resultado.returncode == 0:
            print(f"{mensagem_sucesso}\n")
    except subprocess.CalledProcessError:
        print(f"{mensagem_erro}\n")

def atualizar_sistema_e_aur():
    print("--- 1. Sincronizando Repositórios e Atualizando Sistema (Pacman/AUR) ---")
    # Sem o sudo aqui, o pamac vai gerenciar o AUR perfeitamente e pedir a senha na janela do BigLinux ou terminal se precisar
    executar_comando(["pamac", "upgrade", "--no-confirm"], 
                     "Sistema, KDE e AUR atualizados com sucesso!",
                     "Houve um problema ao atualizar os pacotes.")

def gerenciar_flatpak():
    print("--- 2. Verificando e Atualizando Flatpaks ---")
    checar_flatpak = subprocess.run(["command", "-v", "flatpak"], shell=True, capture_output=True)
    
    if checar_flatpak.returncode != 0:
        print("Flatpak não encontrado. Instalando...")
        # Adicionado 'sudo' apenas para a instalação do pacote nativo
        executar_comando(["sudo", "pacman", "-S", "--noconfirm", "flatpak"],
                         "Flatpak instalado com sucesso!",
                         "Falha ao instalar o Flatpak.")
    
    # Flatpak update pode rodar como usuário normal
    executar_comando(["flatpak", "update", "-y"],
                     "Flatpaks atualizados com sucesso!",
                     "Falha ao atualizar os Flatpaks.")

def limpar_orfaos():
    print("--- 3. Removendo Pacotes Órfãos (Lixo do Sistema) ---")
    resultado = subprocess.run(["pacman", "-Qtdq"], capture_output=True, text=True)
    pacotes_orfaos = resultado.stdout.strip().split()
    
    if pacotes_orfaos and pacotes_orfaos[0] != "":
        print(f"Encontrados {len(pacotes_orfaos)} pacotes órfãos. Removendo...")
        # Adicionado 'sudo' para a remoção
        executar_comando(["sudo", "pacman", "-Rns", "--noconfirm"] + pacotes_orfaos,
                         "Pacotes órfãos removidos com sucesso!",
                         "Erro ao remover pacotes órfãos.")
    else:
        print("Nenhum pacote órfão encontrado para remover.\n")

def limpar_caches_e_logs():
    print("--- 4. Limpando Caches e Logs Antigos ---")
    print("Limpando cache do Pacman/Pamac...")
    # Pamac clean roda como usuário normal
    executar_comando(["pamac", "clean", "--keep", "2", "--no-confirm"],
                     "Cache do Pamac limpo!",
                     "Erro ao limpar cache do Pamac.")
    
    print("Otimizando logs do sistema (Journalctl)...")
    # Adicionado 'sudo' porque os logs do sistema exigem privilégios para limpar
    executar_comando(["sudo", "journalctl", "--vacuum-time=7d"],
                     "Logs antigos limpos com sucesso!",
                     "Erro ao limpar logs do sistema.")

def finalizar_com_fastfetch():
    """Limpa a tela e exibe as informações do sistema."""
    os.system('clear')  # Limpa o terminal antes de exibir o resultado final
    try:
        subprocess.run(["fastfetch"])
    except FileNotFoundError:
        print("Fastfetch não encontrado para exibição final.")

def main():
    verificar_nao_root()
    
    print("==================================================")
    print("      INICIANDO MANUTENÇÃO DO BIGLINUX           ")
    print("==================================================")
    
    atualizar_sistema_e_aur()
    gerenciar_flatpak()
    limpar_orfaos()
    limpar_caches_e_logs()
    
    finalizar_com_fastfetch()
    
    print("\n==================================================")
    print("------Sistema atualizado, limpo e otimizado!------")
    print("==================================================\n")

if __name__ == "__main__":
    main()
