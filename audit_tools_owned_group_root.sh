#!/bin/bash

# Define the log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    local action="$1"
    local description="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $action: $description" >> "$LOG_FILE"
}

# Ensure audit log files are mode 0640 or less permissive
log_files=$(find /var/log/audit/ -type f ! -perm 0640)
if [[ -z "$log_files" ]]; then
    log_action "match" "Audit log files already have permissions of 0640 or less permissive."
else
    find /var/log/audit/ -type f -exec chmod 0640 {} +
    log_action "unmatch" "Audit log files permissions set to 0640 or less permissive."
fi

# Ensure the audit log directory is 0750 or more restrictive
log_dir_perms=$(stat -c "%a" /var/log/audit/)
if [[ "$log_dir_perms" == "750" ]]; then
    log_action "match" "Audit log directory already has permissions of 0750 or more restrictive."
else
    chmod 0750 /var/log/audit/
    log_action "unmatch" "Audit log directory permissions set to 0750 or more restrictive."
fi

# Ensure audit configuration files are 640 or more restrictive
config_files=$(find /etc/audit/ -type f ! -perm 640)
if [[ -z "$config_files" ]]; then
    log_action "match" "Audit configuration files already have permissions of 640 or more restrictive."
else
    find /etc/audit/ -type f -exec chmod 640 {} +
    log_action "unmatch" "Audit configuration files permissions set to 640 or more restrictive."
fi

# Ensure audit configuration files are owned by root
config_ownership=$(find /etc/audit/ ! -user root)
if [[ -z "$config_ownership" ]]; then
    log_action "match" "Audit configuration files are already owned by root."
else
    chown root:root /etc/audit/*
    log_action "unmatch" "Audit configuration files ownership set to root:root."
fi

# Ensure audit tools are owned by root
tools_ownership=$(stat -c '%U:%G' /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules)
if [[ "$tools_ownership" == "root:root" ]]; then
    log_action "match" "Audit tools are already owned by root."
else
    chown root:root /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules
    log_action "unmatch" "Audit tools ownership set to root:root."
fi

# Print completion message to the log
log_action "complete" "Audit checks and updates completed."
