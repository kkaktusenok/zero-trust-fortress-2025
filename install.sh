#!/bin/bash
set -e  # Exit on any error

echo -e "\n🛡️ Zero-Trust Fortress 2025 — Day 1 Setup"
echo "============================================"

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install core prerequisites
echo "Installing core tools: Docker, WireGuard, UFW, etc..."
sudo apt install -y curl wget git docker.io docker-compose ufw wireguard qrencode nftables

# Enable and start Docker service
echo "Enabling Docker service..."
sudo systemctl enable --now docker

# Add current user to docker group (no sudo needed after relogin)
echo "Adding user to docker group..."
sudo usermod -aG docker $USER

# Create basic directories
echo "Creating project directories..."
mkdir -p config/wireguard config/authelia services backup docs/screenshots

echo -e "\n✅ Day 1 complete! Relogin (or run 'newgrp docker') to use Docker without sudo."
echo "Next: Day 2 — WireGuard VPN + zero open ports."
echo "Run 'bash install.sh' again after relogin to continue."
