#!/usr/bin/env bash
# server.sh — node-specific provisioning for the server VM
# Configures: web server, DNS stub, SSH host config for client access
# Idempotent: safe to run multiple times
set -euxo pipefail

# ─── Install server-side packages ─────────────────────────────
dnf install -y \
  httpd \
  nginx \
  dnsmasq \
  rsync

# ─── Configure dnsmasq as local DNS for the lab ──────────────
# Resolves: server.corp.local -> 192.168.56.20
#           client.corp.local -> 192.168.56.10
cat > /etc/dnsmasq.d/corp-local.conf << 'DNS_EOF'
# Lab DNS entries for ITSC-1316 network lab
address=/server.corp.local/192.168.56.20
address=/client.corp.local/192.168.56.10
address=/fileserver.corp.local/192.168.56.20
local=/corp.local/
DNS_EOF

# Override resolv.conf so the server itself uses dnsmasq
# dnsmasq reads /etc/hosts as upstream when local=/corp.local/
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "search corp.local" >> /etc/resolv.conf

systemctl enable --now dnsmasq

# ─── Simple web server on port 80 ────────────────────────────
# Create a minimal web page so the client can test connectivity
mkdir -p /var/www/html
cat > /var/www/html/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head><title>ITSC-1316 Lab Server</title></head>
<body>
<h1>ITSC-1316 Network Lab</h1>
<p>If you can see this page, your client can reach the server on the private network.</p>
<p>Server IP: 192.168.56.20</p>
<p>Hostname: server.corp.local</p>
</body>
</html>
HTML_EOF

# Disable nginx to avoid port conflict, use httpd as the primary web server
systemctl disable nginx 2>/dev/null || true
systemctl enable --now httpd

# ─── Firewall: open ports for the lab ─────────────────────────
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# ─── SSH host key for client to trust ─────────────────────────
# Generate host keys if missing
ssh-keygen -A

echo "Server provisioning complete."
echo "  Web server:  http://192.168.56.20"
echo "  DNS server:  192.168.56.20 (corp.local zone)"
echo "  SSH:         student@192.168.56.20"