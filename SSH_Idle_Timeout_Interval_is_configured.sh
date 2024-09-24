#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Function to check the operating system ID
get_os_id() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        OS_ID="$ID"
    elif [ -f "/etc/lsb-release" ]; then
        . /etc/lsb-release
        OS_ID="$DISTRIB_ID"
    elif [ -f "/etc/redhat-release" ]; then
        OS_ID=$(awk '{print $1}' /etc/redhat-release)
    else
        OS_ID=$(uname -s)
    fi
    echo "$OS_ID"
}

# Get the operating system ID
OS_ID=$(get_os_id)
log_action "Detected operating system: $OS_ID"

if [[ "$OS_ID" == "ubuntu" ]]; then
    # Ubuntu
    SSHD_CONFIG="/etc/ssh/sshd_config"
elif [[ "$OS_ID" == "almalinux" ]]; then
    # AlmaLinux
    SSHD_CONFIG="/etc/ssh/sshd_config"
else
    log_action "Unsupported operating system: $OS_ID"
    exit 1
fi

# Remove any existing lines for ClientAliveInterval and ClientAliveCountMax
sed -i '/^ClientAliveInterval/d' "$SSHD_CONFIG"
sed -i '/^ClientAliveCountMax/d' "$SSHD_CONFIG"

# Add the SSH Idle Timeout Interval configuration
echo "ClientAliveInterval 120" >> "$SSHD_CONFIG"
echo "ClientAliveCountMax 3" >> "$SSHD_CONFIG"
log_action "SSH Idle Timeout Interval has been configured for $OS_ID."

log_action "SSH Idle Timeout configuration check complete."
