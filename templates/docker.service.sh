cat > tmp/docker.service << EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
ExecStart=/usr/bin/docker daemon \
  --graph=/mnt/docker \
  --iptables=false \
  --ip-masq=false \
  --host=unix:///var/run/docker.sock \
  --log-level=error \
  --log-opt max-size=50m \
  --default-ulimit nofile=65536:65536
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
