#!/bin/bash

# Define log file
LOGFILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Check OS and architecture compatibility
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" && ("$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" || "$VERSION_ID" == "24.04") ]]; then
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; then
            OS_COMPATIBLE=true
        else
            log_action "Unsupported architecture: $ARCH"
            echo "Unsupported architecture: $ARCH"
            exit 1
        fi
    elif [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" ]]; then
        OS_COMPATIBLE=true
    else
        log_action "Unsupported OS: $ID $VERSION_ID"
        echo "Unsupported OS: $ID $VERSION_ID"
        exit 1
    fi
else
    log_action "Cannot determine OS"
    echo "Cannot determine OS"
    exit 1
fi

# Check if the authentication is already required for single user mode
if grep -q "^auth required pam_securetty.so$" /etc/sulogin; then
    log_action "Authentication is already required for single user mode."
    echo "Authentication is already required for single user mode."
else
    # Add the authentication requirement to the sulogin file
    echo "auth required pam_securetty.so" | sudo tee -a /etc/sulogin > /dev/null

    # Inform the user that authentication is now required
    log_action "Authentication is now required for single user mode."
    echo "Authentication is now required for single user mode."
fi
