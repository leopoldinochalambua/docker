#!/bin/bash
set -e

echo "--- Iniciando Provisionamento em $(hostname) ---"

# 1. Configurar /etc/hosts para resolução local
# Mantemos o localhost e adicionamos as máquinas do lab
cat <<EOF > /etc/hosts
127.0.0.1   localhost
192.168.200.10 master.docker-lab.example master
192.168.200.21 node01.docker-lab.example node01
192.168.200.22 node02.docker-lab.example node02
192.168.200.50 registry.docker-lab.example registry
EOF

# 2. Detectar SO e Instalar Docker (COMENTADO)
if [ -f /etc/debian_version ]; then
    OS_TYPE="debian"
elif [ -f /etc/redhat-release ]; then
    OS_TYPE="rhel"
fi

echo "[INFO] Instalação automática do Docker para $OS_TYPE está desativada (bloco comentado)."

: '
if [ "$OS_TYPE" == "debian" ]; then
    echo "Sabor detectado: Debian/Ubuntu"
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

elif [ "$OS_TYPE" == "rhel" ]; then
    echo "Sabor detectado: RHEL/AlmaLinux"
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    systemctl enable --now docker
fi
'

# 3. Configurar Insecure Registry
# Nota: Só tentará configurar/reiniciar se o binário do docker existir
if [ -x "$(command -v docker)" ]; then
    echo "[INFO] Configurando Insecure Registry e permissões..."
    mkdir -p /etc/docker
    cat <<EOF > /etc/docker/daemon.json
{
  "insecure-registries": ["192.168.200.50:5000"],
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

    systemctl restart docker
    usermod -aG docker vagrant

    # 4. Se for a máquina Registry, rodar o container de registro
    if [[ "$(hostname)" == *"registry"* ]]; then
        if ! docker ps -a | grep -q "local-registry"; then
            echo "Configurando Container Registry..."
            docker run -d -p 5000:5000 --restart=always --name local-registry registry:2
        fi
    fi
else
    echo "[WARN] Docker não encontrado. Pulando configurações do daemon.json e Registry."
fi

echo "--- Provisionamento concluído! ---"
