#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
    python3-pip \
    python3-venv \
    git \
    unzip

python3 --version