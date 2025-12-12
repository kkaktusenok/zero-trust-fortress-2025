# 🛡️ Zero-Trust Fortress 2025
**Zero open ports · WireGuard + 2FA only · One command deploy**

One command turns your VPS/Ubuntu into an impenetrable fortress:
```bash
curl -sSL https://raw.githubusercontent.com/kkaktusenok/zero-trust-fortress-2025/main/install.sh | bash
```

### What This Project Does
*   **Zero open ports** to the internet (even SSH is closed externally)
    
*   **Access only via WireGuard VPN + 2FA** (Authelia with TOTP/YubiKey)
    
*   **Protected self-hosted services** (Open WebUI, Homepage, Vaultwarden, Jellyfin, etc.) behind Authelia
    
*   **CrowdSec intrusion prevention** + Watchtower auto-updates + encrypted backups
    
*   **Telegram alerts** for logins, bans, and issues
    
### Project Status
| Day | Task | Status |
| --- | --- | --- |
| 1 | Repo setup + basic install.sh | ✅ Done |
| 2 | WireGuard + full port lockdown | ⏳ In Progress |
| 3 | Traefik + Tailscale/Cloudflare Tunnel | ⏳ |
| 4 | Authelia 2FA + service protection | ⏳ |
| 5 | CrowdSec + finalization + demo | ⏳ |
### **Goal:** Fully ready by December 17, 2025 — portfolio-ready for Upwork.
### Demo (coming soon)
*   ss -tuln → empty (no listening ports!)
    
*   Brute-force attempt → instant ban + Telegram alert
    
*   Login flow: WireGuard → Authelia 2FA → secure dashboard
    
### Prerequisites
*   Ubuntu 22.04/24.04 or Debian 12
    
*   Root/sudo access
    
*   Clean server (recommended)
    
### Quick Start
1.  Run the installer (will guide you step by step)
    
2.  Connect via generated WireGuard client (QR code provided)
    
3.  Access protected services through the internal dashboard
    
### Security Notes
*   Never commit real keys or secrets (handled by .gitignore)
    
*   All sensitive data is generated during installation
    
*   Designed for production-grade security
    
### Contributing
Contributions welcome! Feel free to open issues or PRs.

### License
MIT License — free to use, modify, and deploy commercially.

* * *
_Built for homelabs, small businesses, and security-conscious developers. Turn any server into a fortress in minutes._
