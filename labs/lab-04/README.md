# Lab 04: Building and Securing the IOTBN Directory Structure

> **This is a local Vagrant-based version of the Canvas lab.**
> Instead of a single cloud workstation, you have two Fedora VMs — a **client** where you do your work and a **server** for testing. This lab runs entirely on the client VM.

## Lab Overview

| Item | Value |
|------|-------|
| **Course** | ITSC-1316 Linux Primary Shell |
| **Module** | 4 — File Management |
| **Textbook** | Eckert, *Linux+* 6e, Chapter 4 |
| **Points** | 40 |
| **Time** | 90–120 minutes |
| **Environment** | Vagrant single-VM profile (client) |

## Before You Begin

> **Starting this lab:** This lab uses the `single` profile (one VM). If you haven't already started it, run:
> ```bash
> PROFILE=single vagrant up
> ```
> If you are on a Mac with Apple Silicon (M1–M5), add `--provider=utm`:
> ```bash
> PROFILE=single vagrant up --provider=utm
> ```
> If you are on Linux using KVM/libvirt, add `--provider=libvirt`:
> ```bash
> PROFILE=single vagrant up --provider=libvirt
> ```
> See your platform setup guide in the `docs/` folder for details.

1. Make sure the VM is running:

   ```bash
   vagrant status
   ```

   If it is down, run the same `PROFILE=single vagrant up` command (with your provider flag if needed).

2. Log into the **client** VM:

   ```bash
   vagrant ssh client
   ```

3. Switch to the student user:

   ```bash
   su - student
   ```

   Password: `fedora`

---

## Assignment

### IOTBN INC. // INFRASTRUCTURE ENGINEERING

#### Building and Securing the IOTBN Directory Structure

**40 points** · Chapter 4

**MEMO — FROM THE OFFICE OF THE CTO**

Team,

We now have a workstation, a shell, and the ability to find our way around a filesystem. What we do not yet have is a place for company work to live, or any rules about who may touch it.

That changes this week. You are building the `/opt/iotbn` directory tree — one subdirectory per role, plus a shared space where the creative teams collaborate. Then you are locking it down: correct owners, correct groups, correct permissions, and one shared folder configured so that a designer can add a file but cannot delete a colleague's work.

I want two things from this exercise. First, a working structure I can hand to a new hire on day one. Second, evidence that you understand **why** each number you typed was the right number. A permission you cannot explain is a permission you cannot defend in an audit.

— E. Ello, Chief Technology Officer

### Assignment Objectives

| # | Objective | Assessed in |
|---|-----------|-------------|
| 1 | Find files and directories on the filesystem | Step 3 |
| 2 | Describe and create linked files | Step 4 |
| 3 | Explain the function of the Filesystem Hierarchy Standard | Step 1 |
| 4 | Use standard Linux commands to manage files and directories | Step 2 |
| 5 | Modify file and directory ownership | Step 5 |
| 6 | Define and change Linux file and directory permissions | Step 6 |
| 7 | Identify the default permissions created on files and directories | Step 7 |
| 8 | Apply special file and directory permissions | Step 8 |
| 9 | Modify the default access control list (ACL) | Step 9 |
| 10 | View and set filesystem attributes | Step 10 |

**Before You Begin:** Open a document for your answers. Label each answer with its step and question number. Take screenshots as you go — the checklist below tells you exactly which ones.

> **SAFETY:** Several steps use `sudo`. Read every command before you press Enter, and never run `rm -rf` with a path you have not first confirmed with `ls`. There is no Linux command to restore a deleted file. If a command does not match what you see on screen, stop and re-read the output rather than guessing.

---

### Step 1: Tour the Filesystem Hierarchy Standard (10 minutes)

Before you add anything to the filesystem, confirm you understand the map that is already there.

```bash
ls /
ls /etc | head -20
ls /var/log | head -20
ls /opt
# What kind of file is each of these?
file /etc/hostname
file /bin
file /var/log/syslog
```

**Q 1.1** According to the FHS, what belongs in `/etc`, and what belongs in `/var`? Answer in one sentence each, in your own words.

**Q 1.2** Run `ls -ld /bin`. What does the output tell you about `/bin` on Fedora, and how does that differ from the description in Table 4-1 of the textbook?

**Q 1.3** Why is `/opt` the correct FHS location for a company directory tree, rather than `/home` or `/usr`?

---

### Step 2: Build the IOTBN Directory Structure (12 minutes)

Create the company tree, then practice the four file management commands on it.

```bash
sudo mkdir -p /opt/iotbn/{sysadmin,webdev,design,managers,shared}
ls -l /opt/iotbn

# create a few working files to manipulate
cd /opt/iotbn/design
sudo touch logo-draft1.svg logo-draft2.svg brand-notes.txt scratch.tmp
ls -F

# make a subdirectory and move the drafts into it
sudo mkdir drafts
sudo mv logo-draft*.svg drafts
ls -F ; ls -F drafts

# copy a system file in, then copy it again under a new name
sudo cp /etc/hostname ./workstation-name.txt
sudo cp workstation-name.txt workstation-name.bak

# remove the scratch file, then try to remove a non-empty directory
sudo rm scratch.tmp
sudo rmdir drafts
```

**Q 2.1** What exactly did the shell do with the `{sysadmin,webdev,…}` portion of the `mkdir` command? What would have happened without the `-p` option?

**Q 2.2** Paste the error message `rmdir` produced. Why did it refuse, and what single command would remove `drafts` and its contents?

**Q 2.3** Run `alias` on your VM. Does Fedora alias `rm` to `rm -i` the way the textbook describes? What does your answer mean for how carefully you must type?

---

### Step 3: Find Files Three Different Ways (12 minutes)

`locate`, `find`, and `which` each solve a different problem. Use all three and compare.

```bash
# 1) the indexed database
locate brand-notes.txt
sudo updatedb
locate brand-notes.txt

# 2) the live tree walk
sudo find /opt/iotbn -name "*.svg"
sudo find /opt/iotbn -type d
sudo find /opt/iotbn -type f -mmin -60
sudo find /var/log -size +1M

# 3) executables on the PATH
echo $PATH
which chmod
type chmod
whereis chmod
```

**Q 3.1** The first `locate` command probably found nothing, and the second one worked. Explain why, using the word *database* in your answer.

**Q 3.2** Run the `find` command for `.svg` files without the quotation marks. Does the result differ? Explain what the shell does to an unquoted wildcard before `find` ever sees it.

**Q 3.3** Paste your `$PATH`. If someone placed an executable named `ls` in the first directory listed, which `ls` would run when you typed the command, and why?

---

### Step 4: Create and Compare Linked Files (10 minutes)

Prove to yourself that a hard link and a symbolic link are genuinely different things.

```bash
cd /opt/iotbn/design
sudo ln brand-notes.txt brand-notes-hard.txt
sudo ln -s brand-notes.txt brand-notes-soft.txt
ls -li

# edit through one name, read through the others
echo "Primary brand color: teal" | sudo tee -a brand-notes.txt
cat brand-notes-hard.txt
cat brand-notes-soft.txt

# now delete the original and look again
sudo rm brand-notes.txt
ls -li
cat brand-notes-hard.txt
cat brand-notes-soft.txt
```

**Q 4.1** From your `ls -li` output, record the inode number and link count of all three files. Which two share an inode, and what does that prove?

**Q 4.2** After deleting `brand-notes.txt`, one `cat` command still worked and one failed. Explain both results in terms of inodes and data blocks.

**Q 4.3** Give one situation from real system administration where a symbolic link is the right choice and a hard link would not work at all.

---

### Step 5: Set Ownership and Group Ownership (10 minutes)

Each role directory belongs to a team. Assign owners and groups so the org chart is visible in the filesystem.

```bash
whoami
groups
sudo groupadd -f sysadmins
sudo groupadd -f webdevs
sudo groupadd -f designers
sudo groupadd -f managers
sudo groupadd -f creative

sudo chown -R root:sysadmins /opt/iotbn/sysadmin
sudo chown -R root:webdevs /opt/iotbn/webdev
sudo chown -R root:designers /opt/iotbn/design
sudo chown -R root:managers /opt/iotbn/managers
sudo chown -R root:creative /opt/iotbn/shared
ls -l /opt/iotbn

# audit: prove the ownership took effect
sudo find /opt/iotbn -group designers
sudo find /opt/iotbn ! -group root -type d
```

**Q 5.1** Paste the output of `ls -l /opt/iotbn`. Which column is the owner and which is the group owner?

**Q 5.2** Why does `chown -R` matter here? What would `ls -l` inside `/opt/iotbn/design` have shown if you had left off `-R`?

**Q 5.3** Try running `chown` without `sudo` on any file you do not own. Record the error. Why do most distributions prevent regular users from giving away ownership?

---

### Step 6: Set Permissions — Symbolic and Numeric (15 minutes)

Use both notations. You need fluency in each, and the certification exam tests both.

```bash
# numeric: owner full, group read+execute, other nothing
sudo chmod 750 /opt/iotbn/sysadmin
sudo chmod 750 /opt/iotbn/managers

# symbolic: same idea, expressed differently
sudo chmod u=rwx,g=rx,o= /opt/iotbn/webdev
sudo chmod u=rwx,g=rwx,o= /opt/iotbn/design
ls -ld /opt/iotbn/*

# now prove the execute bit is the light switch
sudo chmod o-x /opt/iotbn/design
sudo -u nobody ls /opt/iotbn/design

# files, not directories, get 644
sudo chmod 644 /opt/iotbn/design/workstation-name.txt
ls -l /opt/iotbn/design/workstation-name.txt
```

**Q 6.1** Write the numeric equivalent of `u=rwx,g=rx,o=` and the symbolic equivalent of `640`. Show your arithmetic for the numeric one.

**Q 6.2** Record the exact error from the `sudo -u nobody ls` command. Which single permission bit caused it, and on which object — the directory or the files inside it?

**Q 6.3** A file has mode `-r---w---x`, owner `bob`, group `proj`. Bob is a member of `proj`. What can bob actually do with this file, and why is the answer not "read and write"?

---

### Step 7: Observe and Change the umask (8 minutes)

Default permissions are not an accident. Find out what your system subtracts, and prove it.

```bash
cd ~
umask
mkdir umask-test-a ; touch umask-file-a
ls -ld umask-test-a ; ls -l umask-file-a

umask 027
umask
mkdir umask-test-b ; touch umask-file-b
ls -ld umask-test-b ; ls -l umask-file-b

# restore and confirm the change was not retroactive
umask 022
ls -ld umask-test-a umask-test-b
```

**Q 7.1** What is your VM's default umask? Show the subtraction for both a new file and a new directory, the way Figure 4-5 does in the textbook.

**Q 7.2** Record the modes of `umask-test-b` and `umask-file-b`. Do they match what a umask of `027` predicts?

**Q 7.3** After you changed the umask, did the permissions on `umask-test-a` change? Explain what that tells you about when umask applies and which command you would need instead.

---

### Step 8: Apply Special Permissions to the Shared Directory (15 minutes)

This is the step the CTO cares about most. The shared directory must let the creative teams collaborate without letting them destroy each other's work.

```bash
# SGID + sticky bit + rwx for owner and group, nothing for other
sudo chmod 3770 /opt/iotbn/shared
ls -ld /opt/iotbn/shared
# expected: drwxrws--T ... root creative ... shared

# prove SGID inheritance works
sudo touch /opt/iotbn/shared/campaign-brief.txt
ls -l /opt/iotbn/shared

# look at a real SUID binary
ls -l /usr/bin/passwd

# and a real sticky-bit directory
ls -ld /tmp

# what a special bit looks like when it cannot work
sudo mkdir /opt/iotbn/shared/broken
sudo chmod 1770 /opt/iotbn/shared/broken
sudo chmod o-x /opt/iotbn/shared/broken
ls -ld /opt/iotbn/shared/broken
```

**Q 8.1** Break `3770` into its four digits and explain what each one sets. Then explain, in one sentence each, what SGID and the sticky bit do for the creative team.

**Q 8.2** Look at the group owner of `campaign-brief.txt`. It is not root's primary group. Which special permission caused that, and why does that behavior matter for a shared folder?

**Q 8.3** Record the mode of `/opt/iotbn/shared/broken`. One character is capitalized. What does a capital letter in that position mean, and how would you fix it?

**Q 8.4** Why does `/usr/bin/passwd` have an `s` in the owner's execute position? What would break if you removed it?

---

### Step 9: Grant an Exception with an ACL (10 minutes)

A contractor needs read access to one design file. Nobody else's access should change.

```bash
cd /opt/iotbn/design
sudo touch contractor-brief.txt
sudo chmod 640 contractor-brief.txt
ls -l contractor-brief.txt

# grant one user read access without touching group or other
sudo setfacl -m u:nobody:r-- contractor-brief.txt
ls -l contractor-brief.txt
getfacl contractor-brief.txt

# tighten the mask and observe the effect
sudo setfacl -m mask::--- contractor-brief.txt
getfacl contractor-brief.txt

# remove all extra ACL entries
sudo setfacl -b contractor-brief.txt
ls -l contractor-brief.txt
getfacl contractor-brief.txt
```

**Q 9.1** After `setfacl`, one character appeared at the end of the mode in `ls -l`. What is it, and what is it telling you?

**Q 9.2** Paste the `getfacl` output from before and after you changed the mask. What effective permission does the `nobody` user have in each case, and why?

**Q 9.3** You could have solved the contractor problem by adding `nobody` to the `designers` group instead. Give one reason the ACL is the better choice here.

---

### Step 10: Lock a File with a Filesystem Attribute (8 minutes)

Permissions can be changed by the owner. Attributes operate below permissions — even root is stopped.

```bash
cd /opt/iotbn
sudo tee iotbn-policy.txt > /dev/null <<'EOF'
IOTBN Inc. Infrastructure Policy
All company data resides under /opt/iotbn.
Shared collaboration occurs in /opt/iotbn/shared only.
EOF

lsattr iotbn-policy.txt
sudo chattr +i iotbn-policy.txt
lsattr iotbn-policy.txt

# now try to change it, as root
sudo sh -c 'echo "unauthorized edit" >> iotbn-policy.txt'
sudo rm iotbn-policy.txt
sudo chmod 777 iotbn-policy.txt

# release the lock
sudo chattr -i iotbn-policy.txt
lsattr iotbn-policy.txt
```

> **TIP:** The `tee` block is a heredoc. Type or paste it exactly, including the closing `EOF` on its own line. If your prompt turns into a bare `>` and will not come back, press `Ctrl+C` and start the block over.

**Q 10.1** Record the attribute string before and after `chattr +i`. Which position changed?

**Q 10.2** Paste the error you received when trying to append to the file as root. Explain why root was refused, given that root supersedes all file permissions.

**Q 10.3** Name one file on a production server you would consider making immutable, and explain the risk you would be protecting against.

---

### Step 11: Verify and Snapshot (5 minutes)

Produce a single listing that shows the finished structure, then preserve it.

```bash
ls -ld /opt/iotbn /opt/iotbn/*
sudo find /opt/iotbn -maxdepth 1 -type d -printf '%M %u:%g %p\n'

# clean up the scratch files from Step 7
cd ~ && rmdir umask-test-a umask-test-b && rm -f umask-file-a umask-file-b
```

> **Note:** In the Vagrant environment, you don't need to take a VMware snapshot. If you want to preserve this state, ask your instructor. To start fresh later, run `vagrant destroy -f && PROFILE=single vagrant up` from your host machine (add `--provider=utm` or `--provider=libvirt` if your setup requires it).

**Q 11.1** Paste the full output of the `find` command above. Every directory should show the correct owner, group, and mode.

---

## Screenshot Checklist

Insert each screenshot into your submission document, labeled with its number. A screenshot must show your terminal prompt, so it is clear the commands ran on your VM.

| # | Screenshot | From |
|---|-----------|------|
| 1 | `ls -l /opt/iotbn` showing all five role directories with owners and groups | Step 5 |
| 2 | `ls -li` in `/opt/iotbn/design` showing the hard link, the symlink, and their inode numbers | Step 4 |
| 3 | `ls -ld /opt/iotbn/*` showing the mode of every role directory | Step 6 |
| 4 | `ls -ld /opt/iotbn/shared` showing `drwxrws--T` | Step 8 |
| 5 | `getfacl contractor-brief.txt` with the extra user entry visible | Step 9 |
| 6 | `lsattr iotbn-policy.txt` with the immutable bit set, plus the refused edit | Step 10 |

---

## Reflection Questions

Answer in two to four sentences each, in your own words. These are graded on reasoning, not on length.

1. Linux permissions are not additive — the system applies the first matching category and stops. Describe a scenario where an administrator could grant a permission and still leave a user unable to do the thing they were trying to enable.

2. Deleting a file requires write permission on its **parent directory**, not on the file itself. What does that mean for how you would protect an important configuration file from accidental deletion?

3. Compare the sticky bit and an ACL. Both restrict what users can do in a shared space. When would you reach for each one?

4. The CTO asked for evidence that you understand why each number you typed was the right number. Pick the single permission decision in this lab you are least confident about, and explain what you would test to become confident.

---

## Submission Instructions

Submit one document (`.docx` or `.pdf`) to this assignment in Canvas.

- Include every numbered question answer from Steps 1–11, labeled by step and question number.
- Include all six screenshots, labeled and in order.
- Include your four reflection answers.
- Name your file `lastname_firstname_module04.docx`.
- Late work follows the policy stated in the syllabus.

---

## Grading Rubric

See [rubric.md](rubric.md) for the full grading criteria.

## Bonus (+5 Points)

Write a short shell command (one line is fine) that audits `/opt/iotbn` and reports any directory whose group owner is not one of the five IOTBN groups. Include the command, its output, and one sentence explaining how it works.

## Need Help?

- **Permission denied errors?** Make sure you are using `sudo` where the lab says to.
- **`locate` command not found?** The lab provisions `plocate` — if it is missing, run `sudo dnf install -y plocate && sudo updatedb`.
- **`setfacl` or `getfacl` not found?** Run `sudo dnf install -y acl`.
- **Want to start over?** From your host machine: `vagrant destroy -f && PROFILE=single vagrant up` (add `--provider=utm` or `--provider=libvirt` if your setup requires it).