#!/bin/bash

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script as root or with sudo."
  exit 1
fi

# Log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Supported OS versions
OS_VERSIONS=("20.04" "22.04" "24.04")
OS_TYPE=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
ARCH=$(uname -m)

# Check if the OS is supported
if [[ "$OS_TYPE" == "Ubuntu" && " ${OS_VERSIONS[@]} " =~ " ${OS_VERSION} " ]] || [[ "$OS_TYPE" == "RedHat" ]]; then
  log_action "Operating System: $OS_TYPE $OS_VERSION $ARCH - Supported"
else
  log_action "Operating System: $OS_TYPE $OS_VERSION $ARCH - Not Supported"
  echo "This script only supports Ubuntu 20.04, 22.04, 24.04, and Red Hat."
  exit 1
fi

# Create /etc/ssh/login_message file with custom content
LOGIN_MESSAGE="/etc/ssh/login_message"
if [ ! -f "$LOGIN_MESSAGE" ]; then
  echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                 ____                 _
                / ___|_   _ _ __  ___| |__  _   _ _ __
               | |  _| | | | '_ \/ __| '_ \| | | | '_ \
               | |_| | |_| | |_) \__ \ | | | |_| | |_) |
                \____|\__,_| .__/|___/_| |_|\__,_| .__/
                           |_|                   |_|

========================================-{:systems@gupshup.io:}-======

             All connections are monitored and recorded.
        Disconnect IMMEDIATELY if you are not an authorized user.

  This system is for the use of authorised users only.individuals
using this computer system without authority, or in excess of their
authority, are subject to having all of their activities on this
system monitored and recorded by system personnel.

   In the course of monitoring individuals improperly using this
system, or in the course of system maintenance, the activities of
authorised users may also be monitored.

    Anyone using this system expressly consents to such monitoring
and is advised that if such monitoring reveals possible evidence of
criminal activity, system personnel may provide the evidence of such
monitoring to law enforcement officials.
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=" > "$LOGIN_MESSAGE"
  log_action "Created $LOGIN_MESSAGE"
else
  log_action "$LOGIN_MESSAGE already exists."
fi

# Set permissions for the login_message file
chmod 777 "$LOGIN_MESSAGE"
log_action "Set permissions for $LOGIN_MESSAGE to 777"

# Restart SSH service
if systemctl restart sshd; then
  log_action "SSH service has been restarted."
else
  log_action "Failed to restart SSH service."
fi

# Change ownership of directories
DIRECTORIES=("/home/deploy" "/backup")
for DIR in "${DIRECTORIES[@]}"; do
  if [ -d "$DIR" ]; then
    chown -R deploy:automation "$DIR"
    log_action "Changed ownership of $DIR to deploy:automation"
  else
    log_action "$DIR does not exist."
  fi
done

echo "Script completed. Check the log at $LOG_FILE for details."
