#!/bin/bash

LOG_FILE="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_duplicate_group_names() {
    os_id=$(grep -oP 'ID=\K\w+' /etc/os-release)

    case "$os_id" in
        ubuntu)
            group_file="/etc/group"
            ;;
        almalinux)
            group_file="/etc/gshadow"
            ;;
        *)
            log_message "Unsupported operating system: $os_id"
            exit 1
            ;;
    esac

    duplicate_groups=$(cut -d: -f1 "$group_file" | sort | uniq -d)
    
    if [[ -z $duplicate_groups ]]; then
        log_message "No duplicate group names found."
    else
        log_message "Duplicate group names found: $duplicate_groups"
    fi
}

check_duplicate_user_names() {
    os_id=$(grep -oP 'ID=\K\w+' /etc/os-release)

    case "$os_id" in
        ubuntu)
            passwd_file="/etc/passwd"
            ;;
        almalinux)
            passwd_file="/etc/shadow"
            ;;
        *)
            log_message "Unsupported operating system: $os_id"
            exit 1
            ;;
    esac

    duplicate_users=$(cut -d: -f1 "$passwd_file" | sort | uniq -d)
    
    if [[ -z $duplicate_users ]]; then
        log_message "No duplicate user names found."
    else
        log_message "Duplicate user names found: $duplicate_users"
    fi
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    log_message "This script must be run as root. Please use sudo."
    exit 1
fi

# Log script start
log_message "Script execution started."

# Execute the functions
check_duplicate_group_names
check_duplicate_user_names

# Log script completion
log_message "Script execution completed."
