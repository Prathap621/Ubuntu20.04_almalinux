#!/bin/bash

# Log file path
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the OS is Ubuntu
if [[ -f /etc/lsb-release ]]; then
    UBUNTU_VERSION=$(grep "DISTRIB_RELEASE" /etc/lsb-release | cut -d '=' -f 2)
    if [[ "$UBUNTU_VERSION" =~ ^(20\.04|22\.04|24\.04)$ ]]; then
        CRON_SERVICE="cron"
        log_message "Ubuntu version $UBUNTU_VERSION matched."
    else
        log_message "Ubuntu version $UBUNTU_VERSION does not match required versions."
        exit 1
    fi
elif [[ -f /etc/os-release ]]; then
    if grep -q "AlmaLinux" /etc/os-release; then
        CRON_SERVICE="crond"
        log_message "AlmaLinux matched."
    elif grep -q "Red Hat" /etc/os-release; then
        CRON_SERVICE="crond"
        log_message "Red Hat matched."
    else
        log_message "Unsupported operating system."
        exit 1
    fi
else
    log_message "Unsupported operating system."
    exit 1
fi

# Check if the cron daemon is enabled
if [[ $(systemctl is-enabled $CRON_SERVICE) == "disabled" ]]; then
    # Enable the cron daemon
    sudo systemctl enable $CRON_SERVICE
    sudo systemctl start $CRON_SERVICE
    log_message "Cron daemon has been enabled."
else
    log_message "Cron daemon is already enabled."
fi

# Check if the cron daemon is running
if [[ $(systemctl is-active $CRON_SERVICE) == "active" ]]; then
    log_message "Cron daemon is running."
else
    log_message "Cron daemon is not running, attempting to start."
    sudo systemctl start $CRON_SERVICE
    if [[ $(systemctl is-active $CRON_SERVICE) == "active" ]]; then
        log_message "Cron daemon started successfully."
    else
        log_message "Failed to start the cron daemon."
    fi
fi
