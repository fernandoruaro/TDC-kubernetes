MASTER_PUBLIC_IP=$1

cat > tmp/kubeconfig << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: http://${MASTER_PUBLIC_IP}:8080
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet
current-context: kubelet
users:
- name: kubelet
  user:
    token: kubelet123
EOF
