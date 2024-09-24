#!/bin/bash -e

set -eou pipefail

LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check OS version
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=$VERSION_ID
else
    log_action "OS information not found."
    exit 1
fi

# Check architecture
ARCHITECTURE=$(uname -m)

# Supported OS versions and architectures
if [[ "$OS_NAME" == "ubuntu" && ("$OS_VERSION" == "20.04" || "$OS_VERSION" == "22.04" || "$OS_VERSION" == "24.04") ]]; then
    log_action "Ubuntu $OS_VERSION detected with architecture $ARCHITECTURE."
    
    if [[ "$ARCHITECTURE" == "x86_64" || "$ARCHITECTURE" == "arm64" ]]; then
        log_action "Supported architecture: $ARCHITECTURE."
        apt-cache policy
        log_action "Executed apt-cache policy."
    else
        log_action "Unsupported architecture: $ARCHITECTURE."
    fi
elif [[ "$OS_NAME" == "rhel" || "$OS_NAME" == "centos" || "$OS_NAME" == "fedora" ]]; then
    log_action "$OS_NAME $OS_VERSION detected."
    log_action "Red Hat flavor detected, no apt-cache policy available."
else
    log_action "Unsupported OS: $OS_NAME $OS_VERSION."
    exit 1
fi

# Additional checks or updates can be added here
# Example: Checking for a package
PACKAGE_NAME="example-package" # Replace with the actual package you want to check

if dpkg -l | grep -q "$PACKAGE_NAME"; then
    log_action "Package '$PACKAGE_NAME' exists."
else
    log_action "Package '$PACKAGE_NAME' does not exist."
fi
