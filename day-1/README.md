# Comandos Úteis do kubectl

Aqui estão alguns comandos úteis do `kubectl` para gerenciar seus pods no Kubernetes.

- `kubectl get pods`: Verifica o número de pods em execução.
- `kubectl get pods -A`: Lista os pods de todos os namespaces.
- `kubectl get pods -o wide`: Exibe informações mais detalhadas dos pods.
- `kubectl get pods -o yaml`: Exibe detalhes do pod em formato YAML.
- `kubectl get pods -o yaml > file.yaml`: Salva as informações do pod em um arquivo YAML.
- `kubectl run strigus --image nginx --port 80`: Inicia um novo pod chamado "strigus" com a imagem nginx na porta 80.
- `kubectl run -ti girus --image alpine`: Cria o pod "girus" e abre um terminal interativo.
- `kubectl run girus-1 --image alpine --dry-run=client -o yaml > pod.yaml`: Simula a criação do pod em modo dry run e salva as configurações em um arquivo YAML.
- `kubectl apply -f pod.yaml`: Cria um novo pod de acordo com as configurações do arquivo YAML.
- `kubectl delete -f pod.yaml`: Remove um pod em execução utilizando o arquivo YAML.
- `kubectl logs girus-1`: Visualiza os logs do pod "girus-1".
- `kubectl describe pods giropops` Utilizado para exibir detalhes de um pod especifico.

Sinta-se à vontade para usar esses comandos para gerenciar seus pods no Kubernetes.
