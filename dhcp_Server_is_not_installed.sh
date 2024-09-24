#!/bin/bash

# Log file path
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check if the operating system is Ubuntu or Red Hat
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION=$VERSION_ID
else
    log_message "Operating system is not recognized."
    exit 1
fi

# Supported architectures
ARCHITECTURE=$(uname -m)

# Check if the architecture is supported
if [[ "$ARCHITECTURE" != "x86_64" && "$ARCHITECTURE" != "arm64" ]]; then
    log_message "Unsupported architecture: $ARCHITECTURE. Exiting."
    exit 1
fi

# Check if DHCP server packages are installed
if dpkg -l | grep -q "isc-dhcp-server"; then
    log_message "DHCP server package is installed. Proceeding to uninstall."

    # Stop the DHCP server service
    sudo systemctl stop isc-dhcp-server.service
    log_message "Stopped isc-dhcp-server.service."

    # Uninstall DHCP server packages
    sudo apt-get purge isc-dhcp-server -y
    log_message "DHCP server package has been uninstalled."

    # Check for successful uninstallation
    if ! dpkg -l | grep -q "isc-dhcp-server"; then
        log_message "DHCP server has been successfully uninstalled."
    else
        log_message "Failed to uninstall DHCP server."
    fi
else
    log_message "DHCP server is not installed."
fi

# For Red Hat systems (if applicable)
if [[ "$ID" == "rhel" || "$ID" == "centos" ]]; then
    if rpm -q dhcp > /dev/null 2>&1; then
        log_message "DHCP server package is installed on Red Hat. Proceeding to uninstall."
        
        # Stop the DHCP server service
        sudo systemctl stop dhcpd.service
        log_message "Stopped dhcpd.service."
        
        # Uninstall DHCP server packages
        sudo yum remove dhcp -y
        log_message "DHCP server package has been uninstalled."
        
        # Check for successful uninstallation
        if ! rpm -q dhcp > /dev/null 2>&1; then
            log_message "DHCP server has been successfully uninstalled on Red Hat."
        else
            log_message "Failed to uninstall DHCP server on Red Hat."
        fi
    else
        log_message "DHCP server is not installed on Red Hat."
    fi
fi
