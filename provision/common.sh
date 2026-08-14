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

# Ensure student can access lab files. Vagrant syncs labs/ to /home/vagrant/labs,
# but the student user's home is /home/student. Symlink so ~/labs resolves correctly.
ln -sfn /home/vagrant/labs /home/student/labs
chown -h student:student /home/student/labs

# ─── MOTD ─────────────────────────────────────────────────────
cat > /etc/motd << 'MOTDEOF'

╔══════════════════════════════════════════════════════════╗
║   ITSC-1316 Linux Primary Shell — Network Lab Environment ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║   Two-VM topology:  client (192.168.56.10)               ║
║                     server (192.168.56.20)               ║
║                                                          ║
║   Lab files:        /home/vagrant/labs/                   ║
║   Student account:  student / fedora  (passwordless sudo)║
║                                                          ║
║   Quick start:                                          ║
║     cd ~/labs/lab-13                                    ║
║     cat README.md                                       ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

MOTDEOF