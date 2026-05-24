#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y git curl unzip

cd /home/ubuntu || exit

# Clone repo only if not present
if [ ! -d "/home/ubuntu/slm-deploy" ]; then
    git clone https://github.com/Harshavardhanchary/slm-deploy.git
fi

# Install III
sudo -u ubuntu bash -c 'curl -fsSL https://iii.sh/install.sh | bash'

# Verify install
if [ ! -f "/home/ubuntu/.local/bin/iii" ]; then
    echo "III install failed"
    exit 1
fi

sudo chmod +x /home/ubuntu/.local/bin/iii

# Add PATH
grep -qxF 'export PATH=$HOME/.local/bin:$PATH' /home/ubuntu/.bashrc || \
echo 'export PATH=$HOME/.local/bin:$PATH' >> /home/ubuntu/.bashrc

# SSH setup
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

# Create service
sudo tee /etc/systemd/system/iii.service > /dev/null <<EOF
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

# Start service
sudo systemctl restart iii

# Debug info
sudo systemctl status iii --no-pager || true
ls -l /home/ubuntu/.local/bin/iii || true
