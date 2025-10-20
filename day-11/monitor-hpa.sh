#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Monitoramento do HPA - Pressione Ctrl+C para sair${NC}"
echo "=================================================="

while true; do
    clear
    echo -e "${GREEN}📊 $(date)${NC}"
    echo "=================================================="
    
    echo -e "\n${YELLOW}🏷️  HPA Status:${NC}"
    kubectl get hpa nginx-hpa
    
    echo -e "\n${YELLOW}📈 CPU/Memory dos Pods Nginx:${NC}"
    kubectl top pods -l app=nginx
    
    echo -e "\n${YELLOW}🔢 Contagem de Pods:${NC}"
    kubectl get pods -l app=nginx --no-headers | wc -l | xargs echo "Total de pods nginx:"
    
    echo -e "\n${YELLOW}⚡ Consumo por Node:${NC}"
    kubectl top nodes
    
    echo -e "\n${BLUE}⏱️  Atualizando em 5 segundos... (Ctrl+C para sair)${NC}"
    sleep 5
done
