#!/bin/bash

apt update -y
apt install -y git curl unzip python3 python3-pip python3-venv

cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git

cd slm-deploy/quickstart/workers/inference-worker

python3 -m venv venv

source venv/bin/activate

pip install -r requirements.txt

cat > /etc/systemd/system/inference-worker.service <<EOF
[Unit]
Description=Inference Worker
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/slm-deploy/quickstart/workers/inference-worker
Environment=III_URL=ws://10.0.0.174:49134
ExecStart=/home/ubuntu/slm-deploy/quickstart/workers/inference-worker/venv/bin/python inference_worker.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable inference-worker
systemctl start inference-worker