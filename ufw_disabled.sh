#!/bin/bash

# Log file
LOGFILE="/root/output.log"

# Function to log messages
log_message() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install or uninstall packages
manage_package() {
  local action="$1"
  local package="$2"
  
  if [ "$action" == "install" ]; then
    if command_exists apt-get; then
      sudo apt-get install "$package" -y
      log_message "$package has been installed."
    elif command_exists dnf; then
      sudo dnf install "$package" -y
      log_message "$package has been installed."
    elif command_exists yum; then
      sudo yum install "$package" -y
      log_message "$package has been installed."
    else
      log_message "Package manager not found. Please install $package manually."
      exit 1
    fi
  elif [ "$action" == "remove" ]; then
    if command_exists apt-get; then
      sudo apt-get remove "$package" -y
      log_message "$package has been uninstalled."
    elif command_exists dnf; then
      sudo dnf remove "$package" -y
      log_message "$package has been uninstalled."
    elif command_exists yum; then
      sudo yum remove "$package" -y
      log_message "$package has been uninstalled."
    else
      log_message "Package manager not found. Please uninstall $package manually."
      exit 1
    fi
  fi
}

# Check if ufw is installed
if command_exists ufw; then
  log_message "ufw is installed."
  
  # Disable ufw
  log_message "Disabling ufw..."
  if command_exists systemctl; then
    sudo systemctl stop ufw
  else
    sudo service ufw stop
  fi
  
  # Uninstall ufw
  log_message "Uninstalling ufw..."
  manage_package "remove" "ufw"
else
  log_message "ufw is not installed."
fi

# Check if iptables is installed
if ! command_exists iptables; then
  log_message "iptables is not installed."
  
  # Install iptables
  log_message "Installing iptables..."
  manage_package "install" "iptables"
else
  log_message "iptables is already installed."
fi
