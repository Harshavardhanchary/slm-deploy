#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

sudo apt install -y \
    nodejs \
    git \
    unzip

node -v
npm -v