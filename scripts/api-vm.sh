#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install -y \
    curl \
    git \
    unzip

curl -fsSL https://install.iii.dev/iii/main/install.sh | sh

echo 'export PATH=$HOME/.local/bin:$PATH' >> /home/ubuntu/.bashrc

export PATH=$HOME/.local/bin:$PATH

/home/ubuntu/.local/bin/iii --version

##Repo clone and setup
cd /home/ubuntu

git clone https://github.com/Harshavardhanchary/slm-deploy.git