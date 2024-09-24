#!/bin/bash

# Log file path
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the OS is Ubuntu or AlmaLinux
if [[ -f /etc/lsb-release && $(grep -c "Ubuntu" /etc/lsb-release) -gt 0 ]]; then
    OS_TYPE="Ubuntu"
    OS_VERSION=$(lsb_release -rs)
    CROND_FILE="/etc/crond"
elif [[ -f /etc/os-release && $(grep -c "AlmaLinux" /etc/os-release) -gt 0 ]]; then
    OS_TYPE="AlmaLinux"
    CROND_FILE="/etc/crond"
else
    log_message "Unsupported operating system."
    echo "Unsupported operating system."
    exit 1
fi

# Check for supported versions and architecture
if [[ "$OS_TYPE" == "Ubuntu" && ! "$OS_VERSION" =~ ^(20.04|22.04|24.04)$ ]]; then
    log_message "Unsupported Ubuntu version: $OS_VERSION."
    echo "Unsupported Ubuntu version."
    exit 1
fi

ARCH=$(uname -m)
if [[ "$OS_TYPE" == "Ubuntu" && "$ARCH" != "x86_64" && "$ARCH" != "arm64" ]]; then
    log_message "Unsupported architecture for Ubuntu: $ARCH."
    echo "Unsupported architecture for Ubuntu."
    exit 1
fi

# Check the permissions on /etc/crond
if [[ -f $CROND_FILE ]]; then
    PERMISSIONS=$(stat -c "%a" $CROND_FILE)
    if [[ $PERMISSIONS != "600" ]]; then
        # Set the correct permissions on /etc/crond
        sudo chmod 600 $CROND_FILE
        log_message "Permissions on $CROND_FILE have been configured (changed to 600)."
        echo "Permissions on $CROND_FILE have been configured."
    else
        log_message "Permissions on $CROND_FILE are already properly configured (exists)."
        echo "Permissions on $CROND_FILE are already properly configured."
    fi
else
    log_message "$CROND_FILE does not exist (doesn't exist)."
    echo "$CROND_FILE does not exist."
fi
