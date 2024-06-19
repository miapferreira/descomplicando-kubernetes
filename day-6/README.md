# Kubernetes Persistent Storage

No Kubernetes, os conceitos de Persistent Volume (PV), Persistent Volume Claim (PVC) e Storage Class são usados para gerenciar o armazenamento persistente para os pods. Aqui está uma descrição de cada um:

## Persistent Volume (PV)

O Persistent Volume (PV) é um pedaço de armazenamento no cluster que foi provisionado por um administrador. É um recurso no cluster, assim como um nó é um recurso de cluster. PVs são volumes independentes do ciclo de vida de qualquer pod que usa o PV.

## Persistent Volume Claim (PVC)

O Persistent Volume Claim (PVC) é um pedido de armazenamento feito por um usuário. Os PVCs consomem PVs. PVCs podem solicitar tamanhos específicos e modos de acesso (como podem ser montados). Um PVC será vinculado a um PV que satisfaça os critérios de pedido (tamanho, modos de acesso, etc.).

## Storage Class

A Storage Class é uma forma de descrever os "tipos" de armazenamento que podem ser solicitados. Diferentes classes podem mapear para diferentes qualidades de serviço, políticas de backup ou políticas de provisionamento. Administradores podem definir tantas Storage Classes quanto necessário.

## Como Eles Interagem

1. **Definir uma Storage Class:** Define a política de provisionamento de armazenamento, por exemplo, o tipo de disco e o sistema de arquivos.
2. **Criar um PVC:** Um usuário ou aplicação define um PVC, especificando o tamanho e a classe de armazenamento desejados. O Kubernetes procura um PV que satisfaça essa reivindicação ou cria um novo PV usando a Storage Class especificada.
3. **Associar um PVC a um PV:** Se um PV apropriado estiver disponível, o PVC será vinculado a ele. Se não, um novo PV será provisionado com base na Storage Class.
4. **Usar o PVC em um Pod:** O PVC é então usado por um Pod para obter acesso ao armazenamento persistente.
