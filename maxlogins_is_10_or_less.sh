#!/bin/bash

# Define the output log file
LOGFILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Check the OS and architecture
OS=$(lsb_release -si)
VERSION=$(lsb_release -sr)
ARCH=$(uname -m)

# Log OS and architecture details
log_message "Detected OS: $OS, Version: $VERSION, Architecture: $ARCH"

# Validate supported OS and architecture
if { [[ "$OS" == "Ubuntu" && "$VERSION" =~ ^(20\.04|22\.04|24\.04)$ && ( "$ARCH" == "x86_64" || "$ARCH" == "arm64" ) ]] || 
     [[ "$OS" == "RedHat" || "$OS" == "CentOS" ]]; }; then

    # Check if the maxlogins limit is already set in limits.conf
    if grep -q "^.*\s*maxlogins\s*.*$" /etc/security/limits.conf; then
        log_message "maxlogins entry exists. Updating the limit."
        # Update the maxlogins limit in limits.conf
        sudo sed -i 's/^\(.*\)\(\s*maxlogins\s*\).*$/\1\2 10/' /etc/security/limits.conf
        log_message "maxlogins limit updated to 10."
    else
        log_message "maxlogins entry does not exist. Appending the limit."
        # Append the maxlogins limit to limits.conf
        echo "*               hard    maxlogins         10" | sudo tee -a /etc/security/limits.conf > /dev/null
        log_message "maxlogins limit set to 10."
    fi

    # Inform the user that the maxlogins limit has been set
    echo "The maxlogins limit has been set to 10 or less."

else
    log_message "Unsupported OS or architecture. Exiting."
    echo "Unsupported OS or architecture. Please run this script on Ubuntu 20.04, 22.04, 24.04, or Red Hat flavors."
    exit 1
fi
