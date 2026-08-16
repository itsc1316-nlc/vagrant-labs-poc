#!/usr/bin/env bash
# dual-client.sh — provisioning for the client VM in the dual-VM profile
# Runs on the client VM after common.sh
# Used by: networking, DNS, routing labs
# Idempotent: safe to run multiple times
set -euo pipefail

# ─── Locate the configured lab interface ──────────────────────
LAB_CIDR="192.168.56.10/24"
LAB_IFACE=$(ip -4 -o addr show | awk -v cidr="$LAB_CIDR" '$4 == cidr { print $2; exit }')
if [ -z "$LAB_IFACE" ]; then
  echo "ERROR: No interface has $LAB_CIDR." >&2
  exit 1
fi

# ─── Use the server for DNS on the lab connection ─────────────
# Remove immutability left by releases that wrote /etc/resolv.conf directly.
chattr -i /etc/resolv.conf 2>/dev/null || true
LAB_CONNECTION_UUID=$(
  nmcli -t -f UUID,DEVICE connection show --active |
    awk -F: -v iface="$LAB_IFACE" '$2 == iface { print $1; exit }'
)
if [ -z "$LAB_CONNECTION_UUID" ]; then
  echo "ERROR: NetworkManager has no active connection for $LAB_IFACE." >&2
  exit 1
fi
nmcli connection modify uuid "$LAB_CONNECTION_UUID" \
  ipv4.dns "192.168.56.20" \
  ipv4.dns-search "corp.local" \
  ipv4.ignore-auto-dns yes \
  ipv4.dns-priority -50
nmcli connection up uuid "$LAB_CONNECTION_UUID" ifname "$LAB_IFACE"

# ─── Add /etc/hosts entries for the private network ───────────
grep -q "192.168.56.20" /etc/hosts || cat >> /etc/hosts << 'HOSTS_EOF'
# Lab private network
192.168.56.20  server  server.corp.local  fileserver  fileserver.corp.local
192.168.56.10  client  client.corp.local
HOSTS_EOF

# ─── SSH config for convenient server access ──────────────────
# Authentication uses the documented student password. Labs that teach SSH
# keys can add them without fighting an instructor-created private key.
STUDENT_HOME="/home/student"
install -d -m 0700 -o student -g student "$STUDENT_HOME/.ssh"
cat > "$STUDENT_HOME/.ssh/config" << 'SSHCFG_EOF'
Host server
    HostName 192.168.56.20
    User student
    StrictHostKeyChecking accept-new

Host server-corp
    HostName server.corp.local
    User student
    StrictHostKeyChecking accept-new
SSHCFG_EOF
chown student:student "$STUDENT_HOME/.ssh/config"
chmod 0600 "$STUDENT_HOME/.ssh/config"

# ─── Firewall ─────────────────────────────────────────────────
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# ─── Verify the dual-VM contract before reporting success ─────
ping -c 1 -W 3 192.168.56.20 >/dev/null
test "$(dig +short @192.168.56.20 server.corp.local A)" = "192.168.56.20"
WEB_RESPONSE=$(curl --fail --silent --show-error http://192.168.56.20/)
grep -Fq "ITSC-1316 Network Lab" <<<"$WEB_RESPONSE"

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