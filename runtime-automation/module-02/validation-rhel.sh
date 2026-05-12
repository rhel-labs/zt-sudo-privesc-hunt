#!/bin/sh
echo "Validating module called module-02" >> /tmp/progress.log

# Verify the sudoers file still exists (we find it in this module, remove in module 4)
# if [ -f /etc/sudoers.d/devuser-logs ]; then
    # Verify it contains the vulnerable rule
#     if grep -q "/usr/bin/less" /etc/sudoers.d/devuser-logs; then
#         echo "PASS: Found vulnerable sudo configuration" >> /tmp/progress.log
#         exit 0
#     else
#         echo "FAIL: Sudoers file exists but doesn't contain expected rule" >> /tmp/progress.log
#         exit 1
#     fi
# else
#     echo "FAIL: Sudoers file not found (it should exist at this point)" >> /tmp/progress.log
#     exit 1
# fi
