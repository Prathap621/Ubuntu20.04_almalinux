#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Function to edit the configuration file
edit_config() {
    local config_file="$1"
    local line_to_add1="Storage=persistent"
    local line_to_add2="ForwardToSyslog=yes"
    
    # Check if the lines already exist in the file
    if grep -Fxq "$line_to_add1" "$config_file" && grep -Fxq "$line_to_add2" "$config_file"; then
        log_action "The lines '$line_to_add1' and '$line_to_add2' already exist in '$config_file'. No changes needed."
    else
        # Remove existing entries if they exist to avoid duplicates
        sed -i "/^$line_to_add1/d" "$config_file"
        sed -i "/^$line_to_add2/d" "$config_file"
        
        # Add the lines to the file
        echo "$line_to_add1" >> "$config_file"
        echo "$line_to_add2" >> "$config_file"
        log_action "The lines '$line_to_add1' and '$line_to_add2' have been added to '$config_file'."
    fi
}

# Check the operating system
get_os() {
    if [ -f "/etc/os-release" ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

OS=$(get_os)

if [[ "$OS" == "ubuntu" || "$OS" == "almalinux" || "$OS" == "fedora" || "$OS" == "centos" ]]; then
    log_action "Detected operating system: $OS"

    # Edit /etc/systemd/journald.conf
    edit_config "/etc/systemd/journald.conf"

    # Edit files ending in .conf in /etc/systemd/journald.conf.d/
    for file in /etc/systemd/journald.conf.d/*.conf; do
        if [ -f "$file" ]; then
            edit_config "$file"
        fi
    done

    # Restart the systemd-journald service
    systemctl restart systemd-journald
    log_action "The configuration has been updated, and the systemd-journald service has been restarted."
else
    log_action "Unsupported operating system: $OS"
    exit 1
fi
