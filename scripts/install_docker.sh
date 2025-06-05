#!/bin/bash

set -e

echo "Update package index..."
sudo apt update

echo "Install prerequisites..."
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "Add Docker’s official GPG key..."
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "Set up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Update package index again..."
sudo apt update

echo "Install Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Verify Docker installation..."
docker --version

echo "Add current user to docker group (so you can run docker without sudo)..."
sudo usermod -aG docker $USER

echo "Done. Please logout and login again (or restart) for group changes to take effect."
