#!/bin/bash

apt update -y
apt install -y git curl unzip python3 python3-pip python3-venv nodejs npm

cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git

cd Alchemy-ai-slm-deploy/quickstart

curl -fsSL https://iii.sh/install.sh | bash

cat > /etc/systemd/system/iii.service <<EOF
[Unit]
Description=III Engine
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/slm-deploy/quickstart
ExecStart=/home/ubuntu/.local/bin/iii
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable iii
systemctl start iii