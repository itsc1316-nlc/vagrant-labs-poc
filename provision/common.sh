#!/usr/bin/env bash
# common.sh — runs on every node before profile-specific provisioning
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
  elinks \
  acl \
  plocate \
  tree

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

# ─── IOTBN groups (used by filesystem/permissions labs) ──────
for group in sysadmins webdevs designers managers creative; do
  groupadd -f "$group"
done

# ─── Create nobody test user (used in permissions lab) ────────
id nobody &>/dev/null || useradd -s /sbin/nologin nobody

# ─── /opt/iotbn parent directory ──────────────────────────────
mkdir -p /opt/iotbn

# ─── Update locate database ───────────────────────────────────
updatedb 2>/dev/null || plocate.updatedb 2>/dev/null || true
