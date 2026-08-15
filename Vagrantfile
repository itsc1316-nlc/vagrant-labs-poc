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
# See README.md for the lab-to-profile cross-reference table.

require "pathname"
require "fileutils"

# Which profile to use.
# On `vagrant up`, PROFILE env var is required and saved to .vagrant/profile.
# On subsequent commands (ssh, status, halt, etc.), the saved value is loaded
# automatically so students don't need to pass PROFILE= every time.
PROFILE = ENV["PROFILE"]
PROFILE_FILE = File.expand_path(".vagrant/profile", __dir__)

if PROFILE.nil? || PROFILE.empty?
  # Try to load the previously saved profile
  if File.exist?(PROFILE_FILE)
    PROFILE_LOADED = File.read(PROFILE_FILE).strip
  else
    abort "==> ERROR: You must specify a profile using the PROFILE environment variable."
    abort "    Example: PROFILE=single vagrant up"
    abort "    Example: PROFILE=dual vagrant up"
  end
else
  # Save the profile for future commands
  profile_dir = File.dirname(PROFILE_FILE)
  Dir.mkdir(profile_dir) unless Dir.exist?(profile_dir)
  File.write(PROFILE_FILE, PROFILE)
  PROFILE_LOADED = PROFILE
end

unless %w[single dual].include?(PROFILE_LOADED)
  abort "==> ERROR: Invalid profile '#{PROFILE_LOADED}'. Use 'single' or 'dual'."
end

# UTM does not support private_network — dual profile requires VirtualBox or libvirt
if PROFILE_LOADED == "dual" && (ARGV.include?("--provider=utm") || ARGV.include?("utm"))
  abort "==> ERROR: The dual profile is not supported with the UTM provider."
  abort "    UTM does not support private networks between VMs."
  abort "    Use VirtualBox (macOS Intel) or libvirt (Linux) for the dual profile."
  abort "    On Apple Silicon, dual profile is not available — use single profile instead."
end

# Default box (VirtualBox, libvirt): bento/fedora-latest supports both providers
DEFAULT_BOX = "bento/fedora-latest"
# UTM box: utm/fedora-41 is purpose-built for vagrant_utm plugin (auto-login, guest additions)
UTM_BOX = "utm/fedora-41"

Vagrant.configure("2") do |config|
  config.vm.synced_folder "provision/", "/vagrant-provision"

  # Common provisioning: common.sh runs first on every node
  config.vm.provision "common", type: "shell",
    path: "provision/common.sh"

  # ─── client node (always defined) ────────────────────────────
  config.vm.define "client" do |client|
    client.vm.box = DEFAULT_BOX
    client.vm.hostname = "client"
    client.vm.network "private_network",
      ip: "192.168.56.10",
      virtualbox__intnet: "itsc1316net"

    client.vm.provider "virtualbox" do |vb|
      vb.name = "itsc1316-client"
      vb.cpus = 1
      vb.memory = 1024
      vb.linked_clone = true
    end

    client.vm.provider "utm" do |utm, override|
      override.vm.box = UTM_BOX
      utm.name = "itsc1316-client"
      utm.cpus = 1
      utm.memory = 1024
      utm.wait_time = 60
      utm.check_guest_additions = false
    end

    client.vm.provider "libvirt" do |lv|
      lv.cpus = 1
      lv.memory = 1024
      lv.random_hostname = true
    end

    # Profile-specific client provisioning
    if PROFILE_LOADED == "single"
      client.vm.provision "profile-client", type: "shell",
        path: "provision/single.sh"
    else
      client.vm.provision "profile-client", type: "shell",
        path: "provision/dual-client.sh"
    end
  end

  # ─── server node (only for dual profile) ─────────────────────
  if PROFILE_LOADED == "dual"
    config.vm.define "server" do |server|
      server.vm.box = DEFAULT_BOX
      server.vm.hostname = "server"
      server.vm.network "private_network",
        ip: "192.168.56.20",
        virtualbox__intnet: "itsc1316net"

      server.vm.provider "virtualbox" do |vb|
        vb.name = "itsc1316-server"
        vb.cpus = 1
        vb.memory = 1024
        vb.linked_clone = true
      end

      server.vm.provider "utm" do |utm, override|
        override.vm.box = UTM_BOX
        utm.name = "itsc1316-server"
        utm.cpus = 1
        utm.memory = 1024
        utm.wait_time = 60
        utm.check_guest_additions = false
      end

      server.vm.provider "libvirt" do |lv|
        lv.cpus = 1
        lv.memory = 1024
        lv.random_hostname = true
      end

      server.vm.provision "profile-server", type: "shell",
        path: "provision/dual-server.sh"
    end
  end
end