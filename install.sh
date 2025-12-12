#!/bin/bash
set -e  # Exit on any error

echo -e "\n🛡️ Zero-Trust Fortress 2025 — Day 2: WireGuard + Zero Open Ports"
echo "=================================================================="

# Run Day 1 prerequisites if not already done
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git docker.io docker-compose ufw wireguard qrencode nftables
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
mkdir -p config/wireguard config/authelia services backup docs/screenshots

# Generate WireGuard keys (server and default client)
echo "Generating WireGuard keys..."
wg genkey | tee config/wireguard/server_private.key | wg pubkey > config/wireguard/server_public.key
wg genkey | tee config/wireguard/client_private.key | wg pubkey > config/wireguard/client_public.key

SERVER_PRIVATE=$(cat config/wireguard/server_private.key)
CLIENT_PUBLIC=$(cat config/wireguard/client_public.key)
CLIENT_PRIVATE=$(cat config/wireguard/client_private.key)
SERVER_PUBLIC=$(cat config/wireguard/server_public.key)

# Create server config (wg0.conf)
cat > config/wireguard/wg0.conf << EOF
[Interface]
Address = 10.8.0.1/24
PrivateKey = $SERVER_PRIVATE
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC
AllowedIPs = 10.8.0.2/32
EOF

# Enable IP forwarding permanently
echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# Start WireGuard interface
echo "Starting WireGuard (wg0)..."
sudo cp config/wireguard/wg0.conf /etc/wireguard/wg0.conf
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0

# Full port lockdown: deny all incoming except WireGuard UDP 51820
echo "Locking down all ports (only WireGuard 51820/udp allowed)..."
sudo ufw reset --force
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 51820/udp comment 'WireGuard'
sudo ufw --force enable

# Verification
echo -e "\nVerification: Open ports (should show ONLY WireGuard or nothing visible externally)"
ss -tuln
echo "UFW status:"
sudo ufw status verbose

# Generate client config file
CLIENT_CONFIG="client-wg0.conf"
cat > $CLIENT_CONFIG << EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.8.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = YOUR_SERVER_PUBLIC_IP:51820   # <<< REPLACE WITH YOUR REAL PUBLIC IP !!!
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Display QR code for mobile import
echo -e "\nClient config saved as: $CLIENT_CONFIG"
echo "QR code for WireGuard mobile app:"
qrencode -t ansiutf8 < $CLIENT_CONFIG

echo -e "\n✅ Day 2 COMPLETE!"
echo "Next steps:"
echo "1. Edit $CLIENT_CONFIG: replace YOUR_SERVER_PUBLIC_IP with your real server IP (or domain)"
echo "2. Import config to WireGuard client (phone/PC) via QR or file"
echo "3. Connect — SSH will work ONLY through VPN!"
echo "4. Test from outside: direct SSH should fail, but through VPN — succeed"
