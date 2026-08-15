# ITSC-1316 Linux Lab Environment

A Vagrant-based local lab environment for the **ITSC-1316 Linux Primary Shell** course. This repository gives you Fedora Linux virtual machines on your own computer so you can practice hands-on Linux skills without a remote server.

## Quick Start

Once you have Vagrant installed and this repo cloned, start the profile your instructor assigned:

```bash
PROFILE=single vagrant up
```

Replace `single` with the profile you need (see the table below).

> **Mac with Apple Silicon (M1–M5)?** Add `--provider=utm`:
> ```bash
> PROFILE=single vagrant up --provider=utm
> ```

> **Linux with KVM/libvirt?** Add `--provider=libvirt`:
> ```bash
> PROFILE=single vagrant up --provider=libvirt
> ```

Then connect to the client VM:

```bash
vagrant ssh client
```

## Profiles

Each lab in the course uses one of two VM profiles. Check which profile your lab needs before starting.

| Profile | VMs | What It Provides | Start Command |
|---------|-----|------------------|---------------|
| `single` | 1 VM (client) | Fedora VM with full toolset: ACL tools, plocate, IOTBN groups, /opt/iotbn directory, networking utilities. Student does all work on one machine. | `PROFILE=single vagrant up` |
| `dual` | 2 VMs (client + server) | Same as single plus a server VM running dnsmasq (DNS) and httpd (web server) on a private network. For labs that need cross-machine networking. | `PROFILE=dual vagrant up` |

### Which Profile Should I Use?

| Profile | Used For | Examples |
|---------|----------|----------|
| `single` | Filesystem navigation, permissions, ACLs, shell scripting, file management, process management, system initialization | Modules 2, 3, 4, 5, 7, 10, 11, 12 |
| `dual` | Networking, DNS, routing, client-server connectivity, troubleshooting across machines | Modules 9, 13, 14 |

When in doubt, check your lab instructions on Canvas or ask your instructor.

## Topology

### Single Profile

```
┌────────────────────────────────────┐
│       Your Computer (Host)         │
│                                   │
│  ┌─────────────┐                  │
│  │   client    │                  │
│  │ Fedora VM   │                  │
│  │             │                  │
│  │ 192.168.56. │                  │
│  │    10       │                  │
│  │             │                  │
│  │  student    │                  │
│  │  workspace  │                  │
│  └─────────────┘                  │
│                                   │
└────────────────────────────────────┘
```

### Dual Profile

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
│  │  student    │    │  dnsmasq    │          │
│  │  workspace  │    │  httpd      │          │
│  └─────────────┘    └─────────────┘          │
│     private network: 192.168.56.0/24        │
│                                              │
└──────────────────────────────────────────────┘
```

## Switching Profiles

Each profile configures the VMs differently. To switch profiles:

```bash
vagrant destroy -f
PROFILE=dual vagrant up
```

Add `--provider=utm` or `--provider=libvirt` if your setup requires it.

You must destroy and rebuild when switching profiles so the new provisioning scripts run cleanly.

## Rebuild From Scratch

If something breaks or you want a clean start:

```bash
vagrant destroy -f && PROFILE=single vagrant up
```

Replace `single` with the profile you are working on (add `--provider=utm` or `--provider=libvirt` if your setup requires it). This deletes the VM(s) and rebuilds them from scratch.

## After You Log In

When you run `vagrant ssh client`, you will see a banner with instructions. Before starting your lab:

```bash
su - student
```

Password: `fedora`

The `student` account has passwordless sudo. Your lab instructions are on Canvas — open them in your web browser and follow the steps in your VM.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **"You must specify a profile"** | Always include `PROFILE=single` or `PROFILE=dual` when running `vagrant up`. After the first time, other commands like `vagrant ssh` will remember your choice. |
| **"VT-x not enabled" or "virtualization not enabled"** | Reboot your computer, enter BIOS/UEFI settings, and enable Intel VT-x or AMD-V. This is a one-time setup. Search your computer model + "enable virtualization" for specific steps. |
| **"Provider not found" or "No usable provider"** | Make sure VirtualBox (or UTM on Apple Silicon) is installed and running. Re-open the app once before trying `vagrant up` again. |
| **"Network conflict" or "192.168.56.x already in use"** | Another VirtualBox network is using the same subnet. Run `VBoxManage hostonlyif remove` to clean up old adapters, or shut down other VMs. |
| **VMs start but can't ping each other** | Run `vagrant reload` to restart the VMs. If that fails, `vagrant destroy -f && PROFILE=dual vagrant up` (replace with your profile). |
| **DNS resolution fails from client** | Check that the server is running: `vagrant status`. Then: `vagrant ssh server -c "systemctl status dnsmasq"`. If dnsmasq is down, run `vagrant reload server`. |
| **`vagrant ssh` says connection refused** | The VM may still be booting. Wait 30 seconds and try again. If it persists, `vagrant reload`. |
| **Apple Silicon: UTM not found** | Make sure UTM is installed and has been opened at least once. Verify: `vagrant plugin list` shows `vagrant_utm`. |

## Requirements

- **Vagrant** 2.4 or later
- **A hypervisor:** VirtualBox (Windows, macOS Intel, Linux), UTM (macOS Apple Silicon), or libvirt (Linux)
- **~3 GB free disk space** for one VM (single) or ~5 GB for two VMs (dual)
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