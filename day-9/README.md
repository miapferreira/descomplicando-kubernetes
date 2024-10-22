Instalar cluster EKS

Primeiro é necessário instlalar o eksctl

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

Precisamos configurar o kubectl para utilizar o nosso cluster EKS
aws eks --region us-east-1 update-kubeconfig --name eks-cluster


eksctl create cluster --name=eks-cluster --version=1.24 --region=us-east-1 --nodegroup-name=eks-cluster-nodegroup --node-type=t3.medium --nodes=2 --nodes-min=1 --nodes-max=3 --managed

Para validar 

eksctl get cluster -A

Para deletar
eksctl delete cluster --name=eks-cluster -r us-east-1

Instalando o Kube-Prometheus

git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus

kubectl create -f manifests/setup
kubectl apply -f manifests/
kubectl get pods -n monitoring