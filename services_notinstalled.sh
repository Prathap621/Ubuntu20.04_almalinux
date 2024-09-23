#!/bin/bash

# Log file
log_file="/var/log/uninstall_script.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$log_file"
}

# Function to check if a package is installed on AlmaLinux or Ubuntu
is_installed() {
    if [ -x "$(command -v dpkg)" ]; then
        dpkg -s "$1" &> /dev/null
    elif [ -x "$(command -v rpm)" ]; then
        rpm -q "$1" &> /dev/null
    fi
}

# Function to uninstall a package on AlmaLinux or Ubuntu
uninstall_package() {
    package=$1
    if is_installed "$package"; then
        log_message "$package exists. Uninstalling..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get purge "$package" -y
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf remove "$package" -y
        fi
        log_message "$package has been uninstalled."
        changes_made=true
    else
        log_message "$package does not exist. No action taken."
    fi
}

# Flag to track if any changes were made
changes_made=false

# Services to check and uninstall
declare -a services=("apache2" "squid" "vsftpd" "bind9" "nis" "cups" "rsh-client" "snmpd" "talk" "xserver-xorg*" "slapd")

# Check and uninstall services
for service in "${services[@]}"; do
    uninstall_package "$service"
done

# Custom uninstallation steps for AlmaLinux or Ubuntu
if [ -x "$(command -v systemctl)" ]; then
    log_message "Checking for custom services..."
    
    # Stop bind9 DNS server if active
    if systemctl is-active --quiet bind9; then
        sudo systemctl stop bind9
        log_message "bind9 service was active and has been stopped."
        changes_made=true
    else
        log_message "bind9 service is not active or does not exist."
    fi
    
    # Stop CUPS service if active
    if systemctl is-active --quiet cups; then
        sudo systemctl stop cups
        log_message "CUPS service was active and has been stopped."
        changes_made=true
    else
        log_message "CUPS service is not active or does not exist."
    fi
    
    # Stop LDAP server if active
    if systemctl is-active --quiet slapd; then
        sudo systemctl stop slapd
        log_message "LDAP (slapd) service was active and has been stopped."
        changes_made=true
    else
        log_message "LDAP (slapd) service is not active or does not exist."
    fi
fi

# Final banner if no changes were made
if [ "$changes_made" = false ]; then
    log_message "No changes were made. All services were either not installed or already uninstalled."
else
    log_message "Script completed with changes made."
fi
