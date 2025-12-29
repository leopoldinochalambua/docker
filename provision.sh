#!/bin/bash
set -e

DOMAIN="docker-lab.example"

echo "[INFO] Iniciando provisionamento da máquina..."

# Definindo o hash de IPs para que o script seja dinâmico
declare -A HOSTS_MAP=(
    ["master"]="192.168.200.10"
    ["node01"]="192.168.200.21"
    ["node02"]="192.168.200.22"
    ["registry"]="192.168.200.50"
)

# Atualizando /etc/hosts
echo "[INFO] Atualizando /etc/hosts..."
sed -i '/docker-lab.example/d' /etc/hosts
for host in "${!HOSTS_MAP[@]}"; do
    echo "${HOSTS_MAP[$host]} ${host}.${DOMAIN}" >> /etc/hosts
done

# Detectando sistema operacional
OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')

# Verificando se o Docker está instalado
if ! [ -x "$(command -v docker)" ]; then
    echo "[INFO] Docker não está instalado. A instalação automática foi desabilitada."

    # Bloco de instalação do Docker (comentado)
    : '
    echo "[INFO] Iniciando a instalação do Docker..."

    if [[ "$OS_ID" == "ubuntu" ]]; then
        # Instalação no Ubuntu (Jammy)
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    elif [[ "$OS_ID" =~ ^(almalinux|centos|rocky)$ ]]; then
        # Instalação no AlmaLinux/RHEL
        sudo dnf update -y
        sudo dnf install -y dnf-utils
        sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    else
        echo "[ERROR] Sistema operacional não suportado para instalação automática do Docker."
        exit 1
    fi

    # Habilitando e iniciando o serviço Docker
    sudo systemctl enable --now docker

    # Adicionando o usuário 'vagrant' ao grupo 'docker'
    if id "vagrant" &>/dev/null; then
        sudo usermod -aG docker vagrant
    fi
    '
else
    echo "[INFO] Docker já está instalado. Nenhuma ação necessária."
fi

echo "[INFO] Provisionamento concluído com sucesso!"
