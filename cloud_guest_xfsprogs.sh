#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check and install a package
check_and_install() {
    local package="$1"

    if ! dpkg -l | grep -q "$package"; then
        log "$package is not installed. Installing..."
        sudo apt-get update >> "$LOG_FILE" 2>&1
        sudo apt-get install -y "$package" >> "$LOG_FILE" 2>&1
        log "$package installation complete."
    else
        log "$package is already installed."
    fi
}

# Supported Ubuntu versions
UBUNTU_VERSIONS=("20.04" "22.04" "24.04")

# Check if running on Ubuntu
if [[ $(lsb_release -si) == "Ubuntu" ]]; then
    UBUNTU_VERSION=$(lsb_release -sr)
    
    if [[ " ${UBUNTU_VERSIONS[@]} " =~ " ${UBUNTU_VERSION} " ]]; then
        log "Running on supported Ubuntu version: $UBUNTU_VERSION"
        # Check and install packages
        check_and_install "cloud-guest-utils"
        check_and_install "xfsprogs"
    else
        log "Unsupported Ubuntu version: $UBUNTU_VERSION"
        exit 1
    fi
else
    log "This script is intended for Ubuntu. Checking for Red Hat flavor..."
    
    # Check for Red Hat-based systems
    if command -v yum &> /dev/null; then
        log "Running on a Red Hat flavor."
        # Check and install packages for Red Hat (replace with your desired packages)
        check_and_install "cloud-guest-utils" # Adjust if needed
        check_and_install "xfsprogs" # Adjust if needed
    else
        log "This script can only be run on Ubuntu or Red Hat-based systems."
        exit 1
    fi
fi
