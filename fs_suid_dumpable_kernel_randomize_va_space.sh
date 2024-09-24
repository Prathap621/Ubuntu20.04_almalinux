#!/bin/bash

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Supported distributions and architectures
SUPPORTED_UBUNTU_VERSIONS=("20.04" "22.04" "24.04")
SUPPORTED_ARCH=("x86_64" "arm64")

# Check for supported OS
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
ARCH=$(uname -m)

if [[ "$OS_NAME" != "Ubuntu" && "$OS_NAME" != "RedHat" && "$OS_NAME" != "CentOS" ]]; then
  echo "This script only supports Ubuntu and Red Hat flavors."
  echo "OS: $OS_NAME" >> /root/output.log
  exit 1
fi

if [[ "$OS_NAME" == "Ubuntu" ]]; then
  if [[ ! " ${SUPPORTED_UBUNTU_VERSIONS[@]} " =~ " $OS_VERSION " ]]; then
    echo "This script only supports Ubuntu versions: ${SUPPORTED_UBUNTU_VERSIONS[*]}"
    echo "OS Version: $OS_VERSION" >> /root/output.log
    exit 1
  fi
elif [[ "$OS_NAME" == "RedHat" || "$OS_NAME" == "CentOS" ]]; then
  # You can add specific checks for Red Hat versions if needed
  echo "Red Hat flavor detected. Continuing..."
fi

if [[ ! " ${SUPPORTED_ARCH[@]} " =~ " $ARCH " ]]; then
  echo "This script only supports architectures: ${SUPPORTED_ARCH[*]}"
  echo "Architecture: $ARCH" >> /root/output.log
  exit 1
fi

# Log file
LOG_FILE="/root/output.log"

# Check if the lines are already present in /etc/sysctl.conf
if grep -Fxq "fs.suid_dumpable = 0" /etc/sysctl.conf && grep -Fxq "kernel.randomize_va_space = 2" /etc/sysctl.conf; then
  echo "Both fs.suid_dumpable = 0 and kernel.randomize_va_space = 2 are already present in /etc/sysctl.conf. No changes needed." | tee -a $LOG_FILE
else
  if ! grep -Fxq "fs.suid_dumpable = 0" /etc/sysctl.conf; then
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
    echo "Added: fs.suid_dumpable = 0" | tee -a $LOG_FILE
  else
    echo "Exists: fs.suid_dumpable = 0" | tee -a $LOG_FILE
  fi

  if ! grep -Fxq "kernel.randomize_va_space = 2" /etc/sysctl.conf; then
    echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
    echo "Added: kernel.randomize_va_space = 2" | tee -a $LOG_FILE
  else
    echo "Exists: kernel.randomize_va_space = 2" | tee -a $LOG_FILE
  fi
fi

# Apply the changes immediately
sysctl -p

echo "Core dump restrictions and kernel address space randomization have been enabled." | tee -a $LOG_FILE
