#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Define the log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check for supported Ubuntu versions
supported_ubuntu_versions=("20.04" "22.04" "24.04")
os_version=$(lsb_release -rs)
is_ubuntu=false

for version in "${supported_ubuntu_versions[@]}"; do
    if [[ "$os_version" == "$version" ]]; then
        is_ubuntu=true
        log_action "Match: Ubuntu version $os_version supported."
        break
    fi
done

if [ "$is_ubuntu" = false ]; then
    log_action "Unmatch: Ubuntu version $os_version is not supported."
    exit 1
fi

# Check for architecture
arch=$(uname -m)
if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
    log_action "Unmatch: Architecture $arch is not supported for Ubuntu."
    exit 1
else
    log_action "Match: Architecture $arch is supported for Ubuntu."
fi

# Use find to locate log files under /var/log and change their permissions
log_files=$(find /var/log -type f)

if [ -z "$log_files" ]; then
    log_action "Doesn't exist: No log files found under /var/log."
else
    log_action "Exists: Found log files under /var/log."
    for file in $log_files; do
        chmod g-wx,o-rwx "$file"
        log_action "Updated permissions for $file."
    done
fi

log_action "Permissions for log files under /var/log have been updated."
