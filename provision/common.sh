#!/usr/bin/env bash
# common.sh — runs on every node before node-specific provisioning
# Idempotent: safe to run multiple times
set -euxo pipefail

# ─── Package installation ─────────────────────────────────────
dnf install -y --skip-unavailable \
  vim \
  tmux \
  curl \
  wget \
  net-tools \
  bind-utils \
  iproute \
  firewalld \
  nftables \
  tcpdump \
  podman \
  openssh-server \
  man-db \
  man-pages \
  NetworkManager \
  traceroute \
  mtr \
  nmap-ncat \
  elinks

# ─── Enable and start core services ───────────────────────────
systemctl enable --now firewalld
systemctl enable --now sshd

# ─── Create student user ──────────────────────────────────────
if ! id student &>/dev/null; then
  useradd -m -s /bin/bash student
  echo "student:fedora" | chpasswd
  echo "student ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/student
  chmod 0440 /etc/sudoers.d/student
fi

# Vagrant syncs labs/ to /opt/labs (world-readable). Symlink ~/labs
# for both vagrant and student users so they can cd ~/labs/lab-XX.
ln -sfn /opt/labs /home/vagrant/labs
ln -sfn /opt/labs /home/student/labs
chown -h student:student /home/student/labs
chmod -R a+rX /opt/labs 2>/dev/null || true

# ─── MOTD ─────────────────────────────────────────────────────
cat > /etc/motd << 'MOTDEOF'

╔══════════════════════════════════════════════════════════╗
║   ITSC-1316 Linux Primary Shell — Network Lab Environment ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║   Two-VM topology:  client (192.168.56.10)               ║
║                     server (192.168.56.20)               ║
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
║     cd ~/labs/lab-13                                    ║
║     cat README.md                                       ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

MOTDEOF