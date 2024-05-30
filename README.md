# Prometheus

Este projeto tem como objetivo documentar e compartilhar o conhecimento adquiridido durante os meus estudos sobre o Kubernetes


## Referências

 - [Treinamento LinuxTips PICK](https://www.linuxtips.io/pick)
 - [Documentação oficial Kubernetes](https://kubernetes.io/docs/home/)


Para termos maior compreensão do Kubernetes, precisamos entender alguns componentes que são essenciais para seu funcionamento.

## O que é um Container Engine?

Um container engine é um serviço responsável por criar containers. Alguns dos exemplos mais conhecidos são o Docker e o Podman. Ele fornece a funcionalidade básica de empacotamento de aplicações e suas dependências em containers portáteis e leves.

## O que é um Container Runtime?

Um container runtime é um serviço responsável por executar os containers. Ele interage com o Kernel do sistema operacional e envia as informações para o containerd, que é um daemon que gerencia o ciclo de vida dos containers. Exemplos de runtimes incluem `runc` e `CRI-O`.

## O que é OCI?

Open Container Initiative (OCI) é uma organização fundada por diversas empresas do setor de tecnologia com o objetivo de padronizar a criação de containers. O principal objetivo da OCI é garantir a compatibilidade entre diferentes container engines e runtimes, estabelecendo padrões abertos para a criação, execução e especificação de containers.

### Componentes Principais da OCI

1. **OCI Runtime Specification**: Define como os runtimes de containers devem comportar-se ao executar um container.
2. **OCI Image Specification**: Define o formato das imagens de containers, facilitando a criação e o compartilhamento de imagens de containers entre diferentes plataformas e ferramentas.

## Relação entre Container Engine, Runtime e OCI no Kubernetes

No Kubernetes, o container engine e o container runtime desempenham papéis cruciais para a orquestração de containers:

- **Container Engine**: Utilizado para criar e gerenciar as imagens dos containers.
- **Container Runtime**: Utilizado para executar e gerenciar o ciclo de vida dos containers em execução nos nós do cluster.
- **OCI**: Garante que as imagens de containers e os runtimes sejam compatíveis, permitindo que Kubernetes funcione de maneira eficiente com diferentes tecnologias de container.

Compreender esses componentes e suas funções é fundamental para gerenciar e operar clusters Kubernetes de maneira eficaz.

