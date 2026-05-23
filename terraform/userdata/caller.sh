#!/bin/bash

apt update -y
apt install -y git curl unzip nodejs npm

cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git

cd slm-deploy/quickstart/workers/caller-worker

npm install

cat > /etc/systemd/system/caller-worker.service <<EOF
[Unit]
Description=Caller Worker
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/slm-deploy/quickstart/workers/caller-worker
Environment=III_URL=ws://10.0.0.174:49134
ExecStart=/usr/bin/npm run dev
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable caller-worker
systemctl start caller-worker