# Guia para Instalação do Cluster EKS e Kube-Prometheus

Este documento descreve as etapas para instalar e configurar um cluster EKS e o Kube-Prometheus.

## Pré-requisitos
- AWS CLI configurado e autenticado.
- Permissões adequadas para gerenciar recursos na AWS.

---

## 1. Instalar o `eksctl`

O `eksctl` é necessário para gerenciar o cluster EKS. Use o comando abaixo para instalá-lo:

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

Para confirmar a instalação, execute:

```bash
eksctl version
```

---

## 2. Configurar o `kubectl` para o Cluster EKS

Após criar o cluster, configure o `kubectl` para interagir com ele:

```bash
aws eks --region us-east-1 update-kubeconfig --name eks-cluster
```

---

## 3. Criar o Cluster EKS

Crie o cluster usando o comando abaixo:

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

O comando completo:

```bash
eksctl create cluster --name=eks-cluster --version=1.24 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed
```

### Comandos para Validação

Verifique se o cluster foi criado com sucesso:

```bash
eksctl get cluster -A
```

---

## 4. Deletar o Cluster

Se for necessário remover o cluster:

```bash
eksctl delete cluster --name=eks-cluster --region=us-east-1
```

---

## 5. Instalar o Kube-Prometheus

O Kube-Prometheus é usado para monitoramento de clusters Kubernetes. Para instalá-lo, siga as etapas:

### Clonar o Repositório do Kube-Prometheus

```bash
git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus
```

### Aplicar os Manifests

1. Configurar o ambiente inicial:

   ```bash
   kubectl create -f manifests/setup
   ```

2. Aplicar os manifests restantes:

   ```bash
   kubectl apply -f manifests/
   ```

### Verificar os Pods

Confirme que os pods foram criados corretamente no namespace `monitoring`:

```bash
kubectl get pods -n monitoring
```