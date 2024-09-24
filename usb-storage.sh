#!/bin/bash

# Define log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    local action=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action: $message" >> "$LOG_FILE"
}

# Check if the usb-storage.conf file exists
if [ ! -f "/etc/modprobe.d/usb-storage.conf" ]; then
    # Create the usb-storage.conf file
    sudo touch /etc/modprobe.d/usb-storage.conf
    log_action "create" "Created usb-storage.conf file."

    # Set the permissions of the file to 644
    sudo chmod 644 /etc/modprobe.d/usb-storage.conf
    log_action "update" "Set permissions of usb-storage.conf to 644."

    # Add the configuration line to disable usb-storage in the usb-storage.conf file
    echo "install usb-storage /bin/true" | sudo tee /etc/modprobe.d/usb-storage.conf > /dev/null
    log_action "update" "Added configuration to disable usb-storage."

    # Inform the user that the mounting of usb-storage filesystems has been disabled
    echo "Mounting of usb-storage filesystems has been disabled."
    log_action "info" "Mounting of usb-storage filesystems has been disabled."
else
    # Inform the user that the usb-storage.conf file already exists
    echo "usb-storage.conf file already exists. No action taken."
    log_action "info" "usb-storage.conf file already exists. No action taken."
fi

# Check the OS version
OS_VERSION=$(lsb_release -rs)
ARCHITECTURE=$(uname -m)

if [[ "$OS_VERSION" =~ ^(20.04|22.04|24.04)$ ]] && [[ "$ARCHITECTURE" == "x86_64" || "$ARCHITECTURE" == "aarch64" ]]; then
    log_action "info" "Supported OS version: $OS_VERSION, Architecture: $ARCHITECTURE."
else
    log_action "error" "Unsupported OS version or architecture: $OS_VERSION, Architecture: $ARCHITECTURE."
    exit 1
fi
