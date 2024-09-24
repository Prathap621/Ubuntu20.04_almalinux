#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the values are already set
check_auditd_values() {
    if grep -q "^\s*space_left_action\s*=\s*SYSLOG" /etc/audit/auditd.conf && grep -q "^\s*admin_space_left_action\s*=\s*SINGLE" /etc/audit/auditd.conf; then
        log_message "Values are already set (match). No change needed."
        return 0
    else
        log_message "Values are not set as expected (unmatch)."
        return 1
    fi
}

# Update auditd.conf if necessary
update_auditd_config() {
    sed -i 's/^\s*space_left_action.*/space_left_action = SYSLOG/' /etc/audit/auditd.conf
    sed -i 's/^\s*admin_space_left_action.*/admin_space_left_action = SINGLE/' /etc/audit/auditd.conf
    log_message "Values updated in /etc/audit/auditd.conf."
}

# Check OS and Architecture support
OS=$(lsb_release -is)
VERSION=$(lsb_release -rs)
ARCH=$(uname -m)

if [[ "$OS" == "Ubuntu" && "$VERSION" =~ ^(20\.04|22\.04|24\.04)$ && ( "$ARCH" == "x86_64" || "$ARCH" == "arm64" ) ]]; then
    log_message "Running script on supported Ubuntu version $VERSION and architecture $ARCH."
    if check_auditd_values; then
        exit 0
    else
        update_auditd_config
    fi
elif [[ "$OS" == "RedHat" || "$OS" == "CentOS" ]]; then
    log_message "Running script on Red Hat flavor: $OS $VERSION."
    if check_auditd_values; then
        exit 0
    else
        update_auditd_config
    fi
else
    log_message "OS not supported or architecture not supported: $OS $VERSION on $ARCH."
    echo "This script only supports Ubuntu 20.04, 22.04, 24.04 and Red Hat flavors on x86_64 and arm64 architectures."
    exit 1
fi
