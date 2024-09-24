#!/bin/bash

# Define the log file
log_file="/root/output.log"

# Function to log actions
log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Check the OS version and architecture
if [[ "$(uname -s)" == "Linux" ]]; then
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "ubuntu" && ("$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" || "$VERSION_ID" == "24.04") ]]; then
      log_action "Detected Ubuntu version $VERSION_ID"
    elif [[ "$ID" == "rhel" || "$ID" == "centos" || "$ID" == "fedora" ]]; then
      log_action "Detected Red Hat flavor $ID"
    else
      log_action "Unsupported OS: $ID $VERSION_ID"
      exit 1
    fi
  else
    log_action "Could not determine OS version."
    exit 1
  fi
else
  log_action "This script only runs on Linux."
  exit 1
fi

# Ensure sudo authentication timeout is configured correctly
sudo_timeout_conf="/etc/sudoers.d/timeout"
if [[ -f "$sudo_timeout_conf" ]]; then
  log_action "Sudo authentication timeout is already configured."
else
  log_action "Configuring sudo authentication timeout..."
  echo "Defaults timestamp_timeout=300" >> "$sudo_timeout_conf"
  log_action "Sudo authentication timeout has been configured."
fi

# Ensure systemd-journal-remote is installed (only for Ubuntu)
if [[ "$ID" == "ubuntu" ]]; then
  if command -v systemd-journal-remote &>/dev/null; then
    log_action "systemd-journal-remote is already installed."
  else
    log_action "Installing systemd-journal-remote..."
    apt-get update
    apt-get install -y systemd-journal-remote
    log_action "systemd-journal-remote has been installed."
  fi
fi

# Ensure journald is not configured to receive logs from a remote client
journald_conf="/etc/systemd/journald.conf"
if grep -q "^ForwardToSyslog" "$journald_conf"; then
  log_action "Remote logging is already disabled in $journald_conf."
else
  log_action "Disabling remote logging in $journald_conf..."
  sed -i 's/^ForwardToSyslog=yes/ForwardToSyslog=no/' "$journald_conf"
  log_action "Remote logging has been disabled in $journald_conf."
fi

# Restart systemd-journald service
if systemctl restart systemd-journald; then
  log_action "systemd-journald service restarted successfully."
else
  log_action "Failed to restart systemd-journald service."
fi

log_action "Configuration checks and changes completed."
