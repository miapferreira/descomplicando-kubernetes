# Definição de Deployment

O deployment é responsável por armazenar todas as informações e parâmetros da aplicação, além de gerenciar os pods associados a ela. Por meio do deployment, é possível realizar operações como atualização, reinicialização, escalonamento e modificação de qualquer parâmetro relacionado à nossa aplicação.

# Estratégias de Atualização para o Deployment:

## RollingUpdate:

- É a estratégia padrão do deployment no Kubernetes.

## Surge:

- Define quantos pods a mais é permitido ter em relação ao número definido no arquivo.

## Unavailable:

- Define a quantidade de pods a serem atualizados por vez. Por exemplo, se Unavailable=2, significa que os pods serão atualizados de dois em dois.

## Recreate:

- Mata todos os pods de uma vez e sobe a nova versão. Recomendado quando a aplicação não pode rodar em versões diferentes, porém causa indisponibilidade.

Esta é uma documentação de exemplo que pode ser utilizada no GitHub para explicar as estratégias de atualização no Kubernetes.


# Comandos úteis para gerenciar o deployment

1. **kubectl get deployments** - verifica o número de deployments em execução.
   
2. **kubectl get deployments -n giropops -o wide** - traz maiores detalhes sobre o deployment em execução. A opção **-n** especifica o namespace.

3. **kubectl apply -f deployment.yaml** - aplica um novo deployment.

4. **kubectl describe deployments nginx-deployment** - traz detalhes sobre o deployment em execução.

## Rollback: 
- **kubectl rollout undo deployment -n giropops nginx-deployment** - Realiza rollback de uma versão anterior do nosso deployment.

- **kubectl rollout history deployment -n giropops nginx-deployment** - Traz o histórico de deployments aplicados.

- **kubectl rollout history deployment -n giropops nginx-deployment --revision 6** - Traz o histórico de deployments aplicados e o comando --revision 6 traz detalhes da versão específica.

- **kubectl rollout restart deployment -n giropops nginx-deployment** - Realiza o restart do deployment da aplicação.

- **kubectl scale deployment -n giropops --replicas 11 nginx-deployment** - Realiza o scale de réplicas do deployment.



