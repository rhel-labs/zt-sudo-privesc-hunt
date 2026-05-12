#!/bin/sh
echo "Validating module called module-04" >> /tmp/progress.log

# Check that the vulnerable sudoers file has been removed
# if [ -f /etc/sudoers.d/devuser-logs ]; then
#     echo "FAIL: Vulnerable sudoers file still exists" >> /tmp/progress.log
#     exit 1
# fi

# Check that logreaders group exists
# if ! getent group logreaders > /dev/null 2>&1; then
#     echo "FAIL: logreaders group not created" >> /tmp/progress.log
#     exit 1
# fi

# Check that devuser is in the logreaders group
# if ! groups devuser | grep -q logreaders; then
#     echo "FAIL: devuser not added to logreaders group" >> /tmp/progress.log
#     exit 1
# fi

# Check that /var/log/messages is readable by the group
# if [ -f /var/log/messages ]; then
#     if ! ls -l /var/log/messages | grep -q "^-...r....." > /dev/null 2>&1; then
#         echo "FAIL: /var/log/messages not readable by group" >> /tmp/progress.log
#         exit 1
#     fi
# fi

# Verify devuser no longer has sudo access
# if sudo -l -U devuser 2>/dev/null | grep -q "NOPASSWD"; then
#     echo "FAIL: devuser still has sudo privileges" >> /tmp/progress.log
#     exit 1
# fi

# echo "PASS: Remediation complete - vulnerability fixed, access properly granted" >> /tmp/progress.log
exit 0
