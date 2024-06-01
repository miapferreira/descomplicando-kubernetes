# Comandos úteis para gerenciar o deployment

1. **kubectl get deployments** - verifica o número de deployments em execução.
   
2. **kubectl get deployments -n giropops -o wide** - traz maiores detalhes sobre o deployment em execução. A opção **-n** especifica o namespace.

3. **kubectl apply -f deployment.yaml** - aplica um novo deployment.

4. **kubectl describe deployments nginx-deployment** - traz detalhes sobre o deployment em execução.
