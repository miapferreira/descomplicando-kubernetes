#!/bin/bash

# Script de configuração do Control Plane Kubernetes
# Este script é executado automaticamente na inicialização da instância

set -e

# Variáveis
CLUSTER_NAME="${cluster_name}"
KUBERNETES_VERSION="1.28.15"

# Função para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Iniciando configuração do Control Plane para cluster: $CLUSTER_NAME"

# 1. Atualizar sistema
log "Atualizando sistema..."
apt-get update && apt-get upgrade -y

# 2. Carregar módulos do kernel
log "Carregando módulos do kernel..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# 3. Configurar parâmetros do sistema
log "Configurando parâmetros do sistema..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# 4. Instalar dependências
log "Instalando dependências..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# 5. Configurar repositório Docker
log "Configurando repositório Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. Instalar containerd
log "Instalando containerd..."
apt-get update
apt-get install -y containerd.io

# Configurar containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

# 7. Configurar repositório Kubernetes
log "Configurando repositório Kubernetes..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | apt-key add -

echo 'deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# 8. Instalar componentes Kubernetes
log "Instalando componentes Kubernetes..."
apt-get update
apt-get install -y kubelet kubeadm kubectl

# Impedir atualizações automáticas
apt-mark hold kubelet kubeadm kubectl

# Habilitar kubelet
systemctl enable --now kubelet

# 9. Inicializar cluster
log "Inicializando cluster Kubernetes..."
kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# 10. Configurar kubectl para usuário ubuntu
log "Configurando kubectl..."
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# 11. Instalar Weave Net CNI
log "Instalando Weave Net CNI..."
su - ubuntu -c "kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml"

# 12. Aguardar CNI estar pronto
log "Aguardando CNI estar pronto..."
sleep 30

# 13. Verificar status do cluster
log "Verificando status do cluster..."
su - ubuntu -c "kubectl get nodes"
su - ubuntu -c "kubectl get pods -n kube-system"

# 14. Gerar comando de join para workers
log "Gerando comando de join para workers..."
JOIN_COMMAND=$(kubeadm token create --print-join-command)
echo "Comando para workers se juntarem ao cluster:" > /home/ubuntu/join-command.txt
echo "$JOIN_COMMAND" >> /home/ubuntu/join-command.txt
chown ubuntu:ubuntu /home/ubuntu/join-command.txt

log "Configuração do Control Plane concluída!"
log "Para adicionar workers, use o comando em: /home/ubuntu/join-command.txt"
