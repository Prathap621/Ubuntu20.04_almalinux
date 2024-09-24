#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Lines to add to /etc/security/limits.conf
lines_to_add="tomcat soft nofile 100000
tomcat hard nofile 100000"

# Check if the lines are already present
if grep -Fxq "$lines_to_add" /etc/security/limits.conf; then
    log_message "Lines are already present in /etc/security/limits.conf. No update needed. (match)"
else
    # Append lines to /etc/security/limits.conf
    echo "$lines_to_add" | sudo tee -a /etc/security/limits.conf > /dev/null
    log_message "Lines added to /etc/security/limits.conf successfully. (added)"
fi

# Function to install nscd
install_nscd() {
    if ! command -v nscd &> /dev/null; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case "$ID" in
                ubuntu)
                    sudo apt-get update
                    sudo apt-get install -y nscd
                    log_message "nscd installed successfully on $ID $VERSION_ID. (added)"
                    ;;
                centos|rhel)
                    sudo yum install -y nscd
                    log_message "nscd installed successfully on $ID $VERSION_ID. (added)"
                    ;;
                *)
                    log_message "Unsupported OS: $ID $VERSION_ID. (unmatch)"
                    ;;
            esac
        else
            log_message "OS release file not found. Cannot determine OS type. (unmatch)"
        fi
    else
        log_message "nscd is already installed. No update needed. (exists)"
    fi
}

# Determine the architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
    log_message "Unsupported architecture: $ARCH. (unmatch)"
    exit 1
fi

# Call the install_nscd function
install_nscd
