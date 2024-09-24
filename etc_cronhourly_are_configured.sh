#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check if the OS is Ubuntu or Red Hat
if [[ -f /etc/lsb-release && $(grep -c "Ubuntu" /etc/lsb-release) -gt 0 ]]; then
    # Check if the version is 20.04, 22.04, or 24.04
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)
    if [[ "$UBUNTU_VERSION" =~ ^(20\.04|22\.04|24\.04)$ ]]; then
        CRON_DIR="/etc/cron.hourly"
        log_action "Ubuntu $UBUNTU_VERSION detected."
    else
        log_action "Unsupported Ubuntu version: $UBUNTU_VERSION."
        exit 1
    fi
elif [[ -f /etc/os-release && $(grep -c "AlmaLinux\|CentOS\|Rocky" /etc/os-release) -gt 0 ]]; then
    CRON_DIR="/etc/cron.hourly"
    log_action "Red Hat flavor detected."
else
    log_action "Unsupported operating system."
    exit 1
fi

# Check the architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
    log_action "Unsupported architecture: $ARCH."
    exit 1
else
    log_action "Supported architecture: $ARCH."
fi

# Check the permissions on /etc/cron.hourly
PERMISSIONS=$(stat -c "%a" $CRON_DIR)
if [[ $PERMISSIONS != "700" ]]; then
    # Set the correct permissions on /etc/cron.hourly
    sudo chmod 700 $CRON_DIR
    log_action "Permissions on $CRON_DIR have been configured."
else
    log_action "Permissions on $CRON_DIR are already properly configured."
fi
