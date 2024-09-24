#!/bin/bash

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Location of the sshd_config file
sshd_config_file="/etc/ssh/sshd_config"
log_file="/root/output.log"

# Function to log messages
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function to check OS version and architecture
check_system() {
    # Get the OS version and architecture
    os_version=$(lsb_release -rs)
    architecture=$(uname -m)

    # Check if the OS is supported
    if [[ "$os_version" =~ ^(20\.04|22\.04|24\.04)$ ]] && [[ "$architecture" == "x86_64" || "$architecture" == "aarch64" ]]; then
        return 0
    else
        log_action "Unsupported OS version or architecture: $os_version ($architecture)"
        exit 1
    fi
}

# Check the system
check_system

# Check and update PermitRootLogin
if grep -q "PermitRootLogin" "$sshd_config_file"; then
    current_value=$(grep "PermitRootLogin" "$sshd_config_file" | awk '{print $2}')
    if [ "$current_value" != "yes" ]; then
        sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' "$sshd_config_file"
        log_action "PermitRootLogin updated from '$current_value' to 'yes'."
    else
        log_action "PermitRootLogin already set to 'yes'."
    fi
else
    echo "PermitRootLogin yes" >> "$sshd_config_file"
    log_action "PermitRootLogin added with value 'yes'."
fi

# Check and update PasswordAuthentication
if grep -q "PasswordAuthentication" "$sshd_config_file"; then
    current_value=$(grep "PasswordAuthentication" "$sshd_config_file" | awk '{print $2}')
    if [ "$current_value" != "yes" ]; then
        sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' "$sshd_config_file"
        log_action "PasswordAuthentication updated from '$current_value' to 'yes'."
    else
        log_action "PasswordAuthentication already set to 'yes'."
    fi
else
    echo "PasswordAuthentication yes" >> "$sshd_config_file"
    log_action "PasswordAuthentication added with value 'yes'."
fi

# Restart SSH service to apply the changes
service ssh restart
log_action "SSH service restarted. Changes applied to sshd_config."
