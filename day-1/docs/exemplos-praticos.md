# Exemplos Práticos - Dia 1

## 🎯 Exercícios Práticos

### Exercício 1: Criando seu Primeiro Cluster

```bash
# 1. Criar um cluster simples
kind create cluster --name exercicio-1

# 2. Verificar se está funcionando
kubectl cluster-info

# 3. Listar os nós
kubectl get nodes

# 4. Verificar namespaces
kubectl get namespaces
```

### Exercício 2: Trabalhando com Pods

```bash
# 1. Criar um pod simples
kubectl run meu-nginx --image=nginx --port=80

# 2. Verificar o status do pod
kubectl get pods

# 3. Ver detalhes do pod
kubectl describe pod meu-nginx

# 4. Ver logs do pod
kubectl logs meu-nginx

# 5. Acessar o pod interativamente
kubectl exec -it meu-nginx -- /bin/bash
```

### Exercício 3: Usando Arquivos YAML

```bash
# 1. Gerar YAML de um pod
kubectl run test-pod --image=alpine --dry-run=client -o yaml > meu-pod.yaml

# 2. Editar o arquivo gerado
# Adicionar labels e outras configurações

# 3. Aplicar o arquivo
kubectl apply -f meu-pod.yaml

# 4. Verificar se foi criado
kubectl get pods -l app=test
```

## 🔧 Comandos Úteis para Debug

### Verificando o Cluster

```bash
# Status geral do cluster
kubectl get componentstatuses

# Versão do cluster
kubectl version

# Informações do cluster
kubectl cluster-info dump

# Ver todos os recursos
kubectl get all
```

### Debugando Pods

```bash
# Ver eventos do namespace
kubectl get events --sort-by='.lastTimestamp'

# Ver logs de múltiplos pods
kubectl logs -l app=nginx

# Executar comando em pod
kubectl exec meu-pod -- ls -la

# Copiar arquivo para/do pod
kubectl cp meu-pod:/etc/nginx/nginx.conf ./nginx.conf
```

## 📋 Checklist de Verificação

### ✅ Instalação
- [ ] Docker instalado e funcionando
- [ ] kubectl instalado
- [ ] Kind instalado
- [ ] Autocompletar configurado

### ✅ Cluster
- [ ] Cluster criado com sucesso
- [ ] Nós funcionando
- [ ] kubectl conectado ao cluster
- [ ] Namespace default acessível

### ✅ Pods
- [ ] Pod criado com sucesso
- [ ] Pod em estado Running
- [ ] Logs acessíveis
- [ ] Pod pode ser deletado

## 🚨 Troubleshooting Comum

### Problema: Pod em estado Pending
```bash
# Verificar eventos
kubectl describe pod <nome-do-pod>

# Verificar recursos disponíveis
kubectl describe nodes

# Verificar se há problemas de imagem
kubectl get events | grep Failed
```

### Problema: Pod em estado CrashLoopBackOff
```bash
# Ver logs do pod
kubectl logs <nome-do-pod>

# Ver logs de reinicializações anteriores
kubectl logs <nome-do-pod> --previous

# Verificar configuração do pod
kubectl describe pod <nome-do-pod>
```

### Problema: Não consegue conectar ao cluster
```bash
# Verificar se o cluster existe
kind get clusters

# Verificar contexto do kubectl
kubectl config current-context

# Recarregar configuração do cluster
kind export kubeconfig --name <nome-do-cluster>
```

## 🎓 Conceitos para Revisar

1. **Pod**: Menor unidade executável no Kubernetes
2. **Container**: Processo isolado rodando dentro do pod
3. **Image**: Template para criar containers
4. **Namespace**: Isolamento lógico de recursos
5. **Labels**: Metadados para organizar recursos
6. **kubectl**: CLI para interagir com o cluster

---

*Exercícios práticos para consolidar o aprendizado do Dia 1*
