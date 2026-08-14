# Lab 13: Advanced Network Configuration

> **This is a local Vagrant-based version of the Canvas lab.**
> Instead of a single cloud server, you have two VMs — a **client** and a **server** — connected on a private network. This setup lets you test real cross-machine networking, DNS resolution, and routing behavior.

## Lab Overview

| Item | Value |
|------|-------|
| **Course** | ITSC-1316 Linux Primary Shell |
| **Module** | 13 — Advanced Networking Concepts |
| **Textbook** | Eckert, *Linux+* 6e, Chapter 12 (Completion) |
| **Points** | 40 |
| **Time** | 90–120 minutes |
| **Environment** | Two-VM Vagrant lab (client + server) |

## Topology

```
┌─────────────┐       192.168.56.0/24       ┌─────────────┐
│   client    │◄───────────────────────────►│   server    │
│ .56.10      │        private network       │ .56.20      │
│             │                              │             │
│  DNS → server                              │  dnsmasq    │
│  search:    │                              │  httpd      │
│  corp.local │                              │  SSH host   │
└─────────────┘                              └─────────────┘
```

## Before You Begin

> **Starting this lab:** If you haven't already started the VMs for this lab, run:
> ```bash
> LAB=lab-13 vagrant up
> ```
> If you are on a Mac with Apple Silicon (M1–M5), add `--provider=utm`:
> ```bash
> LAB=lab-13 vagrant up --provider=utm
> ```
> If you are on Linux using KVM/libvirt, add `--provider=libvirt`:
> ```bash
> LAB=lab-13 vagrant up --provider=libvirt
> ```
> See your platform setup guide in the `docs/` folder for details.

1. Make sure both VMs are running:

   ```bash
   vagrant status
   ```
   If either is down, run the same `LAB=lab-13 vagrant up` command (with your provider flag if needed).

2. Log into the **client** VM:

   ```bash
   vagrant ssh client
   ```

3. Switch to the student user:

   ```bash
   su - student
   ```

   Password: `fedora`

4. You should be able to ping the server by IP:

   ```bash
   ping -c 3 192.168.56.20
   ```

---

## Assignment: Choose ONE Option

Complete **only one** option below. If you want hands-on practice (recommended), do Option 2.

---

## Option 1: Linux without the Command Line (No Terminal)

**Goal:** Prove you understand the advanced portions of Chapter 12 by interpreting realistic networking configurations, recognizing common failure modes, and recommending correct next steps — without using a terminal.

**What you will submit:** One document with Parts A–D completed. Keep responses to 2–5 sentences unless a table is requested.

### Part A — Network Configuration Storage (10 points)

Linux can store network configuration in different ways depending on the distribution and tools in use. Answer the following:

1. Explain (in your own words) the difference between **temporary (runtime)** network settings and **persistent** settings.
2. Why might a change appear to "work" until reboot and then disappear?
3. In a professional environment, why is it important to know whether NetworkManager (or an equivalent tool) is managing an interface?

### Part B — Routing and Multi-Network Thinking (10 points)

Below is a simplified routing table view. Interpret it and answer the questions.

```
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0 proto kernel src 10.0.2.15
192.168.56.0/24 dev eth1 proto kernel src 192.168.56.10
```

1. What does the **default route** mean in plain English?
2. Which interface would likely be used to reach `192.168.56.25`? Explain why.
3. If the system can reach hosts on `192.168.56.0/24` but not the internet, what would you check first?
4. In 2–4 sentences, explain why a machine might have **two network interfaces** in a VM or lab environment.

### Part C — DNS and Name Resolution (10 points)

Read the name resolution scenario and answer the questions.

```
# /etc/resolv.conf
nameserver 127.0.0.53
search corp.local
```

**Symptoms:**

- `ping 1.1.1.1` = SUCCESS
- `ping example.com` = FAIL (temporary failure in name resolution)
- `ping fileserver` = FAIL
- `ping fileserver.corp.local` = SUCCESS

1. Based on the symptoms, is the system's problem primarily **connectivity** or **name resolution**?
2. Explain why `fileserver.corp.local` succeeds but `fileserver` fails. (Hint: search domains and resolver behavior.)
3. In plain English, what does a **search domain** do?
4. List two administrative actions that could correct the issue where `fileserver` fails.

### Part D — Troubleshooting Methodology (10 points)

Create a **network troubleshooting playbook** for an administrator responding to a report: "The server is reachable by IP but not by hostname."

Your playbook must include:

- At least **5 steps** in the correct order
- At least one step that verifies **DNS configuration**
- At least one step that verifies **name resolution results**
- At least one step that considers **local host mapping** (hosts file concept)

---

## Option 2: VM / Linux Hands-On — Persistent Config, Routing Awareness, and DNS Validation

**Goal:** Demonstrate advanced Chapter 12 understanding by identifying how your system stores network configuration, validating routing behavior, and confirming DNS/name resolution behavior with evidence.

**Safety Notes:**

- Do this in the Vagrant lab VMs.
- If you are unsure how to revert changes, use Option 1.

**What you will submit:** One report with (1) command outputs, (2) screenshots, and (3) short answers.

### Step 1 — Determine What Manages Networking (10 points)

Collect evidence about how your system manages network configuration:

```bash
systemctl status NetworkManager
nmcli general status
ls /etc/NetworkManager/system-connections/
```

**Deliverable:** Screenshot(s) or pasted outputs + a 2–4 sentence explanation of what tool/framework manages networking on your system.

### Step 2 — Validate Routes and Interfaces (10 points)

Run and capture outputs:

```bash
ip a
ip route
```

**Answer (short):** Identify your default gateway route. If you have multiple interfaces, explain what each appears to be used for.

> **Lab tip:** Your client VM has two interfaces — one NAT (for Vagrant's SSH) and one private (`192.168.56.0/24`). Compare the two.

### Step 3 — Validate DNS and Resolution Behavior (10 points)

Run and capture outputs:

```bash
cat /etc/resolv.conf
getent hosts server.corp.local
ping -c 2 server.corp.local
dig server.corp.local
```

**Answer (short):** What DNS server(s) is your system using, and did resolution succeed? Explain what your outputs prove.

> **Lab tip:** The client VM is configured to use the server VM (`192.168.56.20`) as its DNS server. The server runs `dnsmasq` which resolves names in the `corp.local` zone.

### Step 4 — Make a Safe, Reversible Change (10 points)

Make **one** safe change that can be reverted immediately, then prove the effect with evidence. Choose ONE:

**Option A (Preferred):** Add a temporary host mapping for a made-up name in `/etc/hosts` (then test and remove it).

```bash
# Add the entry
echo "192.168.56.20 mytest.lab.local" | sudo tee -a /etc/hosts

# Test it
ping -c 2 mytest.lab.local

# Remove it (revert)
sudo sed -i '/mytest.lab.local/d' /etc/hosts

# Prove it's gone
ping -c 2 mytest.lab.local
```

**Option B:** Change your DNS server setting using `nmcli` (only if you know how to revert).

**Deliverable:** Screenshot(s) showing:

1. The change made
2. A test that proves the change worked
3. The revert (proof that you restored the original state)

---

## Submission

Submit **only ONE option** (Option 1 or Option 2) as a PDF or DOCX to the Canvas assignment.

Name your file: `lastname_firstname_module13.docx`

---

## Grading Rubric

See [rubric.md](rubric.md) for the full grading criteria.

## Need Help?

- **Can't reach the server?** Run `vagrant reload server` and wait for it to come back up.
- **DNS not resolving?** Check that the server's `dnsmasq` service is running: `vagrant ssh server -c "systemctl status dnsmasq"`
- **SSH to server fails?** From the client as `student`: `ssh student@192.168.56.20`
- **Want to start over?** From your host machine: `vagrant destroy -f && LAB=lab-13 vagrant up` (add `--provider=utm` or `--provider=libvirt` if your setup requires it).