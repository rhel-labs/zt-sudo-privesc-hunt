# Troubleshooting Tools - zt-sudo-privesc-hunt Lab

## Lab Overview
This lab teaches how to identify, test, and remediate sudo misconfigurations that allow privilege escalation through seemingly harmless commands.

## Key Concept
Understanding that many Unix tools can execute arbitrary commands or spawn shells, making them dangerous when granted sudo access.

---

## Tools Used & Their Application

### 1. **sudo** - Execute Commands as Another User
**Purpose:** Core privilege elevation mechanism (and the vulnerability in this lab)

**Usage in Lab:**
- Module 02: Switch to devuser account
  ```bash
  sudo -i -u devuser
  ```
- Module 02: List sudo permissions (critical for auditing!)
  ```bash
  sudo -l
  ```
- Module 03: Execute the vulnerable command
  ```bash
  sudo /usr/bin/less /var/log/messages
  ```

**Slide Points:**
- **sudo -l** is THE audit tool for checking permissions
  - Shows what commands a user can run as root
  - Shows NOPASSWD entries (passwords not required)
  - Critical for security audits
- **sudo -i -u** switches to another user (for testing)
- Understanding sudo syntax:
  ```
  user  host=(runas) NOPASSWD: command
  ```
- **NOPASSWD:** means no password required (very dangerous!)

---

### 2. **ls** - List Directory Contents
**Purpose:** Discover sudo configuration files

**Usage in Lab:**
- Module 02: Find sudoers.d files
  ```bash
  sudo ls -la /etc/sudoers.d/
  ```

**Slide Points:**
- Shows files in /etc/sudoers.d/
- `-la` shows hidden files and permissions
- Helps identify custom sudo rules
- Part of configuration discovery process

---

### 3. **cat** - Display File Contents
**Purpose:** Read sudo configuration files and log files

**Usage in Lab:**
- Module 02: Read the vulnerable sudoers file
  ```bash
  sudo cat /etc/sudoers.d/devuser-logs
  ```
- Module 03: Verify privilege escalation by reading root-only file
  ```bash
  cat /etc/shadow
  ```

**Slide Points:**
- Used to examine sudo rules
- Simple but essential for viewing configurations
- Also used to verify root access (reading /etc/shadow)
- No special flags needed for basic viewing

---

### 4. **less** - Interactive File Pager
**Purpose:** THE VULNERABILITY - seemingly innocent pager with shell escape

**Usage in Lab:**
- Module 03: Demonstrate the exploit
  ```bash
  sudo /usr/bin/less /var/log/messages
  # Then press ! and /bin/bash
  ```

**Slide Points:**
- **Primary purpose:** View files page-by-page
- **Hidden danger:** Can execute shell commands
- **Escape sequences:**
  - Press `!` then type command → executes command
  - Press `v` → opens editor (which can also spawn shells)
  - Press `:e filename` → open different file
- When run with sudo, all spawned commands inherit root privileges
- **GTFOBins** documents this and many other binaries with similar capabilities

---

### 5. **whoami** - Display Current User
**Purpose:** Verify effective user ID (prove privilege escalation worked)

**Usage in Lab:**
- Module 03: Confirm we're running as root
  ```bash
  whoami
  ```

**Slide Points:**
- Simple but critical verification command
- Shows effective user (not necessarily login user)
- Expected output after escalation: `root`
- Quick way to prove exploit success

---

### 6. **id** - Display User and Group IDs
**Purpose:** More detailed identity information than whoami

**Usage in Lab:**
- Module 03: Confirm root privileges
  ```bash
  id
  ```

**Slide Points:**
- Shows UID, GID, and all group memberships
- uid=0(root) confirms root privileges
- More detailed than whoami
- Useful for verifying group memberships in general

---

### 7. **touch** - Create Empty File
**Purpose:** Prove write access to restricted directories

**Usage in Lab:**
- Module 03: Create file in /root (root-only directory)
  ```bash
  touch /root/pwned.txt
  ```

**Slide Points:**
- Demonstrates write access to protected areas
- Creating files in /root proves root access
- Part of proving the exploit's severity
- Shows it's not just read access - full control

---

### 8. **rm** - Remove Files
**Purpose:** Clean up vulnerable sudo configuration

**Usage in Lab:**
- Module 04: Delete the insecure sudoers rule
  ```bash
  sudo rm /etc/sudoers.d/devuser-logs
  ```

**Slide Points:**
- Used to remove the vulnerable configuration
- First step in remediation (remove bad rule)
- Must be done carefully with sudoers files
- Syntax errors in sudoers can break sudo entirely

---

### 9. **groupadd** - Create New Group
**Purpose:** Create security group for proper access control

**Usage in Lab:**
- Module 04: Create logreaders group
  ```bash
  sudo groupadd logreaders
  ```

**Slide Points:**
- Proper access control uses groups, not sudo
- Create group for log reading access
- Follows principle of least privilege
- More maintainable than individual sudo rules

---

### 10. **usermod** - Modify User Accounts
**Purpose:** Add user to group for access control

**Usage in Lab:**
- Module 04: Add devuser to logreaders group
  ```bash
  sudo usermod -aG logreaders devuser
  ```

**Slide Points:**
- `-aG` = append to group (don't remove other groups)
- Adds devuser to logreaders group
- Group-based access is more secure than sudo
- Users can be in multiple groups

---

### 11. **chgrp** - Change Group Ownership
**Purpose:** Set group ownership on log files

**Usage in Lab:**
- Module 04: Change /var/log/messages to logreaders group
  ```bash
  sudo chgrp logreaders /var/log/messages
  ```

**Slide Points:**
- Changes group ownership of files
- Allows group members to access files
- Works with chmod to control group permissions
- Part of proper access control implementation

---

### 12. **chmod** - Change File Permissions
**Purpose:** Set group read permissions on log files

**Usage in Lab:**
- Module 04: Make log file group-readable
  ```bash
  sudo chmod g+r /var/log/messages
  ```

**Slide Points:**
- `g+r` = give group read permission
- Works with chgrp to implement access control
- Proper alternative to sudo for read-only access
- Can be done file-by-file or via logrotate config

---

### 13. **exit** - Exit Shell
**Purpose:** Return to previous user context

**Usage in Lab:**
- Module 02: Exit devuser back to rhel
  ```bash
  exit
  ```
- Module 03: Exit root shell after testing
  ```bash
  exit
  ```

**Slide Points:**
- Returns to previous shell/user
- Important for cleaning up test environments
- Always exit privilege-elevated shells when done
- Multiple exits needed if you've escalated multiple times

---

### 14. **su** - Switch User (Alternative Tool)
**Purpose:** Alternative to sudo for switching users

**Usage in Lab:**
- Optional: Could use instead of sudo -i -u
  ```bash
  su - devuser
  ```

**Slide Points:**
- Different from sudo - requires target user's password
- sudo uses YOUR password, su uses TARGET password
- `su -` provides full login environment
- sudo is preferred for most administrative tasks

---

## Privilege Escalation Flow

### Discovery Phase
1. **sudo -i -u devuser** → Become the suspect user
2. **sudo -l** → List what devuser can run with sudo
   - Output shows: `(root) NOPASSWD: /usr/bin/less`
3. **exit** → Return to admin account

### Investigation Phase
4. **sudo ls /etc/sudoers.d/** → Find custom sudo rules
5. **sudo cat /etc/sudoers.d/devuser-logs** → Read the vulnerable rule
   - Reveals: `devuser ALL=(root) NOPASSWD: /usr/bin/less`

### Exploitation Phase (Testing)
6. **sudo -i -u devuser** → Become devuser again
7. **sudo /usr/bin/less /var/log/messages** → Run allowed command
8. **Press !** and type **/bin/bash** → Spawn root shell
9. **whoami** → Verify we're root
10. **id** → Confirm UID=0
11. **touch /root/pwned.txt** → Prove write access
12. **cat /etc/shadow** → Prove read access to sensitive files
13. **exit** (twice) → Clean up

### Remediation Phase
14. **sudo rm /etc/sudoers.d/devuser-logs** → Remove bad rule
15. **sudo groupadd logreaders** → Create proper access group
16. **sudo usermod -aG logreaders devuser** → Add user to group
17. **sudo chgrp logreaders /var/log/messages** → Change file group
18. **sudo chmod g+r /var/log/messages** → Add group read permission
19. **sudo -i -u devuser** → Test as devuser
20. **cat /var/log/messages** → Verify file is now readable (no sudo!)
21. **sudo -l** → Verify sudo permissions removed

---

## Key Teaching Points

### Sudo Misconfigurations
- **Common mistake:** "It's just a viewer, what harm could it do?"
- **Reality:** Many Unix tools have hidden capabilities
- **GTFOBins:** Database of binaries that can break out of restricted shells

### Dangerous Commands to Avoid in Sudo Rules
- **Editors:** vim, vi, nano, emacs (all can spawn shells)
- **Pagers:** less, more (can execute commands)
- **File tools:** find (has -exec), tar (can execute via checkpoints)
- **Interpreters:** python, perl, awk, sed (are programming languages!)
- **Shells:** bash, sh (obviously!)
- **Many others:** See GTFOBins (gtfobins.github.io)

### Principle of Least Privilege
- Don't use sudo for read-only access
- Use groups and file permissions instead
- sudo should be reserved for actions that truly need elevation
- Narrow scope as much as possible

### Proper Solutions
| Need | Bad Solution | Good Solution |
|------|--------------|---------------|
| Read logs | sudo less | Group + chmod g+r |
| Find files | sudo find | Group + appropriate permissions |
| Edit config | sudo vim | Specific app that validates changes |
| Run script | sudo script.sh | Limited sudoers entry with full path & args |

### Secure Sudoers Patterns
```
# BAD - Can escape to shell
devuser ALL=(root) NOPASSWD: /usr/bin/less

# BETTER - But still risky (vim can spawn shells)
devuser ALL=(root) NOPASSWD: /usr/bin/vim /etc/app/config.conf

# BEST - Use groups instead
# No sudo needed, just proper file permissions
```

---

## Slide Deck Suggestions

### Slide 1: The Setup
- InfoSec alert about privilege escalation
- Manager Scott tried to help
- Gave devuser sudo access to "less" for reading logs

### Slide 2: Discovery - sudo -l
```
$ sudo -l
User devuser may run the following commands:
    (root) NOPASSWD: /usr/bin/less
```
- "Looks innocent enough..."

### Slide 3: The Sudoers File
```
devuser ALL=(root) NOPASSWD: /usr/bin/less
```
Breakdown:
- devuser = who
- ALL = from any host  
- (root) = run as root
- NOPASSWD = no password needed
- /usr/bin/less = what command

### Slide 4: Less Than Meets The Eye
**Primary function:** View files page-by-page
**Hidden capabilities:**
- `!command` - execute shell command
- `v` - open in editor (which can spawn shell)
- `:e file` - open different file

### Slide 5: The Exploit
```
$ sudo /usr/bin/less /var/log/messages
  (viewing file...)
!
!/bin/bash
# whoami
root
# id
uid=0(root) gid=0(root) groups=0(root)
```

### Slide 6: Proof of Concept
```
# touch /root/pwned.txt        ← Can create files as root
# cat /etc/shadow               ← Can read protected files
# cat /etc/sudoers              ← Can see all sudo config
# useradd backdoor              ← Could create users
```
**Full root access achieved!**

### Slide 7: Other Dangerous Binaries
**GTFOBins** (gtfobins.github.io) catalogs Unix binaries that can:
- Execute commands
- Write files
- Read files
- Upload/download
- Spawn shells

**Examples:** vim, find, tar, awk, python, perl, ftp, scp, rsync...

### Slide 8: The Fix - Remove Sudo
```bash
# Remove the vulnerable rule
sudo rm /etc/sudoers.d/devuser-logs

# Verify it's gone
sudo -i -u devuser
sudo -l
  → "User devuser is not allowed to run sudo"
```

### Slide 9: The Fix - Proper Access Control
```bash
# Create group for log readers
sudo groupadd logreaders

# Add devuser to group
sudo usermod -aG logreaders devuser

# Make logs readable by group
sudo chgrp logreaders /var/log/messages
sudo chmod g+r /var/log/messages

# Test - no sudo needed!
cat /var/log/messages  ✓
```

### Slide 10: Comparison
**Before (Insecure):**
- User needs sudo to read files
- Sudo command can spawn shell
- Full root access achieved

**After (Secure):**
- User in logreaders group
- Files have group read permission  
- No elevation needed
- No path to root

### Slide 11: Best Practices
✓ Default deny - only grant specific needed access
✓ Use groups + permissions instead of sudo when possible
✓ Never grant sudo to editors, pagers, interpreters
✓ Always specify full paths in sudoers
✓ Use `sudo -l` to audit user permissions
✓ Consult GTFOBins before approving sudo requests
✓ Prefer PASSWD over NOPASSWD (require password)
✓ Log and monitor sudo usage

### Slide 12: Tool Summary
| Tool | Purpose | Key Usage |
|------|---------|-----------|
| sudo -l | Audit permissions | Security checks |
| cat | Read configs | View sudoers files |
| less | View files | THE VULNERABILITY |
| whoami/id | Verify identity | Confirm escalation |
| rm | Remove files | Delete bad rules |
| groupadd | Create group | Proper access control |
| usermod | Modify user | Add to groups |
| chgrp/chmod | File permissions | Group-based access |

---

## Demo Script Notes

1. Start as rhel user
2. sudo -i -u devuser, run sudo -l (show the less permission)
3. exit back to rhel
4. Read the sudoers file with cat
5. Explain what it means
6. sudo -i -u devuser again
7. sudo /usr/bin/less /var/log/messages
8. Press ! and /bin/bash
9. whoami (root!)
10. touch /root/pwned.txt
11. cat /etc/shadow
12. **Explain severity** - full system compromise
13. exit twice
14. Show the fix (rm sudoers file)
15. Show proper solution (group + chmod)
16. Test as devuser - can read without sudo
17. Try sudo -l as devuser - no permissions
18. Emphasize: same access, zero escalation path
