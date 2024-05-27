# Comandos Úteis do kubectl

Aqui estão alguns comandos úteis do `kubectl` para gerenciar seus pods no Kubernetes.

- `kubectl get pods`: Verifica o número de pods em execução.
- `kubectl get pods -A`: Lista o número de pods de todos os namespaces.
- `kubectl get pods -o wide`: Traz informações mais detalhadas dos pods.
- `kubectl get pods -o yaml`: Traz detalhes do pod em formato yaml.
- `kubectl get pods -o yaml > file.yaml`: Salva as informações do pod em arquivo yaml.
- `kubectl run strigus --image nginx --port 80`: Inicia um novo pod chamado "strigus".
- `kubectl run -ti girus --image alpine`: Cria o pod "girus" e abre um terminal em modo de interação.

Sinta-se à vontade para usar esses comandos para gerenciar seus pods no Kubernetes.
