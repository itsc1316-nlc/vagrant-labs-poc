# Setup Guide — macOS (Apple Silicon / ARM)

Follow these steps to run the ITSC-1316 Linux lab on a Mac with an Apple Silicon chip (M1, M2, M3, M4, or M5).

> **Why this guide is different:** VirtualBox does not support Apple Silicon. We use **UTM** instead, which is a free virtualization app built for Apple Silicon.

## Step 1: Install UTM

1. Go to <https://mac.getutm.app>
2. Click **Download** to get the free version
3. Open the downloaded `.dmg` file
4. Drag UTM to your Applications folder
5. Open UTM at least once so macOS recognizes it

> You can also install via Homebrew: `brew install --cask utm`

## Step 2: Install Vagrant

Open **Terminal** (Cmd+Space, type "Terminal") and run:

```bash
brew tap hashicorp/tap
brew install --cask hashicorp/tap/hashicorp-vagrant
```

## Step 3: Install the UTM Vagrant Plugin

```bash
vagrant plugin install vagrant_utm
```

## Step 4: Clone the Lab Repository

Still in Terminal:

```bash
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
```

> If your instructor gave you a different URL, use that instead.

## Step 5: Start the Lab

```bash
PROFILE=single vagrant up --provider=utm
```

Replace `single` with the profile your instructor assigned (see the Lab-to-Profile table in the README).

This downloads and configures a Fedora Linux VM using UTM. The first run takes 10–20 minutes. Let it finish.

> If you see an error about the provider, make sure UTM is open and running in the background.

## Step 6: Connect to the Client VM

```bash
vagrant ssh client
```

You are now inside the Linux client VM. To switch to the student account:

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
vagrant destroy -f && PROFILE=single vagrant up --provider=utm
```

Replace `single` with the profile you are working on.