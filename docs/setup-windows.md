# Setup Guide — Windows 10 or 11

Use this guide if your computer runs Windows 10 or Windows 11. No experience
with Git, Linux, terminals, or virtual machines is required.

## Before You Start

You need:

- permission to install applications on the computer
- an internet connection
- about 5 GB of free storage for one VM or 10 GB for two VMs
- the Canvas assignment that tells you to use the `single` or `dual` profile

This guide uses **Git Bash** for commands. Git Bash is a terminal application
installed with Git. Do not enter these commands in the Linux VM unless the
guide specifically says to do so.

## Step 1: Install VirtualBox

VirtualBox is the application that runs the Fedora Linux virtual machine.

1. Open <https://www.virtualbox.org/wiki/Downloads> in your web browser.
2. Select **Windows hosts**.
3. Open the downloaded installer.
4. Select **Next** through the installer and keep the default choices.
5. If Windows warns that network connections may briefly reset, select **Yes**.
6. If Windows asks whether to install device software, select **Install**.
7. When installation finishes, open **Oracle VirtualBox** once, then close it.

## Step 2: Install Vagrant

Vagrant creates and controls the virtual machines for this course.

1. Open <https://developer.hashicorp.com/vagrant/install>.
2. Find **Windows** and download the **AMD64** installer.
3. Open the downloaded installer and follow its prompts.
4. Restart Windows when the installer finishes. This makes the `vagrant`
   command available to newly opened terminals.

## Step 3: Install Git and Git Bash

Git downloads this lab project from GitHub. The Git installer also provides the
Git Bash terminal used in the remaining steps.

1. Open <https://git-scm.com/install/windows>.
2. The Git for Windows download should begin automatically. Open it when the
   download finishes.
3. Keep the installer defaults unless your instructor gave different settings.
4. Finish the installation.
5. Open the **Start menu**, type **Git Bash**, and open **Git Bash**.

A window with a line ending in `$` should appear. That line is the **prompt**.
It means Git Bash is ready for a command.

## Step 4: Check the Installations

In Git Bash, enter these commands one line at a time:

```bash
git --version
vagrant --version
```

Expected result:

- the first command prints a Git version
- the second command prints a Vagrant version

The exact version numbers may differ. If Git Bash says `command not found`,
close Git Bash, restart Windows, and try again before continuing.

## Step 5: Download the Lab Project

The first command below moves to your Windows user folder. The second command
downloads the project. The third command moves into the downloaded folder.

Enter each line separately in Git Bash:

```bash
cd ~
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
cd vagrant-labs-poc
```

Expected result:

- `git clone` prints lines beginning with `Cloning into`
- after `cd vagrant-labs-poc`, the prompt includes `vagrant-labs-poc`

You only run `git clone` once. If Git says the folder already exists, do not
clone it again. Enter this instead:

```bash
cd ~/vagrant-labs-poc
```

## Step 6: Start the Assigned Profile

Look at your Canvas assignment. Run **one** of the following commands in Git
Bash while you are in the `vagrant-labs-poc` folder.

For the `single` profile:

```bash
PROFILE=single vagrant up
```

For the `dual` profile:

```bash
PROFILE=dual vagrant up
```

The first start downloads Fedora and installs the lab tools. It may take 10–20
minutes and display many lines of text. Leave Git Bash open. Continue only when
the command finishes and the `$` prompt returns.

## Step 7: Connect to the Client VM

In Git Bash, enter:

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
- the second `exit` leaves the VM and returns to Git Bash on Windows

Only after you are back in Git Bash, shut down the VM or VMs:

```bash
vagrant halt
```

Do not run `vagrant halt` from inside the Fedora VM. Vagrant commands control
the VM from Windows.

## The Next Time You Work

1. Open **Git Bash**.
2. Move into the project folder:

   ```bash
   cd ~/vagrant-labs-poc
   ```

3. Download instructor updates:

   ```bash
   git pull
   ```

4. Start the saved profile:

   ```bash
   vagrant up
   ```

5. Connect:

   ```bash
   vagrant ssh client
   ```

Vagrant remembers the profile after the first successful setup.

## Start Over With Clean VMs

This deletes the course VMs, not your Windows files. Run these commands from
Git Bash in the project folder:

```bash
vagrant destroy -f
```

Then repeat Step 6 with the profile named by your Canvas assignment.

For additional error messages and solutions, see the
[README troubleshooting table](../README.md#troubleshooting).
