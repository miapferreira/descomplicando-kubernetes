# Day 7: StatefulSets e Headless Services

## Visão Geral

No Day 7, vamos aprender sobre dois conceitos importantes do Kubernetes:
- **StatefulSets**: Para aplicações que precisam de identidade única e ordem
- **Headless Services**: Para acessar pods diretamente sem balanceamento de carga

## StatefulSet

### O que é um StatefulSet?

Um **StatefulSet** é como um Deployment, mas com superpoderes especiais para aplicações que precisam de:
- **Identidade única**: Cada pod tem um nome fixo (ex: `app-0`, `app-1`, `app-2`)
- **Ordem de criação**: Os pods são criados um por vez, em ordem
- **Armazenamento persistente**: Cada pod tem seu próprio volume de dados

### Quando usar StatefulSet?

✅ **Use StatefulSet para:**
- Bancos de dados (MySQL, PostgreSQL, MongoDB)
- Sistemas de cache (Redis Cluster)
- Aplicações que precisam de ordem específica
- Quando cada pod precisa ter uma identidade única

❌ **NÃO use StatefulSet para:**
- Aplicações web simples
- APIs stateless
- Quando não precisa de ordem ou identidade única

### Exemplo Prático: StatefulSet do Nginx

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: giropops-set
spec:
  serviceName: "giropops-set" # Nome do serviço que será criado
  replicas: 3 
  selector:
    matchLabels:
      app: giropops-set
  template:
    metadata:
      labels:
        app: giropops-set
    spec:
      containers:
      - name: giropops-set
        image: nginx
        ports:
        - containerPort: 80
          name: http 
        volumeMounts:
        - name: nginx-persistent-storage
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: nginx-persistent-storage
    spec:
      accessModes: ["ReadWriteOnce"] 
      resources:
        requests:
          storage: 1Gi
```

### O que acontece quando você aplica este StatefulSet?

1. **Criação ordenada**: Os pods são criados na ordem `giropops-set-0`, `giropops-set-1`, `giropops-set-2`
2. **Volumes únicos**: Cada pod recebe seu próprio PVC (Persistent Volume Claim)
3. **Nomes fixos**: Os nomes dos pods nunca mudam, mesmo se o pod for recriado

### Comandos para testar:

```bash
# Aplicar o StatefulSet
kubectl apply -f statefulset-nginx.yaml

# Ver os pods criados
kubectl get pods

# Ver os PVCs criados automaticamente
kubectl get pvc

# Ver detalhes do StatefulSet
kubectl describe statefulset giropops-set
```

## Headless Service

### O que é um Headless Service?

Um **Headless Service** é um serviço especial que:
- **NÃO tem IP interno** (ClusterIP: None)
- **NÃO faz balanceamento de carga**
- **Permite acessar pods diretamente** pelos seus IPs individuais

### Diferença entre Service Normal vs Headless Service

| Tipo | ClusterIP | Balanceamento | Acesso |
|------|-----------|---------------|---------|
| **Service Normal** | `10.96.0.1` | ✅ Sim | Via IP do serviço |
| **Headless Service** | `None` | ❌ Não | Direto aos pods |

### Exemplo Prático: Headless Service

```yaml
apiVersion: v1 
kind: Service
metadata:
  name: giropops-service
  labels:
    app: giropops-service
spec:
  ports:
  - port: 80
    name: http
  clusterIP: None  # Isso torna o serviço "headless"
  selector:
    app: giropops-set
```

### Como funciona o Headless Service?

1. **DNS Resolution**: Quando você consulta `giropops-service`, o DNS retorna os IPs de todos os pods
2. **Acesso direto**: Você pode acessar cada pod individualmente
3. **Sem balanceamento**: Não há um IP único para balancear a carga

### Testando o Headless Service:

```bash
# Aplicar o Headless Service
kubectl apply -f nginx-headless-svc.yaml

# Ver o serviço criado
kubectl get services

# Testar DNS dentro de um pod
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup giropops-service
```

## Comparação: Deployment vs StatefulSet

### Deployment (Normal)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: michel-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: michel-deployment
  template:
    metadata:
      labels:
        app: michel-deployment
    spec:
      containers:
      - name: michel-deployment
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

**Características:**
- Pods com nomes aleatórios: `michel-deployment-abc123`
- Criação simultânea
- Sem armazenamento persistente
- Balanceamento de carga normal

### StatefulSet (Especial)
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: giropops-set
spec:
  serviceName: "giropops-set"
  replicas: 3
  # ... resto da configuração
```

**Características:**
- Pods com nomes fixos: `giropops-set-0`, `giropops-set-1`, `giropops-set-2`
- Criação ordenada (um por vez)
- Armazenamento persistente para cada pod
- Funciona melhor com Headless Service

## Tipos de Services

### 1. ClusterIP (Padrão)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
spec:
  selector:
    app: michel-deployment
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP  # Padrão - só acessível dentro do cluster
```

### 2. NodePort
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
spec:
  selector:
    app: michel-deployment
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080  # Porta exposta em todos os nodes
  type: NodePort
```

### 3. LoadBalancer
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
spec:
  selector:
    app: michel-deployment
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer  # Cria um load balancer externo
```

### 4. Headless Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: giropops-service
spec:
  ports:
  - port: 80
  clusterIP: None  # Sem IP interno
  selector:
    app: giropops-set
```

## Exemplo Completo: Banco de Dados com StatefulSet

### Cenário: MongoDB com 3 réplicas

```yaml
# 1. Headless Service para o MongoDB
apiVersion: v1
kind: Service
metadata:
  name: mongodb-headless
spec:
  ports:
  - port: 27017
  clusterIP: None
  selector:
    app: mongodb

---
# 2. StatefulSet do MongoDB
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: mongodb-headless
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:4.4
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### O que acontece:

1. **Pods criados**: `mongodb-0`, `mongodb-1`, `mongodb-2`
2. **Volumes únicos**: Cada pod tem seu próprio PVC
3. **DNS**: `mongodb-0.mongodb-headless`, `mongodb-1.mongodb-headless`, etc.
4. **Configuração**: Cada pod pode ser configurado como primário, secundário, etc.

## Comandos Úteis

```bash
# Aplicar todos os recursos
kubectl apply -f statefulset-nginx.yaml
kubectl apply -f nginx-headless-svc.yaml

# Ver StatefulSets
kubectl get statefulset

# Ver pods do StatefulSet
kubectl get pods -l app=giropops-set

# Ver serviços
kubectl get services

# Testar DNS do Headless Service
kubectl run test --image=busybox --rm -it --restart=Never -- nslookup giropops-service

# Ver logs de um pod específico
kubectl logs giropops-set-0

# Escalar StatefulSet
kubectl scale statefulset giropops-set --replicas=5

# Deletar StatefulSet (mantém os volumes)
kubectl delete statefulset giropops-set
```

## Resumo Prático

### StatefulSet
- ✅ Use para: Bancos de dados, aplicações com estado
- ✅ Características: Nomes fixos, ordem de criação, volumes únicos
- ✅ Exemplo: `mongodb-0`, `mongodb-1`, `mongodb-2`

### Headless Service
- ✅ Use para: Acessar pods diretamente
- ✅ Características: Sem IP interno, sem balanceamento
- ✅ Exemplo: `clusterIP: None`

### Quando usar juntos?
- StatefulSet + Headless Service = Perfeito para aplicações distribuídas
- Cada pod pode ser acessado diretamente pelo seu nome
- Ideal para bancos de dados, caches, sistemas de mensagens

## Dicas Importantes

1. **StatefulSets são mais lentos** que Deployments (criação ordenada)
2. **Headless Services** são essenciais para StatefulSets
3. **Volumes são mantidos** mesmo se o pod for deletado
4. **Nomes dos pods** nunca mudam em StatefulSets
5. **Escalabilidade** é mais controlada em StatefulSets
