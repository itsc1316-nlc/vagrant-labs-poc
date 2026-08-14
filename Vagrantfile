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

# Which lab to provision for — required, no default
LAB = ENV["LAB"]
if LAB.nil? || LAB.empty?
  abort "==> ERROR: You must specify a lab using the LAB environment variable."
  abort "    Example: LAB=lab-13 vagrant up"
  abort "    Example: LAB=lab-04 vagrant up"
end

# Detect host architecture (informational; box is multi-arch)
host_arch = RUBY_PLATFORM.include?("arm64") || RUBY_PLATFORM.include?("aarch64") ? "arm64" : "x86_64"

# bento/fedora-latest supports VirtualBox, UTM, and libvirt on both x86_64 and ARM64
BOX = "bento/fedora-latest"

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
    client.vm.box = BOX
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

    client.vm.provider "utm" do |utm|
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
    server.vm.box = BOX
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

    server.vm.provider "utm" do |utm|
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