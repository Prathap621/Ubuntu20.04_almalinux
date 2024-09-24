#!/bin/bash

LOGFILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOGFILE
}

# Check if port 111 is already in use
log_message "Checking if port 111 is in use:"
if netstat -plant | grep LIST | grep '\b111\b'; then
    log_message "Port 111 is already in use. Exiting."
    exit 1
else
    log_message "Port 111 is not in use."
fi

# Function to check package installation
check_and_install_package() {
    PACKAGE=$1
    if ! dpkg -s $PACKAGE &> /dev/null; then
        log_message "$PACKAGE package is not installed. Installing..."
        apt update
        apt install -y $PACKAGE
        log_message "$PACKAGE package installed."
    else
        log_message "$PACKAGE package is already installed."
    fi
}

# Check OS and architecture
OS=$(lsb_release -si)
ARCH=$(uname -m)

if [[ "$OS" == "Ubuntu" && ("$ARCH" == "x86_64" || "$ARCH" == "aarch64") ]]; then
    # Check if nfs-common package is installed
    log_message "Checking if nfs-common package is installed..."
    check_and_install_package "nfs-common"
else
    log_message "This script is designed for Ubuntu (20.04, 22.04, 24.04) on x86_64 or arm64 architecture. Exiting."
    exit 1
fi

# Stop and disable rpcbind.socket service
log_message "Stopping rpcbind.socket service..."
systemctl stop rpcbind.socket
log_message "rpcbind.socket service stopped."

log_message "Disabling rpcbind.socket service..."
systemctl disable rpcbind.socket
log_message "rpcbind.socket service disabled."

# Check again if port 111 is in use after stopping rpcbind.socket
log_message "Checking if port 111 is still in use:"
if netstat -plant | grep LIST | grep '\b111\b'; then
    log_message "Port 111 is still in use."
else
    log_message "Port 111 is not in use."
fi
