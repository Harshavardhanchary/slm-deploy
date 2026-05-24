#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git curl unzip nodejs npm

cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git

cd slm-deploy/quickstart/workers/caller-worker

npm install

sudo cat > /etc/systemd/system/caller-worker.service <<EOF
[Unit]
Description=Caller Worker
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/slm-deploy/quickstart/workers/caller-worker
Environment="III_URL=${iii_url}"
ExecStart=/usr/bin/npm start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable caller-worker
sudo systemctl start caller-worker