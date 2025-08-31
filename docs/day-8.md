# Dia 8 - Secrets e ConfigMaps no Kubernetes

## O que são Secrets?

Secrets são uma forma de armazenar dados sensíveis no Kubernetes de forma segura. Eles podem conter:
- Tokens de autenticação
- Senhas
- Chaves SSH
- Certificados TLS
- Credenciais de registros Docker
- Qualquer informação que não deve ser exposta em texto plano

## Características dos Secrets

**⚠️ Importante**: Os Secrets **NÃO são criptografados por padrão**!

- São armazenados no **etcd** sem criptografia
- São codificados em **base64** (não é criptografia, apenas codificação)
- O propósito é **disponibilizar informações**, não criptografá-las
- É necessário implementar estratégias de segurança adicionais

### Estratégias para tornar Secrets mais seguros

1. **Controle de Acesso (RBAC)**
   - Restringir quem pode criar/ler/editar secrets
   - Usar namespaces para isolamento
   - Implementar políticas de rede (Network Policies)

2. **Criptografia em repouso**
   - Habilitar criptografia no etcd via EncryptionConfiguration
   - Usar provedores: aescbc, aesgcm, secretbox
   - Implementar rotação de chaves de criptografia

3. **Rotação de credenciais**
   - **cert-manager**: Para certificados TLS automáticos
   - **Vault**: Para rotação automática de credenciais
   - **Sealed Secrets**: Para armazenar secrets criptografados no Git
   - **External Secrets Operator**: Para integração com provedores externos

4. **Auditoria e Monitoramento**
   - Monitorar acesso aos secrets via audit logs
   - Implementar alertas para acesso não autorizado
   - Usar ferramentas como Falco para detecção de anomalias

### O que é Base64?

Base64 é um esquema de codificação que converte dados binários em uma string de texto ASCII. **Não é criptografia** - é apenas uma forma de representar dados binários como texto.

#### Exemplo prático:
```bash
# Converter texto para base64
echo -n "giropops" | base64
# Saída: Z2lyb3BvcHM=

# Converter base64 de volta para texto
echo "Z2lyb3BvcHM=" | base64 -d
# Saída: giropops
```

#### Por que usar base64?
- Permite armazenar dados binários em campos de texto
- É compatível com JSON/YAML
- **Mas é facilmente decodificável** - não use para segurança!

### Tipos de Secrets

O Kubernetes oferece diferentes tipos de Secrets para diferentes propósitos. Cada tipo tem uma estrutura específica e é usado para cenários específicos.

#### 1. Opaque (padrão)
**Propósito**: Para dados genéricos e customizados como usuários, senhas, chaves de API, etc.

**Estrutura**: Permite qualquer chave-valor em base64
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: primeiro-secrets
type: Opaque 
data:
  username: Z2lyb3BvcHM=  # "giropops" em base64
  password: cGFzc3dvcmQ=   # "password" em base64
  api-key: <chave-api-em-base64>
  database-url: <url-banco-em-base64>
```

**Uso comum**: Credenciais de banco de dados, chaves de API, tokens de aplicação

#### 2. kubernetes.io/tls
**Propósito**: Para armazenar certificados TLS/SSL e chaves privadas

**Estrutura**: Requer exatamente duas chaves: `tls.crt` e `tls.key`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cert-tls
type: kubernetes.io/tls
data:
  tls.crt: <certificado-em-base64>
  tls.key: <chave-privada-em-base64>
```

**Uso comum**: HTTPS para nginx, ingress controllers, comunicação segura entre serviços

#### 3. kubernetes.io/dockerconfigjson
**Propósito**: Para armazenar credenciais de registros de containers (Docker Hub, ECR, GCR, etc.)

**Estrutura**: Contém um arquivo `.dockerconfigjson` com as credenciais
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: docker-hub-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <credenciais-em-base64>
```

**Como criar**:
```bash
kubectl create secret docker-registry docker-hub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<seu-usuario> \
  --docker-password=<sua-senha> \
  --docker-email=<seu-email>
```

**Uso comum**: Para puxar imagens privadas de registros Docker

#### 4. kubernetes.io/service-account-token
**Propósito**: Tokens de autenticação para contas de serviço (Service Accounts)

**Características**: 
- Criados automaticamente pelo Kubernetes
- Usados para autenticação entre pods e a API do Kubernetes
- Não devem ser criados manualmente

**Uso comum**: Autenticação automática de pods com a API do cluster

#### 5. kubernetes.io/ssh-auth
**Propósito**: Para armazenar chaves SSH públicas e privadas

**Estrutura**: Contém a chave SSH em base64
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-key-secret
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: <chave-ssh-privada-em-base64>
```

**Uso comum**: Conectar pods a servidores externos via SSH

#### 6. kubernetes.io/basic-auth
**Propósito**: Para autenticação básica HTTP (usuário/senha)

**Estrutura**: Requer `username` e `password`
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth-secret
type: kubernetes.io/basic-auth
data:
  username: <usuario-em-base64>
  password: <senha-em-base64>
```

**Uso comum**: Autenticação básica em ingress, nginx, ou aplicações web

#### 7. kubernetes.io/ssh-auth (chaves SSH)
**Propósito**: Para armazenar chaves SSH públicas e privadas

**Estrutura**: Contém a chave SSH em base64
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ssh-key-secret
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: <chave-ssh-privada-em-base64>
```

**Uso comum**: Conectar pods a servidores externos via SSH

### Escolhendo o Tipo Correto

- **Dados genéricos** → `Opaque`
- **Certificados TLS** → `kubernetes.io/tls`
- **Registros Docker** → `kubernetes.io/dockerconfigjson`
- **Autenticação básica** → `kubernetes.io/basic-auth`
- **Chaves SSH** → `kubernetes.io/ssh-auth`
- **Service Accounts** → `kubernetes.io/service-account-token` (automático)

## O que são ConfigMaps?

ConfigMaps são recursos do Kubernetes que permitem **separar a configuração da aplicação** do código da aplicação. É como ter um "arquivo de configuração externo" que pode ser alterado sem precisar recompilar ou reempacotar a aplicação.

### 🎯 **Por que usar ConfigMaps?**

Imagine que você tem uma aplicação que precisa se conectar a diferentes bancos de dados dependendo do ambiente:
- **Desenvolvimento**: `localhost:3306`
- **Homologação**: `homolog-db.company.com:3306`  
- **Produção**: `prod-db.company.com:3306`

**Sem ConfigMaps**: Você precisaria criar 3 imagens diferentes da aplicação
**Com ConfigMaps**: Uma única imagem + 3 configurações diferentes

### 📋 **O que pode ser armazenado em ConfigMaps:**

1. **Arquivos de configuração** → `nginx.conf`, `application.properties`, `config.yaml`
2. **Variáveis de ambiente** → `DATABASE_URL`, `API_KEY`, `LOG_LEVEL`
3. **Comandos de linha** → Argumentos para executar a aplicação
4. **URLs de serviços** → Endpoints de APIs, bancos de dados
5. **Configurações de rede** → Portas, timeouts, retry policies

### 🔧 **Como funcionam:**

1. **Criar** o ConfigMap com as configurações
2. **Montar** no pod como arquivo ou variável de ambiente
3. **Aplicação lê** a configuração do local montado
4. **Alterar configuração** = recriar ConfigMap + restart do pod

### 📁 **Formas de usar ConfigMaps:**

#### **1. Como arquivo montado no pod:**
```yaml
volumeMounts:
- name: config-volume
  mountPath: /etc/app/config
volumes:
- name: config-volume
  configMap:
    name: app-config
```

#### **2. Como variáveis de ambiente:**
```yaml
env:
- name: DATABASE_URL
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: database_url
```

#### **3. Como arquivo individual:**
```yaml
volumeMounts:
- name: config-volume
  mountPath: /etc/nginx/nginx.conf
  subPath: nginx.conf
```

### Exemplo de ConfigMap para Nginx HTTPS

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
            listen 443 ssl;
            ssl_certificate /etc/nginx/tls/certificado.crt;
            ssl_certificate_key /etc/nginx/tls/chave-privada.key;

            location / {
                return 200 'Hello, World!';
                add_header Content-Type text/plain;
            }
        }
    }
```

## Exemplo Prático: Nginx com HTTPS

Para demonstrar como **Secrets** e **ConfigMaps** trabalham juntos, vamos criar um exemplo prático de nginx configurado com HTTPS usando certificados TLS.

### 1. Criando Certificados com OpenSSL

Primeiro, precisamos gerar certificados TLS para o nginx. Estes serão armazenados como Secrets do tipo `kubernetes.io/tls`.

#### Gerar chave privada:
```bash
openssl genrsa -out chave-privada.key 2048
```

#### Gerar certificado auto-assinado:
```bash
# Certificado básico
openssl req -new -x509 -key chave-privada.key -out certificado.crt -days 365 -subj "/CN=localhost"

# Certificado com SAN (recomendado para produção)
openssl req -new -x509 -key chave-privada.key -out certificado.crt -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1"

# Verificar certificado
openssl x509 -in certificado.crt -text -noout
```

#### Converter para base64:
```bash
# Certificado
cat certificado.crt | base64 -w 0

# Chave privada
cat chave-privada.key | base64 -w 0
```

### 2. Criando o Secret TLS

Agora vamos criar um Secret para armazenar os certificados:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cert-tls
type: kubernetes.io/tls
data:
  tls.crt: <certificado-em-base64>
  tls.key: <chave-privada-em-base64>
```

### 3. Configurando o Nginx com ConfigMap

Agora vamos criar um ConfigMap com a configuração do nginx que usa os certificados TLS:

#### Como variáveis de ambiente:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: primeiro-secrets
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: primeiro-secrets
          key: password
```

#### Como volumes:
```yaml
spec:
  containers:
  - name: nginx-https
    image: nginx
    volumeMounts:
    - name: nginx-tls
      mountPath: /etc/nginx/tls
      readOnly: true
  volumes:
  - name: nginx-tls
    secret:
      secretName: cert-tls
      items:
      - key: tls.crt
        path: certificado.crt
      - key: tls.key
        path: chave-privada.key
```

### 4. Criando o Deployment

### 4. Criando o Deployment

Agora vamos criar um Deployment que usa tanto o ConfigMap quanto o Secret TLS:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-https
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx-https
  template:
    metadata:
      labels:
        app: nginx-https
    spec:
      containers:
      - name: nginx-https
        image: nginx
        ports:
        - containerPort: 80
        - containerPort: 443
        volumeMounts:
        - name: nginx-config-volume
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: nginx-tls
          mountPath: /etc/nginx/tls
          readOnly: true
      volumes:
      - name: nginx-config-volume
        configMap:
          name: nginx-config
      - name: nginx-tls
        secret:
          secretName: cert-tls
```

### 5. Como Funciona o Fluxo Completo

1. **Certificados OpenSSL** → Gerados localmente
2. **Secret TLS** → Armazena certificados criptografados
3. **ConfigMap** → Configuração do nginx que referencia os certificados
4. **Deployment** → Monta ambos os recursos no pod
5. **Nginx** → Usa a configuração do ConfigMap e os certificados do Secret

Este exemplo demonstra como **Secrets** e **ConfigMaps** trabalham juntos para criar uma aplicação HTTPS segura no Kubernetes.



## Boas Práticas

### Para Secrets:
1. **Nunca** commitar secrets no Git
2. Use namespaces para isolamento
3. Implemente rotação automática
4. Monitore acesso aos secrets
5. Use ferramentas como Sealed Secrets ou Vault
6. **Sealed Secrets**: Para armazenar secrets criptografados no Git
7. **External Secrets**: Para sincronizar com provedores externos (AWS Secrets Manager, HashiCorp Vault)
8. **cert-manager**: Para gerenciar certificados TLS automaticamente

### Para ConfigMaps:
1. Mantenha configurações simples
2. Use para dados não-sensíveis
3. Versionar configurações
4. Testar configurações antes de aplicar

## Comandos Úteis

### Verificar recursos
```bash
kubectl get secrets
kubectl get configmaps
kubectl describe secret <nome-do-secret>
kubectl describe configmap <nome-do-configmap>
```

### Criar recursos
```bash
kubectl apply -f primeiro-secrets.yaml
kubectl apply -f config-map.yaml
kubectl apply -f cert-tls.yaml
kubectl apply -f deployment-config-map.yaml
```

### Expor serviços
```bash
kubectl expose deployment nginx-https --port=443 --target-port=443
kubectl get services
```

### Port-forward para teste
```bash
kubectl port-forward services/nginx-https 4443:443
```

## Ferramentas Recomendadas para Produção

### Gerenciamento de Secrets:
- **Sealed Secrets**: Para GitOps seguro
- **External Secrets Operator**: Para provedores externos
- **cert-manager**: Para certificados automáticos
- **HashiCorp Vault**: Para rotação automática

### Monitoramento e Auditoria:
- **Falco**: Para detecção de anomalias
- **OPA Gatekeeper**: Para políticas de segurança
- **Audit Logs**: Para rastreamento de acesso
- **Network Policies**: Para isolamento de rede

## Troubleshooting Comum

### Secrets não carregam:
```bash
# Verificar se o secret existe
kubectl get secrets

# Verificar permissões do pod
kubectl describe pod <pod-name>

# Verificar logs do pod
kubectl logs <pod-name>
```

### Certificados inválidos:
```bash
# Verificar certificado
openssl x509 -in certificado.crt -text -noout

# Testar conectividade TLS
openssl s_client -connect localhost:443 -servername localhost
```
