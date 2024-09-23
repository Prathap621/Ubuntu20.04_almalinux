#!/bin/bash

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
        echo "Uninstalling $package..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get purge "$package" -y
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf remove "$package" -y
        fi
        echo "$package has been uninstalled."
        changes_made=true
    else
        echo "$package is not installed."
    fi
}

# Flag to track if any changes were made
changes_made=false

# Services to check and uninstall
declare -a services=("apache2" "squid" "vsftpd" "bind9" "nis" "cups" "rsh-client" "snmpd" "talk" "xserver-xorg*")

# Check and uninstall services
for service in "${services[@]}"; do
    uninstall_package "$service"
done

# Custom uninstallation steps for AlmaLinux or Ubuntu
if [ -x "$(command -v systemctl)" ]; then
    echo "Checking for custom services..."
    
    # Example for custom service steps like stopping services
    if systemctl is-active --quiet bind9; then
        sudo systemctl stop bind9
        echo "Stopped bind9 service."
        changes_made=true
    fi
    
    if systemctl is-active --quiet cups; then
        sudo systemctl stop cups
        echo "Stopped CUPS service."
        changes_made=true
    fi
fi

# Final banner if no changes were made
if [ "$changes_made" = false ]; then
    echo "No changes were done. All services were either not installed or already uninstalled."
fi
