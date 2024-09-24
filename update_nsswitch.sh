#!/bin/bash

# Log file path
log_file="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $log_file
}

# Print a message when the script starts
log_message "Starting the script..."

# Define the path to nsswitch.conf
nsswitch_file="/etc/nsswitch.conf"

# Check if the OS is Ubuntu or Red Hat
os_name=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
os_version=$(grep '^VERSION_ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')

# Check architecture
architecture=$(uname -m)

# Validate the OS and architecture
if [[ "$os_name" == "ubuntu" && ("$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04") && ("$architecture" == "x86_64" || "$architecture" == "arm64") ]]; then
    log_message "Detected Ubuntu version: $os_version, architecture: $architecture."
    supported=true
elif [[ "$os_name" == "rhel" || "$os_name" == "centos" || "$os_name" == "fedora" ]]; then
    log_message "Detected Red Hat flavor: $os_name, version: $os_version."
    supported=true
else
    log_message "Unsupported OS or architecture. Exiting script."
    exit 1
fi

# Check if nsswitch.conf exists before proceeding
if [ -f "$nsswitch_file" ]; then
    log_message "Found $nsswitch_file, proceeding with backup and update."

    # Backup file name with timestamp
    backup_file="$nsswitch_file_$(date +'%Y%m%d%H%M%S').bak"

    # Take a backup of the original nsswitch.conf file
    cp $nsswitch_file $backup_file
    log_message "Backup of $nsswitch_file saved as $backup_file."

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
    log_message "Updated $nsswitch_file with the new configuration."
else
    log_message "$nsswitch_file not found. Exiting script."
    exit 1
fi

# Print a final message when the script completes
log_message "Script execution completed."
