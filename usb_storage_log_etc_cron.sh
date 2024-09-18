#!/bin/bash

# Function to check if the OS is Ubuntu or AlmaLinux
check_os_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_name=$ID
        os_version=$VERSION_ID

        if [[ "$os_name" == "ubuntu" || "$os_name" == "almalinux" ]]; then
            echo "Detected OS: $os_name $os_version."
        else
            echo "This script only supports Ubuntu and AlmaLinux. Exiting..."
            exit 1
        fi
    else
        echo "Cannot determine the OS version. Exiting..."
        exit 1
    fi
}

# Function to check and update log file permissions
check_log_permissions() {
    echo "Checking log file permissions..."
    if find /var/log -type f -perm /220 ! -perm /444 -print -quit | grep -q .; then
        echo "Permissions for log files are not set correctly. Updating permissions..."
        find /var/log -type f -exec chmod g-wx,o-rwx {} +
        echo "Permissions for log files updated."
    else
        echo "No changes: Permissions for log files are already set correctly."
    fi
}

# Function to check and update cron permissions based on OS
check_cron_permissions() {
    echo "Checking cron permissions..."
    
    if [[ "$os_name" == "ubuntu" ]]; then
        cron_dir="/etc/cron.d/"
    elif [[ "$os_name" == "almalinux" ]]; then
        cron_dir="/etc/cron.d/"
    fi

    if [ -d "$cron_dir" ]; then
        current_permissions=$(stat -c %a "$cron_dir")
        if [ "$current_permissions" -ne 600 ]; then
            echo "Permissions for $cron_dir are not set correctly (current: $current_permissions). Updating permissions..."
            sudo chmod 600 "$cron_dir"
            echo "Permissions for $cron_dir updated."
        else
            echo "No changes: Permissions for $cron_dir are already set correctly."
        fi
    else
        echo "No cron directory found to adjust permissions."
    fi
}

# Function to disable usb-storage by creating/modifying usb-storage.conf
check_usb_storage() {
    echo "Checking usb-storage module configuration..."
    
    if [ ! -f "/etc/modprobe.d/usb-storage.conf" ]; then
        echo "usb-storage.conf file not found. Creating and disabling usb-storage..."
        sudo touch /etc/modprobe.d/usb-storage.conf
        sudo chmod 644 /etc/modprobe.d/usb-storage.conf
        echo "install usb-storage /bin/true" | sudo tee /etc/modprobe.d/usb-storage.conf > /dev/null
        echo "Mounting of usb-storage filesystems has been disabled."
    else
        # Check if the configuration is already set
        if grep -Fxq "install usb-storage /bin/true" /etc/modprobe.d/usb-storage.conf; then
            echo "No changes: usb-storage module is already disabled."
        else
            echo "usb-storage.conf exists but usb-storage is not disabled. Disabling now..."
            echo "install usb-storage /bin/true" | sudo tee /etc/modprobe.d/usb-storage.conf > /dev/null
            echo "Mounting of usb-storage filesystems has been disabled."
        fi
    fi
}

# Main script execution
check_os_distribution
check_log_permissions
check_cron_permissions
check_usb_storage
