#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Packages to check/install
packages=("rsync" "cloud-guest-utils" "xfsprogs" "ssmtp" "mailutils" "nscd" "snmpd" "mlocate")

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Determine the OS and architecture
OS=$(lsb_release -is)
VERSION=$(lsb_release -rs)
ARCH=$(uname -m)

# Function to install packages
install_package() {
    local package="$1"
    if command -v "$package" &> /dev/null; then
        log_message "$package exists (match)."
    else
        log_message "$package does not exist (unmatch)."
        echo "Installing $package..."
        if [[ "$OS" == "Ubuntu" ]]; then
            sudo apt-get update
            sudo apt-get install -y "$package"
            if [ $? -eq 0 ]; then
                log_message "$package installed successfully."
            else
                log_message "Error installing $package. Please check and try again."
            fi
        elif [[ "$OS" == "RedHat" || "$OS" == "CentOS" ]]; then
            sudo yum install -y "$package"
            if [ $? -eq 0 ]; then
                log_message "$package installed successfully."
            else
                log_message "Error installing $package. Please check and try again."
            fi
        else
            log_message "Unsupported OS: $OS."
            echo "Unsupported OS: $OS."
        fi
    fi
}

# Check Ubuntu version support
if [[ "$OS" == "Ubuntu" && "$VERSION" =~ ^(20\.04|22\.04|24\.04)$ && ( "$ARCH" == "x86_64" || "$ARCH" == "arm64" ) ]]; then
    for package in "${packages[@]}"; do
        install_package "$package"
    done
elif [[ "$OS" == "RedHat" || "$OS" == "CentOS" ]]; then
    for package in "${packages[@]}"; do
        install_package "$package"
    done
else
    log_message "OS not supported or architecture not supported."
    echo "This script only supports Ubuntu 20.04, 22.04, 24.04 and Red Hat flavors on x86_64 and arm64 architectures."
fi
