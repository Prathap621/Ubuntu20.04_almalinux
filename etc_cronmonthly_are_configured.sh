#!/bin/bash

LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the OS is Ubuntu
if [[ -f /etc/lsb-release ]]; then
    if grep -q "Ubuntu" /etc/lsb-release; then
        VERSION=$(grep -oP '(?<=DISTRIB_RELEASE=).*' /etc/lsb-release)
        ARCH=$(uname -m)

        if [[ "$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04" ]]; then
            if [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; then
                CRON_DIR="/etc/cron.monthly"
                log_message "OS is Ubuntu $VERSION ($ARCH)."
            else
                log_message "Unsupported architecture: $ARCH."
                exit 1
            fi
        else
            log_message "Unsupported Ubuntu version: $VERSION."
            exit 1
        fi
    else
        log_message "Not an Ubuntu OS."
        exit 1
    fi
elif [[ -f /etc/os-release ]]; then
    if grep -q "AlmaLinux" /etc/os-release || grep -q "CentOS" /etc/os-release || grep -q "RHEL" /etc/os-release; then
        CRON_DIR="/etc/cron.monthly"
        log_message "OS is a Red Hat flavor."
    else
        log_message "Unsupported operating system."
        exit 1
    fi
else
    log_message "No recognizable OS file found."
    exit 1
fi

# Check the permissions on /etc/cron.monthly
PERMISSIONS=$(stat -c "%a" "$CRON_DIR")
if [[ $PERMISSIONS != "700" ]]; then
    # Set the correct permissions on /etc/cron.monthly
    sudo chmod 700 "$CRON_DIR"
    log_message "Permissions on $CRON_DIR have been configured to 700."
else
    log_message "Permissions on $CRON_DIR are already properly configured."
fi
