# TDC-kubernetes

Primeiramente será necessário ter terraform instalado para que possamos provisionar a infraestrutura:
(https://www.terraform.io/intro/getting-started/install.html)

Para começar, vamos criar um Key Pair no painel da AWS com o nome de `TDC`. Essa chave será usada para acessarmos os servidores.

`export AWS_ACCESS_KEY_ID=SEU_AWS_ACCESS_KEY_ID`
`export AWS_SECRET_ACCESS_KEY=SEU_AWS_SECRET_ACCESS_KEY`
`export AWS_REGION=us-east-1`

Para verificar o que será criado na AWS:
`(cd terraform; terraform plan)`
Para confirmar:
`(cd terraform; terraform apply)`

Instalar ETCD
`export ETCD_PUBLIC_IP=$(cd terraform; terraform output etcd_public_ip)`
`ssh -i ~/.ssh/TDC.pem ubuntu@${ETCD_PUBLIC_IP} 'bash -s' < scripts/docker.sh`
`ssh -i ~/.ssh/TDC.pem ubuntu@${ETCD_PUBLIC_IP} 'bash -s' < scripts/etcd.sh`


Instalar Master
`export MASTER_PUBLIC_IP=$(cd terraform; terraform output master_public_ip)`
