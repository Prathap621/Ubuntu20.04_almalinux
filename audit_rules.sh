#!/bin/bash

# Log function to print and log messages
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a /root/output.log
}

# Set the audit rules
audit_rules=$(cat <<EOF
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k audit_time_rules
-a always,exit -F arch=b64 -S clock_settime -k audit_time_rules
-w /etc/security/opasswd -p wa -k identity
-w /etc/issue -p wa -k system-locale
-w /etc/group -p wa -k audit_account_changes
-w /etc/passwd -p wa -k audit_account_changes
-w /etc/gshadow -p wa -k audit_account_changes
-w /etc/shadow -p wa -k audit_account_changes
-w /etc/security/opasswd -p wa -k audit_account_changes
-a always,exit -F arch=b64 -S sethostname -k system-locale
-a always,exit -F arch=b64 -S setdomainname -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/issue -p wa -k audit_network_modifications
-w /etc/apparmor/ -p wa -k MAC-policy
-w /var/log/btmp -p wa -k session
-a always,exit -F arch=b32 -S chown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S lsetxattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S removexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S lremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fchmod -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fchmod -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fchmodat -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S chown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S fchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fchown -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S fchownat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fchownat -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S lsetxattr -F auid=0 -k perm_mod
-a always,exit -F arch=b64 -S fsetxattr -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S fsetxattr -F auid=0 -k perm_mod
-a always,exit -F path=/bin/ping6 -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/bin/fusermount -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F path=/bin/mount -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete
-a always,exit -F arch=b64 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S removexattr -F auid=1000 -k perm_mod
-a always,exit -F arch=b64 -S lremovexattr -F auid=1000 -k perm_mod
-a always,exit -F arch=b64 -S fremovexattr -F auid=1000 -k perm_mod
-a always,exit -F arch=b64 -S open -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S open -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access
-w /bin/sudo -p a -k privileged
-w /var/log/lastlog -p wa -k logins
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules
-w /etc/localtime -p wa -k time-change
-w /etc/localtime -p wa -k audit_time_rules
-w /etc/hosts -p wa -k system-locale
-w /etc/apparmor.d/ -p wa -k MAC-policy
-w /var/log/faillog -p wa -k logins
-w /var/log/tallylog -p wa -k logins
-w /var/run/utmp -p wa -k session
-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b64 -S mount -F auid=0 -k mounts
-w /etc/sudoers -p wa -k scope
-w /etc/sudoers -p wa -k actions
-w /var/log/sudo.log -p wa -k actions
-w /sbin/modprobe -p x -k modules
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /etc/hosts -p wa -k audit_network_modifications
-w /etc/issue.net -p wa -k audit_network_modifications
-w /etc/sudoers.d/ -p wa -k scope
-w /var/log/wtmp -p wa -k session
-w /etc/network/ -p wa -k system-locale
-e 2
EOF
)

# Determine the architecture
arch=$(uname -m)

# Check if the architecture is supported
if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
    log_message "Unsupported architecture: $arch. Only x86_64 and arm64 (aarch64) are supported."
    exit 1
fi

# Check OS version
os_version=$(lsb_release -sr)
if [[ "$os_version" != "20.04" && "$os_version" != "22.04" && "$os_version" != "24.04" ]]; then
    log_message "Unsupported OS version: $os_version. Only Ubuntu 20.04, 22.04, and 24.04 are supported."
    exit 1
fi

# Check if audit rules are already set
existing_rules=$(auditctl -l)

if [[ "$existing_rules" == *"$audit_rules"* ]]; then
    log_message "Audit rules are already set."
else
    log_message "Setting audit rules..."
    echo "$audit_rules" > /etc/audit/rules.d/custom.rules
    log_message "Audit rules have been set."
fi

# Reload audit rules
augenrules --load
log_message "Reloaded audit rules."

# Restart auditd service
service auditd restart
log_message "Audit service restarted."

log_message "Audit setup completed."
