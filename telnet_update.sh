#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Function to check and install telnet on Ubuntu
install_telnet_ubuntu() {
    log_action "Checking if telnet is installed on Ubuntu..."
    if dpkg -l telnet | grep -q "^ii"; then
        log_action "telnet is already installed on Ubuntu."
    else
        log_action "Installing telnet on Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y telnet && log_action "telnet has been installed on Ubuntu." || log_action "Failed to install telnet on Ubuntu."
    fi
}

# Function to check and install telnet on AlmaLinux
install_telnet_almalinux() {
    log_action "Checking if telnet is installed on AlmaLinux..."
    if rpm -q telnet >/dev/null; then
        log_action "telnet is already installed on AlmaLinux."
    else
        log_action "Installing telnet on AlmaLinux..."
        sudo yum install -y telnet && log_action "telnet has been installed on AlmaLinux." || log_action "Failed to install telnet on AlmaLinux."
    fi
}

# Get the operating system ID
get_os_id() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

OS_ID=$(get_os_id)

case "$OS_ID" in
    "ubuntu")
        install_telnet_ubuntu
        ;;
    "almalinux" | "centos" | "fedora")
        install_telnet_almalinux
        ;;
    *)
        log_action "Unsupported operating system: $OS_ID"
        exit 1
        ;;
esac
