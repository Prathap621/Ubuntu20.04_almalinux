#!/bin/bash

# Log function to handle logging actions
log_action() {
  local action_message="$1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $action_message" >> /root/output.log
}

# Function to check the operating system ID
get_os_id() {
  if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS_ID="$ID"
  elif [ -f "/etc/lsb-release" ]; then
    . /etc/lsb-release
    OS_ID="$DISTRIB_ID"
  elif [ -f "/etc/redhat-release" ]; then
    OS_ID=$(awk '{print $1}' /etc/redhat-release)
  else
    OS_ID=$(uname -s)
  fi
  echo "$OS_ID"
}

# Get the operating system ID
OS_ID=$(get_os_id)

# Function to check architecture
check_architecture() {
  ARCH=$(uname -m)
  if [[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]]; then
    log_action "Architecture check: $ARCH exists."
    return 0
  else
    log_action "Unsupported architecture: $ARCH."
    return 1
  fi
}

# Ensure the architecture is supported
if ! check_architecture; then
  exit 1
fi

if [[ "$OS_ID" == "ubuntu" ]]; then
  # Check Ubuntu versions
  UBUNTU_VERSION=$(lsb_release -sr)
  if [[ "$UBUNTU_VERSION" == "20.04" || "$UBUNTU_VERSION" == "22.04" || "$UBUNTU_VERSION" == "24.04" ]]; then
    log_action "Ubuntu version $UBUNTU_VERSION exists."
    if [ -f "/etc/login.defs" ]; then
      # Set PASS_MAX_DAYS to 99999
      if grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
        sed -i 's/^#\?PASS_MAX_DAYS.*/PASS_MAX_DAYS 99999/' /etc/login.defs
        log_action "Password expiration has been set to 99999 days for Ubuntu."
      else
        echo "PASS_MAX_DAYS entry not found in /etc/login.defs."
        log_action "PASS_MAX_DAYS entry doesn't exist in /etc/login.defs."
      fi
    else
      log_action "File /etc/login.defs not found for Ubuntu."
    fi
  else
    log_action "Unsupported Ubuntu version: $UBUNTU_VERSION."
  fi
elif [[ "$OS_ID" == "almalinux" || "$OS_ID" == "centos" || "$OS_ID" == "fedora" ]]; then
  # Check AlmaLinux and other Red Hat flavors
  if [ -f "/etc/login.defs" ]; then
    # Set PASS_MAX_DAYS to 99999
    if grep -q "^PASS_MAX_DAYS" /etc/login.defs; then
      sed -i 's/^#\?PASS_MAX_DAYS.*/PASS_MAX_DAYS 99999/' /etc/login.defs
      log_action "Password expiration has been set to 99999 days for $OS_ID."
    else
      echo "PASS_MAX_DAYS entry not found in /etc/login.defs."
      log_action "PASS_MAX_DAYS entry doesn't exist in /etc/login.defs."
    fi
  else
    log_action "File /etc/login.defs not found for $OS_ID."
  fi
else
  log_action "Unsupported operating system: $OS_ID."
fi
