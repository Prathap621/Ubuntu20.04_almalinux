#!/bin/bash

# Log function to print messages to /root/output.log
log_action() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> /root/output.log
}

# Function to check the operating system
get_os() {
  if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS="$NAME"
    VERSION_ID="$VERSION_ID"
  elif [ -f "/etc/lsb-release" ]; then
    . /etc/lsb-release
    OS="$DISTRIB_ID"
    VERSION_ID="$DISTRIB_RELEASE"
  elif [ -f "/etc/redhat-release" ]; then
    OS=$(awk '{print $1}' /etc/redhat-release)
    VERSION_ID=$(awk '{print $3}' /etc/redhat-release)
  else
    OS=$(uname -s)
    VERSION_ID="unknown"
  fi
  echo "$OS:$VERSION_ID"
}

# Set the desired permissions for the sshd_config file
sshd_config_permissions="600"

# Get the operating system and version
os_info=$(get_os)
OS=$(echo $os_info | cut -d':' -f1)
VERSION_ID=$(echo $os_info | cut -d':' -f2)

# Check architecture
ARCH=$(uname -m)

# Log the detected OS and architecture
log_action "Detected OS: $OS, Version: $VERSION_ID, Architecture: $ARCH"

if [[ "$OS" == "Ubuntu" && ("$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" || "$VERSION_ID" == "24.04") ]]; then
  # Ubuntu
  if [ -f "/etc/ssh/sshd_config" ]; then
    # Set the correct permissions
    chmod "$sshd_config_permissions" /etc/ssh/sshd_config
    log_action "Permissions on /etc/ssh/sshd_config have been configured for Ubuntu."
  else
    log_action "File /etc/ssh/sshd_config not found for Ubuntu."
  fi
elif [[ "$OS" == "AlmaLinux" || "$OS" == "CentOS" || "$OS" == "Fedora" ]]; then
  # Red Hat flavors
  if [ -f "/etc/ssh/sshd_config" ]; then
    # Set the correct permissions
    chmod "$sshd_config_permissions" /etc/ssh/sshd_config
    log_action "Permissions on /etc/ssh/sshd_config have been configured for $OS."
  else
    log_action "File /etc/ssh/sshd_config not found for $OS."
  fi
else
  log_action "Unsupported operating system: $OS"
fi

# Log if the architecture is supported
if [[ "$OS" == "Ubuntu" && ("$ARCH" == "x86_64" || "$ARCH" == "aarch64") ]]; then
  log_action "Architecture $ARCH is supported for Ubuntu."
else
  log_action "Architecture $ARCH is not supported for $OS."
fi
