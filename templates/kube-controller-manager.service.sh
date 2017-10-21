MASTER_PUBLIC_IP=$1

cat > tmp/kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-controller-manager \\
  --allocate-node-cidrs=true \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --leader-elect=true \\
  --master=http://${MASTER_PUBLIC_IP}:8080 \\
  --service-cluster-ip-range=10.100.0.0/24 \\
  --service-account-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
