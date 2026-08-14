#!/usr/bin/env bash
# lab-04 server.sh — server-node provisioning for the filesystem/permissions lab
# This lab is client-only; the server just needs basic SSH access for reference
# Idempotent: safe to run multiple times
set -euxo pipefail

# Generate SSH host keys
ssh-keygen -A

# Ensure firewall allows SSH
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

echo "Lab 04 server provisioning complete (minimal — lab runs on client)."
echo "  SSH:  student@192.168.56.20"