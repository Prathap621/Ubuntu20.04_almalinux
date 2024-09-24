#!/bin/bash

# Define the paths for the original and backup files
original_file="/etc/pam.d/common-password"
backup_file="/etc/pam.d/common-password.bak"
log_file="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Check OS version and architecture
os_version=$(lsb_release -rs)
architecture=$(uname -m)

if [[ "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04" ]]; then
    log_action "OS version $os_version is supported."
else
    log_action "OS version $os_version is not supported. Exiting."
    exit 1
fi

if [[ "$architecture" == "x86_64" || "$architecture" == "aarch64" ]]; then
    log_action "Architecture $architecture is supported."
else
    log_action "Architecture $architecture is not supported. Exiting."
    exit 1
fi

# Check if the original file exists
if [[ -f "$original_file" ]]; then
    log_action "Original file $original_file exists."
else
    log_action "Original file $original_file doesn't exist. Exiting."
    exit 1
fi

# Backup the original file
if sudo cp "$original_file" "$backup_file"; then
    log_action "Backup created at $backup_file."
else
    log_action "Failed to create backup at $backup_file."
    exit 1
fi

# Update with new content
new_content="password  sufficient   pam_unix.so use_authok md5 shadow
password  sufficient   pam_krb5.so use_first_pass ignore_root
password  required     pam_deny.so"

# Remove the original file's contents
if sudo truncate -s 0 "$original_file"; then
    log_action "Original file contents removed."
else
    log_action "Failed to truncate original file $original_file."
    exit 1
fi

# Add new content to the original file
if echo "$new_content" | sudo tee "$original_file" > /dev/null; then
    log_action "Original file updated with new content."
else
    log_action "Failed to update original file $original_file."
    exit 1
fi
