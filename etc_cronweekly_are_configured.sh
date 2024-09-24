#!/bin/bash

# Log file path
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check if the OS is Ubuntu or Red Hat flavor
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
        ubuntu)
            if [[ "$VERSION_ID" =~ ^(20.04|22.04|24.04)$ ]]; then
                CRON_DIR="/etc/cron.weekly"
                log_action "Ubuntu $VERSION_ID detected."
            else
                log_action "Unsupported Ubuntu version: $VERSION_ID."
                exit 1
            fi
            ;;
        almalinux|centos|fedora|rhel)
            CRON_DIR="/etc/cron.weekly"
            log_action "$ID detected."
            ;;
        *)
            log_action "Unsupported operating system: $ID."
            exit 1
            ;;
    esac
else
    log_action "Operating system identification file not found."
    exit 1
fi

# Check the permissions on /etc/cron.weekly
PERMISSIONS=$(stat -c "%a" "$CRON_DIR")
if [[ $PERMISSIONS != "700" ]]; then
    # Set the correct permissions on /etc/cron.weekly
    sudo chmod 700 "$CRON_DIR"
    log_action "Permissions on $CRON_DIR have been configured."
else
    log_action "Permissions on $CRON_DIR are already properly configured."
fi
