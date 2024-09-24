#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Check for architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "arm64" ]]; then
    log_message "Unsupported architecture: $ARCH"
    exit 1
fi

# Determine the OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS_NAME=$ID
    OS_VERSION=$VERSION_ID
else
    log_message "OS not recognized."
    exit 1
fi

# Check if postfix is installed
if dpkg -s postfix &> /dev/null; then
    log_message "Postfix is installed."

    # Check if postfix is configured for local-only mode
    if grep -q "^inet_interfaces[[:space:]]*=[[:space:]]*localhost" /etc/postfix/main.cf; then
        log_message "Postfix is already configured for local-only mode."
    else
        # Configure postfix for local-only mode
        log_message "Configuring Postfix for local-only mode..."
        echo "inet_interfaces = localhost" | sudo tee -a /etc/postfix/main.cf > /dev/null
        sudo service postfix restart
        log_message "Postfix has been configured for local-only mode."
    fi
else
    log_message "Postfix is not installed."
fi

log_message "Mail Transfer Agent configuration check completed."
