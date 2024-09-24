#!/bin/bash

# Log file path
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check for supported OS and architecture
OS_VERSION=$(lsb_release -rs)
ARCH=$(uname -m)

# Supported versions for Ubuntu
if [[ "$OS_VERSION" =~ ^(20.04|22.04|24.04)$ && "$ARCH" =~ ^(x86_64|arm64)$ ]]; then
    log_message "Running on supported Ubuntu version $OS_VERSION and architecture $ARCH."
else
    log_message "Unsupported OS version or architecture: $OS_VERSION $ARCH."
    exit 1
fi

# Check if the usb-storage module is loaded
if lsmod | grep -q usb_storage; then
    # Blacklist the usb-storage module
    echo 'blacklist usb-storage' | sudo tee /etc/modprobe.d/disable-usb-storage.conf > /dev/null
    
    # Update the initramfs
    sudo update-initramfs -u
    
    # Inform the user that USB storage has been disabled
    log_message "USB storage has been disabled (match)."
    echo "USB storage has been disabled."
else
    # Inform the user that USB storage is already disabled
    log_message "USB storage is already disabled (unmatch)."
    echo "USB storage is already disabled."
fi
