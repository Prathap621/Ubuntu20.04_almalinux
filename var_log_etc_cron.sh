#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check for supported Ubuntu versions
UBUNTU_VERSIONS=("20.04" "22.04" "24.04")
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)

if [[ "$OS_NAME" == "Ubuntu" ]] && [[ " ${UBUNTU_VERSIONS[@]} " =~ " ${OS_VERSION} " ]]; then
    log_action "Running on supported Ubuntu version: $OS_VERSION"
else
    log_action "Unsupported OS or version: $OS_NAME $OS_VERSION. Exiting."
    exit 1
fi

# Check for Red Hat flavor
if [[ "$OS_NAME" == "RedHat" || "$OS_NAME" == "CentOS" || "$OS_NAME" == "Fedora" ]]; then
    log_action "Running on Red Hat flavor: $OS_NAME $OS_VERSION"
else
    log_action "Unsupported OS flavor: $OS_NAME. Exiting."
    exit 1
fi

# Check if permissions are already set for log files
if find /var/log -type f -perm /220 ! -perm /444 -print -quit | grep -q .; then
    log_action "Permissions for log files are not set correctly. Updating permissions..."
    find /var/log -type f -exec chmod g-wx,o-rwx {} +
    log_action "Permissions for log files updated."
else
    log_action "Permissions for log files are already set correctly. No change needed."
fi

# Check if permissions are already set for /etc/cron.d/
if [ "$(stat -c %a /etc/cron.d/)" -ne 600 ]; then
    log_action "Permissions for /etc/cron.d/ are not set correctly. Updating permissions..."
    sudo chmod 600 /etc/cron.d/
    log_action "Permissions for /etc/cron.d/ updated."
else
    log_action "Permissions for /etc/cron.d/ are already set correctly. No change needed."
fi

