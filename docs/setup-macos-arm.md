# Setup Guide — Mac with Apple Silicon

Use this guide if **About This Mac** lists an Apple M1, M2, M3, M4, or M5
chip. No experience with Git, Linux, Terminal, or virtual machines is required.

This lab uses **UTM** to run Fedora Linux on Apple Silicon.

## Before You Start

You need:

- the administrator password for your Mac so you can install applications
- an internet connection
- about 5 GB of free storage for one VM or 10 GB for two VMs
- the Canvas assignment that tells you to use the `single` or `dual` profile

Commands in this guide are entered in **Terminal** on your Mac. Do not enter
them inside the Fedora VM unless the guide specifically says to do so.

## Step 1: Install UTM

UTM is the application that runs the Fedora Linux virtual machines.

1. Open <https://mac.getutm.app> in your web browser.
2. Select **Download** to download the free version.
3. Open the downloaded `.dmg` file.
4. Drag **UTM** into the **Applications** folder shown in the installer window.
5. Open **Finder**, select **Applications**, and open **UTM**.
6. If macOS asks whether you want to open an application downloaded from the
   internet, select **Open**.
7. After the UTM window appears, you may close it. Opening it once allows the
   Vagrant plugin to find it later.

## Step 2: Install Vagrant

Vagrant creates and controls the course virtual machines.

1. Open <https://developer.hashicorp.com/vagrant/install>.
2. Find **macOS** and download the **ARM64** installer.
3. Open the download and run the installer package inside it.
4. Follow the installer prompts. Enter your Mac administrator password if
   macOS asks for it.
5. Close the installer when it reports that installation succeeded.

## Step 3: Open Terminal and Install Git

Git downloads this lab project from GitHub. macOS can install Git through its
Command Line Tools.

1. Press **Command+Space** to open Spotlight Search.
2. Type **Terminal** and press **Return**.
3. A window with a line ending in `%` or `$` appears. That line is the
   **prompt**. It means Terminal is ready for a command.
4. Enter:

   ```bash
   git --version
   ```

5. If macOS offers to install the Command Line Developer Tools, select
   **Install**, accept the license, and wait for installation to finish.
6. Enter `git --version` again. It should print a Git version number.

Now verify Vagrant:

```bash
vagrant --version
```

The exact version numbers may differ. If Terminal says `command not found`,
close Terminal, open it again, and retry before continuing.

## Step 4: Install the UTM Vagrant Plugin

Vagrant needs one additional plugin to control UTM. In Terminal, enter:

```bash
vagrant plugin install vagrant_utm
```

Wait until the command reports that the plugin was installed. Then verify it:

```bash
vagrant plugin list
```

The output must include `vagrant_utm`. You only install this plugin once.

## Step 5: Download the Lab Project

The first command below moves to your Mac user folder. The second command
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
PROFILE=single vagrant up --provider=utm
```

For the `dual` profile:

```bash
PROFILE=dual vagrant up --provider=utm
```

The first start downloads Fedora and installs the lab tools. It may take 10–20
minutes and display many lines of text. Leave Terminal open. If macOS asks UTM
for permission to access files or the network, allow it.

Continue only when the command finishes and the `%` or `$` prompt returns.

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

Nothing appears while you type a password. That is normal. Press **Return**
when you finish. The prompt should now begin with `[student@client`.

Open the assignment in Canvas and perform the lab commands there.

## Step 8: Leave and Shut Down the Lab

When the lab is finished, enter `exit` twice:

```bash
exit
exit
```

- the first `exit` leaves the student account
- the second `exit` leaves the VM and returns to macOS Terminal

Only after you are back on your Mac, shut down the VM or VMs:

```bash
vagrant halt
```

Do not run `vagrant halt` from inside Fedora. Vagrant commands control the VM
from macOS.

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

Vagrant remembers both the profile and UTM provider after the first successful
setup.

## Start Over With Clean VMs

This deletes the course VMs, not your Mac files. Run this from macOS Terminal
in the project folder:

```bash
vagrant destroy -f
```

Then repeat Step 6 with the profile named by your Canvas assignment.

For UTM errors, network problems, and other messages, see the
[README troubleshooting table](../README.md#troubleshooting).
