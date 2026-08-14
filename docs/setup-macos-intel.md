# Setup Guide — macOS (Intel)

Follow these steps to run the ITSC-1316 Linux lab on an Intel-based Mac (any Mac with an Intel processor).

## Step 1: Install VirtualBox

1. Go to <https://www.virtualbox.org/wiki/Downloads>
2. Click **OS X hosts** to download the `.dmg` file
3. Open the `.dmg` and double-click **VirtualBox.pkg**
4. Follow the installer wizard and accept all defaults
5. If macOS blocks the install, go to **System Settings > Privacy & Security** and click **Open Anyway**

## Step 2: Install Vagrant

**Option A — Homebrew (recommended):**

```bash
brew tap hashicorp/tap
brew install --cask hashicorp/tap/hashicorp-vagrant
```

**Option B — Direct download:**

1. Go to <https://developer.hashicorp.com/vagrant/downloads>
2. Download the **macOS (Intel)** `.dmg` file
3. Open it and drag Vagrant to your Applications folder

## Step 3: Clone the Lab Repository

Open **Terminal** (Cmd+Space, type "Terminal") and run:

```bash
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
```

> If your instructor gave you a different URL, use that instead.

## Step 4: Start the Lab

```bash
LAB=lab-13 vagrant up
```

Replace `lab-13` with the lab your instructor assigned (see the Available Labs table in the README).

This downloads and configures two Fedora Linux VMs. The first run takes 10–20 minutes. Let it finish.

## Step 5: Connect to the Client VM

```bash
vagrant ssh client
```

You are now inside the Linux client VM. To switch to the student account:

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

vagrant destroy -f && LAB=lab-13 vagrant up
```

Replace `lab-13` with the lab you are working on.