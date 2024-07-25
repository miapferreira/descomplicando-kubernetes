# Secrets no Kubernetes

Os secrets têm o objetivo de fornecer uma maneira segura de armazenar e gerenciar informações sensíveis dentro do cluster, como senhas, tokens, chaves SSH, entre outros dados que você não quer expor nas configurações da sua aplicação.

## Algumas informações de como os secrets funcionam:

- São armazenados no etcd e, por padrão, são armazenados sem criptografia.
- Seu acesso é restrito por meio de Role-Based Access Control (RBAC), o que permite controlar quais usuários e pods podem acessar quais secrets.
- Os secrets podem ser montados em pods como arquivos e volumes ou podem ser utilizados para preencher variáveis de ambiente.

## Tipos de Secrets

### Opaque secrets
São os mais simples e comuns, armazenando dados como chaves de API, senhas e tokens.
São codificados em base64, mas não são criptografados. Por conta disso, não são seguros para armazenar informações altamente sensíveis.

### kubernetes.io/service-account-token
São utilizados para armazenar tokens de acesso de contas de serviço.

### kubernetes.io/dockercfg e kubernetes.io/dockerconfigjson
São utilizados para armazenar credenciais de registro do Docker.

### kubernetes.io/tls, kubernetes.io/ssh-auth e kubernetes.io/basic-auth
São utilizados para armazenar certificados TLS, chaves SSH e credenciais de autenticação básica.

### bootstrap.kubernetes.io/token
São utilizados para armazenar tokens de inicialização do cluster.

## Criando um secret do tipo Opaque

Transformar a senha "giropops" e o usuário "ruberval" em base64.
Seus respectivos outputs já codificados serão os valores utilizados no secrets.

```sh
# Transformar a senha "giropops" em base64
echo -n "giropops" | base64

# Transformar o usuário "ruberval" em base64
echo -n "ruberval" | base64
