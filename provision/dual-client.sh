#!/usr/bin/env bash
# dual-client.sh — provisioning for the client VM in the dual-VM profile
# Runs on the client VM after common.sh
# Used by: networking, DNS, routing labs
# Idempotent: safe to run multiple times
set -euxo pipefail

# ─── Assign static IP on the lab network interface ───────────
# The QEMU socket NIC has a specific MAC and no IPv4 address at boot.
# On VirtualBox/libvirt, the private_network already has the IP.
LAB_IP="192.168.56.10"
LAB_MAC="52:54:00:12:34:10"

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

# ─── Point client DNS at the server's dnsmasq ────────────────
cat > /etc/resolv.conf << 'DNS_EOF'
nameserver 192.168.56.20
search corp.local
DNS_EOF

# Make resolv.conf immutable so NetworkManager does not overwrite it
chattr +i /etc/resolv.conf 2>/dev/null || true

# ─── Add /etc/hosts entries for the private network ───────────
grep -q "192.168.56.20" /etc/hosts || cat >> /etc/hosts << 'HOSTS_EOF'
# Lab private network
192.168.56.20  server  server.corp.local  fileserver  fileserver.corp.local
192.168.56.10  client  client.corp.local
HOSTS_EOF

# ─── Set up SSH key for student to access server ──────────────
STUDENT_HOME="/home/student"
if [ ! -f "$STUDENT_HOME/.ssh/id_ed25519" ]; then
  sudo -u student mkdir -p "$STUDENT_HOME/.ssh"
  sudo -u student ssh-keygen -t ed25519 -N "" -f "$STUDENT_HOME/.ssh/id_ed25519"
fi

# Add server's host key to known_hosts (may fail if server isn't up yet)
sudo -u student bash -c "ssh-keyscan -H 192.168.56.20 server.corp.local 2>/dev/null >> ~/.ssh/known_hosts" || true
sudo -u student bash -c "ssh-keyscan -H 192.168.56.10 client.corp.local 2>/dev/null >> ~/.ssh/known_hosts" || true

# Ensure correct ownership
chown -R student:student "$STUDENT_HOME/.ssh"
chmod 700 "$STUDENT_HOME/.ssh"
chmod 600 "$STUDENT_HOME/.ssh/id_ed25519"
chmod 644 "$STUDENT_HOME/.ssh/id_ed25519.pub"

# ─── SSH config for easy server access ───────────────────────
cat > "$STUDENT_HOME/.ssh/config" << 'SSHCFG_EOF'
Host server
    HostName 192.168.56.20
    User student
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no

Host server-corp
    HostName server.corp.local
    User student
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
SSHCFG_EOF

chown student:student "$STUDENT_HOME/.ssh/config"
chmod 600 "$STUDENT_HOME/.ssh/config"

# ─── Firewall ─────────────────────────────────────────────────
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# ─── MOTD ─────────────────────────────────────────────────────
cat > /etc/motd << 'MOTDEOF'

╔══════════════════════════════════════════════════════════╗
║   ITSC-1316 Linux Primary Shell — Lab Environment         ║
║   Dual-VM Profile (client + server)                        ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║   Two-VM topology:  client (192.168.56.10)               ║
║                     server (192.168.56.20)               ║
║   Server runs:      dnsmasq (DNS), httpd (web)           ║
║                                                          ║
║   You are logged in as: vagrant                           ║
║   Switch to student account before starting:             ║
║     su - student                                         ║
║     (password: fedora)                                   ║
║                                                          ║
║   Student account:  student / fedora  (passwordless sudo)║
║                                                          ║
║   Lab instructions are on Canvas.                         ║
║   Open your assignment in a web browser and               ║
║   follow the steps in this terminal.                      ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

MOTDEOF

echo "Dual-VM client provisioning complete."
echo "  DNS server:    192.168.56.20 (server)"
echo "  Search domain: corp.local"
echo "  SSH to server: ssh student@server"