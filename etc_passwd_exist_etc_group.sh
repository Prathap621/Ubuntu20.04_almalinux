#!/bin/bash

log_file="/root/output.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

check_groups_existence() {
    os_id=$(grep -oP 'ID=\K\w+' /etc/os-release)
    os_version=$(grep -oP 'VERSION_ID=\K\w+' /etc/os-release)

    case "$os_id" in
        ubuntu)
            if [[ "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04" ]]; then
                check_groups_existence_ubuntu
            else
                log_message "Unsupported Ubuntu version: $os_version"
            fi
            ;;
        almalinux)
            check_groups_existence_almalinux
            ;;
        *)
            log_message "Unsupported operating system."
            exit 1
            ;;
    esac
}

check_groups_existence_ubuntu() {
    for group_id in $(cut -s -d: -f4 /etc/passwd | sort -u); do
        if grep -q -P "^.*?:[^:]*:$group_id:" /etc/group; then
            log_message "Group $group_id exists in /etc/group."
        else
            log_message "Group $group_id is referenced by /etc/passwd but does not exist in /etc/group."
        fi
    done
}

check_groups_existence_almalinux() {
    for group_id in $(cut -s -d: -f4 /etc/passwd | sort -u); do
        if grep -q -P "^.*?:[^:]*:$group_id:" /etc/group; then
            log_message "Group $group_id exists in /etc/group."
        elif grep -q -P "^.*?:[^:]*:[^:]*:$group_id:" /etc/group; then
            log_message "Group $group_id exists in /etc/group as a secondary group."
        else
            log_message "Group $group_id is referenced by /etc/passwd but does not exist in /etc/group."
        fi
    done
}

# Execute the function
check_groups_existence
