#!/usr/bin/env bash
# dual-network.sh — configure one node's 192.168.56.0/24 lab interface
# Arguments: <IPv4 address> <UTM QEMU NIC MAC>
#
# VirtualBox/libvirt assign the address before this script runs. UTM needs a
# persistent NetworkManager profile for its QEMU socket NIC.
# Idempotent: safe to run multiple times.
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <IPv4 address> <UTM NIC MAC>" >&2
  exit 2
fi

LAB_IP=$1
LAB_CIDR="${LAB_IP}/24"
LAB_MAC=${2,,}
LAB_IFACE=$(ip -4 -o addr show | awk -v cidr="$LAB_CIDR" '$4 == cidr { print $2; exit }')

if [ -z "$LAB_IFACE" ]; then
  for iface_path in /sys/class/net/*; do
    iface=${iface_path##*/}
    [ "$iface" = "lo" ] && continue
    if [ "$(cat "$iface_path/address")" = "$LAB_MAC" ]; then
      LAB_IFACE=$iface
      break
    fi
  done
fi

if [ -z "$LAB_IFACE" ]; then
  echo "ERROR: Neither $LAB_CIDR nor lab NIC $LAB_MAC was found." >&2
  exit 1
fi

# Only the UTM NIC has the managed MAC. Reconcile its NetworkManager profile
# even when a previous release left a temporary address on the interface.
if [ "$(cat "/sys/class/net/$LAB_IFACE/address")" = "$LAB_MAC" ]; then
  mapfile -t LAB_UUIDS < <(
    nmcli -t -f UUID,NAME connection show |
      awk -F: '$2 == "labnet" { print $1 }'
  )
  if [ "${#LAB_UUIDS[@]}" -eq 0 ]; then
    nmcli connection add type ethernet con-name labnet ifname "$LAB_IFACE"
    mapfile -t LAB_UUIDS < <(
      nmcli -t -f UUID,NAME connection show |
        awk -F: '$2 == "labnet" { print $1 }'
    )
  fi
  if [ "${#LAB_UUIDS[@]}" -eq 0 ]; then
    echo "ERROR: NetworkManager did not create the labnet profile." >&2
    exit 1
  fi
  LAB_UUID=${LAB_UUIDS[0]}
  for ((i = 1; i < ${#LAB_UUIDS[@]}; i++)); do
    nmcli connection delete uuid "${LAB_UUIDS[$i]}"
  done

  nmcli connection modify uuid "$LAB_UUID" \
    connection.interface-name "$LAB_IFACE" \
    connection.autoconnect yes \
    802-3-ethernet.mac-address "$LAB_MAC" \
    ipv4.method manual \
    ipv4.addresses "$LAB_CIDR" \
    ipv4.gateway "" \
    ipv4.never-default yes \
    ipv6.method disabled
  nmcli connection up uuid "$LAB_UUID" ifname "$LAB_IFACE"
fi

if ! ip -4 -o addr show dev "$LAB_IFACE" | grep -Fq " $LAB_CIDR "; then
  echo "ERROR: $LAB_IFACE does not have $LAB_CIDR." >&2
  exit 1
fi

echo "Lab network ready: $LAB_IFACE has $LAB_CIDR"
