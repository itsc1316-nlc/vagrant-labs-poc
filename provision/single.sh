#!/usr/bin/env bash
# single.sh — provisioning for the single-VM profile
# Runs on the client VM after common.sh
# Used by: filesystem, permissions, shell scripting labs
# Idempotent: safe to run multiple times
set -euxo pipefail

# All base packages, IOTBN groups, /opt/iotbn, and student user
# are already set up by common.sh. This script handles MOTD only.

# ─── MOTD ─────────────────────────────────────────────────────
cat > /etc/motd << 'MOTDEOF'

╔══════════════════════════════════════════════════════════╗
║   ITSC-1316 Linux Primary Shell — Lab Environment         ║
║   Single-VM Profile                                        ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║   You are logged in as: vagrant                           ║
║   Switch to student account before starting:             ║
║     su - student                                         ║
║     (password: fedora)                                   ║
║                                                          ║
║   Lab files:        ~/labs/                              ║
║   Student account:  student / fedora  (passwordless sudo)║
║                                                          ║
║   Quick start:                                          ║
║     cd ~/labs/                                          ║
║     ls                                                  ║
║     cd lab-XX                                           ║
║     cat README.md                                       ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

MOTDEOF

echo "Single-VM profile provisioning complete."