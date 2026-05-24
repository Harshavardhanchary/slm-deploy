#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y git curl unzip

cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git

curl -fsSL https://iii.sh/install.sh | bash

echo 'export PATH=$HOME/.local/bin:$PATH' >> /home/ubuntu/.bashrc

mkdir -p /home/ubuntu/.ssh

cat <<EOF >/home/ubuntu/.ssh/id_rsa
${ssh_private_key}
EOF

chmod 600 /home/ubuntu/.ssh/id_rsa
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

cat <<EOF >> /home/ubuntu/.ssh/config
Host *
    StrictHostKeyChecking no
EOF

chown ubuntu:ubuntu /home/ubuntu/.ssh/config

cat <<EOF >/etc/systemd/system/iii.service
[Unit]
Description=III Engine
After=network-online.target
Wants=network-online.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/slm-deploy/quickstart
Environment="PATH=/home/ubuntu/.local/bin:/usr/bin:/bin"
ExecStart=/home/ubuntu/.local/bin/iii
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable iii
sudo systemctl start iii