#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

check_shadow_group() {
    os_id=$(grep -oP 'ID=\K\w+' /etc/os-release)

    case "$os_id" in
        ubuntu)
            log_action "Detected Ubuntu OS."
            shadow_group_users=$(awk -F: '($1=="shadow") {print $NF}' /etc/group)
            shadow_group_gid=$(awk -F: '($1=="shadow") {print $3}' /etc/group)
            ;;
        almalinux)
            log_action "Detected AlmaLinux OS."
            shadow_group_users=$(awk -F: '($1=="shadow") {print $NF}' /etc/group)
            shadow_group_gid=$(awk -F: '($1=="shadow") {print $3}' /etc/group)
            ;;
        *)
            log_action "Unsupported operating system: $os_id."
            exit 1
            ;;
    esac

    # Check if shadow group has users
    if [[ -z $shadow_group_users ]]; then
        log_action "No users found in the shadow group (doesn't exist)."
    else
        log_action "Users found in the shadow group (exists):"
        log_action "$shadow_group_users"
    fi

    # Remediation
    if [[ -n $shadow_group_users ]]; then
        log_action "Performing remediation steps..."
        
        # Remove users from the shadow group in the group file
        sed -ri 's/(^shadow:[^:]*:[^:]*:)([^:]+$)/\1/' /etc/group
        log_action "Removed users from the shadow group in /etc/group."

        # Change primary group for users with shadow as their primary group
        while read -r user; do
            primary_group=$(id -gn "$user")
            log_action "Changing primary group for user $user from shadow to $primary_group."
            usermod -g "$primary_group" "$user"
        done < <(awk -F: -v GID="$shadow_group_gid" '($4==GID) {print $1}' /etc/passwd)

        log_action "Remediation steps completed."
    else
        log_action "No remediation steps necessary."
    fi
}

# Execute the function
log_action "Starting script execution."
check_shadow_group
log_action "Script execution completed."
