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

## O que é o Amazon EKS?

O **Amazon Elastic Kubernetes Service (EKS)** é um serviço gerenciado do AWS que facilita a execução de clusters Kubernetes na nuvem AWS. Ele remove a complexidade de gerenciar a infraestrutura do cluster, permitindo que você se concentre no desenvolvimento de aplicações.

### 🌟 **Vantagens do EKS:**

- **Gerenciamento simplificado**: AWS gerencia o plano de controle
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
  --version=1.24 \
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
eksctl create cluster --name=eks-cluster --version=1.24 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

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

## Boas Práticas

### Para EKS:

1. **Use múltiplas zonas de disponibilidade** para alta disponibilidade
2. **Configure Auto Scaling Groups** para escalabilidade
3. **Use IAM roles** para permissões de pods
4. **Monitore custos** regularmente
5. **Configure backup** dos dados importantes

### Para Monitoramento:

1. **Configure alertas** para métricas críticas
2. **Use dashboards** para visualização
3. **Monitore recursos** do cluster regularmente
4. **Configure retenção** de dados apropriada
5. **Teste alertas** regularmente

## Próximos Passos

1. **Configurar alertas** personalizados
2. **Criar dashboards** customizados no Grafana
3. **Implementar métricas** de aplicação
4. **Configurar notificações** via Slack/Email
5. **Implementar backup** e recuperação
