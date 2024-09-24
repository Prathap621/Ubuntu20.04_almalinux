#!/bin/bash

LOG_FILE="/root/output.log"
ARCH=$(uname -m)
OS=$(grep '^ID=' /etc/os-release | cut -d'=' -f2)
VERSION=$(grep 'VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')

# Function to log actions
log_action() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check for supported architectures and OS
if [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; then
    if [[ "$OS" == "ubuntu" && ("$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04") ]]; then
        log_action "Ubuntu $VERSION with architecture $ARCH detected. Proceeding with service management."
    elif [[ "$OS" == "rhel" || "$OS" == "centos" ]]; then
        log_action "Red Hat/CentOS detected. Proceeding with service management."
    else
        log_action "Unsupported OS version: $OS $VERSION. Exiting."
        exit 1
    fi
else
    log_action "Unsupported architecture: $ARCH. Exiting."
    exit 1
fi

# Run the lsof command to get the list of services
services=$(lsof -i -P -n | grep -v "(ESTABLISHED)")

# Loop through each service in the list
while read -r line; do
    # Extract the service name
    service=$(echo "$line" | awk '{print $1}')
    
    # Check if the service exists before proceeding
    if systemctl list-units --type=service | grep -q "$service"; then
        log_action "Service $service exists. Stopping and masking."
        sudo systemctl stop "$service" --quiet
        sudo systemctl mask "$service" --quiet
        log_action "Service $service stopped and masked."
    else
        log_action "Service $service doesn't exist."
    fi
done <<< "$services"

log_action "Service stopping and masking completed."
