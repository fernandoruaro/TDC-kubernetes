# TDC-kubernetes

Primeiramente será necessário ter terraform instalado para que possamos provisionar a infraestrutura:
(https://www.terraform.io/intro/getting-started/install.html)

Para começar, vamos criar um Key Pair no painel da AWS com o nome de `TDC`. Essa chave será usada para acessarmos os servidores.

Mova a chave para a pasta ~/.ssh/ no seu computador.

Instale as seguintes dependências:

``` shell
sudo apt-get -y -q install awscli jq
```

Configure suas credenciais da AWS:

``` shell
export AWS_ACCESS_KEY_ID=SEU_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=SEU_AWS_SECRET_ACCESS_KEY
export AWS_REGION=us-east-1
```

Agora é só rodar o arquivo de instalação.

``` shell
./install.sh
```
