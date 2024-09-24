#!/bin/bash

LOG_FILE="/root/output.log"

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Define the parameter and its desired value
param="X11Forwarding"
desired_value="no"

# Path to the sshd_config file
config_file="/etc/ssh/sshd_config"

# Remove any existing entries for the parameter to avoid duplicates
sed -i "/^\s*$param/d" "$config_file"

# Now add the desired parameter value
echo "$param $desired_value" >> "$config_file"
log_action "Configuration for $param set to $desired_value."

# Restart the SSH service to apply changes
systemctl restart sshd
log_action "SSH service restarted to apply changes."
