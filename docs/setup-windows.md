# Setup Guide — Windows

Follow these steps to run the ITSC-1316 Linux lab on Windows 10 or 11 (Home or Pro).

## Step 1: Install VirtualBox

1. Go to <https://www.virtualbox.org/wiki/Downloads>
2. Click **Windows hosts** to download the installer
3. Run the downloaded `.exe` file and follow the wizard
4. Accept all defaults — just keep clicking **Next**
5. If Windows shows a security warning about network interfaces, click **Install**

## Step 2: Install Vagrant

1. Go to <https://developer.hashicorp.com/vagrant/downloads>
2. Download the **Windows** installer (`.exe`)
3. Run the installer and follow the wizard
4. Restart your computer after installation finishes

## Step 3: Install Git

1. Go to <https://git-scm.com/download/win>
2. Download and run the installer
3. Accept all defaults
4. After install, open **Git Bash** (search for it in the Start menu)

## Step 4: Clone the Lab Repository

Open **Git Bash** and run:

```bash
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
```

> If your instructor gave you a different URL, use that instead.

## Step 5: Start the Lab

Still in Git Bash, in the `vagrant-labs-poc` folder:

```bash
PROFILE=single vagrant up
```

Replace `single` with the profile your instructor assigned (see the Lab-to-Profile table in the README).

This will download a Fedora Linux VM and set it up. It may take 10–20 minutes the first time. You will see a lot of text scroll by — that is normal.

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

To shut down the VM(s):

```bash
vagrant halt
```

To delete and rebuild from scratch:

```bash
vagrant destroy -f && PROFILE=single vagrant up
```

Replace `single` with the profile you are working on.