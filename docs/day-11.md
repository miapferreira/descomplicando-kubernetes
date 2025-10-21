# Day 11 - HPA (Horizontal Pod Autoscaler): Escalabilidade Automática no Kubernetes

## O que é HPA?

O **Horizontal Pod Autoscaler (HPA)** é um recurso do Kubernetes que **automaticamente escala** o número de pods baseado em métricas de utilização de recursos. Ele é responsável por:

- **Monitorar métricas** de CPU, memória e métricas customizadas
- **Escalar horizontalmente** (mais pods) quando a carga aumenta
- **Fazer scale down** quando a carga diminui
- **Manter performance** otimizada automaticamente
- **Reduzir custos** ao usar apenas recursos necessários

### 🎯 **Analogia simples:**
Imagine o HPA como um **"gerente inteligente"** de uma loja:
- **Monitora** quantas pessoas estão na loja (métricas)
- **Contrata mais funcionários** quando está lotada (scale up)
- **Reduz funcionários** quando está vazia (scale down)
- **Mantém sempre** um número mínimo de funcionários (minReplicas)

## Como funciona o HPA?

### **1. Coleta de Métricas**
O HPA coleta métricas através do **Metrics Server**:
- **CPU utilization** dos pods
- **Memory utilization** dos pods
- **Custom metrics** (opcional)

### **2. Cálculo de Replicas**
Baseado nas métricas coletadas, o HPA calcula quantos pods são necessários:
```
Replicas desejadas = ceil[Replicas atuais × (Métrica atual / Métrica target)]
```

### **3. Aplicação do Scaling**
- **Scale Up**: Cria novos pods quando métricas > target
- **Scale Down**: Remove pods quando métricas < target
- **Respeita limites**: minReplicas e maxReplicas

## HPA vs Manual Scaling: Qual a diferença?

| Aspecto | HPA | Manual Scaling |
|---------|-----|----------------|
| **Automação** | ✅ Automático | ❌ Manual |
| **Tempo de resposta** | ⚡ Segundos | 🐌 Minutos |
| **Monitoramento** | 📊 Contínuo | 👁️ Esporádico |
| **Otimização de custos** | 💰 Automática | 💸 Manual |
| **Disponibilidade** | 🟢 Alta | 🟡 Média |

## Configuração do HPA

### **Versões da API:**
- **autoscaling/v1**: Apenas CPU (mais simples)
- **autoscaling/v2**: CPU, memória e métricas customizadas (mais flexível)

### **Parâmetros principais:**
- **minReplicas**: Número mínimo de pods
- **maxReplicas**: Número máximo de pods
- **targetCPUUtilizationPercentage**: Target de CPU (%)
- **scaleTargetRef**: Referência ao deployment/statefulset

## Instalação do Metrics Server

O **Metrics Server** é essencial para o HPA funcionar. Ele coleta métricas de recursos dos pods e nodes.

### **1. Instalação no Kind/Minikube:**

```bash
# Para Kind
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Para Minikube
minikube addons enable metrics-server
```

### **2. Instalação manual (se necessário):**

```bash
# Baixar o manifest
curl -LO https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Aplicar
kubectl apply -f components.yaml
```

### **3. Verificar instalação:**

```bash
# Verificar se está rodando
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Testar métricas
kubectl top nodes
kubectl top pods
```

### **4. Troubleshooting comum:**

Se `kubectl top` não funcionar:

```bash
# Verificar logs do metrics-server
kubectl logs -n kube-system -l k8s-app=metrics-server

# Para Kind, pode ser necessário adicionar flags
kubectl patch deployment metrics-server -n kube-system --type='merge' -p='{"spec":{"template":{"spec":{"containers":[{"name":"metrics-server","args":["--cert-dir=/tmp","--secure-port=4443","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-use-node-status-port","--metric-resolution=15s"]}]}}}}'
```

## Locust: Ferramenta de Teste de Carga

O **Locust** é uma ferramenta de teste de carga moderna e fácil de usar, escrita em Python. É perfeita para testar HPA porque:

- **Simula usuários reais** com comportamento realista
- **Interface web** intuitiva para configuração
- **Gráficos em tempo real** de performance
- **Escalável** para grandes volumes de teste
- **Scriptável** em Python

### **Documentação oficial:**
📖 **[Locust Official Documentation](https://docs.locust.io/)**

### **Características principais:**
- **User-friendly**: Interface web simples
- **Distributed**: Suporte a múltiplos workers
- **Flexible**: Scripts em Python
- **Real-time**: Estatísticas em tempo real
- **Lightweight**: Baixo consumo de recursos

## Exemplo Prático: HPA + Locust

### **1. Estrutura de arquivos:**

```
day-11/
├── deployment.yaml          # Aplicação nginx
├── nginx-service.yaml       # Service da aplicação
├── primeiro-hpa.yaml        # Configuração do HPA
├── locust-configmap.yaml    # Script do Locust
├── locust-deployment.yaml   # Deployment do Locust
├── locust-service.yaml      # Service do Locust
└── teste-hpa.sh            # Script de teste automatizado
```

### **2. Aplicação de exemplo (deployment.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: "0.02"      # 20 milicores
            memory: 32Mi     # 32 megabytes
          requests:
            cpu: "0.01"      # 10 milicores
            memory: 16Mi     # 16 megabytes
```

### **3. Service da aplicação (nginx-service.yaml):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  selector:
    app: nginx
```

### **4. Configuração do HPA (primeiro-hpa.yaml):**

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 3        # Mínimo de 3 pods
  maxReplicas: 10       # Máximo de 10 pods
  targetCPUUtilizationPercentage: 50  # Target de 50% CPU
```

### **5. Script do Locust (locust-configmap.yaml):**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: locust-config
  labels:
    app: locust
data:
  locustfile.py: |
    from locust import HttpUser, task, between
    import random

    class WebsiteUser(HttpUser):
        wait_time = between(1, 3)  # Aguarda entre 1 e 3 segundos
        
        @task(3)
        def visit_homepage(self):
            """Task com peso 3 - mais frequente"""
            self.client.get("/")
        
        @task(2)
        def visit_heavy_page(self):
            """Task com peso 2 - simula carga pesada"""
            with self.client.get("/", catch_response=True) as response:
                if response.status_code == 200:
                    # Simula processamento pesado
                    import time
                    time.sleep(random.uniform(0.1, 0.5))
                    response.success()
                else:
                    response.failure(f"Status code: {response.status_code}")
        
        @task(1)
        def visit_error_page(self):
            """Task com peso 1 - simula requests que podem falhar"""
            with self.client.get("/nonexistent-page", catch_response=True) as response:
                if response.status_code == 404:
                    response.success()  # Esperamos 404
                else:
                    response.failure(f"Unexpected status code: {response.status_code}")
```

### **6. Deployment do Locust (locust-deployment.yaml):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: locust
  labels:
    app: locust
spec:
  replicas: 1
  selector:
    matchLabels:
      app: locust
  template:
    metadata:
      labels:
        app: locust
    spec:
      containers:
      - name: locust
        image: locustio/locust:latest
        ports:
        - containerPort: 8089
        - containerPort: 5557
        env:
        - name: LOCUST_HOST
          value: "http://nginx:80"  # Aponta para o service do nginx
        volumeMounts:
        - name: locustfile
          mountPath: /mnt/locust
          readOnly: true
        command: ["locust"]
        args: ["-f", "/mnt/locust/locustfile.py", "--host=http://nginx:80", "--web-host=0.0.0.0"]
      volumes:
      - name: locustfile
        configMap:
          name: locust-config
```

### **7. Service do Locust (locust-service.yaml):**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: locust
  labels:
    app: locust
spec:
  type: NodePort
  ports:
  - port: 8089
    targetPort: 8089
    nodePort: 30089  # Porta para acessar o Locust UI
    protocol: TCP
    name: web-ui
  - port: 5557
    targetPort: 5557
    protocol: TCP
    name: master
  selector:
    app: locust
```

## Executando o Teste de HPA

### **1. Aplicar todos os recursos:**

```bash
# Aplicar na ordem correta
kubectl apply -f nginx-service.yaml
kubectl apply -f deployment.yaml
kubectl apply -f primeiro-hpa.yaml
kubectl apply -f locust-configmap.yaml
kubectl apply -f locust-deployment.yaml
kubectl apply -f locust-service.yaml
```

### **2. Acessar o Locust:**

```bash
# Port-forward para acessar o Locust
kubectl port-forward svc/locust 8089:8089

# Acessar no navegador
# http://localhost:8089
```

### **3. Configurar o teste no Locust:**

- **Number of users**: 50-100
- **Spawn rate**: 10
- **Host**: http://nginx:80

### **4. Monitorar o HPA:**

```bash
# Ver status do HPA
kubectl get hpa nginx-hpa

# Ver consumo de recursos
kubectl top pods -l app=nginx

# Ver pods em tempo real
watch kubectl get pods -l app=nginx

# Ver detalhes do HPA
kubectl describe hpa nginx-hpa
```

## Comandos de Monitoramento

### **Monitoramento básico:**

```bash
# Status do HPA
kubectl get hpa

# Consumo de CPU/Memory
kubectl top pods
kubectl top nodes

# Pods do deployment
kubectl get pods -l app=nginx
```

### **Monitoramento avançado:**

```bash
# Detalhes do HPA
kubectl describe hpa nginx-hpa

# Eventos do HPA
kubectl get events --field-selector involvedObject.name=nginx-hpa

# Logs do metrics-server
kubectl logs -n kube-system -l k8s-app=metrics-server

# Status detalhado em YAML
kubectl get hpa nginx-hpa -o yaml
```

### **Monitoramento em tempo real:**

```bash
# Watch HPA
watch kubectl get hpa nginx-hpa

# Watch pods com recursos
watch kubectl top pods -l app=nginx

# Watch pods sendo criados/destruídos
watch kubectl get pods -l app=nginx
```

## Comportamento do HPA

### **Scale Up:**
- **Trigger**: Métricas acima do target
- **Tempo**: 15-30 segundos
- **Comportamento**: Cria novos pods gradualmente

### **Scale Down:**
- **Trigger**: Métricas abaixo do target
- **Tempo**: 5 minutos (stabilization window)
- **Comportamento**: Remove pods gradualmente
- **Limite**: Respeita minReplicas

### **Exemplo de eventos:**

```
Normal  SuccessfulRescale  2m   horizontal-pod-autoscaler  New size: 5; reason: cpu resource utilization above target
Normal  SuccessfulRescale  1m   horizontal-pod-autoscaler  New size: 8; reason: cpu resource utilization above target
Normal  SuccessfulRescale  30s  horizontal-pod-autoscaler  New size: 10; reason: cpu resource utilization above target
Normal  SuccessfulRescale  2m   horizontal-pod-autoscaler  New size: 7; reason: All metrics below target
Normal  SuccessfulRescale  1m   horizontal-pod-autoscaler  New size: 3; reason: All metrics below target
```

## HPA v1 vs v2

### **autoscaling/v1:**
```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
spec:
  targetCPUUtilizationPercentage: 50  # Apenas CPU
```

### **autoscaling/v2:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

## Troubleshooting

### **Problemas comuns:**

**1. HPA não escala:**
```bash
# Verificar se metrics-server está rodando
kubectl get pods -n kube-system -l k8s-app=metrics-server

# Verificar se pods têm requests definidos
kubectl describe pod <pod-name>
```

**2. Métricas não aparecem:**
```bash
# Verificar logs do metrics-server
kubectl logs -n kube-system -l k8s-app=metrics-server

# Testar kubectl top
kubectl top nodes
kubectl top pods
```

**3. HPA fica em "Unknown" status:**
```bash
# Verificar se deployment existe
kubectl get deployment nginx

# Verificar se HPA está apontando para deployment correto
kubectl describe hpa nginx-hpa
```

## Boas Práticas

### **1. Configuração de recursos:**
- **Sempre defina requests e limits**
- **Requests** são usados pelo HPA para cálculo
- **Limits** protegem contra resource starvation

### **2. Configuração do HPA:**
- **minReplicas**: Mantenha um mínimo para disponibilidade
- **maxReplicas**: Limite para controlar custos
- **targetCPUUtilizationPercentage**: Comece com 70-80%

### **3. Monitoramento:**
- **Monitore métricas** antes de configurar HPA
- **Use alertas** para detectar problemas
- **Teste** com carga real

### **4. Testes:**
- **Use ferramentas como Locust** para gerar carga
- **Teste scale up e scale down**
- **Monitore comportamento** durante testes

## Conclusão

O HPA é uma ferramenta essencial para **automação de escalabilidade** no Kubernetes. Com ele, você pode:

- **Automatizar scaling** baseado em métricas
- **Otimizar custos** usando apenas recursos necessários
- **Manter alta disponibilidade** com scaling automático
- **Reduzir trabalho manual** de monitoramento

### **Próximos passos:**
- Explore **métricas customizadas**
- Teste **HPA v2** com múltiplas métricas
- Implemente **alertas** para HPA
- Estude **VPA (Vertical Pod Autoscaler)**

---

**📚 Recursos adicionais:**
- [Kubernetes HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Metrics Server Documentation](https://github.com/kubernetes-sigs/metrics-server)
- [Locust Official Documentation](https://docs.locust.io/)
