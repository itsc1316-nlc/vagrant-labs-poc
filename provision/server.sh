#!/usr/bin/env bash
# server.sh — generic server-node provisioning (runs when no lab-specific
# server.sh exists at labs/{LAB}/provision/server.sh)
# Idempotent: safe to run multiple times
set -euxo pipefail

# Generate SSH host keys so the client can connect
ssh-keygen -A

# Ensure firewall allows SSH
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

echo "Server provisioning complete (generic)."
echo "  SSH:  student@192.168.56.20"