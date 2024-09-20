#!/bin/bash

# Detect if the OS is Ubuntu or AlmaLinux
detect_os() {
    if [[ -f /etc/lsb-release && $(grep -c "Ubuntu" /etc/lsb-release) -gt 0 ]]; then
        OS="ubuntu"
    elif [[ -f /etc/os-release && $(grep -c "AlmaLinux" /etc/os-release) -gt 0 ]]; then
        OS="almalinux"
    else
        echo "Unsupported operating system."
        exit 1
    fi
}

# Function to check permissions for cron directories or files
check_permissions() {
    local CRON_PATH=$1
    local EXPECTED_PERMISSIONS=$2

    # Check if the file or directory exists
    if [[ -e $CRON_PATH ]]; then
        CURRENT_PERMISSIONS=$(stat -c "%a" $CRON_PATH)

        # Check if permissions are as expected
        if [[ $CURRENT_PERMISSIONS != $EXPECTED_PERMISSIONS ]]; then
            echo "To update: $CRON_PATH (Current: $CURRENT_PERMISSIONS, Expected: $EXPECTED_PERMISSIONS)"
        else
            echo "Already configured: $CRON_PATH"
        fi
    else
        echo "$CRON_PATH does not exist on this system."
    fi
}

# Main function to handle all cron directories and files
main() {
    detect_os
    
    # Define directories and expected permissions
    declare -A cron_paths_permissions=(
        ["/etc/cron.hourly"]="700"
        ["/etc/cron.daily"]="700"
        ["/etc/cron.weekly"]="700"
        ["/etc/cron.monthly"]="700"
        ["/etc/crond"]="600"
    )

    # Loop through each path and check permissions
    for CRON_PATH in "${!cron_paths_permissions[@]}"; do
        EXPECTED_PERMISSIONS=${cron_paths_permissions[$CRON_PATH]}
        check_permissions $CRON_PATH $EXPECTED_PERMISSIONS
    done
}

# Execute the main function
main
