# Setup Guide — Linux

Follow these steps to run the ITSC-1316 Linux lab on a Linux computer (Fedora, Ubuntu, Debian, or similar).

## Option A: VirtualBox (easiest, works everywhere)

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
git clone https://github.com/itsc1316/linux_lab_poc.git
cd linux_lab_poc
vagrant up
```

> If your instructor told you to use a specific lab (not the default), run:
> ```bash
> LAB=lab-04 vagrant up
> ```
> Replace `lab-04` with the lab your instructor assigned.

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
git clone https://github.com/itsc1316/linux_lab_poc.git
cd linux_lab_poc
vagrant up --provider=libvirt
```

> If your instructor told you to use a specific lab (not the default), run:
> ```bash
> LAB=lab-04 vagrant up --provider=libvirt
> ```
> Replace `lab-04` with the lab your instructor assigned.

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

## When You Are Done

To shut down the VMs:

```bash
vagrant halt
```

To delete and rebuild from scratch:

```bash
vagrant destroy -f && vagrant up
```