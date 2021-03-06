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
  mkdir -p /var/lib/kubernetes/
  CERTIFICATE=$1
  cp /tmp/${CERTIFICATE} /var/lib/kubernetes/${CERTIFICATE}
  chmod 0644 /var/lib/kubernetes/${CERTIFICATE}
}
function move_service(){
  SERVICE=$1
  cp /tmp/${SERVICE}.service /etc/systemd/system/${SERVICE}.service
  chmod 700 /etc/systemd/system/${SERVICE}.service
}

function move_docker_service(){
  SERVICE=$1
  cp /usr/local/src/docker/docker/${SERVICE} /usr/bin/${SERVICE}
  chmod 0755 /usr/bin/${SERVICE}
}

function install_docker(){
  wget -q -O /usr/local/src/docker-1.11.2.tgz https://get.docker.com/builds/Linux/x86_64/docker-1.11.2.tgz
  mkdir -p /usr/local/src/docker/
  tar -xvzf /usr/local/src/docker-1.11.2.tgz -C /usr/local/src/docker/
  move_docker_service "docker"
  move_docker_service "docker-containerd"
  move_docker_service "docker-containerd-ctr"
  move_docker_service "docker-containerd-shim"
  move_docker_service "docker-runc"
}

install_docker

move_certificate "kubernetes.pem"
move_certificate "kubernetes-key.pem"
move_certificate "ca.pem"

wget -q -O /usr/local/src/cni-c864f0e1ea73719b8f4582402b0847064f9883b0.tar.gz https://storage.googleapis.com/kubernetes-release/network-plugins/cni-c864f0e1ea73719b8f4582402b0847064f9883b0.tar.gz
mkdir -p /opt/cni/
tar -xvzf /usr/local/src/cni-c864f0e1ea73719b8f4582402b0847064f9883b0.tar.gz -C /opt/cni/
echo "PATH=$PATH:/opt/cni/bin" >> /etc/profile

mkdir -p /var/lib/kubelet
cp /tmp/kubeconfig /var/lib/kubelet/kubeconfig

download_kube_module "kubelet"
download_kube_module "kube-proxy"
download_kube_module "kubectl"

move_service "docker"
move_service "kubelet"
move_service "kube-proxy"

systemctl daemon-reload

systemctl enable docker
systemctl enable kubelet
systemctl enable kube-proxy

systemctl restart docker
systemctl restart kubelet
systemctl restart kube-proxy
