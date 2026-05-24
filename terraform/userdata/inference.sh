#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git curl unzip python3 python3-pip python3-venv

cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git

cd slm-deploy/quickstart/workers/inference-worker

python3 -m venv venv

source venv/bin/activate

sudo pip install -r requirements.txt

sudo cat > /etc/systemd/system/inference-worker.service <<EOF
[Unit]
Description=Inference Worker
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/slm-deploy/quickstart/workers/inference-worker
Environment="III_URL=${iii_url}"
ExecStart=/home/ubuntu/slm-deploy/quickstart/workers/inference-worker/venv/bin/python inference_worker.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable inference-worker
sudo systemctl start inference-worker