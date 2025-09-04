# Dia 9 - Monitoramento com Prometheus Operator e Kube-Prometheus

## O que é o Prometheus Operator?

O **Prometheus Operator** é um operador do Kubernetes que simplifica o gerenciamento de instâncias do Prometheus e de componentes relacionados. Ele automatiza a configuração, descoberta e manutenção de recursos de monitoramento no cluster Kubernetes.

### 🎯 **Por que usar o Prometheus Operator?**

- **Automatização**: Configura automaticamente o Prometheus, Alertmanager e Grafana
- **Descoberta de serviços**: Detecta automaticamente novos serviços para monitorar
- **Gerenciamento de configurações**: Atualiza configurações sem reiniciar o Prometheus
- **Recursos nativos do Kubernetes**: Usa CRDs (Custom Resource Definitions) para gerenciar recursos

## O que é o Kube-Prometheus?

O **Kube-Prometheus** é um conjunto de manifestos Kubernetes que inclui:

- **Prometheus**: Sistema de monitoramento e alertas
- **Grafana**: Dashboard de visualização de métricas
- **Alertmanager**: Gerenciamento de alertas
- **Node Exporter**: Coleta métricas dos nós
- **Kube State Metrics**: Métricas do estado do cluster Kubernetes

### 📊 **Componentes do Stack de Monitoramento:**

1. **Prometheus** → Coleta e armazena métricas
2. **Grafana** → Visualiza métricas em dashboards
3. **Alertmanager** → Gerencia e envia alertas
4. **Node Exporter** → Coleta métricas dos nós do cluster
5. **Kube State Metrics** → Expõe métricas do estado do Kubernetes

## O que é Observabilidade?

**Observabilidade** é a capacidade de entender o que está acontecendo dentro de um sistema através de **métricas**, **logs** e **tracing**. No contexto do Kubernetes, isso significa ter visibilidade completa sobre:

- **📊 Métricas** → Performance, uso de recursos, saúde dos pods
- **📝 Logs** → O que está acontecendo dentro das aplicações
- **🔍 Tracing** → Como as requisições fluem entre serviços

### 🎯 **Prometheus Operator + Kube-Prometheus = Observabilidade Completa**

O **Prometheus Operator** e **Kube-Prometheus** juntos fornecem uma solução completa de observabilidade para clusters Kubernetes:

#### **1. Métricas (Metrics)**
- **Prometheus** → Coleta métricas do cluster e aplicações
- **Node Exporter** → Métricas dos nós (CPU, memória, disco)
- **Kube State Metrics** → Estado do Kubernetes (pods, deployments, services)

#### **2. Visualização (Dashboards)**
- **Grafana** → Dashboards para visualizar as métricas
- **Dashboards pré-configurados** → Para Kubernetes, aplicações, etc.

#### **3. Alertas (Alerts)**
- **Alertmanager** → Gerencia e envia alertas
- **Regras de alerta** → Para problemas críticos

### 🌟 **Benefícios da Observabilidade:**

1. **Detecção proativa** de problemas
2. **Visibilidade completa** do cluster
3. **Alertas automáticos** para problemas críticos
4. **Dashboards** para análise de performance
5. **Histórico** de métricas para análise

### 🔧 **Como Funciona:**

```yaml
# O Prometheus Operator automaticamente:
# 1. Descobre novos serviços para monitorar
# 2. Configura coleta de métricas
# 3. Cria dashboards no Grafana
# 4. Configura alertas no Alertmanager
```

**Resumo**: O Prometheus Operator + Kube-Prometheus são a solução completa de observabilidade para clusters Kubernetes, fornecendo métricas, visualização, alertas e descoberta automática de serviços.

## O que é o Amazon EKS?

O **Amazon Elastic Kubernetes Service (EKS)** é um serviço gerenciado do AWS que facilita a execução de clusters Kubernetes na nuvem AWS. Ele remove a complexidade de gerenciar a infraestrutura do cluster, permitindo que você se concentre no desenvolvimento de aplicações.

### 🌟 **Vantagens do EKS:**

- **Gerenciamento simplificado**: AWS gerencia o control-plane
- **Alta disponibilidade**: Múltiplas zonas de disponibilidade
- **Integração nativa**: Integra com outros serviços AWS
- **Segurança**: IAM, VPC, e outros controles de segurança
- **Escalabilidade**: Auto Scaling Groups para nós

## Pré-requisitos

Antes de começar, você precisa ter:

1. **AWS CLI** configurado e autenticado
2. **kubectl** instalado
3. **eksctl** (ferramenta para gerenciar clusters EKS)
4. **Permissões adequadas** na AWS para criar recursos

## Instalação do eksctl

O `eksctl` é a ferramenta oficial para gerenciar clusters EKS. Instale-o com:

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

**Verificar a instalação:**

```bash
eksctl version
```

## Criando um Cluster EKS

### Comando Básico

```bash
eksctl create cluster \
  --name=eks-cluster \
  --version=1.29 \
  --region=us-east-1 \
  --nodegroup-name=eks-cluster-nodegroup \
  --node-type=t3.medium \
  --nodes=2 \
  --nodes-min=1 \
  --nodes-max=3 \
  --managed
```

### Comando em uma linha

```bash
eksctl create cluster --name=eks-cluster --version=1.29 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

> **⚠️ IMPORTANTE**: Sempre verifique a versão mais recente do Kubernetes disponível no EKS. Use `eksctl get cluster --region=us-east-1` para ver versões suportadas ou consulte a [documentação oficial do EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html).

### Parâmetros explicados:

- `--name`: Nome do cluster
- `--version`: Versão do Kubernetes
- `--region`: Região da AWS
- `--nodegroup-name`: Nome do grupo de nós
- `--node-type`: Tipo de instância EC2
- `--nodes`: Número inicial de nós
- `--nodes-min`: Número mínimo de nós
- `--nodes-max`: Número máximo de nós
- `--managed`: Usa nós gerenciados pela AWS

## Configurando o kubectl

Após criar o cluster, configure o `kubectl` para interagir com ele:

```bash
aws eks --region us-east-1 update-kubeconfig --name eks-cluster
```

**Verificar a conexão:**

```bash
kubectl get nodes
```

## Instalando o Kube-Prometheus

### 1. Clonar o Repositório

```bash
git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus
```

### 2. Aplicar os Manifests

**Passo 1 - Configurar o ambiente inicial:**

```bash
kubectl create -f manifests/setup
```

**Passo 2 - Aplicar os manifests restantes:**

```bash
kubectl apply -f manifests/
```

### 3. Verificar a Instalação

**Verificar os pods no namespace monitoring:**

```bash
kubectl get pods -n monitoring
```

**Verificar os serviços:**

```bash
kubectl get services -n monitoring
```

## Acessando os Dashboards

### 🔧 **Por que usar `kubectl port-forward`?**

Por padrão, os serviços no Kubernetes **não são acessíveis externamente**. O `port-forward` cria um túnel seguro do seu localhost para o serviço dentro do cluster:

```bash
kubectl port-forward -n monitoring svc/prometheus-k8s 9090:9090
#                    ↑                ↑                ↑     ↑
#                    namespace        serviço          porta  porta
#                                                      local  remota
```

**Tradução**: "Crie um túnel do meu localhost:9090 para o serviço prometheus-k8s:9090 no namespace monitoring"

#### **🎯 Vantagens do port-forward:**
- **Segurança** → Não expõe serviços publicamente
- **Simplicidade** → Não precisa configurar Ingress ou LoadBalancer
- **Desenvolvimento** → Acesso rápido para testes
- **Temporário** → Conexão que termina quando você para o comando

#### **⚠️ Limitações:**
- **Temporário** → Para quando você para o comando
- **Uma conexão** → Só você pode acessar
- **Desenvolvimento** → Não é para produção

### Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus-k8s 9090:9090
```

Acesse: http://localhost:9090

### Grafana

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

Acesse: http://localhost:3000

**Credenciais padrão:**
- Usuário: `admin`
- Senha: `admin`

### Alertmanager

```bash
kubectl port-forward -n monitoring svc/alertmanager-main 9093:9093
```

Acesse: http://localhost:9093

## Service Monitor e Pod Monitor

### O que é Service Monitor?

O **ServiceMonitor** é um recurso customizado (CRD) do Prometheus Operator que define **como o Prometheus deve descobrir e coletar métricas** de serviços Kubernetes. Ele é responsável por:

- **Descoberta automática** de serviços para monitoramento
- **Configuração de scraping** (coleta de métricas)
- **Definição de endpoints** e intervalos de coleta
- **Seleção de serviços** baseada em labels

### O que é Pod Monitor?

O **PodMonitor** é similar ao ServiceMonitor, mas focado em **monitorar pods diretamente** em vez de serviços. Útil quando você quer monitorar pods específicos sem criar um serviço.

### 🎯 **Fluxo de Monitoramento:**

1. **Aplicação** → Expõe métricas em `/metrics`
2. **Exporter** → Converte métricas para formato Prometheus
3. **Service** → Expõe o exporter
4. **ServiceMonitor** → Define como coletar métricas
5. **Prometheus** → Coleta automaticamente as métricas

## Exemplo Prático: Monitorando Nginx

Vamos criar um exemplo completo de monitoramento do Nginx usando ServiceMonitor.

### 1. ConfigMap do Nginx

Primeiro, criamos um ConfigMap com configuração do Nginx que expõe métricas:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events {
      worker_connections 1024;
    }

    http {
      server {
        listen 80;
        location / {
          root /usr/share/nginx/html;
          index index.html index.htm;
        }
        location /metrics {
          stub_status on;
          access_log off;
        }
      }
    }
```

### 2. Deployment com Nginx + Exporter

Criamos um Deployment que roda tanto o Nginx quanto o nginx-prometheus-exporter:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '9113'
    spec: 
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
          name: http
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      - name: prometheus-exporter
        image: nginx/nginx-prometheus-exporter:1.4.2
        args:
          - '-nginx.scrape-uri=http://localhost/metrics'
        resources:
          requests:
            cpu: 0.3
            memory: 128Mi
        ports:
        - containerPort: 9113
          name: metrics
      volumes:  
      - name: nginx-config
        configMap:
          name: nginx-config
          defaultMode: 420
```

### 3. Service para o Exporter

Criamos um Service que expõe as métricas do exporter:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  ports:
  - port: 9113
    name: metrics
  selector:
    app: nginx
```

### 4. ServiceMonitor

Agora criamos o ServiceMonitor que diz ao Prometheus como coletar as métricas:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nginx-service-monitor
  labels:
    app: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  endpoints:
  - interval: 10s
    path: /metrics
    targetPort: 9113
```

### 5. PrometheusRule (Alertas)

Criamos regras de alerta para o Nginx:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: nginx-prometheus-rule
  namespace: monitoring
  labels:
    prometheus: k8s
    role: alert-rules
spec:
  groups:
  - name: nginx-prometheus-rule
    rules:
    - alert: NginxDown
      expr: nginx_up == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Nginx está fora"
        description: "O nosso servidor web Nginx está fora"
    - alert: NginxHighRequestRate
      expr: rate(nginx_http_requests_total[5m]) > 10
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Nginx recebendo muitos requests"
        description: "O Nginx está recebendo um número alto de requests"
```

### 6. Aplicando os Manifests

```bash
# Aplicar todos os recursos
kubectl apply -f nginx.configmap.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f service-monitor.yaml
kubectl apply -f nginx-prometheus-rules.yaml
```

### 7. Verificando o Monitoramento

**Verificar se o ServiceMonitor foi descoberto:**

```bash
kubectl get servicemonitors -n monitoring
```

**Verificar targets no Prometheus:**

1. Acesse o Prometheus: `kubectl port-forward -n monitoring svc/prometheus-k8s 9090:9090`
2. Vá em **Status → Targets**
3. Procure por `nginx-service-monitor`

**Verificar métricas:**

```bash
# Testar endpoint de métricas
kubectl port-forward svc/nginx-service 9113:9113
curl http://localhost:9113/metrics
```

## Pod Monitor (Alternativa)

Se você quiser monitorar pods diretamente sem Service:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: pod-monitor
  labels:
    app: pod-monitor
spec:
  namespaceSelector:
    matchNames:
    - default
  selector:
    matchLabels:
      app: pod-monitor
  podMetricsEndpoints:
  - interval: 10s
    path: /metrics
    targetPort: 9113
```

## Comandos Úteis

### Verificar status do cluster EKS

```bash
eksctl get cluster -A
```

### Verificar logs dos pods de monitoramento

```bash
kubectl logs -n monitoring deployment/prometheus-operator
kubectl logs -n monitoring deployment/grafana
```

### Verificar métricas do cluster

```bash
kubectl top nodes
kubectl top pods -A
```

### Comandos para Service Monitor

```bash
# Listar ServiceMonitors
kubectl get servicemonitors -A

# Descrever ServiceMonitor específico
kubectl describe servicemonitor nginx-service-monitor

# Verificar PodMonitors
kubectl get podmonitors -A

# Verificar PrometheusRules
kubectl get prometheusrules -n monitoring

# Verificar se targets estão sendo descobertos
kubectl port-forward -n monitoring svc/prometheus-k8s 9090:9090
# Acesse: http://localhost:9090/targets
```

### Deletar o cluster EKS

```bash
eksctl delete cluster --name=eks-cluster --region=us-east-1
```

## Troubleshooting

### Problema: Pods não iniciam

**Verificar recursos disponíveis:**

```bash
kubectl describe nodes
kubectl get events -n monitoring
```

### Problema: Não consegue acessar os dashboards

**Verificar se os serviços estão rodando:**

```bash
kubectl get svc -n monitoring
kubectl get pods -n monitoring
```

### Problema: Métricas não aparecem

**Verificar se o Node Exporter está funcionando:**

```bash
kubectl logs -n monitoring daemonset/node-exporter
```

### Problema: ServiceMonitor não descobre targets

**Verificar labels do Service:**

```bash
kubectl get service nginx-service -o yaml
# Verificar se as labels coincidem com o selector do ServiceMonitor
```

**Verificar se o ServiceMonitor está no namespace correto:**

```bash
kubectl get servicemonitors -A
# ServiceMonitor deve estar no namespace 'monitoring'
```

**Verificar logs do Prometheus Operator:**

```bash
kubectl logs -n monitoring deployment/prometheus-operator
```

### Problema: Exporter não expõe métricas

**Testar endpoint de métricas:**

```bash
kubectl port-forward svc/nginx-service 9113:9113
curl http://localhost:9113/metrics
```

**Verificar se o exporter está rodando:**

```bash
kubectl get pods -l app=nginx
kubectl logs <pod-name> -c prometheus-exporter
```


