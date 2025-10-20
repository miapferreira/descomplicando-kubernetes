#!/bin/bash

echo "🚀 Iniciando teste de HPA com Locust"
echo "=================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se kubectl está disponível
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl não encontrado. Por favor, instale o kubectl."
    exit 1
fi

print_status "1. Aplicando configurações do nginx..."
kubectl apply -f deployment.yaml

print_status "2. Aplicando HPA..."
kubectl apply -f primeiro-hpa.yaml

print_status "3. Aplicando ConfigMap do Locust..."
kubectl apply -f locust-configmap.yaml

print_status "4. Aplicando Deployment do Locust..."
kubectl apply -f locust-deployment.yaml

print_status "5. Aplicando Service do Locust..."
kubectl apply -f locust-service.yaml

print_status "6. Aguardando pods ficarem prontos..."
kubectl wait --for=condition=ready pod -l app=nginx --timeout=60s
kubectl wait --for=condition=ready pod -l app=locust --timeout=60s

print_success "Todos os recursos foram aplicados com sucesso!"

echo ""
print_status "📊 Status dos recursos:"
echo "========================"

echo ""
print_status "Pods do nginx:"
kubectl get pods -l app=nginx

echo ""
print_status "Pods do Locust:"
kubectl get pods -l app=locust

echo ""
print_status "HPA:"
kubectl get hpa

echo ""
print_status "Services:"
kubectl get svc -l app=nginx
kubectl get svc -l app=locust

echo ""
print_warning "🎯 Próximos passos para testar o HPA:"
echo "============================================="
echo ""
echo "1. Acesse a interface do Locust:"
echo "   http://localhost:30089"
echo ""
echo "2. Configure o teste no Locust:"
echo "   - Number of users: 50-100"
echo "   - Spawn rate: 10"
echo "   - Host: http://nginx:80"
echo ""
echo "3. Monitore o HPA em tempo real:"
echo "   watch kubectl get hpa"
echo ""
echo "4. Monitore os pods:"
echo "   watch kubectl get pods"
echo ""
echo "5. Para ver logs detalhados do HPA:"
echo "   kubectl describe hpa nginx-hpa"
echo ""

print_status "🔍 Comandos úteis para monitoramento:"
echo "========================================="
echo ""
echo "# Ver status do HPA"
echo "kubectl get hpa nginx-hpa -w"
echo ""
echo "# Ver métricas detalhadas"
echo "kubectl top pods -l app=nginx"
echo ""
echo "# Ver eventos do cluster"
echo "kubectl get events --sort-by='.lastTimestamp'"
echo ""
echo "# Ver logs do Locust"
echo "kubectl logs -f deployment/locust"
echo ""

print_success "Setup completo! Agora você pode testar o HPA com o Locust! 🎉"
