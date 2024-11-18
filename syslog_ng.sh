#!/bin/bash

# Exit script if any command fails
set -e

# Install syslog-ng
echo "Installing syslog-ng..."
sudo apt update && sudo apt install -y syslog-ng

# Define the configuration snippet to be added
CONFIG_SNIPPET='filter ff_local6     { facility(local6); };
destination dd_local6 { file("/var/log/commands.log"); };
log { source(s_src); filter(ff_local6); destination(dd_local6); };'

# File to be edited
CONF_FILE="/etc/syslog-ng/syslog-ng.conf"

# Backup the original configuration file
echo "Backing up the original syslog-ng configuration..."
sudo cp "$CONF_FILE" "${CONF_FILE}.bak"

# Add the configuration snippet after the specified line
echo "Updating syslog-ng configuration..."
sudo sed -i "/########################\n# Destinations\n########################\n# First some standard logfile/a $CONFIG_SNIPPET" "$CONF_FILE"

# Restart syslog-ng service
echo "Restarting syslog-ng service..."
sudo systemctl restart syslog-ng.service

# Print syslog-ng service status
echo "Displaying syslog-ng service status..."
sudo systemctl status syslog-ng.service
