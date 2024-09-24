#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Check if the OS is Ubuntu or AlmaLinux
if [[ -f /etc/lsb-release && $(grep -c "Ubuntu" /etc/lsb-release) -gt 0 ]]; then
    log_action "Detected Ubuntu OS."
    
    # Check for architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]]; then
        log_action "Detected supported architecture: $ARCH."
        
        # Check if rsyslog is installed
        if ! dpkg -s rsyslog &> /dev/null; then
            log_action "rsyslog is not installed (doesn't exist). Installing..."
            sudo apt-get update && sudo apt-get install rsyslog -y
            if [[ $? -eq 0 ]]; then
                log_action "rsyslog has been successfully installed."
            else
                log_action "Failed to install rsyslog."
            fi
        else
            log_action "rsyslog is already installed (exists)."
        fi
    else
        log_action "Unsupported architecture: $ARCH."
        exit 1
    fi
elif [[ -f /etc/os-release && $(grep -c "AlmaLinux" /etc/os-release) -gt 0 ]]; then
    log_action "Detected AlmaLinux OS."

    # Check if rsyslog is installed
    if ! rpm -q rsyslog &> /dev/null; then
        log_action "rsyslog is not installed (doesn't exist). Installing..."
        sudo dnf install rsyslog -y
        if [[ $? -eq 0 ]]; then
            log_action "rsyslog has been successfully installed."
        else
            log_action "Failed to install rsyslog."
        fi
    else
        log_action "rsyslog is already installed (exists)."
    fi
else
    log_action "Unsupported operating system."
    exit 1
fi

log_action "Script execution completed."
