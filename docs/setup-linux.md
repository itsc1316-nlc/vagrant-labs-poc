# Setup Guide — Linux

Use this guide on Fedora, Ubuntu, Debian, or a closely related Linux system. No
experience with Git, Vagrant, or virtual machines is required.

This guide uses **libvirt/KVM**, the virtualization system built into Linux.

## Before You Start

You need:

- an account allowed to run `sudo` commands
- an internet connection
- about 5 GB of free storage for one VM or 10 GB for two VMs
- the Canvas assignment that tells you to use the `single` or `dual` profile

A `sudo` command may ask for your Linux login password. Nothing appears while
you type the password. That is normal; type it and press **Enter**.

## Step 1: Open Terminal and Identify Your Distribution

Open your system's **Terminal** application. On many Linux desktops,
**Ctrl+Alt+T** opens it.

A line ending in `$` is the **prompt**. It means Terminal is ready for a
command. Enter:

```bash
cat /etc/os-release
```

Look at the `NAME` line in the output:

- use the **Fedora** instructions below if it says Fedora
- use the **Ubuntu or Debian** instructions if it says Ubuntu, Debian, Linux
  Mint, or another Debian-based distribution

## Step 2: Install Git, Vagrant, and libvirt

Git downloads the lab project. Vagrant creates and controls its virtual
machines. libvirt/KVM runs those machines.

### Fedora

Enter this command in Terminal:

```bash
sudo dnf install git vagrant vagrant-libvirt @virtualization
```

When `dnf` asks whether to continue, type `y` and press **Enter**.

### Ubuntu or Debian

Enter these commands one line at a time:

```bash
sudo apt update
sudo apt install git qemu-kvm libvirt-daemon-system libvirt-clients vagrant vagrant-libvirt
```

When `apt` asks whether to continue, type `Y` and press **Enter**.

## Step 3: Start libvirt and Give Your Account Access

Enter these commands one line at a time:

```bash
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"
```

`$USER` automatically means your current Linux account. Do not replace it with
a password.

The group change takes effect at your next login:

1. Save any open work.
2. Sign out of the Linux desktop.
3. Sign back in.
4. Open Terminal again.

## Step 4: Check the Installations

Enter these commands one line at a time:

```bash
git --version
vagrant --version
virsh --version
vagrant plugin list
```

Expected result:

- the first three commands print version numbers
- `vagrant plugin list` includes `vagrant-libvirt`

The exact version numbers may differ. If a command says `command not found`,
return to Step 2 and make sure its installation finished without errors.

## Step 5: Download the Lab Project

The first command below moves to your Linux user folder. The second command
downloads the project. The third command moves into the downloaded folder.

Enter each line separately in Terminal:

```bash
cd ~
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
```

Expected result:

- `git clone` prints lines beginning with `Cloning into`
- after `cd vagrant-labs-poc`, the prompt includes `vagrant-labs-poc`

You only run `git clone` once. If Git says the folder already exists, enter
this instead:

```bash
cd ~/vagrant-labs-poc
```

## Step 6: Start the Assigned Profile

Look at your Canvas assignment. Run **one** of the following commands in
Terminal while you are in the `vagrant-labs-poc` folder.

For the `single` profile:

```bash
PROFILE=single vagrant up --provider=libvirt
```

For the `dual` profile:

```bash
PROFILE=dual vagrant up --provider=libvirt
```

The first start downloads Fedora and installs the lab tools. It may take 10–20
minutes and display many lines of text. Leave Terminal open. Continue only when
the command finishes and the `$` prompt returns.

## Step 7: Connect to the Client VM

In Terminal, enter:

```bash
vagrant ssh client
```

The prompt changes to something similar to `[vagrant@client ~]$`. You are now
inside the Fedora Linux client VM.

Switch to the student account:

```bash
su - student
```

When Fedora asks for a password, type:

```text
fedora
```

Nothing appears while you type a password. That is normal. Press **Enter** when
you finish. The prompt should now begin with `[student@client`.

Open the assignment in Canvas and perform the lab commands there.

## Step 8: Leave and Shut Down the Lab

When the lab is finished, enter `exit` twice:

```bash
exit
exit
```

- the first `exit` leaves the student account
- the second `exit` leaves the VM and returns to your Linux Terminal

Only after you are back on the host computer, shut down the VM or VMs:

```bash
vagrant halt
```

Do not run `vagrant halt` from inside Fedora. Vagrant commands control the VM
from your host Linux system.

## The Next Time You Work

1. Open **Terminal**.
2. Move into the project folder:

   ```bash
   cd ~/vagrant-labs-poc
   ```

3. Download instructor updates:

   ```bash
   git pull
   ```

4. Start the saved VM or VMs:

   ```bash
   vagrant up
   ```

5. Connect:

   ```bash
   vagrant ssh client
   ```

Vagrant remembers both the profile and libvirt provider after the first
successful setup.

## Start Over With Clean VMs

This deletes the course VMs, not your files in the Linux home folder. Run this
from Terminal in the project folder:

```bash
vagrant destroy -f
```

Then repeat Step 6 with the profile named by your Canvas assignment.

## If Your Instructor Requires VirtualBox

The main instructions use libvirt because it is native to Linux. If your
instructor specifically requires VirtualBox, install VirtualBox and Vagrant
using the instructions for your Linux distribution, then use these start
commands instead:

```bash
PROFILE=single vagrant up
```

or:

```bash
PROFILE=dual vagrant up
```

Do not install and run both libvirt and VirtualBox for this lab at the same
time unless your instructor directs you to do so.

For virtualization errors, permission errors, and other messages, see the
[README troubleshooting table](../README.md#troubleshooting).
