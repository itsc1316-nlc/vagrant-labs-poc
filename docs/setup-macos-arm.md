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
brew install hashicorp/tap/vagrant
```

## Step 3: Install the UTM Vagrant Plugin

```bash
vagrant plugin install vagrant_utm
```

## Step 4: Clone the Lab Repository

Still in Terminal:

```bash
git clone https://github.com/itsc1316/linux_lab_poc.git
cd linux_lab_poc
```

> If your instructor gave you a different URL, use that instead.

## Step 5: Start the Lab

```bash
vagrant up --provider=utm
```

This downloads and configures two Fedora Linux VMs using UTM. The first run takes 10–20 minutes. Let it finish.

> If your instructor told you to use a specific lab (not the default), run:
> ```bash
> LAB=lab-04 vagrant up --provider=utm
> ```
> Replace `lab-04` with the lab your instructor assigned.

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

## When You Are Done

To shut down the VMs:

```bash
vagrant halt
```

To delete and rebuild from scratch:

```bash
vagrant destroy -f && vagrant up --provider=utm
```