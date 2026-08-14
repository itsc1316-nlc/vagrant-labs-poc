# Lab 04 Grading Rubric — Building and Securing the IOTBN Directory Structure

**Total Possible Points: 40** (plus 5 bonus)

| Criterion | What Earns Full Credit | Points |
|-----------|------------------------|--------|
| **FHS exploration (Step 1)** | All three questions answered accurately and in the student's own words; the `/bin` symlink observation is correct | 4 |
| **File management (Step 2)** | Directory tree created correctly; `mkdir`, `mv`, `cp`, `rm`, and `rmdir` all demonstrated; `rmdir` error explained | 5 |
| **Finding files (Step 3)** | `locate`, `find`, and `which`/`type`/`whereis` all used; the `updatedb` explanation and the quoting explanation are correct | 4 |
| **Linking files (Step 4)** | Both link types created; inode numbers and link counts recorded; the post-deletion behavior of each explained correctly | 4 |
| **Ownership (Step 5)** | All five role directories carry the correct owner and group; `-R` explained; the `chown` restriction is understood | 4 |
| **Permissions (Steps 6–7)** | Both notations used correctly; the non-additive rule explained; umask observed, changed, and its non-retroactive nature explained | 6 |
| **Special permissions (Step 8)** | `shared` is `drwxrws--T`; each digit of `3770` explained; SGID inheritance demonstrated; the capitalized bit identified and explained | 5 |
| **ACLs and attributes (Steps 9–10)** | ACL added, mask effect observed, ACL removed; immutable attribute set, tested against root, and removed | 4 |
| **Screenshots and reflection (Step 11)** | All six screenshots present, legible, and labeled; four reflection answers show reasoning rather than restatement | 4 |
| **TOTAL** | | **40** |

### Bonus (+5 Points)

Write a short shell command (one line is fine) that audits `/opt/iotbn` and reports any directory whose group owner is not one of the five IOTBN groups. Include the command, its output, and one sentence explaining how it works.