#!/bin/bash

# Define the log file
log_file="/root/output.log"

# Function to log messages
log_action() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') : $message" | tee -a $log_file
}

# Start the script
log_action "Starting the script..."

# Check if the OS is Ubuntu and its version
os_version=$(lsb_release -rs)
os_id=$(lsb_release -is)

if [[ "$os_id" != "Ubuntu" ]]; then
    log_action "Not running on Ubuntu. Exiting script."
    exit 1
fi

log_action "Detected OS: $os_id $os_version"

# Define the supported Ubuntu versions
supported_versions=("20.04" "22.04" "24.04")

# Check if the version is supported
if [[ ! " ${supported_versions[@]} " =~ " ${os_version} " ]]; then
    log_action "Ubuntu version $os_version is not supported. Exiting script."
    exit 1
else
    log_action "Ubuntu version $os_version is supported. Proceeding..."
fi

# Check architecture
arch=$(uname -m)

if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
    log_action "Unsupported architecture: $arch. Exiting script."
    exit 1
else
    log_action "Detected architecture: $arch. Proceeding..."
fi

# Define the path to nsswitch.conf
nsswitch_file="/etc/nsswitch.conf"

# Check if nsswitch.conf exists before proceeding
if [ -f "$nsswitch_file" ]; then
    log_action "Found $nsswitch_file, proceeding with backup and update."

    # Backup file name with timestamp
    backup_file="${nsswitch_file}_$(date +'%Y%m%d%H%M%S').bak"

    # Take a backup of the original nsswitch.conf file
    cp $nsswitch_file $backup_file
    log_action "Backup of $nsswitch_file saved as $backup_file"

    # Define the new content to update nsswitch.conf
    new_content="# /etc/nsswitch.conf
    #
    # Example configuration of GNU Name Service Switch functionality.
    # If you have the \`glibc-doc-reference' and \`info' packages installed, try:
    # \`info libc \"Name Service Switch\"' for information about this file.

    passwd:         files ldap
    group:          files ldap
    shadow:         files ldap
    gshadow:        files ldap

    hosts:          files dns
    networks:       files

    protocols:      db files
    services:       db files
    ethers:         db files
    rpc:            db files

    netgroup:       nis
    "

    # Write the new content to nsswitch.conf
    echo "$new_content" > $nsswitch_file
    log_action "Updated $nsswitch_file with new configuration."
else
    log_action "$nsswitch_file not found. Exiting script."
    exit 1
fi

# Final message
log_action "Script execution completed."
