#!/bin/bash

# Define the log file
log_file="/root/output.log"

# Function to log actions
log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Define the backup file name
backup_file="/etc/default/grub.bak"

# Check if the backup file already exists, and create one if it doesn't
if [ ! -f "$backup_file" ]; then
  sudo cp /etc/default/grub "$backup_file"
  log_action "Backup created: $backup_file"
else
  log_action "Backup already exists: $backup_file"
fi

# Define the new audit setting
new_audit_setting='GRUB_CMDLINE_LINUX="audit=1"'

# Check if the audit setting already exists in the grub file
if grep -q 'GRUB_CMDLINE_LINUX="audit=' /etc/default/grub; then
  # The audit setting exists; update it to 1
  sudo sed -i 's/GRUB_CMDLINE_LINUX="audit=[0-9]*"/'$new_audit_setting'/' /etc/default/grub
  log_action "Updated existing audit setting to audit=1."
else
  # The audit setting doesn't exist; add it as "audit=1"
  echo "$new_audit_setting" | sudo tee -a /etc/default/grub > /dev/null
  log_action "Added new audit setting: $new_audit_setting"
fi

# Update the grub configuration
sudo update-grub
log_action "GRUB configuration updated with audit=1."

# Optional: Check the OS version and architecture
os_version=$(lsb_release -rs)
arch=$(uname -m)

if [[ "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04" ]]; then
  log_action "Supported Ubuntu version detected: $os_version"
else
  log_action "Unsupported Ubuntu version: $os_version"
fi

if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
  log_action "Supported architecture detected: $arch"
else
  log_action "Unsupported architecture detected: $arch"
fi
