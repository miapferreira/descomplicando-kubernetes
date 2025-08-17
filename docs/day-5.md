# Dia 5 - Cluster Kubernetes

## Cluster Kubernetes

### O que é um Cluster?

Um cluster Kubernetes é um conjunto de máquinas (nós) que trabalham juntas para executar aplicações containerizadas. É composto por:

- **Control Plane**: Gerencia o cluster e toma decisões sobre o estado desejado
- **Worker Nodes**: Executam os pods e aplicações

**Estrutura básica:**
- **Control Plane**: 1 ou mais nós master (gerenciamento)
- **Worker Nodes**: Múltiplas instâncias (execução dos pods)

### Instalação do Cluster com kubeadm

O kubeadm é a ferramenta oficial do Kubernetes para criar clusters. Suporta diferentes tipos de infraestrutura:
- Instâncias EC2 na AWS
- VMs em cloud providers
- Bare metal servers
- Máquinas virtuais locais

### Criando um Cluster na AWS EC2

#### Pré-requisitos
- **AMI**: Ubuntu 24.04 LTS
- **Instance Type**: t2.medium (mínimo recomendado)
- **Security Group**: Portas necessárias liberadas

#### Portas Necessárias no Security Group
```bash
# Control Plane
6443 - API Server
2379-2380 - etcd
10250 - Kubelet
10251 - kube-scheduler
10252 - kube-controller-manager

# Worker Nodes
10250 - Kubelet
30000-32767 - NodePort Services
```

#### 1. Carregar Módulos do Kernel

**Para que serve**: O Kubernetes precisa de módulos específicos do kernel para funcionar corretamente com containers e rede.

```bash
sudo vim /etc/modules-load.d/k8s.conf
```

**Conteúdo do arquivo:**
```
overlay
br_netfilter
```

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

**Explicação dos módulos:**
- **overlay**: Permite que containers compartilhem o sistema de arquivos do host
- **br_netfilter**: Permite que o bridge network funcione com iptables

#### 2. Configurar Parâmetros do Sistema

**Para que serve**: Garante que o tráfego de rede seja roteado corretamente entre containers e que o cluster funcione adequadamente.

```bash
sudo vim /etc/sysctl.d/k8s.conf
```

**Conteúdo do arquivo:**
```
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
```

```bash
sudo sysctl --system
```

**Explicação dos parâmetros:**
- **bridge-nf-call-iptables**: Permite que regras iptables sejam aplicadas ao tráfego bridge
- **bridge-nf-call-ip6tables**: Mesmo para IPv6
- **ip_forward**: Habilita roteamento de pacotes entre interfaces

#### 3. Instalar Pacotes do Kubernetes

**Atualizar repositórios e instalar dependências:**
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

**Adicionar chave GPG do repositório Kubernetes:**
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

**Adicionar repositório Kubernetes:**
```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

**Atualizar e instalar componentes:**
```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
```

**Impedir atualizações automáticas dos componentes:**
```bash
sudo apt-mark hold kubelet kubeadm kubectl
```

**Nota**: O repositório Kubernetes foi migrado do Google Cloud para o novo repositório oficial em `pkgs.k8s.io`. Os comandos acima usam a versão mais recente e estável do Kubernetes.

#### 4. Inicializar o Cluster (Control Plane)

**Inicializar o cluster:**
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

**Configurar kubectl para usuário não-root:**
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### 5. Instalar CNI (Container Network Interface)

```bash
# Exemplo com Flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

#### 6. Adicionar Worker Nodes

```bash
# No worker node, executar o comando gerado pelo kubeadm init
sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

### Verificação do Cluster

**Verificar status dos nós:**
```bash
kubectl get nodes
```

**Verificar componentes do control plane:**
```bash
kubectl get pods -n kube-system
```

**Verificar informações do cluster:**
```bash
kubectl cluster-info
```

### Comandos Úteis para Gerenciamento do Cluster

```bash
# Ver informações detalhadas do cluster
kubectl cluster-info dump

# Ver configuração do cluster
kubectl config view

# Ver contexto atual
kubectl config current-context

# Listar todos os contextos
kubectl config get-contexts

# Mudar contexto
kubectl config use-context <context-name>

# Ver versão do cluster
kubectl version --short

# Ver informações dos nós
kubectl describe nodes

# Ver logs dos componentes do control plane
kubectl logs -n kube-system kube-apiserver-<node-name>
kubectl logs -n kube-system kube-controller-manager-<node-name>
kubectl logs -n kube-system kube-scheduler-<node-name>
```

### Troubleshooting Comum

#### Problema: Pods ficam em estado Pending
```bash
# Verificar se há nós disponíveis
kubectl get nodes

# Verificar se o CNI está funcionando
kubectl get pods -n kube-system

# Verificar eventos
kubectl get events --sort-by='.lastTimestamp'
```

#### Problema: Worker node não se junta ao cluster
```bash
# Verificar conectividade
ping <control-plane-ip>

# Verificar se as portas estão abertas
telnet <control-plane-ip> 6443

# Verificar logs do kubelet
sudo journalctl -u kubelet -f
```

#### Problema: Token expirado para join
```bash
# Gerar novo token
sudo kubeadm token create --print-join-command
```

### Considerações de Segurança

- **RBAC**: Configurar controle de acesso baseado em roles
- **Network Policies**: Implementar políticas de rede para isolamento
- **Pod Security Standards**: Aplicar padrões de segurança para pods
- **Secrets Management**: Gerenciar secrets de forma segura
- **Audit Logging**: Habilitar logs de auditoria

### Próximos Passos

Após criar o cluster, considere:
1. Configurar um sistema de monitoramento (Prometheus/Grafana)
2. Implementar backup do etcd
3. Configurar autoscaling
4. Implementar políticas de rede
5. Configurar ingress controller
