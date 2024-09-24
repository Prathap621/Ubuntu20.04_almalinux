#!/bin/bash

TMOUT_VALUE=600
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    log_action "Script not run as root. Exiting."
    echo "Please run this script as root."
    exit 1
fi

# Determine the OS version and architecture
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
ARCHITECTURE=$(uname -m)

# Validate OS and architecture
if [[ "$OS_NAME" == "Ubuntu" && ( "$OS_VERSION" == "20.04" || "$OS_VERSION" == "22.04" || "$OS_VERSION" == "24.04" ) && ( "$ARCHITECTURE" == "x86_64" || "$ARCHITECTURE" == "arm64" ) ]]; then
    log_action "Supported OS and architecture detected: $OS_NAME $OS_VERSION $ARCHITECTURE"
else
    log_action "Unsupported OS or architecture. Exiting."
    echo "This script only supports Ubuntu 20.04, 22.04, 24.04 with x86_64 or arm64 architecture."
    exit 1
fi

# Check if the TMOUT variable is already defined in /etc/profile
if grep -q "TMOUT=" /etc/profile; then
    log_action "TMOUT is already defined in /etc/profile. Not making changes."
else
    # Define the desired TMOUT value
    TMOUT=$TMOUT_VALUE
    export TMOUT

    # Update /etc/profile with the new TMOUT setting
    echo "TMOUT=$TMOUT" | tee -a /etc/profile > /dev/null
    log_action "TMOUT set to $TMOUT seconds in /etc/profile."

    # Apply the change immediately to the current shell session
    . /etc/profile
fi
