MASTER_PUBLIC_IP=$1

cat > tmp/kubelet.service << EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --allow-privileged=true \\
  --api-servers=http://${MASTER_PUBLIC_IP}:8080 \\
  --cluster-dns=10.100.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=docker \\
  --docker=unix:///var/run/docker.sock \\
  --network-plugin=kubenet \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --reconcile-cidr=true \\
  --serialize-image-pulls=false \\
  --v=2

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
