# Dia 3 - Deployments

## O que é um Deployment?

O deployment é responsável por armazenar todas as informações e parâmetros da aplicação, além de gerenciar os pods associados a ela. Por meio do deployment, é possível realizar operações como atualização, reinicialização, escalonamento e modificação de qualquer parâmetro relacionado à nossa aplicação.

## Criação de Deployment

O deployment é criado através de um arquivo YAML. Aqui está um exemplo prático:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-deployment
    fruit: banana   
  name: nginx-deployment
  namespace: giropops
spec:
  replicas: 10   
  revisionHistoryLimit: 10   
  selector:
    matchLabels:
      app: nginx-deployment
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
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
            cpu: 600m
            memory: 250Mi
          requests:
            cpu: 150m
            memory: 100Mi
        ports:
        - containerPort: 80
```

## Componentes do Deployment

### Selector

O `selector` define como o deployment identifica quais pods ele deve gerenciar. Ele usa labels para fazer essa seleção:

```yaml
selector:
  matchLabels:
    app: nginx-deployment
```

- **matchLabels**: Define os labels que devem corresponder exatamente
- **matchExpressions**: Permite expressões mais complexas para seleção

### Template

O `template` define como os pods devem ser criados. Ele contém:

```yaml
template:
  metadata:
    labels:
      app: nginx-deployment  # Deve corresponder ao selector
  spec:
    containers:
    - name: nginx
      image: nginx:latest
```

**Importante**: Os labels no template devem corresponder aos labels definidos no selector.

## Namespaces

Namespaces são uma forma de organizar e isolar recursos no Kubernetes. Eles permitem:

- **Organização**: Agrupar recursos relacionados
- **Isolamento**: Separar ambientes (dev, staging, prod)
- **Controle de acesso**: Definir permissões por namespace

### Exemplo de Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: giropops
spec: {}
status: {}
```

### Aplicando recursos em um namespace

```bash
# Aplicar namespace primeiro
kubectl apply -f namespace.yaml

# Aplicar deployment no namespace
kubectl apply -f deployment.yaml
```

## Estratégias de Atualização

### RollingUpdate (Padrão)

É a estratégia padrão do deployment no Kubernetes:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 0        # Pods extras permitidos
    maxUnavailable: 1  # Pods indisponíveis durante update
```

### Recreate

Mata todos os pods de uma vez e sobe a nova versão:

```yaml
strategy:
  type: Recreate
```

**⚠️ Cuidado**: Causa indisponibilidade temporária da aplicação.

## Comandos Úteis

### Verificar deployments
```bash
kubectl get deployments
kubectl get deployments -n giropops -o wide
```

### Aplicar deployment
```bash
kubectl apply -f deployment.yaml
```

### Descrever deployment
```bash
kubectl describe deployment nginx-deployment -n giropops
```

### Rollback

O rollback permite desfazer mudanças em um deployment, voltando para uma versão anterior que estava funcionando corretamente.

#### Ver Histórico de Revisões

```bash
# Ver todas as revisões do deployment
kubectl rollout history deployment nginx-deployment -n giropops
```

**Exemplo de saída:**
```
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment/nginx-deployment nginx=nginx:1.19.1
3         kubectl set image deployment/nginx-deployment nginx=nginx:latest
```

#### Ver Detalhes de uma Revisão Específica

```bash
# Ver detalhes da revisão 2
kubectl rollout history deployment nginx-deployment -n giropops --revision 2
```

**Exemplo de saída:**
```
deployment.apps/nginx-deployment with revision #2
Pod Template:
  Labels:	app=nginx-deployment
  Containers:
   nginx:
    Image:	nginx:1.19.1
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
```

#### Fazer Rollback

```bash
# Desfazer para a revisão anterior
kubectl rollout undo deployment nginx-deployment -n giropops

# Desfazer para uma revisão específica
kubectl rollout undo deployment nginx-deployment -n giropops --to-revision=2
```

#### Monitorar Status do Rollback

```bash
# Verificar status do rollback
kubectl rollout status deployment nginx-deployment -n giropops
```

#### Configurar Histórico de Revisões

No deployment, você pode configurar quantas revisões manter:

```yaml
spec:
  revisionHistoryLimit: 10  # Mantém as últimas 10 revisões
```

### Reiniciar deployment
```bash
kubectl rollout restart deployment nginx-deployment -n giropops
```

### Escalar deployment
```bash
kubectl scale deployment nginx-deployment -n giropops --replicas 11
```

### Status do rollout
```bash
kubectl rollout status deployment nginx-deployment -n giropops
```
