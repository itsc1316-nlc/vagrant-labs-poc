#!/usr/bin/env bash
# dual-server.sh — provisioning for the server VM in the dual-VM profile
# Runs on the server VM after common.sh
# Used by: networking, DNS, routing labs
# Idempotent: safe to run multiple times
set -euo pipefail

# ─── Locate the configured lab interface ──────────────────────
LAB_CIDR="192.168.56.20/24"
LAB_IFACE=$(ip -4 -o addr show | awk -v cidr="$LAB_CIDR" '$4 == cidr { print $2; exit }')
if [ -z "$LAB_IFACE" ]; then
  echo "ERROR: No interface has $LAB_CIDR." >&2
  exit 1
fi

# ─── Install server-side packages ─────────────────────────────
dnf install -y \
  httpd \
  dnsmasq \
  rsync

# ─── Configure dnsmasq as local DNS for the lab ───────────────
# Keep the host's NetworkManager resolver unchanged: dnsmasq reads those
# upstream servers when forwarding names outside corp.local.
cat > /etc/dnsmasq.d/corp-local.conf << DNS_EOF
# Lab DNS entries for ITSC-1316 network lab
interface=lo
interface=${LAB_IFACE}
bind-dynamic
domain-needed
bogus-priv
local=/corp.local/
address=/server.corp.local/192.168.56.20
address=/client.corp.local/192.168.56.10
address=/fileserver.corp.local/192.168.56.20
DNS_EOF

dnsmasq --test
systemctl enable dnsmasq
systemctl restart dnsmasq

# ─── Simple web server on port 80 ────────────────────────────
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

systemctl enable --now httpd

# ─── Firewall: open only services provided by this lab ────────
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=dns
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

echo "Dual-VM server provisioning complete."
echo "  Web server:  http://192.168.56.20"
echo "  DNS server:  192.168.56.20 (corp.local zone)"
echo "  SSH:         student@192.168.56.20"