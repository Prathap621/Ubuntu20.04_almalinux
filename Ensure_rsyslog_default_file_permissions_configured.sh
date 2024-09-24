#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Check the operating system and set the rsyslog configuration file path
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    case "$ID" in
        "ubuntu")
            rsyslogConfigFile="/etc/rsyslog.conf"
            ;;
        "almalinux"|"rhel"|"centos")
            rsyslogConfigFile="/etc/rsyslog/rsyslog.conf"
            ;;
        *)
            log_action "Unsupported operating system: $ID"
            exit 1
            ;;
    esac
else
    log_action "Failed to detect the operating system."
    exit 1
fi

# Function to check architecture
check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        log_action "Architecture is x86_64."
    elif [[ "$ARCH" == "aarch64" && "$ID" == "ubuntu" ]]; then
        log_action "Architecture is arm64 on Ubuntu."
    else
        log_action "Unsupported architecture: $ARCH"
        exit 1
    fi
}

# Verify and update the rsyslog configuration file
if [[ -f "$rsyslogConfigFile" ]]; then
    log_action "Found rsyslog configuration file: $rsyslogConfigFile"
    
    # Check if default file permissions are correctly set
    if grep -qE '^\$FileCreateMode\s+0640$' "$rsyslogConfigFile" && grep -qE '^\$DirCreateMode\s+0755$' "$rsyslogConfigFile"; then
        log_action "Default file permissions for rsyslog are already configured correctly (match)."
    else
        log_action "Default file permissions for rsyslog are not configured correctly (unmatch). Updating..."
        # Update the file permissions
        sed -i 's/^\($FileCreateMode\s\+\).*/\10640/' "$rsyslogConfigFile"
        sed -i 's/^\($DirCreateMode\s\+\).*/\10755/' "$rsyslogConfigFile"
        log_action "Default file permissions for rsyslog have been updated."
    fi

    # Restart the rsyslog service
    if systemctl restart rsyslog; then
        log_action "rsyslog service has been restarted successfully."
    else
        log_action "Failed to restart rsyslog service."
        exit 1
    fi
else
    log_action "rsyslog configuration file not found: $rsyslogConfigFile (doesn't exist)"
    exit 1
fi

# Check architecture after confirming rsyslog file
check_architecture

log_action "Script execution completed."
