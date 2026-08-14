# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile for ITSC-1316 Linux Primary Shell — multi-lab environment
# Two-VM topology: client + server on 192.168.56.0/24 private network
#
# Supported providers:
#   - VirtualBox (default on Windows, macOS Intel, Linux)
#   - UTM        (macOS ARM / Apple Silicon)
#   - libvirt    (Linux KVM alternative)
#
# Lab selection:
#   LAB=lab-13 vagrant up    # provisions for the networking lab
#   LAB=lab-04 vagrant up    # provisions for the filesystem lab
#
# If labs/{LAB}/provision/{client,server}.sh exist, they override the
# generic provision/{client,server}.sh fallbacks.

require "pathname"
require "fileutils"

# Which lab to provision for.
# On `vagrant up`, LAB env var is required and saved to .vagrant/lab.
# On subsequent commands (ssh, status, halt, etc.), the saved value is loaded
# automatically so students don't need to pass LAB= every time.
LAB = ENV["LAB"]
LAB_FILE = File.expand_path(".vagrant/lab", __dir__)

if LAB.nil? || LAB.empty?
  # Try to load the previously saved lab
  if File.exist?(LAB_FILE)
    LAB = File.read(LAB_FILE).strip
  else
    abort "==> ERROR: You must specify a lab using the LAB environment variable."
    abort "    Example: LAB=lab-13 vagrant up"
    abort "    Example: LAB=lab-04 vagrant up"
  end
else
  # Save the lab for future commands
  lab_dir = File.dirname(LAB_FILE)
  Dir.mkdir(lab_dir) unless Dir.exist?(lab_dir)
  File.write(LAB_FILE, LAB)
end

# Default box (VirtualBox, libvirt): bento/fedora-latest supports both providers
DEFAULT_BOX = "bento/fedora-latest"
# UTM box: utm/fedora-41 is purpose-built for vagrant_utm plugin (auto-login, guest additions)
UTM_BOX = "utm/fedora-41"

# Resolve lab-specific provision scripts, fall back to generic ones
def lab_script(node)
  lab_path    = File.expand_path("labs/#{LAB}/provision/#{node}.sh", __dir__)
  generic_path = File.expand_path("provision/#{node}.sh", __dir__)
  File.exist?(lab_path) ? lab_path : generic_path
end

Vagrant.configure("2") do |config|
  config.vm.synced_folder "labs/", "/home/vagrant/labs"
  config.vm.synced_folder "provision/", "/vagrant-provision"

  # Common provisioning: common.sh runs first on every node
  config.vm.provision "common", type: "shell",
    path: "provision/common.sh"

  # ─── client node ──────────────────────────────────────────────
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

    client.vm.provision "client-specific", type: "shell",
      path: lab_script("client")
  end

  # ─── server node ──────────────────────────────────────────────
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

    server.vm.provision "server-specific", type: "shell",
      path: lab_script("server")
  end
end