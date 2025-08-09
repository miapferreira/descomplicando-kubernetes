# Dia 1: Introdução ao Kubernetes com Kind

## 🎯 Objetivos do Dia

- Entender o que é o Kind e como ele funciona
- Instalar e configurar um ambiente local de Kubernetes
- Aprender comandos básicos do kubectl
- Criar e gerenciar pods simples

## 📚 Conteúdo

### 1. [Kind - Kubernetes in Docker](./docs/kind.md)
- Instalação e configuração do Kind
- Criação de clusters locais
- Comandos essenciais do kubectl
- Dicas e boas práticas

### 2. Arquivos de Configuração
- [`kind/kind-cluster.yml`](./kind/kind-cluster.yml) - Configuração do cluster com 3 nós
- [`pod.yaml`](./pod.yaml) - Exemplo de pod simples

## 🚀 Hands-on

### Criando seu Primeiro Cluster

```bash
# 1. Criar cluster usando arquivo de configuração
kind create cluster --name meu-cluster --config kind/kind-cluster.yml

# 2. Verificar se o cluster foi criado
kind get clusters

# 3. Verificar os nós
kubectl get nodes

# 4. Criar um pod de teste
kubectl apply -f pod.yaml

# 5. Verificar o pod
kubectl get pods
```

### Comandos Importantes Aprendidos

```bash
# Kind
kind create cluster
kind get clusters
kind delete cluster --name meu-cluster

# kubectl básico
kubectl get pods
kubectl describe pod <nome-do-pod>
kubectl logs <nome-do-pod>
kubectl apply -f <arquivo.yaml>
kubectl delete -f <arquivo.yaml>
```

## 📝 Anotações Importantes

### Conceitos Chave
- **Kind**: Ferramenta para criar clusters Kubernetes locais usando Docker
- **Pod**: Menor unidade executável no Kubernetes
- **kubectl**: CLI oficial do Kubernetes para interagir com clusters
- **Namespace**: Isolamento lógico de recursos (default é o namespace padrão)

### Dicas do SRE
1. Sempre use `--dry-run=client -o yaml` para gerar arquivos YAML
2. Configure autocompletar do kubectl para produtividade
3. Use `kubectl describe` para debugar problemas
4. Mantenha clusters Kind organizados com nomes descritivos

## 📖 Recursos Adicionais

- [Documentação oficial do Kind](https://kind.sigs.k8s.io/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)

---

*Documentação criada durante o curso "Descomplicando Kubernetes"*
