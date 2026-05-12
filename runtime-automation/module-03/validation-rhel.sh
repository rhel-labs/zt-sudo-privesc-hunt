#!/bin/sh
echo "Validating module called module-03" >> /tmp/progress.log

# Module 3 is about understanding the vulnerability
# Just verify the vulnerable configuration still exists
# if [ -f /etc/sudoers.d/devuser-logs ]; then
    # Verify devuser can still use sudo (before remediation in module 4)
#     if sudo -l -U devuser 2>/dev/null | grep -q "/usr/bin/less"; then
#         echo "PASS: Vulnerability still exists (as expected before remediation)" >> /tmp/progress.log
#         exit 0
#     else
#         echo "FAIL: Sudo rule not found for devuser" >> /tmp/progress.log
#         exit 1
#     fi
# else
#     echo "FAIL: Sudoers file removed too early" >> /tmp/progress.log
#     exit 1
# fi
