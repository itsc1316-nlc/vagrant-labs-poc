#!/usr/bin/env bash
# dual-server.sh — provisioning for the server VM in the dual-VM profile
# Runs on the server VM after common.sh
# Used by: networking, DNS, routing labs
# Idempotent: safe to run multiple times
set -euxo pipefail

# ─── Assign static IP on the lab network interface ───────────
# The QEMU socket NIC has a specific MAC and no IPv4 address at boot.
# On VirtualBox/libvirt, the private_network already has the IP.
LAB_IP="192.168.56.20"
LAB_MAC="52:54:00:12:34:20"

# If the IP is already assigned, we're done
if ip -4 addr show | grep -q "$LAB_IP"; then
  echo "IP $LAB_IP already assigned, skipping."
else
  # Find the interface matching our QEMU socket NIC MAC
  LAB_IFACE=""
  for iface in $(ls /sys/class/net/ | grep -v lo); do
    mac=$(cat /sys/class/net/"$iface"/address 2>/dev/null || echo "")
    if [ "$mac" = "$LAB_MAC" ]; then
      LAB_IFACE="$iface"
      break
    fi
  done

  if [ -n "$LAB_IFACE" ]; then
    ip addr add "${LAB_IP}/24" dev "$LAB_IFACE"
    ip link set "$LAB_IFACE" up
    echo "Assigned $LAB_IP to $LAB_IFACE (MAC: $LAB_MAC)"
  fi
fi

# ─── Install server-side packages ─────────────────────────────
dnf install -y \
  httpd \
  nginx \
  dnsmasq \
  rsync

# ─── Configure dnsmasq as local DNS for the lab ──────────────
cat > /etc/dnsmasq.d/corp-local.conf << 'DNS_EOF'
# Lab DNS entries for ITSC-1316 network lab
address=/server.corp.local/192.168.56.20
address=/client.corp.local/192.168.56.10
address=/fileserver.corp.local/192.168.56.20
local=/corp.local/
DNS_EOF

# Override resolv.conf so the server itself uses dnsmasq
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "search corp.local" >> /etc/resolv.conf

systemctl enable --now dnsmasq

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
ssh-keygen -A

echo "Dual-VM server provisioning complete."
echo "  Web server:  http://192.168.56.20"
echo "  DNS server:  192.168.56.20 (corp.local zone)"
echo "  SSH:         student@192.168.56.20"