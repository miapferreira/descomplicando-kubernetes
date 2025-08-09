# Validação de Comandos - Dia 1

## ✅ Comandos Validados e Testados

### Instalação

```bash
# kubectl
brew install kubectl
kubectl version --client

# autocompletar
echo 'source <(kubectl completion zsh)' >>~/.zshrc
source ~/.zshrc

# Docker
brew install --cask docker

# Kind
brew install kind
kind version
```

### Kind - Clusters

```bash
# Cluster simples
kind create cluster
kind get clusters

# Cluster com configuração
kind create cluster --name meu-cluster --config kind-cluster.yml

# Gerenciamento
kind describe cluster meu-cluster
kind delete cluster --name meu-cluster
kind delete clusters --all
kind export kubeconfig --name meu-cluster
```

### kubectl - Visualização

```bash
kubectl get pods
kubectl get pods -A
kubectl get pods -o wide
kubectl get pods -o yaml
kubectl get pods -o yaml > pod-config.yaml
```

### kubectl - Criação de Pods

```bash
# Pod simples
kubectl run nginx-pod --image=nginx --port=80

# Pod interativo (CORRIGIDO)
kubectl run alpine-pod --image=alpine --rm -it --restart=Never -- sh

# Dry-run
kubectl run test-pod --image=nginx --dry-run=client -o yaml > pod.yaml

# Aplicar/deletar
kubectl apply -f pod.yaml
kubectl delete -f pod.yaml
```

### kubectl - Monitoramento

```bash
kubectl logs nginx-pod
kubectl logs -f nginx-pod
kubectl describe pod nginx-pod
kubectl get events
```

### kubectl - Contexto

```bash
kubectl config current-context
kubectl config get-contexts
kubectl config use-context kind-meu-cluster
kubectl config view
```

## 🚨 Problemas Encontrados e Corrigidos

1. **Comando Kind com arquivo de configuração**
   - ❌ `kind create cluster --name meu-cluster kind-cluster.yml`
   - ✅ `kind create cluster --name meu-cluster --config kind-cluster.yml` (executado no diretório day-1/kind)

2. **Pod interativo**
   - ❌ `kubectl run alpine-pod --image=alpine -it --rm`
   - ✅ `kubectl run alpine-pod --image=alpine --rm -it --restart=Never -- sh`

## 📋 Checklist de Validação

- [x] Todos os comandos de instalação testados
- [x] Comandos Kind validados
- [x] Comandos kubectl básicos verificados
- [x] Sintaxe de flags corrigida
- [x] Caminhos de arquivos verificados
- [x] Comandos interativos ajustados

---

*Documentação validada e testada - SRE Senior*
