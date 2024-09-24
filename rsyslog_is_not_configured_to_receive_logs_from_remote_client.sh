#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to remove specific lines from rsyslog configuration files
remove_rsyslog_lines() {
    local config_files=(/etc/rsyslog.conf /etc/rsyslog.d/*.conf)
    
    for file in "${config_files[@]}"; do
        if [ -f "$file" ]; then
            log_message "$file exists (match)."
            # Backup the original file
            cp "$file" "$file.bak"
            
            # Remove the lines matching the patterns
            sed -i '/^\h*\$ModLoad imtcp$/d' "$file"
            sed -i '/^\h*\$InputTCPServerRun$/d' "$file"
            sed -i '/^\h*module(load="imtcp")$/d' "$file"
            sed -i '/^\h*input(type="imtcp" port="514")$/d' "$file"
            
            log_message "Lines removed from $file."
        else
            log_message "$file does not exist (unmatch)."
        fi
    done
}

# Restart rsyslog service
restart_rsyslog_service() {
    systemctl restart rsyslog
    log_message "rsyslog service restarted."
}

# Check OS and Architecture support
OS=$(lsb_release -is)
VERSION=$(lsb_release -rs)
ARCH=$(uname -m)

if [[ "$OS" == "Ubuntu" && "$VERSION" =~ ^(20\.04|22\.04|24\.04)$ && ( "$ARCH" == "x86_64" || "$ARCH" == "arm64" ) ]]; then
    log_message "Running script on supported Ubuntu version $VERSION and architecture $ARCH."
    remove_rsyslog_lines
    restart_rsyslog_service
elif [[ "$OS" == "RedHat" || "$OS" == "CentOS" ]]; then
    log_message "Running script on Red Hat flavor: $OS $VERSION."
    remove_rsyslog_lines
    restart_rsyslog_service
else
    log_message "OS not supported or architecture not supported: $OS $VERSION on $ARCH."
    echo "This script only supports Ubuntu 20.04, 22.04, 24.04 and Red Hat flavors on x86_64 and arm64 architectures."
    exit 1
fi
