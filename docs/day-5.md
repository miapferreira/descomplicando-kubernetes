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

#### 3. Instalar Container Runtime (containerd)

**O que é o containerd?**
O containerd é um **container runtime** que permite executar containers de forma isolada e segura. É o componente responsável por:
- **Gerenciar o ciclo de vida dos containers** (criar, iniciar, parar, remover)
- **Baixar e armazenar imagens** de containers
- **Fornecer isolamento** entre containers e o sistema host
- **Ser a interface** entre o Kubernetes e os containers

O Kubernetes precisa de um container runtime para executar os pods. O containerd é a escolha recomendada por ser:
- **Leve e eficiente** - Menos overhead que o Docker
- **Estável e maduro** - Desenvolvido pela CNCF
- **Padrão da indústria** - Usado por grandes provedores de cloud

**Atualizar repositórios e instalar dependências:**
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
```

**Copiar a chave do repositório do Docker:**
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

**Adicionar repositório do Docker:**
```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

**Explicação do comando acima:**
- `[arch=amd64]`: Especifica a arquitetura (AMD64)
- `signed-by=/usr/share/keyrings/docker-archive-keyring.gpg`: Usa a chave GPG que baixamos
- `$(lsb_release -cs)`: Detecta automaticamente a versão do Ubuntu (ex: noble, jammy)
- `stable`: Canal estável do Docker

**Atualizar e instalar containerd:**
```bash
sudo apt-get update
sudo apt-get install containerd.io
```

**Configurar o containerd:**
```bash
# Gerar configuração padrão
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Habilitar SystemdCgroup (necessário para Kubernetes)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Reiniciar o serviço
sudo systemctl restart containerd

# Habilitar para iniciar automaticamente
sudo systemctl enable containerd

# Verificar status
sudo systemctl status containerd
```

#### 4. Instalar Pacotes do Kubernetes

**Atualizar repositórios e instalar dependências:**
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

**Adicionar chave GPG do repositório Kubernetes:**
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo apt-key add -
```

**Adicionar repositório Kubernetes:**
```bash
echo 'deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
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

**Habilitar o serviço do kubelet:**
```bash
# Habilitar para iniciar automaticamente com o sistema
sudo systemctl enable --now kubelet

# Verificar status
sudo systemctl status kubelet
```

**Nota**: O repositório Kubernetes foi migrado do Google Cloud para o novo repositório oficial em `pkgs.k8s.io`. Os comandos acima usam a versão mais recente e estável do Kubernetes.

**Nota**: Este método usa `apt-key` que é o mais compatível com Ubuntu 24.04 e versões anteriores.

#### 5. Inicializar o Cluster (Control Plane)

**Inicializar o cluster:**
```bash
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=IP_DA_MAQUINA
```

**Explicação dos parâmetros:**
- `--pod-network-cidr=10.10.0.0/16`: Define a rede para os pods (deve ser diferente da rede do host)
- `--apiserver-advertise-address=IP_DA_MAQUINA`: IP que será usado pelos worker nodes para se conectar

**Após a inicialização, você verá uma mensagem como esta:**
```
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

sudo kubeadm join 172.31.91.34:6443 --token 3vrkwi.kve7m3y3c8zawxvq \
	--discovery-token-ca-cert-hash sha256:84378d3208d3bed7f3bd1be723fa4592679e9e9443f8a8a03c9f05726464dcfd
```

**Configurar kubectl para usuário não-root:**
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**Verificar status do cluster:**
```bash
kubectl get nodes
```

**Exemplo de saída:**
```
NAME              STATUS     ROLES           AGE    VERSION
ip-172-31-91-34   NotReady   control-plane   2m1s   v1.28.15
```

**Nota**: O status `NotReady` é normal neste momento, pois ainda não instalamos o plugin de rede.

#### 6. Instalar CNI (Container Network Interface)

**O que é CNI?**
CNI (Container Network Interface) é um plugin de rede que permite que os pods se comuniquem entre si e com serviços externos. Sem um CNI, os pods ficam isolados e não conseguem se comunicar.

**Por que precisamos de um CNI?**
- **Comunicação entre pods** - Permite que pods em nós diferentes se comuniquem
- **Load balancing** - Distribui tráfego entre pods
- **Network policies** - Controla acesso à rede
- **Status Ready** - Faz com que os nós fiquem prontos para receber pods

**Instalar Weave Net (CNI recomendado):**
```bash
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

**Documentação oficial do Weave Net:**
- [Weave Net Documentation](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)
- [Kubernetes Network Add-ons](https://kubernetes.io/docs/concepts/cluster-administration/addons/)

**Verificar se o CNI foi instalado:**
```bash
kubectl get pods -n kube-system
```

**Aguardar os pods do Weave ficarem prontos e verificar status dos nós:**
```bash
kubectl get nodes
```

**Exemplo de saída após instalação do CNI:**
```
NAME              STATUS   ROLES           AGE   VERSION
ip-172-31-91-34   Ready    control-plane   5m    v1.28.15
```

#### 7. Adicionar Worker Nodes

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
