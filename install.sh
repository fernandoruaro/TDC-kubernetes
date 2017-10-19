#!/bin/bash

#Terraform
(cd terraform; terraform apply)

#ETCD
ETCD_PUBLIC_IP=$(cd terraform; terraform output etcd_public_ip)

echo "Waiting for etcd server to reply on port 22"
until [ $(nc -z $ETCD_PUBLIC_IP 22; echo "$?") == 0 ]; do
    printf '.'
    sleep 1
done;
printf '\n'

ssh-keygen -R ${ETCD_PUBLIC_IP}
ssh-keyscan -H ${ETCD_PUBLIC_IP} >> ~/.ssh/known_hosts
ssh -i ~/.ssh/TDC.pem ubuntu@${ETCD_PUBLIC_IP} 'bash -s' < scripts/docker.sh
ssh -i ~/.ssh/TDC.pem ubuntu@${ETCD_PUBLIC_IP} 'bash -s' < scripts/etcd.sh
