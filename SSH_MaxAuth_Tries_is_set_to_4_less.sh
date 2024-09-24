#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Function to check the operating system
get_os() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        OS="$NAME"
    elif [ -f "/etc/lsb-release" ]; then
        . /etc/lsb-release
        OS="$DISTRIB_ID"
    elif [ -f "/etc/redhat-release" ]; then
        OS=$(awk '{print $1}' /etc/redhat-release)
    else
        OS=$(uname -s)
    fi
    echo "$OS"
}

# Get the operating system
OS=$(get_os)
log_action "Detected operating system: $OS"

if [[ "$OS" == "Ubuntu" ]]; then
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if [ -f "$SSHD_CONFIG" ]; then
        # Check if MaxAuthTries is already set to 4
        if grep -q '^MaxAuthTries 4$' "$SSHD_CONFIG"; then
            log_action "MaxAuthTries is already set to 4 for Ubuntu."
        else
            # Remove any existing MaxAuthTries setting to avoid duplicates
            sed -i '/^MaxAuthTries/d' "$SSHD_CONFIG"
            # Add the new MaxAuthTries setting
            echo "MaxAuthTries 4" >> "$SSHD_CONFIG"
            log_action "SSH MaxAuthTries has been set to 4 for Ubuntu."
        fi
    else
        log_action "File /etc/ssh/sshd_config not found for Ubuntu."
    fi
elif [[ "$OS" == "AlmaLinux" ]]; then
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if [ -f "$SSHD_CONFIG" ]; then
        # Check if MaxAuthTries is already set to 4
        if grep -q '^MaxAuthTries 4$' "$SSHD_CONFIG"; then
            log_action "MaxAuthTries is already set to 4 for AlmaLinux."
        else
            # Remove any existing MaxAuthTries setting to avoid duplicates
            sed -i '/^MaxAuthTries/d' "$SSHD_CONFIG"
            # Add the new MaxAuthTries setting
            echo "MaxAuthTries 4" >> "$SSHD_CONFIG"
            log_action "SSH MaxAuthTries has been set to 4 for AlmaLinux."
        fi
    else
        log_action "File /etc/ssh/sshd_config not found for AlmaLinux."
    fi
else
    log_action "Unsupported operating system: $OS"
    exit 1
fi

log_action "SSH MaxAuthTries configuration check complete."
