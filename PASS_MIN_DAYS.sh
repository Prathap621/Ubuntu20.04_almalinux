#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Function to configure minimum days between password changes on Ubuntu
configure_password_changes_ubuntu() {
    log_action "Configuring minimum days between password changes on Ubuntu..."
    if grep -q '^PASS_MIN_DAYS\s*7' /etc/login.defs; then
        log_action "PASS_MIN_DAYS is already set to 7 (match)."
    else
        sudo sed -i '/^PASS_MIN_DAYS/c\PASS_MIN_DAYS   7' /etc/login.defs
        log_action "PASS_MIN_DAYS has been set to 7 (update)."
    fi
}

# Function to configure minimum days between password changes on AlmaLinux
configure_password_changes_almalinux() {
    log_action "Configuring minimum days between password changes on AlmaLinux..."
    if grep -q '^PASS_MIN_DAYS\s*7' /etc/login.defs; then
        log_action "PASS_MIN_DAYS is already set to 7 (match)."
    else
        sudo sed -i '/^PASS_MIN_DAYS/c\PASS_MIN_DAYS   7' /etc/login.defs
        log_action "PASS_MIN_DAYS has been set to 7 (update)."
    fi
}

# Read OS distribution from /etc/os-release
os_distribution=$(grep -oP '(?<=^ID=).+' /etc/os-release)

# Check OS distribution and configure minimum days between password changes
case $os_distribution in
    "ubuntu"|"Ubuntu")
        log_action "Detected Ubuntu..."
        configure_password_changes_ubuntu
        ;;
    "almalinux"|"AlmaLinux")
        log_action "Detected AlmaLinux..."
        configure_password_changes_almalinux
        ;;
    *)
        log_action "Unsupported OS distribution: $os_distribution."
        exit 1
        ;;
esac

log_action "Configuration check complete."
