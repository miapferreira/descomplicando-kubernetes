# Cluster Kubernetes na AWS com Terraform

Este diretório contém a infraestrutura como código (IaC) para criar um cluster Kubernetes completo na AWS usando Terraform.

## 🏗️ Arquitetura

- **1 Control Plane** - Gerencia o cluster
- **2 Worker Nodes** - Executam as aplicações
- **Security Group** - Todas as portas necessárias liberadas
- **Scripts de automação** - Configuração automática das instâncias

## 📁 Estrutura dos Arquivos

```
day-5/
├── main.tf                 # Configuração principal e providers
├── variables.tf            # Variáveis configuráveis
├── security.tf            # Security Group com portas
├── instances.tf           # EC2 Instances
├── outputs.tf             # Informações de saída
├── scripts/
│   ├── control-plane-setup.sh  # Script do control plane
│   └── worker-setup.sh         # Script dos workers
└── README-TERRAFORM.md    # Este arquivo
```

## 🚀 Como Usar

### Pré-requisitos

1. **Terraform** instalado (versão >= 1.0)
2. **AWS CLI** configurado
3. **Chave SSH** criada na AWS (nome: `k8s`)

### Passo a Passo

#### 1. Configurar AWS
```bash
aws configure
```

#### 2. Criar chave SSH (se não existir)
```bash
aws ec2 create-key-pair --key-name k8s --query 'KeyMaterial' --output text > ~/.ssh/k8s.pem
chmod 400 ~/.ssh/k8s.pem
```

#### 3. Inicializar Terraform
```bash
cd day-5
terraform init
```

#### 4. Verificar plano
```bash
terraform plan
```

#### 5. Aplicar infraestrutura
```bash
terraform apply
```

#### 6. Aguardar configuração automática
Aguarde aproximadamente **10-15 minutos** para que os scripts de configuração terminem.

#### 7. Verificar cluster
```bash
# Ver outputs do Terraform
terraform output

# Acessar control plane
ssh -i ~/.ssh/k8s.pem ubuntu@<IP_DO_CONTROL_PLANE>

# Verificar status do cluster
kubectl get nodes
kubectl get pods -n kube-system
```

## ⚙️ Configurações

### Variáveis Disponíveis

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `aws_region` | Região AWS | `us-east-1` |
| `cluster_name` | Nome do cluster | `meu-cluster-k8s` |
| `instance_type` | Tipo de instância | `t2.medium` |
| `key_name` | Nome da chave SSH | `k8s` |
| `control_plane_count` | Número de control planes | `1` |
| `worker_count` | Número de workers | `2` |

### Personalizar Configuração

Crie um arquivo `terraform.tfvars`:
```hcl
aws_region = "us-west-2"
cluster_name = "meu-cluster-producao"
worker_count = 3
instance_type = "t3.medium"
```

## 🔧 Portas Liberadas

O Security Group libera todas as portas necessárias:

- **22** - SSH
- **6443** - Kubernetes API
- **2379-2380** - etcd
- **10250** - Kubelet
- **10257** - kube-controller-manager
- **10259** - kube-scheduler
- **30000-32767** - NodePort Services
- **6783/TCP** - Weave Net controle/dados
- **6783-6784/UDP** - Weave Net dados
- **80/443** - HTTP/HTTPS
- **53** - DNS

## 📊 Outputs Importantes

Após `terraform apply`, você verá:

- **IPs das instâncias** (público e privado)
- **Comandos SSH** para acesso
- **Comandos kubectl** para verificar status
- **Informações do cluster**

## 🧹 Limpeza

Para destruir toda a infraestrutura:
```bash
terraform destroy
```

## 🔍 Troubleshooting

### Problema: Instâncias não iniciam
```bash
# Verificar logs da instância
aws ec2 get-console-output --instance-id <instance-id>
```

### Problema: Cluster não funciona
```bash
# Verificar logs do kubelet
ssh -i ~/.ssh/k8s.pem ubuntu@<control-plane-ip>
sudo journalctl -u kubelet -f
```

### Problema: Workers não se juntam
```bash
# Verificar comando de join
ssh -i ~/.ssh/k8s.pem ubuntu@<control-plane-ip>
cat /home/ubuntu/join-command.txt
```

## 📝 Notas Importantes

- **Custo**: t2.medium custa aproximadamente $0.0416/hora
- **Tempo**: Configuração completa leva 10-15 minutos
- **Segurança**: Security Group libera todas as portas (não recomendado para produção)
- **Backup**: Sempre faça backup do etcd em ambientes de produção

## 🎯 Próximos Passos

Após criar o cluster:
1. Configurar kubectl localmente
2. Instalar aplicações de exemplo
3. Configurar monitoramento
4. Implementar backup do etcd
