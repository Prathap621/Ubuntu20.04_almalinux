#!/bin/bash

# Log file
log_file="/root/output.log"

# Function to log messages
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Check the OS
if [[ -f /etc/os-release ]]; then
  source /etc/os-release
  if [[ "$ID" == "ubuntu" ]]; then
    # Check Ubuntu version
    if [[ "$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" || "$VERSION_ID" == "24.04" ]]; then
      conf_file="/etc/systemd/journald.conf"
      service_name="systemd-journald"
      log "OS: Ubuntu $VERSION_ID - Match"
    else
      log "OS: Ubuntu $VERSION_ID - Unmatch"
      exit 1
    fi
  elif [[ "$ID" == "almalinux" || "$ID" == "centos" || "$ID" == "fedora" ]]; then
    # Red Hat flavors
    conf_file="/etc/systemd/journald.conf.d/00-journald.conf"
    service_name="systemd-journald"
    log "OS: $ID - Match"
  else
    log "Unsupported OS: $ID"
    exit 1
  fi

  # Check if the configuration file exists
  if [[ -f "$conf_file" ]]; then
    log "Configuration file found: $conf_file - Exists"
    
    # Configure journald to compress large log files
    if grep -q "^#Compress=yes" "$conf_file"; then
      sudo sed -i 's/#Compress=yes/Compress=yes/' "$conf_file"
      sudo systemctl restart "$service_name"
      log "journald configuration updated."
    else
      log "journald configuration already set - No changes made."
    fi
  else
    log "journald configuration file not found: $conf_file - Doesn’t exist."
    exit 1
  fi
else
  log "Unable to determine the OS."
  exit 1
fi
