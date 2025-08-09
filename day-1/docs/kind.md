# Kind (Kubernetes in Docker) - Criando Clusters Locais

## O que é o Kind?

O **Kind** (Kubernetes in Docker) é uma ferramenta que permite criar clusters Kubernetes locais usando containers Docker. É ideal para desenvolvimento, testes e aprendizado, pois simula um ambiente Kubernetes real sem a necessidade de recursos computacionais pesados.

## Pré-requisitos

Antes de começar, você precisa ter instalado:

1. **Docker** - Container engine
2. **kubectl** - CLI do Kubernetes
3. **Kind** - Ferramenta para criar clusters

## Instalação

### 1. Instalando o kubectl

**macOS (usando Homebrew):**

```bash
brew install kubectl
```

**Verificar a instalação:**

```bash
kubectl version --client
```

### 2. Configurando autocompletar do kubectl

**Para zsh (macOS):**

```bash
echo 'source <(kubectl completion zsh)' >>~/.zshrc
source ~/.zshrc
```

**Para bash:**

```bash
echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc
```

### 3. Instalando o Docker

**Linux (Ubuntu/Debian):**

```bash
curl -fsSL https://get.docker.com/ | sh
```

**macOS - Docker Desktop:**

```bash
brew install --cask docker
```

> **Nota**: Ou baixar do site oficial: https://www.docker.com/products/docker-desktop

**macOS - Colima (Alternativa ao Docker Desktop):**

```bash
brew install colima
```

**⚠️ IMPORTANTE**: Após a instalação, você precisa iniciar o Docker. O Kind depende do Docker para funcionar.

**Iniciar o Docker Desktop (macOS):**

```bash
open -a Docker
```

**Iniciar o Colima (macOS):**

```bash
colima start
```

**Verificar se o Docker está rodando:**

```bash
docker ps
```

### 4. Instalando o Kind

**macOS (usando Homebrew):**

```bash
brew install kind
```

**Verificar a instalação:**

```bash
kind version
```

## Criando Clusters

### Cluster Simples (1 nó)

**Criar um cluster básico:**

```bash
kind create cluster
```

**Verificar o cluster criado:**

```bash
kind get clusters
```

### Cluster com Múltiplos Nós

**Criar cluster com 3 nós (1 control-plane + 2 workers):**

```bash
kind create cluster --name meu-cluster --config kind-cluster.yml
```

### Arquivo de Configuração (kind-cluster.yml)

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
- role: worker
- role: worker
```

## Comandos Úteis do Kind

**Listar clusters:**

```bash
kind get clusters
```

**Ver detalhes de um cluster específico:**

```bash
kind describe cluster meu-cluster
```

**Deletar um cluster:**

```bash
kind delete cluster --name meu-cluster
```

**Deletar todos os clusters:**

```bash
kind delete clusters --all
```

**Exportar configuração do cluster:**

```bash
kind export kubeconfig --name meu-cluster
```

## Comandos Úteis do kubectl

### Visualizando Recursos

**Listar pods no namespace atual:**

```bash
kubectl get pods
```

**Listar pods em todos os namespaces:**

```bash
kubectl get pods -A
```

**Informações detalhadas dos pods:**

```bash
kubectl get pods -o wide
```

**Ver configuração YAML de um pod:**

```bash
kubectl get pods -o yaml
```

**Salvar configuração em arquivo:**

```bash
kubectl get pods -o yaml > pod-config.yaml
```

### Criando e Gerenciando Pods

**Criar um pod simples com nginx:**

```bash
kubectl run nginx-pod --image=nginx --port=80
```

**Criar pod interativo:**

```bash
kubectl run alpine-pod --image=alpine --rm -it --restart=Never -- sh
```

**Modo dry-run (simular criação):**

```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml > pod.yaml
```

**Aplicar configuração de arquivo:**

```bash
kubectl apply -f pod.yaml
```

**Deletar pod usando arquivo:**

```bash
kubectl delete -f pod.yaml
```

### Monitoramento e Logs

**Ver logs de um pod:**

```bash
kubectl logs nginx-pod
```

**Ver logs com follow (tempo real):**

```bash
kubectl logs -f nginx-pod
```

**Descrever detalhes de um pod:**

```bash
kubectl describe pod nginx-pod
```

**Ver eventos do cluster:**

```bash
kubectl get events
```

### Contexto e Configuração

**Ver contexto atual:**

```bash
kubectl config current-context
```

**Listar todos os contextos:**

```bash
kubectl config get-contexts
```

**Mudar contexto:**

```bash
kubectl config use-context kind-meu-cluster
```

**Ver configuração do cluster:**

```bash
kubectl config view
```

## Dicas Importantes

1. **Namespaces**: Por padrão, os recursos são criados no namespace `default`
2. **Portas**: Use `extraPortMappings` no Kind para expor portas do host
3. **Persistência**: Dados em volumes são perdidos quando o cluster é deletado
4. **Performance**: Clusters Kind são mais lentos que clusters nativos, mas ideais para desenvolvimento

## 📖 Documentação Oficial

Para consultas mais detalhadas e configurações avançadas, consulte a documentação oficial do Kind:

- **Site Oficial**: [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)
- **GitHub**: [https://github.com/kubernetes-sigs/kind](https://github.com/kubernetes-sigs/kind)
- **Quick Start**: [https://kind.sigs.k8s.io/docs/user/quick-start/](https://kind.sigs.k8s.io/docs/user/quick-start/)

---

*Documentação criada durante o curso "Descomplicando Kubernetes" - Dia 1*

