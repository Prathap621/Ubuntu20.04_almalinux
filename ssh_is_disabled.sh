#!/bin/bash

LOGFILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to check the operating system ID and version
get_os_id_and_version() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        OS_ID="$ID"
        OS_VERSION="$VERSION_ID"
    elif [ -f "/etc/lsb-release" ]; then
        . /etc/lsb-release
        OS_ID="$DISTRIB_ID"
        OS_VERSION="$DISTRIB_RELEASE"
    elif [ -f "/etc/redhat-release" ]; then
        OS_ID=$(awk '{print $1}' /etc/redhat-release)
        OS_VERSION=$(awk '{print $7}' /etc/redhat-release)
    else
        OS_ID=$(uname -s)
        OS_VERSION="unknown"
    fi
    echo "$OS_ID:$OS_VERSION"
}

# Get the operating system ID and version
OS_INFO=$(get_os_id_and_version)
OS_ID=$(echo "$OS_INFO" | cut -d':' -f1)
OS_VERSION=$(echo "$OS_INFO" | cut -d':' -f2)

# Validate OS and architecture support
if [[ "$OS_ID" == "ubuntu" && "$OS_VERSION" =~ ^(20\.04|22\.04|24\.04)$ ]]; then
    SSH_CONFIG="/etc/ssh/sshd_config"
    log_action "Detected Ubuntu version: $OS_VERSION"

    if [ "$(uname -m)" != "x86_64" ] && [ "$(uname -m)" != "arm64" ]; then
        log_action "Unsupported architecture: $(uname -m). Only x86_64 and arm64 are supported."
        exit 1
    fi
elif [[ "$OS_ID" == "almalinux" || "$OS_ID" == "centos" || "$OS_ID" == "fedora" ]]; then
    SSH_CONFIG="/etc/ssh/sshd_config"
    log_action "Detected Red Hat flavor: $OS_ID"
else
    log_action "Unsupported operating system: $OS_ID"
    exit 1
fi

# Check if PermitUserEnvironment is enabled in sshd_config
if grep -q "^PermitUserEnvironment yes" "$SSH_CONFIG"; then
    # Disable PermitUserEnvironment
    sed -i 's/^PermitUserEnvironment yes/PermitUserEnvironment no/' "$SSH_CONFIG"
    log_action "SSH PermitUserEnvironment has been disabled for $OS_ID version $OS_VERSION."
else
    log_action "SSH PermitUserEnvironment is already disabled for $OS_ID version $OS_VERSION."
fi
