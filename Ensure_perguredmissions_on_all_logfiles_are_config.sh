#!/bin/bash

# Set the log directory path
log_directory="/var/log"

# Set the log file
log_file="/root/output.log"

# Set the desired permissions for log files
log_file_permissions="640"

# Set the desired permissions for log directories
log_directory_permissions="750"

# Function to log messages
log_action() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Check the operating system and architecture
if [ -f "/etc/lsb-release" ]; then
  source /etc/lsb-release
  
  # Only for Ubuntu systems
  if [[ "$DISTRIB_ID" == "Ubuntu" ]]; then
    # Get architecture
    arch=$(uname -m)
    if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
      log_action "Detected Ubuntu $DISTRIB_RELEASE on $arch architecture."
      
      # Apply file and directory permissions
      log_action "Updating permissions for log files and directories."
      find "$log_directory" -type f -perm /g+wx,o+rwx -exec chmod --changes g-wx,o-rwx "{}" + -exec bash -c 'log_action "Updated permissions on file: $0"' "{}" \;
      find "$log_directory" \( -type d -exec chmod --changes g-wx,o-rwx "{}" + -exec bash -c 'log_action "Updated permissions on directory: $0"' "{}" \; \) -o \( -type f -exec chmod --changes "$log_file_permissions" "{}" + -exec bash -c 'log_action "Updated permissions on file: $0"' "{}" \; \)

      log_action "Permissions for Ubuntu system have been configured."
    else
      log_action "Unsupported architecture: $arch. No action taken."
    fi
  else
    log_action "Non-Ubuntu system detected in lsb-release. No action taken."
  fi

elif [ -f "/etc/os-release" ]; then
  source /etc/os-release
  
  # Check for Red Hat flavors like AlmaLinux
  if [[ "$ID" == "almalinux" || "$ID" == "rhel" || "$ID" == "centos" ]]; then
    log_action "Detected Red Hat flavor: $NAME $VERSION_ID."
    
    # Apply file and directory permissions
    log_action "Updating permissions for log files and directories."
    find "$log_directory" -type f -perm /g+wx,o+wx -exec chmod --changes g-wx,o-wx "{}" + -exec bash -c 'log_action "Updated permissions on file: $0"' "{}" \;
    find "$log_directory" -type d -perm /g+wx,o+wx -exec chmod --changes g-wx,o-wx "{}" + -exec bash -c 'log_action "Updated permissions on directory: $0"' "{}" \;
    find "$log_directory" -type f -exec chmod --changes "$log_file_permissions" "{}" + -exec bash -c 'log_action "Updated permissions on file: $0"' "{}" \;
    find "$log_directory" -type d -exec chmod --changes "$log_directory_permissions" "{}" + -exec bash -c 'log_action "Updated permissions on directory: $0"' "{}" \;

    log_action "Permissions for Red Hat flavor have been configured."
  else
    log_action "Unsupported Red Hat-like system detected. No action taken."
  fi

else
  log_action "Unsupported operating system detected. Exiting."
  echo "Unsupported operating system."
  exit 1
fi

log_action "Script execution completed."
echo "Permissions on log files and directories have been configured."
