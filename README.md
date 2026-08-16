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
│  │ One client  │                  │
│  │ VM; no lab  │                  │
│  │ network is  │                  │
│  │ required    │                  │
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

VirtualBox and libvirt provide this private network natively. On Apple
Silicon, only the UTM provider uses a QEMU TCP socket to create the same
isolated link. The lab addresses inside the VMs stay the same.

## After You Log In

When you run `vagrant ssh client`, you will see a banner with instructions. Before starting your lab:

```bash
su - student
```

Password: `fedora`

The `student` account has passwordless sudo. Your lab instructions are on Canvas — open them in your web browser and follow the steps in your VM.

## Exiting the VM

When you are done working inside the VM, first log out of the student account:

```bash
exit
```

Then log out of the vagrant session to return to your host computer:

```bash
exit
```

You are now back on your own computer. Vagrant commands like `vagrant halt` and `vagrant destroy` only work from your host computer — **not from inside the VM**.

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


## Troubleshooting

| Problem | Solution |
|---------|----------|
| **"You must specify a profile"** | Include `PROFILE=single` or `PROFILE=dual` with the first `vagrant up`. Later commands remember the validated profile. |
| **"VT-x not enabled" or "virtualization not enabled"** | Reboot your computer, enter BIOS/UEFI settings, and enable Intel VT-x or AMD-V. Search your computer model plus "enable virtualization" for the exact steps. |
| **"Provider not found" or "No usable provider"** | Make sure VirtualBox, libvirt, or UTM is installed for your platform. On Apple Silicon, open UTM once and verify that `vagrant plugin list` includes `vagrant_utm`. |
| **"Network conflict" or "192.168.56.x already in use"** | Shut down unrelated VMs using that subnet. In VirtualBox, use **Tools > Network** to inspect host-only networks before removing anything. |
| **VMs start but cannot ping each other** | Run `vagrant provision`. If provisioning still fails, rebuild with `vagrant destroy -f && PROFILE=dual vagrant up` and add your provider flag. |
| **DNS resolution fails from client** | Check `vagrant status`, then run `vagrant ssh server -c "sudo systemctl status dnsmasq"`. Reapply the server configuration with `vagrant provision server`. |
| **`vagrant ssh` says connection refused** | The VM may still be booting. Wait 30 seconds and try again. If it persists, run `vagrant reload`. |
| **UTM reports that port 4444 is already in use** | Rebuild with another host port, for example: `vagrant destroy -f && UTM_NET_PORT=45444 PROFILE=dual vagrant up --provider=utm`. |
| **UTM dual profile cannot start the client** | Start the listener first: `PROFILE=dual vagrant up server --provider=utm`, then `vagrant up client --provider=utm`. A normal `PROFILE=dual vagrant up --provider=utm` already uses this order. |

## Requirements

- **Vagrant** 2.4 or later
- **A hypervisor:** VirtualBox (Windows, macOS Intel, Linux), UTM (macOS Apple Silicon), or libvirt (Linux)
- **~3 GB free disk space** for one VM (single) or ~5 GB for two VMs (dual)
- **Internet access** for the initial box download
- **Git** for cloning and updating this repository

## Accounts

| VM | User | Password | Sudo |
|----|------|----------|------|
| client | `vagrant` | Vagrant-managed SSH key | yes |
| client | `student` | `fedora` | yes (passwordless) |
| server | `vagrant` | Vagrant-managed SSH key | yes |
| server | `student` | `fedora` | yes (passwordless) |

## License

This lab material is for educational use in the ITSC-1316 course at Alamo Colleges.