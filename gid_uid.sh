#!/bin/bash

# Log function to handle logging
log_action() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> /root/output.log
}

# Check for supported OS versions
check_os_support() {
    os_id=$(grep -oP 'ID=\K\w+' /etc/os-release)
    os_version=$(grep -oP 'VERSION_ID=\K\S+' /etc/os-release)

    case "$os_id" in
        ubuntu)
            if [[ "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04" ]]; then
                log_action "Supported Ubuntu version: $os_version"
            else
                log_action "Unsupported Ubuntu version: $os_version"
                exit 1
            fi
            ;;
        almalinux | centos | rhel)
            log_action "Supported Red Hat flavor: $os_id $os_version"
            ;;
        *)
            log_action "Unsupported operating system: $os_id"
            exit 1
            ;;
    esac
}

check_duplicate_gids() {
    group_file="/etc/group"
    duplicate_gids=$(cut -d: -f3 "$group_file" | sort | uniq -d)

    if [[ -z $duplicate_gids ]]; then
        log_action "No duplicate Group IDs (GIDs) found in $group_file."
    else
        log_action "Duplicate Group IDs (GIDs) found in $group_file:"
        echo "$duplicate_gids" | while read gid; do
            log_action "Duplicate GID: $gid"
        done
    fi
}

check_duplicate_uids() {
    duplicate_uids=$(cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x; do
        [ -z "$x" ] && break
        set - $x
        if [ $1 -gt 1 ]; then
            users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
            echo "Duplicate UID ($2): $users"
        fi
    done)

    if [[ -z $duplicate_uids ]]; then
        log_action "No duplicate UIDs found in /etc/passwd."
    else
        log_action "Duplicate UIDs found in /etc/passwd:"
        echo "$duplicate_uids" | while read line; do
            log_action "$line"
        done
    fi
}

# Main script execution
log_action "Script execution started."
check_os_support
check_duplicate_gids
check_duplicate_uids
log_action "Script execution finished."
