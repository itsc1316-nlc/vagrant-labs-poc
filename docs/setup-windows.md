# Setup Guide — Windows 10 or 11

Use this guide if your computer runs Windows 10 or Windows 11. No experience
with Git, Linux, terminals, or virtual machines is required.

These instructions support standard 64-bit Windows computers with an Intel or
AMD processor. They have not been verified on Windows on ARM.

## Before You Start

You need:

- permission to install applications on the computer
- an internet connection
- about 5 GB of free storage for one VM or 10 GB for two VMs
- the Canvas assignment that tells you to use the `single` or `dual` profile

This guide uses **PowerShell**, which is included with Windows, for commands on
your computer. Commands entered after `vagrant ssh client` run inside the
Fedora VM instead. The guide identifies that change when it happens.

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
2. Find **Windows** and download the **AMD64** installer. Despite the name,
   AMD64 is the correct choice for standard 64-bit computers with either an
   Intel or AMD processor.
3. Open the downloaded installer and follow its prompts.
4. Restart Windows when the installer finishes. This makes the `vagrant`
   command available to newly opened terminals.

## Step 3: Install Git

Git downloads this lab project from GitHub. Its installer makes the `git`
command available in PowerShell.

1. Open <https://git-scm.com/install/windows>.
2. The Git for Windows download should begin automatically. Open it when the
   download finishes.
3. Keep the installer defaults unless your instructor gave different settings.
4. If the installer shows an **Adjusting your PATH environment** page, keep
   the option that allows Git to run from the command line and third-party
   software.
5. Finish the installation.
6. Open the **Start menu**, type **PowerShell**, and select **Windows
   PowerShell**. Open it normally; do not select **Run as administrator**.

A window with a prompt beginning with `PS` should appear. The prompt means
PowerShell is ready for a command.

### How to Enter a PowerShell Command

You do not need to memorize these commands.

1. Click in the PowerShell window after the `>` character in the prompt.
2. Copy one command line from this guide.
3. Paste it with **Ctrl+V**.
4. Make sure you did not copy the word `powershell`, the three backticks, or
   prompt text such as `PS C:\Users\Student>`.
5. Press **Enter once**.
6. Wait for the `PS ...>` prompt to return before entering the next command.

Some successful PowerShell commands display no message and immediately show
the prompt again. Error messages normally appear in red. If you receive an
error, stop and read it rather than continuing.

Characters such as `$`, `:`, quotation marks, and backslashes shown inside a
command are part of that command. Copy them exactly.

## Step 4: Check the Installations

In PowerShell, enter these commands one line at a time:

```powershell
git --version
vagrant --version
```

Expected result:

- the first command prints a Git version
- the second command prints a Vagrant version

The exact version numbers may differ. If PowerShell says that a command is not
recognized, close PowerShell, restart Windows, and retry before continuing.

## Step 5: Download the Lab Project

The first command moves to your Windows user folder. `$HOME` automatically
means a location such as `C:\Users\YourName`. The second command downloads the
project. The third command moves into the new project folder.

Enter each line separately in PowerShell:

```powershell
Set-Location $HOME
git clone https://github.com/itsc1316-nlc/vagrant-labs-poc.git
Set-Location "$HOME\vagrant-labs-poc"
```

Here is what each line does:

- `Set-Location $HOME` moves PowerShell to your Windows user folder.
- `git clone ...` creates a folder named `vagrant-labs-poc` and downloads the
  project into it.
- `Set-Location "$HOME\vagrant-labs-poc"` moves PowerShell into that project
  folder. The quotation marks keep the path together if your user-folder path
  contains spaces.

Expected result:

- `git clone` prints lines beginning with `Cloning into`
- after `Set-Location`, the prompt includes `vagrant-labs-poc`

You only run `git clone` once. If Git says the folder already exists, do not
clone it again. Enter this instead:

```powershell
Set-Location "$HOME\vagrant-labs-poc"
```

## Step 6: Start the Assigned Profile

Look at your Canvas assignment. In PowerShell, run the two lines for your
assigned profile while you are in the `vagrant-labs-poc` folder.

For the `single` profile:

```powershell
$env:PROFILE = "single"
vagrant up
```

For the `dual` profile:

```powershell
$env:PROFILE = "dual"
vagrant up
```

The `$env:PROFILE` line creates a temporary PowerShell environment setting that
the `vagrant` program can read. It normally produces no output; seeing the
`PS ...>` prompt again means you can enter `vagrant up`.

Enter both lines in the same PowerShell window. Type the `$`, colon, quotation
marks, and profile name exactly as shown. Do not run both the `single` and
`dual` examples.

The first start downloads Fedora and installs the lab tools. It may take 10–20
minutes and display many lines of text. Leave PowerShell open. Continue only
when the command finishes and the `PS` prompt returns.

## Step 7: Connect to the Client VM

In PowerShell, enter:

```powershell
vagrant ssh client
```

The prompt changes to something similar to `[vagrant@client ~]$`. You are now
inside the Fedora Linux client VM. This is a Linux prompt ending in `$`, not a
PowerShell prompt beginning with `PS`.

Until you enter the second `exit` in Step 8, the commands below run inside
Fedora.

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
- the second `exit` leaves the VM and returns to PowerShell on Windows

Only after you are back in PowerShell, shut down the VM or VMs:

```powershell
vagrant halt
```

Do not run `vagrant halt` from inside the Fedora VM. Vagrant commands control
the VM from Windows.

## The Next Time You Work

1. Open **Windows PowerShell**.
2. Move into the project folder:

   ```powershell
   Set-Location "$HOME\vagrant-labs-poc"
   ```

3. Download instructor updates:

   ```powershell
   git pull
   ```

4. Start the saved profile:

   ```powershell
   vagrant up
   ```

5. Connect:

   ```powershell
   vagrant ssh client
   ```

Vagrant remembers the selected profile in this project after the first
successful setup. That is why later sessions do not need another
`$env:PROFILE` command.

## Start Over With Clean VMs

This deletes the course VMs, not your Windows files. Run this command from
PowerShell in the project folder:

```powershell
vagrant destroy --force
```

Then repeat Step 6 with the profile named by your Canvas assignment.

For additional error messages and solutions, see the
[README troubleshooting table](../README.md#troubleshooting).
