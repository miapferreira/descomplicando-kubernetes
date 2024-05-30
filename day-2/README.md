# Limites de Utilização nos Pods

Podemos definir limites de recursos em nossos pods por CPU e memória.

## Diferença entre Limits e Requests

- **limits**: Limite máximo estabelecido de recurso que um pod poderá utilizar.
- **requests**: Limite mínimo necessário para que o pod possa ser iniciado. O Kubernetes garante a reserva desses recursos na inicialização do pod. Por exemplo, se um pod tem um request de 100Mi de memória, esse recurso já será reservado para o pod na sua inicialização.

# Persistindo Informações no Pod

## emptyDir

No Kubernetes, o `emptyDir` é um tipo de volume que é usado para fornecer armazenamento temporário a um pod. Este tipo de volume é criado quando o pod é agendado em um nó e existe enquanto o pod estiver em execução no nó. Quando o pod é removido (ou reiniciado), o conteúdo do `emptyDir` é apagado permanentemente.

### Características do emptyDir

- **Criado ao iniciar o pod**: O volume `emptyDir` é criado vazio quando o pod é iniciado.
- **Compartilhado entre containers do mesmo pod**: Todos os containers do pod podem acessar o volume `emptyDir`, permitindo o compartilhamento de dados entre os containers.
- **Apagado ao terminar o pod**: Quando o pod é deletado ou reiniciado, o conteúdo do `emptyDir` é apagado.
- **Armazenamento temporário**: Ideal para dados temporários que não precisam persistir após o ciclo de vida do pod, como caches temporários, dados intermediários, etc.
