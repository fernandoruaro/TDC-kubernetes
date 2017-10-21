#!/bin/bash
sudo su

function download_kube_module(){
  MODULE=$1
  echo "Downloading ${MODULE}"
  wget -q -O /usr/bin/${MODULE} https://storage.googleapis.com/kubernetes-release/release/v1.5.3/bin/linux/amd64/${MODULE}
  chmod 0755 /usr/bin/${MODULE}
  echo "Downloading ${MODULE} finished"
}
function move_certificate(){
  CERTIFICATE=$1
  cp /tmp/${CERTIFICATE} /var/lib/kubernetes/${CERTIFICATE}
  chmod 0644 /var/lib/kubernetes/${CERTIFICATE}
}

function move_service(){
  SERVICE=$1
  cp /tmp/${SERVICE}.service /etc/systemd/system/${SERVICE}.service
  chmod 700 /etc/systemd/system/${SERVICE}.service
}


mkdir -p /var/lib/kubernetes/

move_certificate "kubernetes.pem"
move_certificate "kubernetes-key.pem"
move_certificate "ca.pem"

mkdir -p /usr/kubernetes/
cp /tmp/authorization-policy.jsonl /usr/kubernetes/authorization-policy.jsonl
chmod 0644 /usr/kubernetes/authorization-policy.jsonl
cp /tmp/token.csv /usr/kubernetes/token.csv
chmod 0644 /usr/kubernetes/authorization-policy.jsonl

download_kube_module "kube-apiserver"
download_kube_module "kube-controller-manager"
download_kube_module "kube-scheduler"
download_kube_module "kubectl"

move_service "kube-apiserver"
move_service "kube-controller-manager"
move_service "kube-scheduler"

#kube-scheduler

systemctl daemon-reload

systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler

systemctl restart kube-apiserver
systemctl restart kube-controller-manager
systemctl restart kube-scheduler
