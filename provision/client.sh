#!/usr/bin/env bash
# client.sh — generic client-node provisioning (runs when no lab-specific
# client.sh exists at labs/{LAB}/provision/client.sh)
# Idempotent: safe to run multiple times
set -euxo pipefail

# Add /etc/hosts entries for the private network so students can reach the server
grep -q "192.168.56.20" /etc/hosts || cat >> /etc/hosts << 'HOSTS_EOF'
# Lab private network
192.168.56.20  server
192.168.56.10  client
HOSTS_EOF

# Generate SSH key for student so they can connect to the server
STUDENT_HOME="/home/student"
if [ ! -f "$STUDENT_HOME/.ssh/id_ed25519" ]; then
  sudo -u student mkdir -p "$STUDENT_HOME/.ssh"
  sudo -u student ssh-keygen -t ed25519 -N "" -f "$STUDENT_HOME/.ssh/id_ed25519"
fi

# Scan server host key so SSH does not prompt
sudo -u student bash -c "ssh-keyscan -H 192.168.56.20 2>/dev/null >> ~/.ssh/known_hosts"

# Basic SSH config for server access
cat > "$STUDENT_HOME/.ssh/config" << 'SSHCFG_EOF'
Host server
    HostName 192.168.56.20
    User student
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
SSHCFG_EOF

chown -R student:student "$STUDENT_HOME/.ssh"
chmod 700 "$STUDENT_HOME/.ssh"
chmod 600 "$STUDENT_HOME/.ssh/config"

# Firewall: allow SSH
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

echo "Client provisioning complete (generic)."
echo "  SSH to server: ssh student@server"