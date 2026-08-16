# Setup Guide — Linux

Follow these steps to run the ITSC-1316 Linux lab on a Linux computer (Fedora, Ubuntu, Debian, or similar).

## Option A: VirtualBox (common on x86-64 Linux)

### Step 1: Install VirtualBox

**Fedora:**

```bash
sudo dnf install VirtualBox
```

**Ubuntu / Debian:**

```bash
sudo apt update
sudo apt install virtualbox
```

**Arch:**

```bash
sudo pacman -S virtualbox
```

### Step 2: Install Vagrant

**Fedora:**

```bash
sudo dnf install vagrant
```

**Ubuntu / Debian:**

```bash
sudo apt install vagrant
```

**Arch:**

```bash
sudo pacman -S vagrant
```

### Step 3: Clone and Start

```bash
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
PROFILE=single vagrant up
```

Replace `single` with the profile your instructor assigned (see the profile table in the README).

---

## Option B: libvirt / KVM (faster on Linux, no VirtualBox needed)

### Step 1: Install libvirt and vagrant-libvirt

**Fedora:**

```bash
sudo dnf install libvirt vagrant vagrant-libvirt
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER
```

**Ubuntu / Debian:**

```bash
sudo apt install libvirt-daemon-system vagrant vagrant-libvirt
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER
```

Log out and log back in for the group change to take effect.

### Step 2: Clone and Start

```bash
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
PROFILE=single vagrant up --provider=libvirt
```

Replace `single` with the profile your instructor assigned (see the profile table in the README).

---

## Connect to the Client VM

After `vagrant up` finishes:

```bash
vagrant ssh client
```

To switch to the student account:

```bash
su - student
```

Password: `fedora`

## Exiting the VM

When you are done working inside the VM, type `exit` twice — once to log out of the student account, and once to leave the VM:

```bash
exit
exit
```

You are now back on your own computer. Vagrant commands like `vagrant halt` only work here — **not from inside the VM**.

## When You Are Done

To shut down the VM(s):

```bash
vagrant halt
```

To delete and rebuild from scratch:

```bash
vagrant destroy -f && PROFILE=single vagrant up
```

Replace `single` with the profile you are working on.