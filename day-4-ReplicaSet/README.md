# Kubernetes Workloads

## ReplicaSet

No Kubernetes, o **ReplicaSet** é o recurso responsável por garantir que um número específico de réplicas de um pod esteja rodando a qualquer momento. O ReplicaSet monitora o estado dos pods e, se um pod falhar ou for removido, ele cria um novo pod para manter o número desejado de réplicas. Normalmente, um ReplicaSet é criado automaticamente quando criamos um Deployment.

## DaemonSet

No Kubernetes, um **DaemonSet** garante que uma cópia de um pod específico esteja rodando em todos (ou alguns) nós do cluster. Ele é utilizado para implementar pods que precisam estar presentes em cada nó, como agentes de monitoramento, coletores de logs, ou serviços de rede. Isso assegura que pelo menos uma réplica do pod esteja rodando em cada nó especificado.
