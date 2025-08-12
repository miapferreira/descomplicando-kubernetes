# Dia 1 - Introdução ao Kubernetes com Kind

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

## Criando um Cluster

### Comando Básico

```bash
kind create cluster --name meu-cluster
```

### Usando Arquivo de Configuração

Crie um arquivo `kind-cluster.yml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
- role: worker
- role: worker
```

E execute:

```bash
kind create cluster --name meu-cluster --config kind-cluster.yml
```

## Comandos Úteis

### Listar clusters
```bash
kind get clusters
```

### Deletar cluster
```bash
kind delete cluster --name meu-cluster
```

### Acessar o cluster
```bash
kubectl cluster-info --context kind-meu-cluster
```

### Verificar nós
```bash
kubectl get nodes
```


