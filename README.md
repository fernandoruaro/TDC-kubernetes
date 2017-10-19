# TDC-kubernetes

Primeiramente será necessário ter terraform instalado para que possamos provisionar a infraestrutura:
(https://www.terraform.io/intro/getting-started/install.html)

Para começar, vamos criar um Key Pair no painel da AWS com o nome de `TDC`. Essa chave será usada para acessarmos os servidores.


``` shell
export AWS_ACCESS_KEY_ID=SEU_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=SEU_AWS_SECRET_ACCESS_KEY
export AWS_REGION=us-east-1
```

Para verificar o que será criado na AWS:

``` shell
(cd terraform; terraform plan)
```

Para confirmar/aplicar:

``` shell
(cd terraform; terraform apply)
```

Instalar ETCD
``` shell
export ETCD_PUBLIC_IP=$(cd terraform; terraform output etcd_public_ip)
ssh -i ~/.ssh/TDC.pem ubuntu@${ETCD_PUBLIC_IP} 'bash -s' < scripts/docker.sh
ssh -i ~/.ssh/TDC.pem ubuntu@${ETCD_PUBLIC_IP} 'bash -s' < scripts/etcd.sh
```


Instalar Master
``` shell
export MASTER_PUBLIC_IP=$(cd terraform; terraform output master_public_ip)
```


Instalar Minions
``` shell
export MINION_PUBLIC_IPS=$(cd terraform; terraform output minion_public_ips)

for MINION_IP in $(echo $MINION_PUBLIC_IPS | sed "s/,/ /g")
do
    echo "$MINION_IP"
done
```
