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
    # Ubuntu
    if [ -f "/etc/ssh/sshd_config" ]; then
        # Check the current setting for AllowTcpForwarding
        if grep -q "^AllowTcpForwarding yes" /etc/ssh/sshd_config; then
            sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding no/' /etc/ssh/sshd_config
            log_action "SSH AllowTcpForwarding has been disabled for Ubuntu."
        else
            log_action "AllowTcpForwarding is already set to no (match) for Ubuntu."
        fi
    else
        log_action "File /etc/ssh/sshd_config not found for Ubuntu."
    fi
elif [[ "$OS" == "AlmaLinux" ]]; then
    # AlmaLinux
    if [ -f "/etc/ssh/sshd_config" ]; then
        # Check the current setting for AllowTcpForwarding
        if grep -q "^AllowTcpForwarding yes" /etc/ssh/sshd_config; then
            sed -i 's/^#*AllowTcpForwarding.*/AllowTcpForwarding no/' /etc/ssh/sshd_config
            log_action "SSH AllowTcpForwarding has been disabled for AlmaLinux."
        else
            log_action "AllowTcpForwarding is already set to no (match) for AlmaLinux."
        fi
    else
        log_action "File /etc/ssh/sshd_config not found for AlmaLinux."
    fi
else
    log_action "Unsupported operating system: $OS."
fi

log_action "Configuration check complete."
