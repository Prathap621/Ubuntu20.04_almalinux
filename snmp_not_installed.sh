#!/bin/bash

# Define log file
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if the OS is Ubuntu or Red Hat
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERSION_ID=$VERSION_ID
else
    log_message "OS not recognized."
    exit 1
fi

# Check architecture
ARCH=$(uname -m)

# Function to check and uninstall SNMP server
check_snmpd() {
    if [[ "$OS_NAME" == "Ubuntu" ]]; then
        if dpkg -s snmpd &> /dev/null; then
            log_message "SNMP Server found on $OS_NAME $OS_VERSION_ID ($ARCH). Uninstalling..."
            sudo apt-get purge snmpd -y
            log_message "SNMP Server has been uninstalled."
        else
            log_message "SNMP Server is not installed on $OS_NAME $OS_VERSION_ID ($ARCH)."
        fi
    elif [[ "$OS_NAME" == "Red Hat" || "$OS_NAME" == "CentOS" ]]; then
        if rpm -q snmp &> /dev/null; then
            log_message "SNMP Server found on $OS_NAME $OS_VERSION_ID ($ARCH). Uninstalling..."
            sudo yum remove snmp -y
            log_message "SNMP Server has been uninstalled."
        else
            log_message "SNMP Server is not installed on $OS_NAME $OS_VERSION_ID ($ARCH)."
        fi
    else
        log_message "Unsupported OS: $OS_NAME $OS_VERSION_ID."
        exit 1
    fi
}

# Execute the check and uninstall function
check_snmpd

log_message "SNMP Server check completed."
