#!/bin/bash

# Backup file path
CONFIG_FILE="/etc/apt/apt.conf.d/20auto-upgrades"
BACKUP_FILE="/etc/apt/apt.conf.d/20auto-upgrades.bak"

LOG_FILE="/root/output.log"  # Log file location in /root/output.log

# Function to log messages
log_action() {
    local action="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action - $message" | tee -a $LOG_FILE
}

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    log_action "ERROR" "Script needs to be run as root."
    exit 1
fi

# Detect OS and architecture
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
    ARCH=$(uname -m)
else
    log_action "ERROR" "Cannot detect operating system. Exiting."
    exit 1
fi

log_action "INFO" "Detected OS: $OS, Version: $VERSION, Architecture: $ARCH"

# Support Ubuntu and Red Hat flavors
if [[ "$OS" == "ubuntu" ]]; then
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; then
        if [[ "$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04" ]]; then
            log_action "INFO" "Ubuntu version $VERSION and architecture $ARCH supported."
        else
            log_action "ERROR" "Unsupported Ubuntu version: $VERSION"
            exit 1
        fi
    else
        log_action "ERROR" "Unsupported architecture for Ubuntu: $ARCH"
        exit 1
    fi
elif [[ "$OS" == "rhel" || "$OS" == "centos" || "$OS" == "fedora" ]]; then
    log_action "INFO" "Red Hat flavor detected: $OS"
else
    log_action "ERROR" "Unsupported operating system: $OS"
    exit 1
fi

# Backup the existing file if it exists
if [ -f "$CONFIG_FILE" ]; then
    log_action "INFO" "Backing up existing configuration file to $BACKUP_FILE"
    cp $CONFIG_FILE $BACKUP_FILE
else
    log_action "INFO" "No existing configuration file found. Skipping backup."
fi

# Write the new configuration settings to the file
log_action "INFO" "Writing new configuration settings to $CONFIG_FILE"
cat <<EOF > $CONFIG_FILE
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF

# Verify if the changes were applied
if grep -q 'APT::Periodic::Update-Package-Lists "0";' "$CONFIG_FILE"; then
    log_action "MATCH" "APT::Periodic::Update-Package-Lists correctly set."
else
    log_action "UNMATCH" "APT::Periodic::Update-Package-Lists setting failed."
fi

if grep -q 'APT::Periodic::Download-Upgradeable-Packages "0";' "$CONFIG_FILE"; then
    log_action "MATCH" "APT::Periodic::Download-Upgradeable-Packages correctly set."
else
    log_action "UNMATCH" "APT::Periodic::Download-Upgradeable-Packages setting failed."
fi

if grep -q 'APT::Periodic::AutocleanInterval "0";' "$CONFIG_FILE"; then
    log_action "MATCH" "APT::Periodic::AutocleanInterval correctly set."
else
    log_action "UNMATCH" "APT::Periodic::AutocleanInterval setting failed."
fi

if grep -q 'APT::Periodic::Unattended-Upgrade "0";' "$CONFIG_FILE"; then
    log_action "MATCH" "APT::Periodic::Unattended-Upgrade correctly set."
else
    log_action "UNMATCH" "APT::Periodic::Unattended-Upgrade setting failed."
fi

# Notify the user
log_action "INFO" "Automatic updates have been disabled."

# Display the new configuration file contents
log_action "INFO" "New configuration file contents:"
cat $CONFIG_FILE | tee -a $LOG_FILE

# Check the status of the unattended-upgrades service (for any Linux distribution that has it)
if systemctl list-units --type=service | grep -q "unattended-upgrades.service"; then
    log_action "INFO" "Checking status of unattended-upgrades service..."
    systemctl status unattended-upgrades --no-pager | tee -a $LOG_FILE
else
    log_action "INFO" "unattended-upgrades service not found on this system."
fi

# Completion message
log_action "INFO" "Script execution completed."
