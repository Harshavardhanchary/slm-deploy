#!/bin/bash

set -e

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y git curl unzip

cd /home/ubuntu

# Clone repo
git clone https://github.com/Harshavardhanchary/slm-deploy.git || true

# Install III as ubuntu user
sudo -u ubuntu bash -c 'curl -fsSL https://iii.sh/install.sh | bash'

# Ensure binary is executable
sudo chmod +x /home/ubuntu/.local/bin/iii

# Verify install
ls -l /home/ubuntu/.local/bin/iii

# Add PATH for ubuntu shell sessions
echo 'export PATH=$HOME/.local/bin:$PATH' >> /home/ubuntu/.bashrc

# Setup SSH
mkdir -p /home/ubuntu/.ssh

cat <<EOF >/home/ubuntu/.ssh/id_rsa
${ssh_private_key}
EOF

chmod 600 /home/ubuntu/.ssh/id_rsa

cat <<EOF >/home/ubuntu/.ssh/config
Host *
    StrictHostKeyChecking no
EOF

chmod 600 /home/ubuntu/.ssh/config
chmod 700 /home/ubuntu/.ssh

chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/iii.service
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
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable iii

# Small wait before start
sleep 5

# Start service
sudo systemctl start iii

# Show service status
sudo systemctl status iii --no-pager
