# Day 10 - Ingress: Roteamento HTTP/HTTPS no Kubernetes

## O que é Ingress?

O **Ingress** é um recurso do Kubernetes que fornece **roteamento HTTP e HTTPS** para serviços dentro do cluster. Ele atua como um **"roteador inteligente"** que:

- **Expõe serviços** para fora do cluster
- **Gerencia tráfego** baseado em regras de roteamento
- **Fornece balanceamento de carga** automático
- **Suporta SSL/TLS** termination
- **Permite roteamento por domínio** e path

### 🎯 **Analogia simples:**
Imagine o Ingress como um **"porteiro inteligente"** de um prédio:
- **Cliente** chega na porta (domínio)
- **Porteiro** (Ingress) verifica o destino (path)
- **Porteiro** direciona para o apartamento correto (Service/Pod)

## Ingress vs Service: Qual a diferença?

### **Service (ClusterIP)**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: minha-app
spec:
  selector:
    app: minha-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP  # ← Só funciona DENTRO do cluster
```

**Limitações:**
- ❌ **Não acessível externamente**
- ❌ **Sem roteamento por domínio**
- ❌ **Sem SSL/TLS automático**
- ❌ **Sem regras de roteamento complexas**

### **Ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minha-app-ingress
spec:
  rules:
  - host: minha-app.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: minha-app
            port:
              number: 80
```

**Vantagens:**
- ✅ **Acessível externamente**
- ✅ **Roteamento por domínio e path**
- ✅ **SSL/TLS termination**
- ✅ **Regras complexas de roteamento**
- ✅ **Balanceamento de carga**

### **📊 Comparação:**

| **Recurso** | **Service** | **Ingress** |
|-------------|-------------|-------------|
| **Acesso externo** | ❌ Não | ✅ Sim |
| **Roteamento por domínio** | ❌ Não | ✅ Sim |
| **SSL/TLS** | ❌ Manual | ✅ Automático |
| **Regras complexas** | ❌ Não | ✅ Sim |
| **Balanceamento** | ✅ Básico | ✅ Avançado |
| **Uso** | Comunicação interna | Exposição externa |

## Como funciona o Ingress?

### **🔄 Fluxo de tráfego:**

```
Cliente → Ingress Controller → Ingress → Service → Pod
```

### **📋 Componentes necessários:**

1. **Ingress Controller** (nginx-ingress-controller)
2. **Ingress Resource** (regras de roteamento)
3. **Service** (expõe os pods)
4. **Pods** (aplicação)

### **🎯 Exemplo prático:**

```yaml
# 1. Pod da aplicação
apiVersion: v1
kind: Pod
metadata:
  name: nginx-example
  labels:
    app: nginx-example
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80

---
# 2. Service expõe o pod
apiVersion: v1
kind: Service
metadata:
  name: nginx-example-service
spec:
  selector:
    app: nginx-example
  ports:
  - port: 80
    targetPort: 80

---
# 3. Ingress roteia o tráfego
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: mafinfo.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-example-service
            port:
              number: 80
```

## Regras de Roteamento

### **1. Roteamento por Domínio**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-domain-ingress
spec:
  rules:
  - host: app1.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### **2. Roteamento por Path**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-based-ingress
spec:
  rules:
  - host: exemplo.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

### **3. Path Types**

| **Tipo** | **Descrição** | **Exemplo** |
|----------|---------------|-------------|
| **Exact** | Caminho exato | `/api/v1` |
| **Prefix** | Prefixo (mais comum) | `/api` |
| **ImplementationSpecific** | Específico do controller | Depende do controller |

### **4. Annotations (Anotações)**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: annotated-ingress
  annotations:
    # Rewrite target (nginx)
    nginx.ingress.kubernetes.io/rewrite-target: /
    
    # SSL redirect
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    
    # Rate limiting
    nginx.ingress.kubernetes.io/rate-limit: "100"
    
    # CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    
    # Custom headers
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Custom-Header "Hello World";
spec:
  rules:
  - host: exemplo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## Ingress Controllers

### **Nginx Ingress Controller (Padrão de Mercado)**

**Vantagens:**
- ✅ **Mais popular** e estável
- ✅ **Documentação extensa**
- ✅ **Muitas annotations**
- ✅ **Suporte a SSL/TLS**
- ✅ **Rate limiting**
- ✅ **CORS**
- ✅ **WebSocket**

**📚 Repositório oficial:**
- **GitHub**: https://github.com/kubernetes/ingress-nginx
- **Documentação**: https://kubernetes.github.io/ingress-nginx/
- **Annotations**: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/

**Instalação no Kind:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### **Outras opções:**

| **Controller** | **Características** | **Uso** | **Links** |
|----------------|---------------------|---------|-----------|
| **Traefik** | Auto-discovery, dashboard | Microserviços | [GitHub](https://github.com/traefik/traefik) |
| **HAProxy** | Alta performance | Carga alta | [GitHub](https://github.com/haproxytech/kubernetes-ingress) |
| **Istio Gateway** | Service mesh | Arquiteturas complexas | [Istio](https://istio.io/latest/docs/tasks/traffic-management/ingress/) |
| **AWS ALB** | Integração AWS | EKS | [AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html) |
| **GCP Ingress** | Integração GCP | GKE | [GCP Docs](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress) |

## Configuração no Kind

### **1. Criar cluster com port mapping**

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: michel-test-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
```

### **2. Criar cluster**

```bash
kind create cluster --config kind-config.yaml
```

### **3. Instalar nginx-ingress-controller**

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### **4. Aguardar controller ficar pronto**

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## Exemplo Prático Completo

### **Cenário: Duas aplicações no mesmo cluster**

```yaml
# app1-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: app1
        image: nginx:latest
        ports:
        - containerPort: 80

---
# app1-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app1-service
spec:
  selector:
    app: app1
  ports:
  - port: 80
    targetPort: 80

---
# app2-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: app2
        image: httpd:latest
        ports:
        - containerPort: 80

---
# app2-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app2-service
spec:
  selector:
    app: app2
  ports:
  - port: 80
    targetPort: 80

---
# multi-app-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-app-ingress
spec:
  rules:
  - host: app1.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
```

### **Aplicar e testar:**

```bash
# Aplicar manifestos
kubectl apply -f app1-deployment.yaml
kubectl apply -f app1-service.yaml
kubectl apply -f app2-deployment.yaml
kubectl apply -f app2-service.yaml
kubectl apply -f multi-app-ingress.yaml

# Testar
curl -H "Host: app1.local" http://localhost/
curl -H "Host: app2.local" http://localhost/
```

## Testando Domínios Localmente

### **🔧 Configuração do /etc/hosts**

Para testar domínios localmente, você precisa configurar o arquivo `/etc/hosts` do seu sistema:

#### **1. Editar o arquivo hosts**

**Linux/macOS:**
```bash
sudo nano /etc/hosts
```

**Windows:**
```
C:\Windows\System32\drivers\etc\hosts
```

#### **2. Adicionar entradas para seus domínios**

```bash
# Adicionar estas linhas no final do arquivo
127.0.0.1 app1.local
127.0.0.1 app2.local
127.0.0.1 mafinfo.io
127.0.0.1 exemplo.com
```

#### **3. Salvar e testar**

```bash
# Testar resolução DNS
ping app1.local
ping mafinfo.io

# Testar no navegador
# http://app1.local/
# http://mafinfo.io/
```

### **📋 Exemplo completo de teste:**

#### **1. Configurar Ingress com múltiplos domínios**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-domain-ingress
spec:
  rules:
  - host: app1.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app1-service
            port:
              number: 80
  - host: app2.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app2-service
            port:
              number: 80
  - host: mafinfo.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

#### **2. Configurar /etc/hosts**

```bash
# Editar arquivo hosts
sudo nano /etc/hosts

# Adicionar:
127.0.0.1 app1.local
127.0.0.1 app2.local
127.0.0.1 mafinfo.io
```

#### **3. Aplicar e testar**

```bash
# Aplicar Ingress
kubectl apply -f multi-domain-ingress.yaml

# Testar com curl
curl http://app1.local/
curl http://app2.local/
curl http://mafinfo.io/

# Testar no navegador
# Abrir: http://app1.local/
# Abrir: http://mafinfo.io/
```

### **🔍 Verificações importantes:**

#### **1. Verificar se o domínio resolve**

```bash
# Testar resolução DNS
nslookup app1.local
# Deve retornar: 127.0.0.1

# Testar ping
ping app1.local
# Deve responder do 127.0.0.1
```

#### **2. Verificar se o Ingress está funcionando**

```bash
# Verificar Ingress
kubectl get ingress

# Verificar detalhes
kubectl describe ingress multi-domain-ingress

# Verificar se o controller está processando
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

#### **3. Testar conectividade**

```bash
# Testar com curl (simula navegador)
curl -v http://app1.local/
# Deve retornar HTML da aplicação

# Testar com wget
wget -O- http://mafinfo.io/
```

### **⚠️ Troubleshooting comum:**

#### **Problema: Domínio não resolve**

```bash
# Verificar se está no /etc/hosts
cat /etc/hosts | grep app1.local

# Verificar permissões do arquivo
ls -la /etc/hosts

# Recarregar configuração DNS
sudo systemctl restart systemd-resolved  # Linux
sudo dscacheutil -flushcache             # macOS
```

#### **Problema: Ingress não funciona**

```bash
# Verificar se o controller está rodando
kubectl get pods -n ingress-nginx

# Verificar logs do controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verificar se o Ingress foi criado
kubectl get ingress
```

#### **Problema: Aplicação não carrega**

```bash
# Testar Service diretamente
kubectl port-forward svc/app1-service 8080:80
curl http://localhost:8080

# Verificar se os pods estão rodando
kubectl get pods -l app=app1
```

### **🎯 Dicas importantes:**

1. **Sempre use domínios `.local`** para testes locais
2. **Reinicie o navegador** após editar /etc/hosts
3. **Use `curl -v`** para ver headers HTTP completos
4. **Verifique logs** do nginx-ingress-controller
5. **Teste Services** diretamente antes do Ingress

### **📱 Exemplo de teste completo:**

```bash
# 1. Configurar hosts
echo "127.0.0.1 app1.local app2.local mafinfo.io" | sudo tee -a /etc/hosts

# 2. Aplicar manifestos
kubectl apply -f day-10/

# 3. Verificar status
kubectl get ingress
kubectl get pods

# 4. Testar domínios
curl http://app1.local/        # Aplicação 1
curl http://app2.local/        # Aplicação 2  
curl http://mafinfo.io/        # Nginx

# 5. Abrir no navegador
# http://app1.local/
# http://mafinfo.io/
```

**Agora você pode testar múltiplos domínios localmente como se fossem reais!** 🌐

## Balanceamento de Carga

### **Como funciona:**

1. **Ingress Controller** recebe requisição
2. **Aplica regras** de roteamento
3. **Seleciona Service** baseado no host/path
4. **Service** distribui entre os pods
5. **Pod** processa requisição

### **Algoritmos de balanceamento:**

| **Algoritmo** | **Descrição** | **Uso** |
|---------------|---------------|---------|
| **Round Robin** | Distribui sequencialmente | Padrão |
| **Least Connections** | Menor número de conexões | Carga variável |
| **IP Hash** | Baseado no IP do cliente | Sessões persistentes |
| **Weighted** | Baseado em pesos | Pods com capacidades diferentes |

### **Configuração de balanceamento:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: balanced-ingress
  annotations:
    nginx.ingress.kubernetes.io/upstream-hash-by: "$binary_remote_addr"
spec:
  rules:
  - host: exemplo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## Troubleshooting

### **Problemas comuns:**

#### **1. Ingress não funciona**

```bash
# Verificar se o controller está rodando
kubectl get pods -n ingress-nginx

# Verificar logs do controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Verificar se o Ingress foi criado
kubectl get ingress

# Verificar detalhes do Ingress
kubectl describe ingress meu-ingress
```

#### **2. Service não encontrado**

```bash
# Verificar se o Service existe
kubectl get svc

# Verificar se o Service tem pods
kubectl get pods -l app=minha-app

# Verificar se os labels coincidem
kubectl get svc minha-app -o yaml
kubectl get pods -l app=minha-app --show-labels
```

#### **3. Domínio não resolve**

```bash
# Testar com curl
curl -H "Host: meu-dominio.com" http://localhost/

# Verificar se o domínio está no Ingress
kubectl get ingress -o wide

# Testar diretamente o Service
kubectl port-forward svc/minha-app 8080:80
curl http://localhost:8080
```

#### **4. SSL/TLS não funciona**

```bash
# Verificar certificado
kubectl get secret

# Verificar annotations do Ingress
kubectl get ingress meu-ingress -o yaml

# Verificar logs do controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

## Comandos Úteis

### **Verificar status**

```bash
# Listar Ingresses
kubectl get ingress

# Descrever Ingress específico
kubectl describe ingress meu-ingress

# Verificar Services
kubectl get svc

# Verificar Pods
kubectl get pods

# Verificar logs do controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### **Testar conectividade**

```bash
# Testar com curl
curl -H "Host: meu-dominio.com" http://localhost/

# Testar Service diretamente
kubectl port-forward svc/minha-app 8080:80
curl http://localhost:8080

# Testar Pod diretamente
kubectl port-forward pod/meu-pod 8080:80
curl http://localhost:8080
```

### **Debugging**

```bash
# Verificar eventos
kubectl get events --sort-by=.metadata.creationTimestamp

# Verificar configuração do nginx
kubectl exec -n ingress-nginx deployment/ingress-nginx-controller -- cat /etc/nginx/nginx.conf

# Verificar métricas
kubectl top pods -n ingress-nginx
```

## Boas Práticas

### **1. Nomenclatura**

```yaml
# ✅ Bom
metadata:
  name: web-app-ingress
  labels:
    app: web-app
    component: ingress

# ❌ Ruim
metadata:
  name: ingress1
  labels: {}
```

### **2. Organização**

```yaml
# ✅ Usar namespaces
apiVersion: v1
kind: Namespace
metadata:
  name: production

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-app-ingress
  namespace: production
spec:
  rules:
  - host: app.production.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

### **3. SSL/TLS**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - app.exemplo.com
    secretName: app-tls-secret
  rules:
  - host: app.exemplo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

### **4. Monitoramento**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitored-ingress
  annotations:
    nginx.ingress.kubernetes.io/enable-access-log: "true"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      access_log /var/log/nginx/access.log;
      error_log /var/log/nginx/error.log;
spec:
  rules:
  - host: app.exemplo.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app-service
            port:
              number: 80
```

## Resumo

### **🎯 O que aprendemos:**

1. **Ingress** é o recurso para exposição externa de serviços
2. **Service** é para comunicação interna, **Ingress** é para externa
3. **nginx-ingress-controller** é o padrão de mercado
4. **Kind** precisa de port mapping para funcionar
5. **Roteamento** por domínio e path é poderoso
6. **Balanceamento de carga** é automático
7. **Troubleshooting** é essencial para produção


