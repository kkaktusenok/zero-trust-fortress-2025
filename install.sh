#!/bin/bash
set -e

echo -e "\n🛡️ Zero-Trust Fortress 2025 — Full Auto Install"
echo "======================================================="

# Step 1: Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install required tools
echo "Installing ufw, git, curl, etc..."
sudo apt install -y ufw curl wget git

# Step 3: Install Docker (clean way)
echo "Installing Docker..."
sudo apt remove --purge containerd containerd.io runc docker.io docker-compose -y || true
sudo apt autoremove -y
sudo apt install -y docker.io docker-compose
sudo systemctl unmask docker.service docker.socket
sudo systemctl enable --now docker || echo "Docker service will start after reboot or manual fix"
sudo usermod -aG docker $USER

# Step 4: Install Tailscale via snap
echo "Installing Tailscale via snap..."
sudo snap install tailscale || echo "Tailscale snap already installed"

# Step 5: Start Tailscale
echo "Starting Tailscale..."
sudo tailscale up || echo "Tailscale already authenticated"

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "YOUR_TAILSCALE_IP")
echo "Your Tailscale IP: $TAILSCALE_IP"

# Step 6: Create project directories
echo "Creating project directories..."
mkdir -p config/wireguard config/authelia services/{traefik,homepage/config} backup docs/screenshots

# Step 7: Firewall lockdown
echo "Applying firewall lockdown..."
sudo ufw default deny incoming --force
sudo ufw default allow outgoing --force
sudo ufw --force enable
sudo ufw reload || true

# Step 8: Create docker-compose.yml with Glances
echo "Creating docker-compose.yml with Traefik, Homepage and Glances..."
sudo tee services/docker-compose.yml > /dev/null << 'EOF'
services:
  traefik:
    image: traefik:v3.1
    container_name: traefik
    restart: unless-stopped
    command:
      - "--entrypoints.web.address=:80"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--log.level=INFO"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - fortress

  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    restart: unless-stopped
    environment:
      - HOMEPAGE_ALLOWED_HOSTS=*
    volumes:
      - ./homepage/config:/app/config
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.homepage.rule=PathPrefix(`/`)"
      - "traefik.http.services.homepage.loadbalancer.server.port=3000"
    networks:
      - fortress

  glances:
    image: nicolargo/glances:latest-full
    container_name: glances
    restart: unless-stopped
    pid: host
    network_mode: host
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - GLANCES_OPT=--webserver

networks:
  fortress:
    driver: bridge
EOF

# Step 9: Create Homepage config with Monitoring widgets
echo "Creating Homepage configuration with Monitoring widgets..."
sudo tee services/homepage/config/settings.yaml > /dev/null << 'EOF'
title: Zero-Trust Fortress
theme: dark
headerStyle: clean
EOF

sudo tee services/homepage/config/services.yaml > /dev/null << 'EOF'
- Fortress Services:
    - Homepage:
        icon: homepage
        href: /
        description: Secure Dashboard

- Monitoring:
    - Glances Full:
        icon: glances
        href: http://100.93.158.108:61208
        description: Full System Monitor

    - CPU Load:
        widget:
          type: glances
          url: http://100.93.158.108:61208
          metric: cpu

    - RAM Usage:
        widget:
          type: glances
          url: http://100.93.158.108:61208
          metric: mem

    - Disk Usage:
        widget:
          type: glances
          url: http://100.93.158.108:61208
          metric: disk

    - Network:
        widget:
          type: glances
          url: http://100.93.158.108:61208
          metric: network
EOF

# Step 10: Start containers
echo "Starting Traefik + Homepage + Glances..."
cd services
docker compose up -d --force-recreate || echo "Containers failed — run manually: docker compose up -d"
cd ..

echo -e "\n🛡️ INSTALLATION COMPLETE!"
echo "Open dashboard: http://$TAILSCALE_IP"
echo "Glances full monitor: http://$TAILSCALE_IP:61208"
echo "If Docker not running — reboot or run: sudo systemctl restart docker"