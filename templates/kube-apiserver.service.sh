#!/bin/bash

ETCD_PUBLIC_IP=$1
MASTER_PUBLIC_IP=$2

cat > tmp/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-apiserver \\
  --admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota \\
  --advertise-address=${MASTER_PUBLIC_IP} \\
  --allow-privileged=true \\
  --apiserver-count=1 \\
  --authorization-mode=ABAC \\
  --bind-address=0.0.0.0 \\
  --enable-swagger-ui=false \\
  --insecure-bind-address=0.0.0.0 \\
  --etcd-servers=http://${ETCD_PUBLIC_IP}:2379 \\
  --service-cluster-ip-range=10.100.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --runtime-config=batch/v2alpha1 \\
  --storage-backend=etcd2 \\
  --authorization-policy-file=/usr/kubernetes/authorization-policy.jsonl \\
  --token-auth-file=/usr/kubernetes/token.csv \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --service-account-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
