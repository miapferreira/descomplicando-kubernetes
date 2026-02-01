# Day 12 - Kyverno: Políticas para Kubernetes

## O que é Kyverno?

O **Kyverno** é um motor de políticas para Kubernetes que permite **validar**, **mutar** e **gerar** recursos de forma declarativa. Ele roda como um **admission controller** no cluster e avalia ou modifica recursos no momento em que são criados ou atualizados.

- **Validar** recursos (bloquear ou alertar quando não seguem regras)
- **Mutar** recursos (alterar automaticamente antes de persistir no etcd)
- **Gerar** recursos (criar novos recursos em resposta a eventos, ex.: novo Namespace)
- **Políticas em YAML** (sem necessidade de linguagem de programação)
- **Integração nativa** com a API do Kubernetes

### 🎯 **Analogia simples:**
Imagine o Kyverno como um **"fiscal e assistente"** na porta do cluster:
- **Valida** se quem entra está dentro das regras (ex.: Pod com limites de recursos)
- **Ajusta** automaticamente o que pode ser corrigido (ex.: adicionar labels em Namespaces)
- **Provisiona** coisas que devem existir (ex.: criar um ConfigMap em todo novo Namespace)

## Para que serve o Kyverno?

- **Segurança**: Garantir que Pods não rodem como root, que imagens venham de registries permitidos, etc.
- **Padronização**: Exigir labels, limites de CPU/memória, ou adicionar labels em recursos.
- **Automação**: Criar ConfigMaps, NetworkPolicies, RoleBindings quando um Namespace é criado.
- **Governança**: Centralizar regras em ClusterPolicies/Policy em vez de scripts ou processos manuais.

## Como funciona o Kyverno?

1. **Admission controller**: O API server do Kubernetes envia requisições (create/update) para o Kyverno via webhooks.
2. **Match**: O Kyverno verifica se o recurso corresponde ao `match` da política (kind, namespace, etc.).
3. **Ação**: Conforme o tipo de regra, o Kyverno **valida** (aceita/rejeita), **muta** (aplica patch) ou agenda **generate** (cria recurso em background).
4. **Resultado**: O recurso é aceito (e opcionalmente alterado) ou a requisição é rejeitada com a mensagem configurada na política.

## Tipos de políticas

| Tipo       | Função                                      | Exemplo                                      |
|-----------|---------------------------------------------|----------------------------------------------|
| **validate** | Bloquear ou reportar recursos que não seguem o padrão | Exigir `resources.limits` em todos os Pods   |
| **mutate**   | Alterar o recurso antes de ser persistido   | Adicionar label em todo Namespace            |
| **generate** | Criar novos recursos quando algo acontece   | Criar ConfigMap em todo novo Namespace       |

## Documentação oficial

📖 **[Kyverno – Documentation](https://kyverno.io/docs/)**

- [Installation](https://kyverno.io/docs/installation/)
- [Writing Policies](https://kyverno.io/docs/writing-policies/)
- [Generate Rules](https://kyverno.io/docs/writing-policies/generate/)

---

## Instalação do Kyverno do zero

O Kyverno deve ser instalado em um **namespace dedicado** (por exemplo, `kyverno`). Não instale no `kube-system` nem junto com outras aplicações no mesmo namespace.

### **Requisitos**

- Cluster Kubernetes (versões suportadas conforme [compatibility matrix](https://kyverno.io/docs/installation/))
- `kubectl` configurado
- Opcional: **Helm 3** (recomendado para produção)

### **Método 1: YAML (rápido para testes)**

```bash
# Criar namespace e instalar com o manifest oficial
kubectl create namespace kyverno
kubectl apply -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml

# Verificar pods
kubectl get pods -n kyverno
```

### **Método 2: Helm (recomendado para produção)**

```bash
# Adicionar repositório e instalar
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace

# Verificar
kubectl get pods -n kyverno
```

### **Instalação em alta disponibilidade (Helm)**

```bash
helm install kyverno kyverno/kyverno -n kyverno --create-namespace \
  --set admissionController.replicas=3 \
  --set backgroundController.replicas=2 \
  --set cleanupController.replicas=2 \
  --set reportsController.replicas=2
```

### **Verificar se o Kyverno está funcionando**

```bash
# Pods no namespace kyverno
kubectl get pods -n kyverno

# ClusterPolicies instaladas (após aplicar as suas)
kubectl get clusterpolicies

# Logs do admission controller (em caso de dúvida)
kubectl logs -n kyverno -l app.kubernetes.io/name=kyverno
```

### **Desinstalação (YAML)**

```bash
kubectl delete -f https://github.com/kyverno/kyverno/releases/latest/download/install.yaml
kubectl delete namespace kyverno
```

### **Desinstalação (Helm)**

```bash
helm uninstall kyverno -n kyverno
kubectl delete namespace kyverno
```

---

## Estrutura de arquivos do Day 12

Os exemplos de políticas que criamos no repositório estão em:

```
day-12/
├── add-label-namespace.yaml      # Mutate: adiciona label em Namespaces
├── generate-cm-add-namespace.yaml # Generate: ConfigMap em todo novo Namespace
├── require-resources-limits.yaml  # Validate: exige limits em Pods
├── root-disable.yaml              # Validate: exige runAsNonRoot em Pods
└── pod.yaml                       # Pod de exemplo (compatível com as políticas)
```

---

## Exemplos de políticas do Day 12

### **1. add-label-namespace.yaml (mutate)**

**O que faz:** Toda vez que um **Namespace** é criado, o Kyverno **adiciona** o label `app: application_test` no metadata do Namespace.

**Uso:** Padronizar labels em namespaces para organização, custo ou seleção (ex.: NetworkPolicies, métricas).

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: add-label-namespace
spec:
  rules:
    - name: add-label-namespace
      match:
        resources:
          kinds:
            - Namespace
      mutate:
        patchStrategicMerge:
          metadata:
            labels:
              app: application_test
```

**Aplicar e testar:**

```bash
kubectl apply -f day-12/add-label-namespace.yaml
kubectl create namespace teste-labels
kubectl get namespace teste-labels -o yaml   # deve mostrar o label app: application_test
```

---

### **2. generate-cm-add-namespace.yaml (generate)**

**O que faz:** Quando um **Namespace** é criado, o Kyverno **gera** um ConfigMap chamado `config-map-namespace` dentro desse namespace, com as chaves `key1` e `key2`.

**Uso:** Provisionar configuração padrão (variáveis, endpoints) em todo novo namespace.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: generate-cm-add-namespace
spec:
  rules:
    - name: generate-cm-add-namespace
      match:
        resources:
          kinds:
            - Namespace
      generate:
        apiVersion: v1
        kind: ConfigMap
        name: config-map-namespace
        namespace: "{{request.object.metadata.name}}"
        data:
          data:
            key1: "GiroPops"
            key2: "Strigus"
```

**Aplicar e testar:**

```bash
kubectl apply -f day-12/generate-cm-add-namespace.yaml
kubectl create namespace teste-cm
kubectl get configmap -n teste-cm
kubectl get configmap config-map-namespace -n teste-cm -o yaml
```

**Nota:** A variável `{{request.object.metadata.name}}` é o nome do recurso que disparou a regra (o novo Namespace). O namespace do ConfigMap gerado será esse nome.

---

### **3. require-resources-limits.yaml (validate)**

**O que faz:** **Valida** que todo **Pod** tenha em todos os containers `resources.limits` definidos para `cpu` e `memory`. Se faltar, a criação/atualização do Pod é **bloqueada** (`enforce`).

**Uso:** Evitar que workloads consumam recursos sem limite e afetem o cluster.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resources-limits
spec:
  validationFailureAction: enforce
  rules:
    - name: validate-limits
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Pod must have resources limits"
        pattern:
          spec:
            containers:
              - name: "*"
                resources:
                  limits:
                    cpu: "?*"
                    memory: "?*"
```

**Aplicar e testar:**

```bash
kubectl apply -f day-12/require-resources-limits.yaml

# Pod SEM limits – deve ser rejeitado
kubectl run nginx-sem-limits --image=nginx
# Expected: Error from server: admission webhook ... Pod must have resources limits

# Pod COM limits – deve ser aceito (ex.: pod.yaml)
kubectl apply -f day-12/pod.yaml
kubectl get pod pod-example
```

---

### **4. root-disable.yaml (validate)**

**O que faz:** **Valida** que todo **Pod** tenha em todos os containers `securityContext.runAsNonRoot: true`. Se não tiver, a criação/atualização do Pod é **bloqueada**.

**Uso:** Reforçar segurança evitando que containers rodem como root.

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: root-disable
spec:
  validationFailureAction: enforce
  rules:
    - name: check-runAsNonRoot
      match:
        resources:
          kinds:
            - Pod
      validate:
        message: "Root is not allowed"
        pattern:
          spec:
            containers:
              - securityContext:
                  runAsNonRoot: true
```

**Aplicar e testar:**

```bash
kubectl apply -f day-12/root-disable.yaml

# Pod sem runAsNonRoot – deve ser rejeitado
kubectl run nginx-root --image=nginx
# Expected: Error from server: admission webhook ... Root is not allowed

# Pod com runAsNonRoot e com limits (ex.: pod.yaml precisa ser ajustado)
# Adicione securityContext.runAsNonRoot: true nos containers para passar.
```

---

### **5. pod.yaml (recurso de exemplo)**

**O que faz:** Define um Pod de exemplo com **resources limits/requests** configurados, compatível com a política `require-resources-limits`. Útil para testar as políticas de validação.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-example
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      limits:
        cpu: "101m"
        memory: "128Mi"
      requests:
        cpu: "50m"
        memory: "64Mi"
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```

Para que esse Pod também passe na política **root-disable**, adicione no container:

```yaml
securityContext:
  runAsNonRoot: true
```

---

## Ordem sugerida para aplicar as políticas

1. Instalar o Kyverno (YAML ou Helm).
2. Aplicar políticas de **mutate** e **generate** (não bloqueiam recursos existentes):
   - `add-label-namespace.yaml`
   - `generate-cm-add-namespace.yaml`
3. Testar criando um namespace e verificando label e ConfigMap.
4. Aplicar políticas de **validate** (podem bloquear Pods sem limites ou sem runAsNonRoot):
   - `require-resources-limits.yaml`
   - `root-disable.yaml`
5. Criar/ajustar Pods (ex.: `pod.yaml`) para cumprir as regras e validar que são aceitos.

---

## validationFailureAction: enforce vs audit

- **enforce** (padrão em nossos exemplos): recurso que não passa na validação é **rejeitado** pelo API server.
- **audit**: recurso é **aceito**, mas o Kyverno registra uma violação (útil para Policy Reports e para testar políticas sem bloquear ainda).

Exemplo para modo audit:

```yaml
spec:
  validationFailureAction: audit
  rules:
    - name: validate-limits
      ...
```

---

## Conclusão

O Kyverno é uma ferramenta essencial para **governança e padronização** no Kubernetes. Com ele você pode:

- **Validar** recursos (segurança e padrões, ex.: limits e runAsNonRoot)
- **Mutar** recursos (padronizar labels, annotations, etc.)
- **Gerar** recursos (provisionar ConfigMaps, NetworkPolicies, etc. em novos namespaces)

### **Próximos passos**

- Explorar [Policy Library](https://kyverno.io/policies/) do Kyverno
- Testar **generate** com `synchronize: true` e `generateExisting: true`
- Integrar com **Policy Reports** para relatórios de conformidade
- Estudar **exceptions** e **preconditions** para políticas mais refinadas

---

**📚 Recursos adicionais**

- [Kyverno – Documentation](https://kyverno.io/docs/)
- [Kyverno – Installation](https://kyverno.io/docs/installation/)
- [Kyverno – Writing Policies](https://kyverno.io/docs/writing-policies/)
- [Kyverno – Generate Rules](https://kyverno.io/docs/writing-policies/generate/)
