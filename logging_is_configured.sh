#!/bin/bash

LOG_FILE="/root/output.log"

# Function to log messages
log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if OS is Ubuntu
if [[ -f /etc/lsb-release ]]; then
  if grep -q -E 'DISTRIB_ID=Ubuntu' /etc/lsb-release; then
    VERSION=$(grep -E '^DISTRIB_RELEASE=' /etc/lsb-release | cut -d'=' -f2)

    if [[ "$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04" ]]; then
      log_action "Detected Ubuntu version $VERSION."
      # Check architecture
      if [[ "$(uname -m)" == "x86_64" || "$(uname -m)" == "aarch64" ]]; then
        # Ubuntu configuration
        sudo sed -i '/^\*\.=\(.*\)$/s/^#//' /etc/rsyslog.conf
        sudo sed -i '/^\*\.=\/var\/log\/syslog$/s/^#//' /etc/rsyslog.conf
        sudo service rsyslog restart
        log_action "Logging configuration updated for Ubuntu $VERSION."
      else
        log_action "Architecture not supported: $(uname -m). Skipping configuration for Ubuntu $VERSION."
      fi
    else
      log_action "Ubuntu version $VERSION does not match supported versions (20.04, 22.04, 24.04)."
    fi
  else
    log_action "Not an Ubuntu OS."
  fi
else
  log_action "/etc/lsb-release does not exist. Not an Ubuntu OS."
fi

# Check if OS is AlmaLinux or RHEL
if [[ -f /etc/os-release ]]; then
  if grep -q -E 'ID=(alma|rhel)' /etc/os-release; then
    log_action "Detected AlmaLinux or RHEL."
    # AlmaLinux/RHEL configuration
    sudo sed -i '/^\*\.=\(.*\)$/s/^#//' /etc/rsyslog.conf
    sudo sed -i '/^\*\.=\/var\/log\/messages$/s/^#//' /etc/rsyslog.conf
    sudo systemctl restart rsyslog
    log_action "Logging configuration updated for AlmaLinux/RHEL."
  else
    log_action "Not an AlmaLinux or RHEL OS."
  fi
else
  log_action "/etc/os-release does not exist. Not an AlmaLinux or RHEL OS."
fi
