# Day 7: Services, StatefulSets e Headless Services

## Visão Geral

No Day 7, vamos aprender sobre três conceitos fundamentais do Kubernetes:
- **Services**: Para expor aplicações e permitir comunicação entre pods
- **StatefulSets**: Para aplicações que precisam de identidade única e ordem
- **Headless Services**: Para acessar pods diretamente sem balanceamento de carga

## Services no Kubernetes

### O que é um Service?

Um **Service** é um recurso do Kubernetes que:
- **Expõe aplicações** para serem acessadas por outros pods ou externamente
- **Fornece balanceamento de carga** entre múltiplos pods
- **Cria um ponto de entrada estável** para sua aplicação
- **Resolve problemas de conectividade** quando pods são criados/destruídos

### Por que precisamos de Services?

Sem Services, você teria problemas como:
- **IPs dinâmicos**: Pods mudam de IP quando são recriados
- **Sem balanceamento**: Não há distribuição de carga entre pods
- **Conectividade complexa**: Difícil para pods se comunicarem entre si
- **Acesso externo limitado**: Não há forma padronizada de expor aplicações

### Como funcionam Services?

1. **Selector**: O Service identifica pods através de labels
2. **Endpoints**: Cria automaticamente endpoints para cada pod selecionado
3. **Balanceamento**: Distribui o tráfego entre os pods disponíveis
4. **DNS**: Fornece resolução de nome para descoberta de serviço

## Tipos de Services

### 1. ClusterIP (Padrão)

**ClusterIP** é o tipo padrão de Service que:
- **Só é acessível dentro do cluster**
- **Tem um IP interno** (ex: 10.96.0.1)
- **Faz balanceamento de carga** entre pods
- **É usado para comunicação interna** entre aplicações

#### Exemplo Prático: ClusterIP Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-clusterip
  labels:
    app: nginx-clusterip
    env: dev
spec:
  selector:
    app: michel-deployment
  ports:
  - port: 80
    name: http
    targetPort: 80
  type: ClusterIP  # Padrão - só acessível dentro do cluster
```

**Características:**
- ✅ Acessível apenas dentro do cluster
- ✅ IP interno estável
- ✅ Balanceamento de carga automático
- ❌ Não acessível externamente

**Use quando:** Aplicações internas, APIs entre microserviços, comunicação cluster-interna

### 2. NodePort

**NodePort** expõe o Service:
- **Em uma porta específica** de todos os nodes do cluster
- **Acessível externamente** via IP de qualquer node
- **Mantém o ClusterIP** para acesso interno
- **Porta fixa** em todos os nodes (ex: 30080)

#### Exemplo Prático: NodePort Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-nodeport
  labels:
    app: nginx-nodeport
    env: dev
spec:
  selector:
    app: michel-deployment
  ports:
  - port: 80
    name: http
    targetPort: 80
    nodePort: 30080  # Porta exposta em todos os nodes
  type: NodePort
```

**Características:**
- ✅ Acessível externamente via `NODE_IP:30080`
- ✅ Mantém acesso interno via ClusterIP
- ✅ Porta fixa em todos os nodes
- ❌ Porta deve estar disponível em todos os nodes
- ❌ Não é ideal para produção (sem SSL, sem domínio)

**Use quando:** Desenvolvimento, testes, acesso externo simples

### 3. LoadBalancer

**LoadBalancer** é o tipo mais avançado que:
- **Cria um load balancer externo** (se suportado pelo cloud provider)
- **Expõe a aplicação externamente** com IP público
- **Faz fallback para NodePort** se não houver load balancer
- **Ideal para produção** com alta disponibilidade

#### Exemplo Prático: LoadBalancer Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-loadbalancer
  labels:
    app: nginx-loadbalancer
    env: dev
spec:
  selector:
    app: michel-deployment
  ports:
  - port: 80
    name: http
    targetPort: 80
  type: LoadBalancer  # Cria um load balancer externo
```

**Características:**
- ✅ IP público externo
- ✅ Load balancer gerenciado pelo cloud provider
- ✅ Alta disponibilidade e escalabilidade
- ✅ Ideal para produção
- ❌ Pode ter custo adicional
- ❌ Requer suporte do cloud provider

**Use quando:** Produção, aplicações públicas, alta disponibilidade

#### 🚀 Exemplo Prático com EKS da AWS

Para testar o LoadBalancer Service na AWS, você pode criar um cluster EKS temporário:

**1. Criar cluster EKS (temporário para teste):**
```bash
eksctl create cluster \
  --name=eks-test-cluster \
  --version=1.24 \
  --region=us-east-1 \
  --nodegroup-name=eks-test-nodegroup \
  --node-type=t3.medium \
  --nodes=2 \
  --nodes-min=1 \
  --nodes-max=3 \
  --managed
```

**2. Configurar kubectl para o cluster:**
```bash
aws eks --region us-east-1 update-kubeconfig --name eks-test-cluster
```

**3. Aplicar o LoadBalancer Service:**
```bash
kubectl apply -f day-7/live/nginx-deployment.yaml
kubectl apply -f day-7/live/nginx-loadbalancer.yaml
```

**4. Verificar o LoadBalancer criado:**
```bash
kubectl get service nginx-loadbalancer
# Aguarde o EXTERNAL-IP ser atribuído
```

**5. Testar o acesso externo:**
```bash
# Substitua EXTERNAL_IP pelo IP retornado pelo comando anterior
curl http://EXTERNAL_IP
```

**⚠️ IMPORTANTE: Deletar o cluster após o teste para evitar custos!**
```bash
eksctl delete cluster --name=eks-test-cluster --region=us-east-1
```

**💡 Dica:** O cluster EKS pode levar 15-20 minutos para ser criado e deletado. Use apenas para testes e sempre delete após o uso!

### 4. Headless Service

**Headless Service** é especial porque:
- **NÃO tem IP interno** (`clusterIP: None`)
- **NÃO faz balanceamento de carga**
- **Permite acessar pods diretamente** pelos seus IPs individuais
- **Ideal para StatefulSets** e aplicações distribuídas

#### Exemplo Prático: Headless Service

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

**Características:**
- ✅ Acesso direto aos pods
- ✅ Sem balanceamento de carga
- ✅ Ideal para StatefulSets
- ✅ DNS retorna IPs de todos os pods
- ❌ Não tem IP único para balanceamento
- ❌ Cada pod deve ser acessado individualmente

**Use quando:** StatefulSets, bancos de dados, aplicações que precisam de acesso direto aos pods

## Comparação dos Tipos de Services

| Tipo | Acesso Interno | Acesso Externo | Balanceamento | IP Público | Use Case |
|------|----------------|----------------|---------------|------------|----------|
| **ClusterIP** | ✅ Sim | ❌ Não | ✅ Sim | ❌ Não | Comunicação interna |
| **NodePort** | ✅ Sim | ✅ Via Node IP | ✅ Sim | ❌ Não | Desenvolvimento/Teste |
| **LoadBalancer** | ✅ Sim | ✅ Sim | ✅ Sim | ✅ Sim | Produção |
| **Headless** | ✅ Direto aos pods | ❌ Não | ❌ Não | ❌ Não | StatefulSets |

## Como testar os diferentes tipos de Services

### 1. Preparar o ambiente

Antes de testar os Services, você precisa ter o deployment base rodando:

```bash
# Aplicar o deployment base primeiro
kubectl apply -f day-7/live/nginx-deployment.yaml

# Verificar se os pods estão rodando
kubectl get pods -l app=michel-deployment
```

### 2. Aplicar os Services

```bash
# Aplicar todos os tipos de Services
kubectl apply -f day-7/live/nginx-clusterip.yaml
kubectl apply -f day-7/live/nginx-nodeport.yaml
kubectl apply -f day-7/live/nginx-loadbalancer.yaml
```

### 3. Verificar os Services criados

```bash
# Ver todos os Services
kubectl get services

# Ver detalhes de um Service específico
kubectl describe service nginx-clusterip
kubectl describe service nginx-nodeport
kubectl describe service nginx-loadbalancer
```

### 4. Testar conectividade

```bash
# Testar ClusterIP (dentro do cluster)
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- nginx-clusterip:80

# Testar NodePort (externamente)
# Substitua NODE_IP pelo IP de um dos seus nodes
curl http://NODE_IP:30080

# Testar LoadBalancer (se disponível)
# Aguarde o IP externo ser atribuído
kubectl get service nginx-loadbalancer
curl http://EXTERNAL_IP

# ⚠️ IMPORTANTE: Para testes com EKS, sempre delete o cluster após o uso!
# eksctl delete cluster --name=eks-test-cluster --region=us-east-1

# Testar Headless Service
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup giropops-service
```

### 5. Verificar endpoints

```bash
# Ver os endpoints de cada Service
kubectl get endpoints nginx-clusterip
kubectl get endpoints nginx-nodeport
kubectl get endpoints nginx-loadbalancer

# Ver detalhes dos endpoints
kubectl describe endpoints nginx-clusterip
```

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
kubectl apply -f day-7/live/statefulset-nginx.yaml
kubectl apply -f day-7/live/nginx-headless-svc.yaml

# Aplicar todos os tipos de Services
kubectl apply -f day-7/live/nginx-clusterip.yaml
kubectl apply -f day-7/live/nginx-nodeport.yaml
kubectl apply -f day-7/live/nginx-loadbalancer.yaml

# Ver StatefulSets
kubectl get statefulset

# Ver pods do StatefulSet
kubectl get pods -l app=giropops-set

# Ver todos os Services
kubectl get services

# Ver detalhes de um Service específico
kubectl describe service nginx-clusterip
kubectl describe service nginx-nodeport
kubectl describe service nginx-loadbalancer

# Testar DNS do Headless Service
kubectl run test --image=busybox --rm -it --restart=Never -- nslookup giropops-service

# Testar conectividade dos Services
kubectl run test-pod --image=busybox --rm -it --restart=Never -- wget -O- nginx-clusterip:80

# Ver logs de um pod específico
kubectl logs giropops-set-0

# Escalar StatefulSet
kubectl scale statefulset giropops-set --replicas=5

# Deletar StatefulSet (mantém os volumes)
kubectl delete statefulset giropops-set

# Deletar Services
kubectl delete service nginx-clusterip nginx-nodeport nginx-loadbalancer

# 🚀 Comandos específicos para EKS (LoadBalancer)
# Criar cluster de teste
eksctl create cluster --name=eks-test-cluster --version=1.24 --region=us-east-1 --nodegroup-name=eks-test-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed

# Configurar kubectl para o cluster
aws eks --region us-east-1 update-kubeconfig --name eks-test-cluster

# Deletar cluster após teste (IMPORTANTE para evitar custos!)
eksctl delete cluster --name=eks-test-cluster --region=us-east-1
```

## Resumo Prático

### Services - Tipos e Usos

#### ClusterIP
- ✅ Use para: Comunicação interna, APIs entre microserviços
- ✅ Características: IP interno estável, balanceamento automático
- ✅ Exemplo: `type: ClusterIP` (padrão)

#### NodePort
- ✅ Use para: Desenvolvimento, testes, acesso externo simples
- ✅ Características: Porta fixa em todos os nodes, mantém ClusterIP
- ✅ Exemplo: `type: NodePort, nodePort: 30080`

#### LoadBalancer
- ✅ Use para: Produção, aplicações públicas, alta disponibilidade
- ✅ Características: IP público, load balancer externo
- ✅ Exemplo: `type: LoadBalancer`
- ⚠️ **EKS/AWS:** Sempre delete clusters de teste para evitar custos

#### Headless Service
- ✅ Use para: StatefulSets, acesso direto aos pods
- ✅ Características: Sem IP interno, sem balanceamento
- ✅ Exemplo: `clusterIP: None`

### StatefulSet
- ✅ Use para: Bancos de dados, aplicações com estado
- ✅ Características: Nomes fixos, ordem de criação, volumes únicos
- ✅ Exemplo: `mongodb-0`, `mongodb-1`, `mongodb-2`

### Quando usar juntos?
- **StatefulSet + Headless Service** = Perfeito para aplicações distribuídas
- **Deployment + ClusterIP** = Para APIs e aplicações internas
- **Deployment + NodePort** = Para desenvolvimento e testes
- **Deployment + LoadBalancer** = Para produção e aplicações públicas

## Dicas Importantes

### Services
1. **ClusterIP é o padrão** - não precisa especificar `type: ClusterIP`
2. **NodePort** expõe em todos os nodes, mas porta deve estar disponível
3. **LoadBalancer** requer suporte do cloud provider
4. **Headless Services** são ideais para StatefulSets
5. **Services usam labels** para selecionar pods automaticamente

### StatefulSets
1. **StatefulSets são mais lentos** que Deployments (criação ordenada)
2. **Headless Services** são essenciais para StatefulSets
3. **Volumes são mantidos** mesmo se o pod for deletado
4. **Nomes dos pods** nunca mudam em StatefulSets
5. **Escalabilidade** é mais controlada em StatefulSets

### Boas Práticas
1. **Use ClusterIP** para comunicação interna entre pods
2. **Use NodePort** apenas para desenvolvimento e testes
3. **Use LoadBalancer** para produção com alta disponibilidade
4. **Combine StatefulSets** com Headless Services para aplicações distribuídas
5. **Monitore endpoints** dos Services para verificar conectividade

### ⚠️ Cuidados com Custos (EKS/AWS)
1. **Sempre delete clusters de teste** para evitar cobranças inesperadas
2. **Use instâncias t3.medium** para testes (mais baratas)
3. **Monitore o tempo de uso** - clusters EKS têm custo por hora
4. **Configure alertas de billing** na sua conta AWS
5. **Use tags para identificar** recursos de teste vs produção
