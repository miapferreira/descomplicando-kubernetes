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
```
