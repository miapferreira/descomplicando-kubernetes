# Dia 4 - Kubernetes Workloads

## O que são Kubernetes Workloads?

Kubernetes Workloads são recursos que definem como as aplicações devem ser executadas no cluster. Eles gerenciam o ciclo de vida dos pods e garantem que as aplicações estejam sempre disponíveis conforme especificado.

## ReplicaSet

No Kubernetes, o **ReplicaSet** é o recurso responsável por garantir que um número específico de réplicas de um pod esteja rodando a qualquer momento. O ReplicaSet monitora o estado dos pods e, se um pod falhar ou for removido, ele cria um novo pod para manter o número desejado de réplicas. Normalmente, um ReplicaSet é criado automaticamente quando criamos um Deployment.

### Exemplo de ReplicaSet

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: "200Mi"
            cpu: "500m"
```

### Comandos Úteis para ReplicaSet

```bash
# Criar ReplicaSet
kubectl apply -f nginx-replicaset.yaml

# Ver ReplicaSets
kubectl get replicasets
kubectl get rs

# Ver detalhes do ReplicaSet
kubectl describe replicaset nginx-replicaset

# Escalar ReplicaSet
kubectl scale replicaset nginx-replicaset --replicas=5

# Deletar ReplicaSet
kubectl delete replicaset nginx-replicaset
```

## DaemonSet

No Kubernetes, um **DaemonSet** garante que uma cópia de um pod específico esteja rodando em todos (ou alguns) nós do cluster. Ele é utilizado para implementar pods que precisam estar presentes em cada nó, como agentes de monitoramento, coletores de logs, ou serviços de rede. Isso assegura que pelo menos uma réplica do pod esteja rodando em cada nó especificado.

### Exemplo de DaemonSet (Node Exporter)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      containers:
        - name: node-exporter
          image: prom/node-exporter:latest
          ports:
            - containerPort: 9100
              hostPort: 9100
          volumeMounts:
            - name: proc
              mountPath: /host/proc
              readOnly: true
            - name: sys
              mountPath: /host/sys
              readOnly: true
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: sys
          hostPath:
            path: /sys
```

### Comandos Úteis para DaemonSet

```bash
# Criar DaemonSet
kubectl apply -f node-exporter-daemonset.yaml

# Ver DaemonSets
kubectl get daemonsets
kubectl get ds

# Ver detalhes do DaemonSet
kubectl describe daemonset node-exporter

# Ver pods do DaemonSet
kubectl get pods -l app=node-exporter

# Deletar DaemonSet
kubectl delete daemonset node-exporter
```

## Deployment vs ReplicaSet vs DaemonSet

### Deployment
- **Uso**: Aplicações stateless
- **Escalabilidade**: Horizontal (múltiplas réplicas)
- **Atualizações**: Rolling updates, rollbacks
- **Exemplo**: Aplicação web

### ReplicaSet
- **Uso**: Garantir número de réplicas
- **Escalabilidade**: Horizontal (múltiplas réplicas)
- **Atualizações**: Não suporta rolling updates
- **Exemplo**: Backup de Deployment

### DaemonSet
- **Uso**: Agentes em cada nó
- **Escalabilidade**: Um pod por nó
- **Atualizações**: Rolling updates
- **Exemplo**: Monitoramento, logs, proxy

## Exemplo de Deployment com Rolling Update

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
  name: nginx-deployment
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx-deployment
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 2 
      maxUnavailable: 1 
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        resources:
          limits:
            cpu: "0.5"
            memory: 256Mi
          requests:
            cpu: 0.25
            memory: 128Mi
```

## Probes - Verificação de Integridade dos Pods

Probes são modos de verificação que garantem a integridade dos pods. Eles permitem que o Kubernetes monitore o estado de saúde das aplicações e tome ações automáticas quando necessário.

### Tipos de Probes

#### 1. Liveness Probe
Usado para saber quando um pod está vivo e rodando, garante a integridade dos pods. Se o liveness probe falhar, o Kubernetes reinicia o pod automaticamente.

**Exemplo de Liveness Probe:**
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

#### 2. Readiness Probe
Verifica se o pod está ok e pronto para receber requisições externas. Se o readiness probe falhar, o pod é removido do service (não recebe tráfego), mas não é reiniciado.

**Exemplo de Readiness Probe:**
```yaml
readinessProbe:
  exec:
    command:
      - curl
      - -f
      - http://localhost:80/
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1
```

#### 3. Startup Probe
Executa um teste para saber se o pod está pronto, só é executado uma única vez e existem diversas formas de fazer esta verificação como por exemplo comando, http, porta, exec. É útil para aplicações que demoram para inicializar.

**Exemplo de Startup Probe:**
```yaml
startupProbe:
  tcpSocket:
    port: 80
  initialDelaySeconds: 10
  timeoutSeconds: 5
  failureThreshold: 1
```

### Métodos de Verificação

- **httpGet**: Faz uma requisição HTTP GET para verificar se a aplicação responde
- **tcpSocket**: Verifica se uma porta TCP está aberta e aceitando conexões
- **exec**: Executa um comando dentro do container e verifica se retorna sucesso (exit code 0)

### Parâmetros Importantes

- **initialDelaySeconds**: Tempo de espera antes da primeira verificação
- **periodSeconds**: Intervalo entre as verificações
- **timeoutSeconds**: Tempo limite para cada verificação
- **failureThreshold**: Número de falhas antes de considerar o probe como falhado
- **successThreshold**: Número de sucessos necessários para considerar o probe como bem-sucedido

### Ordem e Funcionamento dos Probes

#### Quando usar o mesmo initialDelaySeconds?

Ter o mesmo `initialDelaySeconds` para livenessProbe e readinessProbe pode ser um problema, dependendo do comportamento da aplicação:

**Problemas Potenciais:**
- **Conflito de Timing**: Se ambos os probes começarem a verificar ao mesmo tempo, você pode ter situações onde o readinessProbe ainda está falhando enquanto o livenessProbe já está tentando reiniciar o pod
- **Reinicializações Desnecessárias**: Se o livenessProbe falhar antes da aplicação estar completamente pronta, o pod será reiniciado desnecessariamente

#### Diferença Fundamental entre Liveness e Readiness

**Liveness Probe:**
- **O que faz**: Verifica se o pod está "vivo" (não travado, não em deadlock)
- **Quando executa**: **Continuamente** durante toda a vida do pod
- **Ação**: Reinicia o pod se falhar
- **Objetivo**: Detectar quando a aplicação "morreu" durante a execução

**Readiness Probe:**
- **O que faz**: Verifica se o pod está pronto para receber tráfego
- **Quando executa**: **Continuamente** durante toda a vida do pod
- **Ação**: Remove o pod do service (não recebe tráfego) se falhar
- **Objetivo**: Garantir que só pods saudáveis recebam requisições

#### Estratégias Recomendadas

**Opção 1: Readiness antes do Liveness**
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10  # Começa primeiro
  periodSeconds: 5

livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30  # Começa depois
  periodSeconds: 10
```

**Opção 2: Usar Startup Probe (Recomendado)**
```yaml
startupProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 30  # Dá tempo para a aplicação inicializar

livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 0  # Só começa após o startup probe
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 0  # Só começa após o startup probe
  periodSeconds: 5
```

#### Resumo da Lógica

- **Startup**: "A aplicação inicializou?"
- **Readiness**: "A aplicação está pronta para tráfego?"
- **Liveness**: "A aplicação ainda está viva?"

Todos trabalham em conjunto, não em sequência! O `initialDelaySeconds` é apenas o tempo de espera **antes da primeira verificação**, não a ordem de execução.

## Comandos de Monitoramento

```bash
# Ver todos os workloads
kubectl get all

# Ver pods por workload
kubectl get pods -l app=nginx
kubectl get pods -l app=node-exporter

# Ver logs de um pod específico
kubectl logs <pod-name>

# Executar comando em um pod
kubectl exec -it <pod-name> -- /bin/bash

# Ver eventos relacionados aos probes
kubectl describe pod <pod-name>
```
