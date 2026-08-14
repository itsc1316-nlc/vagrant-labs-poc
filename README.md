# ITSC-1316 Linux Lab Environment

A Vagrant-based local lab environment for the **ITSC-1316 Linux Primary Shell** course. This repository gives you two Fedora Linux virtual machines — a **client** and a **server** — connected on a private network. Each lab has its own provisioning scripts that configure the VMs for that lab's specific tasks.

## Quick Start

| Your Computer | Setup Guide |
|---------------|-------------|
| Windows 10 / 11 | [setup-windows.md](docs/setup-windows.md) |
| Mac (Intel) | [setup-macos-intel.md](docs/setup-macos-intel.md) |
| Mac (Apple Silicon M1–M5) | [setup-macos-arm.md](docs/setup-macos-arm.md) |
| Linux | [setup-linux.md](docs/setup-linux.md) |

Once you have Vagrant installed and this repo cloned, start the lab your instructor assigned:

```bash
LAB=lab-13 vagrant up
```

Replace `lab-13` with the lab you need (see the table below).

> **Mac with Apple Silicon (M1–M5)?** Add `--provider=utm`:
> ```bash
> LAB=lab-13 vagrant up --provider=utm
> ```

> **Linux with KVM/libvirt?** Add `--provider=libvirt`:
> ```bash
> LAB=lab-13 vagrant up --provider=libvirt
> ```

Then connect to the client VM:

```bash
vagrant ssh client
```

## What Is This?

Instead of connecting to a remote cloud server, you run two Linux VMs on your own computer. The **client** VM is where you do your work. The **server** VM runs services (web, DNS, file shares — depending on the lab) that the client interacts with. When you run `LAB=lab-XX vagrant up`, Vagrant installs and configures only what that lab needs.

## Topology

```
        ┌──────────────────────────────────────────────┐
        │          Your Computer (Host)                 │
        │                                              │
        │  ┌─────────────┐    ┌─────────────┐          │
        │  │   client    │    │   server    │          │
        │  │ Fedora VM   │    │ Fedora VM   │          │
        │  │             │    │             │          │
        │  │ 192.168.56. │◄──►│ 192.168.56. │          │
        │  │    10       │    │    20       │          │
        │  │             │    │             │          │
        │  │  student    │    │  services   │          │
        │  │  workspace  │    │  (per lab)  │          │
        │  └─────────────┘    └─────────────┘          │
        │     private network: 192.168.56.0/24        │
        │                                              │
        └──────────────────────────────────────────────┘
```

## Available Labs

| Lab | Module | Topic | Start Command | Link |
|-----|--------|-------|---------------|------|
| Lab 13 | Module 13 | Advanced Network Configuration | `LAB=lab-13 vagrant up` | [labs/lab-13/README.md](labs/lab-13/README.md) |
| Lab 04 | Module 4 | Building and Securing Directory Structure | `LAB=lab-04 vagrant up` | [labs/lab-04/README.md](labs/lab-04/README.md) |

### Switching Labs

Each lab configures the VMs differently. To switch to a different lab:

```bash
vagrant destroy -f
LAB=lab-04 vagrant up
```

You must destroy and rebuild when switching labs so the new provisioning scripts run cleanly. Add `--provider=utm` or `--provider=libvirt` if your setup requires it.

## Rebuild From Scratch

If something breaks or you want a clean start:

```bash
vagrant destroy -f && LAB=lab-13 vagrant up
```

Replace `lab-13` with the lab you are working on (add `--provider=utm` or `--provider=libvirt` if your setup requires it). This deletes both VMs and rebuilds them from scratch. Your lab files on your host computer are not affected.


## Troubleshooting

| Problem | Solution |
|---------|----------|
| **"VT-x not enabled" or "virtualization not enabled"** | Reboot your computer, enter BIOS/UEFI settings, and enable Intel VT-x or AMD-V. This is a one-time setup. Search your computer model + "enable virtualization" for specific steps. |
| **"Provider not found" or "No usable provider"** | Make sure VirtualBox (or UTM on Apple Silicon) is installed and running. Re-open the app once before trying `vagrant up` again. |
| **"Network conflict" or "192.168.56.x already in use"** | Another VirtualBox network is using the same subnet. Run `VBoxManage hostonlyif remove` to clean up old adapters, or shut down other VMs. |
| **VMs start but can't ping each other** | Run `vagrant reload` to restart both VMs. If that fails, `vagrant destroy -f && LAB=lab-13 vagrant up` (replace with your lab). |
| **DNS resolution fails from client** | Check that the server is running: `vagrant status`. Then: `vagrant ssh server -c "systemctl status dnsmasq"`. If dnsmasq is down, run `vagrant reload server`. |
| **`vagrant ssh` says connection refused** | The VM may still be booting. Wait 30 seconds and try again. If it persists, `vagrant reload`. |
| **Apple Silicon: UTM not found** | Make sure UTM is installed and has been opened at least once. Verify: `vagrant plugin list` shows `vagrant_utm`. |

## Requirements

- **Vagrant** 2.4 or later
- **A hypervisor:** VirtualBox (Windows, macOS Intel, Linux), UTM (macOS Apple Silicon), or libvirt (Linux)
- **~5 GB free disk space** for two VMs
- **Internet access** for the initial box download

## Accounts

| VM | User | Password | Sudo |
|----|------|----------|------|
| client | `vagrant` | `vagrant` | yes |
| client | `student` | `fedora` | yes (passwordless) |
| server | `vagrant` | `vagrant` | yes |
| server | `student` | `fedora` | yes (passwordless) |

## License

This lab material is for educational use in the ITSC-1316 course at Alamo Colleges.