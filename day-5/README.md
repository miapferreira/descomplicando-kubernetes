# O que são Probes no Kubernetes?

Probes no Kubernetes são verificações periódicas executadas pelo kubelet (o agente que roda em cada nó do cluster) para monitorar a saúde dos containers em um Pod. Com base nos resultados dessas verificações, o Kubernetes pode tomar ações automáticas, como reiniciar o container ou removê-lo do balanceador de carga, para garantir a alta disponibilidade e confiabilidade dos aplicativos.

Existem três tipos principais de probes:

## Liveness Probe

- **Propósito**: Verificar se o container está funcionando corretamente.
- **Ação em caso de falha**: Se a probe falhar, o kubelet irá reiniciar o container. Isso ajuda a recuperar automaticamente de falhas que deixariam o container em um estado inconsistente ou não funcional.
- **Uso comum**: Verificar se o processo principal do container está rodando, verificar a saúde geral do aplicativo.

## Readiness Probe

- **Propósito**: Verificar se o container está pronto para receber tráfego.
- **Ação em caso de falha**: Se a probe falhar, o container será removido dos serviços de balanceamento de carga. Isso assegura que apenas containers prontos e aptos para processar requisições recebam tráfego.
- **Uso comum**: Verificar se o aplicativo está pronto para servir solicitações, como se todas as dependências foram carregadas ou se a inicialização foi concluída corretamente.

## Startup Probe

- **Propósito**: Verificar se o container iniciou corretamente.
- **Ação em caso de falha**: Se a probe falhar, o kubelet irá reiniciar o container. É usada para substituir a liveness probe durante a fase de inicialização do container.
- **Uso comum**: Para aplicativos que têm um tempo de inicialização longo, garantindo que a aplicação tenha tempo suficiente para inicializar antes que outras probes (como liveness e readiness) comecem a executar.