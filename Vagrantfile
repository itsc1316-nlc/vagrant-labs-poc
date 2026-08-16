# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile for ITSC-1316 Linux Primary Shell — multi-lab environment
#
# Supported providers:
#   - VirtualBox (default on Windows, macOS Intel, Linux)
#   - UTM        (macOS ARM / Apple Silicon)
#   - libvirt    (Linux KVM alternative)
#
# Profile selection:
#   PROFILE=single vagrant up    # one VM (filesystem, permissions, shell labs)
#   PROFILE=dual vagrant up      # two VMs — client + server (networking labs)
#
# See README.md for the profile descriptions.

require "fileutils"

# Profile selection.
# `PROFILE` is required for the first `vagrant up`, then persisted so later
# commands such as `ssh`, `status`, `halt`, and `destroy` use the same topology.
PROFILE = ENV.fetch("PROFILE", "").strip
PROFILE_FILE = File.expand_path(".vagrant/profile", __dir__)
SAVED_PROFILE = File.exist?(PROFILE_FILE) ? File.read(PROFILE_FILE).strip : ""
PROFILE_LOADED = PROFILE.empty? ? SAVED_PROFILE : PROFILE

if PROFILE_LOADED.empty?
  abort <<~MESSAGE
    ==> ERROR: You must specify a profile using the PROFILE environment variable.
        Example: PROFILE=single vagrant up
        Example: PROFILE=dual vagrant up
  MESSAGE
end

unless %w[single dual].include?(PROFILE_LOADED)
  abort "==> ERROR: Invalid profile '#{PROFILE_LOADED}'. Use 'single' or 'dual'."
end

# Persist only validated, explicitly requested profiles. An invalid value must
# not poison later commands through .vagrant/profile.
unless PROFILE.empty?
  FileUtils.mkdir_p(File.dirname(PROFILE_FILE))
  File.write(PROFILE_FILE, PROFILE)
end

# TCP port for UTM dual-profile inter-VM networking. QEMU socket netdev on
# macOS uses TCP (host:port): the server listens and the client connects.
UTM_NET_PORT_TEXT = ENV.fetch("UTM_NET_PORT", "4444")
unless UTM_NET_PORT_TEXT.match?(/\A\d+\z/) &&
       (1024..65_535).cover?(UTM_NET_PORT_TEXT.to_i)
  abort "==> ERROR: UTM_NET_PORT must be an integer from 1024 through 65535."
end
UTM_NET_PORT = UTM_NET_PORT_TEXT.to_i
UTM_NETWORK_SCRIPT = File.expand_path(
  "scripts/configure_utm_network.applescript",
  __dir__
)

# Default box (VirtualBox, libvirt): bento/fedora-latest supports both providers
DEFAULT_BOX = "bento/fedora-latest"
# UTM box: purpose-built for vagrant_utm (auto-login and guest additions)
UTM_BOX = "utm/fedora-41"

Vagrant.configure("2") do |config|

  # Common provisioning: common.sh runs first on every node
  config.vm.provision "common", type: "shell",
    path: "provision/common.sh"

  # ─── server node (defined first for dual profile so it boots first) ──
  # On UTM, the server listens on the QEMU socket and the client connects.
  # The server must be up before the client starts, so we define it first.
  if PROFILE_LOADED == "dual"
    config.vm.define "server" do |server|
      server.vm.box = DEFAULT_BOX
      server.vm.hostname = "server"

      server.vm.provider "virtualbox" do |vb, override|
        vb.name = "itsc1316-server"
        vb.cpus = 1
        vb.memory = 1024
        vb.linked_clone = true
        override.vm.network "private_network",
          ip: "192.168.56.20",
          virtualbox__intnet: "itsc1316net"
      end

      server.vm.provider "utm" do |utm, override|
        override.vm.box = UTM_BOX
        utm.name = "itsc1316-server"
        utm.cpus = 1
        utm.memory = 1024
        utm.wait_time = 60
        utm.check_guest_additions = false

        # Replace this project's managed arguments on every boot, then add one
        # socket NIC. This avoids duplicate QEMU ids after halt/reload/up.
        utm.customize "pre-boot", [
          UTM_NETWORK_SCRIPT, :id,
          "-netdev socket,id=labnet,listen=127.0.0.1:#{UTM_NET_PORT}",
          "virtio-net-pci,netdev=labnet,mac=52:54:00:12:34:20"
        ]
      end

      server.vm.provider "libvirt" do |lv, override|
        lv.cpus = 1
        lv.memory = 1024
        lv.random_hostname = true
        override.vm.network "private_network", ip: "192.168.56.20"
      end

      server.vm.provision "lab-network", type: "shell",
        path: "provision/dual-network.sh",
        args: ["192.168.56.20", "52:54:00:12:34:20"]

      server.vm.provision "profile-server", type: "shell",
        path: "provision/dual-server.sh"
    end
  end

  # ─── client node (always defined; boots after server in dual profile) ──
  config.vm.define "client" do |client|
    client.vm.box = DEFAULT_BOX
    client.vm.hostname = "client"

    client.vm.provider "virtualbox" do |vb, override|
      vb.name = "itsc1316-client"
      vb.cpus = 1
      vb.memory = 1024
      vb.linked_clone = true
      override.vm.network "private_network",
        ip: "192.168.56.10",
        virtualbox__intnet: "itsc1316net"
    end

    client.vm.provider "utm" do |utm, override|
      override.vm.box = UTM_BOX
      utm.name = "itsc1316-client"
      utm.cpus = 1
      utm.memory = 1024
      utm.wait_time = 60
      utm.check_guest_additions = false

      # In dual profile, connect to the server's QEMU socket. The server is
      # defined first and vagrant_utm runs multi-machine actions sequentially.
      if PROFILE_LOADED == "dual"
        utm.customize "pre-boot", [
          UTM_NETWORK_SCRIPT, :id,
          "-netdev socket,id=labnet,connect=127.0.0.1:#{UTM_NET_PORT}",
          "virtio-net-pci,netdev=labnet,mac=52:54:00:12:34:10"
        ]
      end
    end

    client.vm.provider "libvirt" do |lv, override|
      lv.cpus = 1
      lv.memory = 1024
      lv.random_hostname = true
      override.vm.network "private_network", ip: "192.168.56.10"
    end

    # Profile-specific client provisioning
    if PROFILE_LOADED == "single"
      client.vm.provision "profile-client", type: "shell",
        path: "provision/single.sh"
    else
      client.vm.provision "lab-network", type: "shell",
        path: "provision/dual-network.sh",
        args: ["192.168.56.10", "52:54:00:12:34:10"]
      client.vm.provision "profile-client", type: "shell",
        path: "provision/dual-client.sh"
    end
  end
end