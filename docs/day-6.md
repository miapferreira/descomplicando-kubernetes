# Day 6: Kubernetes Persistent Storage

## Visão Geral

No Kubernetes, os conceitos de **Persistent Volume (PV)**, **Persistent Volume Claim (PVC)** e **Storage Class** são fundamentais para gerenciar o armazenamento persistente para os pods. Vamos explorar cada um desses componentes e como eles interagem.

## Persistent Volume (PV)

O **Persistent Volume (PV)** é um pedaço de armazenamento no cluster que foi provisionado por um administrador. É um recurso no cluster, assim como um nó é um recurso de cluster. PVs são volumes independentes do ciclo de vida de qualquer pod que usa o PV.

### Características do PV:
- **Independente do Pod**: O PV existe independentemente do pod que o utiliza
- **Recurso de Cluster**: É um recurso no nível do cluster
- **Provisionamento Manual**: Geralmente criado pelo administrador
- **Políticas de Reclaim**: Define o que acontece com os dados quando o PV é liberado

### Exemplo de PV:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    storage: lento
  name: pv-lento
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce # Tem acesso de leitura e escrita para um único node
  persistentVolumeReclaimPolicy: Retain # Retém os dados após a remoção do volume
  hostPath:
    path: /mnt/data
  storageClassName: giropops
```

## Persistent Volume Claim (PVC)

O **Persistent Volume Claim (PVC)** é um pedido de armazenamento feito por um usuário. Os PVCs consomem PVs. PVCs podem solicitar tamanhos específicos e modos de acesso (como podem ser montados). Um PVC será vinculado a um PV que satisfaça os critérios de pedido (tamanho, modos de acesso, etc.).

### Características do PVC:
- **Solicitação de Armazenamento**: Define o que o usuário precisa
- **Vinculação com PV**: É vinculado a um PV que satisfaça os critérios
- **Independente do Pod**: Pode ser reutilizado por diferentes pods
- **Seletor de Labels**: Pode especificar PVs específicos através de labels

### Exemplo de PVC:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    pvc: my-pvc
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: giropops
  selector:
    matchLabels:
      storage: lento
```

## Storage Class

A **Storage Class** é uma forma de descrever os "tipos" de armazenamento que podem ser solicitados. Diferentes classes podem mapear para diferentes qualidades de serviço, políticas de backup ou políticas de provisionamento. Administradores podem definir tantas Storage Classes quanto necessário.

### Características da Storage Class:
- **Provisionamento Dinâmico**: Pode provisionar PVs automaticamente
- **Políticas de Reclaim**: Define o que acontece com os dados
- **Modo de Vinculação**: Define quando o PV é criado
- **Provisionadores**: Define como o armazenamento é provisionado

### Provisionadores Comuns:

- **kubernetes.io/aws-ebs**: AWS Elastic Block Store (EBS)
- **kubernetes.io/azure-disk**: Azure Disk
- **kubernetes.io/gce-pd**: Google Compute Engine (GCE) Persistent Disk
- **kubernetes.io/cinder**: OpenStack Cinder
- **kubernetes.io/vsphere-volume**: vSphere
- **kubernetes.io/no-provisioner**: Volumes locais (sem provisionamento automático)
- **kubernetes.io/host-path**: Volumes locais

### Exemplo de Storage Class:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: giropops
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
```

## Modos de Acesso (Access Modes)

- **ReadWriteOnce (RWO)**: Leitura e escrita por um único node
- **ReadOnlyMany (ROX)**: Leitura por múltiplos nodes
- **ReadWriteMany (RWM)**: Leitura e escrita por múltiplos nodes

## Políticas de Reclaim (Reclaim Policy)

- **Retain**: Mantém os dados após a remoção do PV
- **Delete**: Remove os dados quando o PV é deletado
- **Recycle**: Limpa os dados e disponibiliza o volume para reuso

## Como Eles Interagem

### Fluxo de Trabalho:

1. **Definir uma Storage Class**: Define a política de provisionamento de armazenamento
2. **Criar um PV**: Administrador cria um volume persistente
3. **Criar um PVC**: Usuário solicita armazenamento através de um PVC
4. **Vinculação**: Kubernetes vincula o PVC ao PV apropriado
5. **Uso no Pod**: O PVC é usado pelo Pod para acessar o armazenamento

### Exemplo Prático - Nginx com Armazenamento Persistente:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: nginx-storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: nginx-storage
    persistentVolumeClaim:
      claimName: my-pvc
```

### Exemplo Prático - Redis Deployment com Armazenamento Persistente:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: redis
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - image: redis
        name: redis
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-storage
          mountPath: /data
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: my-pvc
```

## Exemplo com NFS

Para volumes NFS, você pode criar um PV que aponte para um servidor NFS:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  labels:
    storage: nfs
  name: meu-pv-nfs
spec:
  capacity:
   storage: 1Gi
  accessModes:
   - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: 192.168.1.100
    path: /private/tmp/nfs
  storageClassName: nfs-storage
```

## Comandos Úteis

```bash
# Listar Storage Classes
kubectl get storageclass

# Listar Persistent Volumes
kubectl get pv

# Listar Persistent Volume Claims
kubectl get pvc

# Descrever um PV
kubectl describe pv <nome-do-pv>

# Descrever um PVC
kubectl describe pvc <nome-do-pvc>

# Aplicar os recursos
kubectl apply -f storageclass.yaml
kubectl apply -f pv.yaml
kubectl apply -f pvc.yaml
kubectl apply -f nginx.yaml
```

## Benefícios do Armazenamento Persistente

1. **Persistência de Dados**: Os dados sobrevivem ao ciclo de vida dos pods
2. **Portabilidade**: Aplicações podem ser movidas entre nodes
3. **Escalabilidade**: Múltiplos pods podem compartilhar o mesmo volume
4. **Flexibilidade**: Diferentes tipos de armazenamento para diferentes necessidades
5. **Isolamento**: Cada aplicação pode ter seu próprio espaço de armazenamento

## Considerações Importantes

- **Backup**: Sempre tenha estratégias de backup para dados importantes
- **Performance**: Escolha o tipo de armazenamento adequado para sua aplicação
- **Custos**: Diferentes tipos de armazenamento têm custos diferentes
- **Disponibilidade**: Considere a disponibilidade do armazenamento para sua aplicação
- **Segurança**: Implemente políticas de segurança adequadas para seus dados
