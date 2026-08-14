#!/usr/bin/env bash
# lab-04 client.sh — client-node provisioning for the filesystem/permissions lab
# Installs: ACL tools, mlocate, creates IOTBN groups
# Idempotent: safe to run multiple times
set -euxo pipefail

# ─── Lab-specific packages ────────────────────────────────────
dnf install -y --skip-unavailable \
  acl \
  plocate \
  tree

# Update the locate database so 'locate' works immediately
# plocate may need updatedb from the plocate package
updatedb 2>/dev/null || plocate.updatedb 2>/dev/null || true

# ─── Create IOTBN groups ──────────────────────────────────────
# These are the groups the lab uses for ownership/permissions exercises
for group in sysadmins webdevs designers managers creative; do
  groupadd -f "$group"
done

# ─── Create the nobody test user (used in Step 6) ─────────────
# Fedora includes nobody by default, but ensure it exists
id nobody &>/dev/null || useradd -s /sbin/nologin nobody

# ─── Create /opt/iotbn parent directory ───────────────────────
# The lab has students create subdirectories here, but the parent must exist
mkdir -p /opt/iotbn

# ─── Ensure student can sudo without issues ───────────────────
# Already set up in common.sh, but verify the sudoers file is intact
echo "student ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/student
chmod 0440 /etc/sudoers.d/student

echo "Lab 04 client provisioning complete."
echo "  ACL tools:    acl (setfacl, getfacl)"
echo "  File search:  mlocate (locate, updatedb)"
echo "  IOTBN groups: sysadmins, webdevs, designers, managers, creative"
echo "  Work dir:     /opt/iotbn (ready for student to build)"