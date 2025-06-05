#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install required dependencies
sudo apt install -y git python3 python3-venv python3-pip wget

# Stop and disable Nginx if it's running
sudo systemctl stop nginx 2>/dev/null || true
sudo systemctl disable nginx 2>/dev/null || true
sudo pkill -f nginx || true

# Set up workspace
sudo mkdir -p /workspace
sudo chmod -R 777 /workspace
cd /workspace
# Clone and install ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# Clone and install ComfyUI-Manager inside custom_nodes
sudo mkdir -p custom_nodes
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
pip install -r requirements.txt

# Set execution permission
chmod +x /workspace/ComfyUI/main.py

# Kill any process using port 3001
fuser -k 3001/tcp || true

# Run ComfyUI on port 3001
nohup /workspace/ComfyUI/venv/bin/python /workspace/ComfyUI/main.py --listen --port 3001 > /workspace/ComfyUI.log 2>&1 &
