#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

check_user_home_ownership() {
    os_release_file="/etc/os-release"

    if [ -f "$os_release_file" ]; then
        os_name=$(grep -oP '(?<=^ID=).+' "$os_release_file")
        log_action "Detected operating system: $os_name."

        if [ "$os_name" == "ubuntu" ]; then
            log_action "Checking user home directory ownership for Ubuntu."
            awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1 " " $6 }' /etc/passwd | while read -r user dir; do
                if [ -d "$dir" ]; then
                    dir_owner=$(stat -c "%U" "$dir")
                    if [ "$dir_owner" != "$user" ]; then
                        log_action "Changing ownership of $dir from $dir_owner to $user."
                        chown "$user:$user" "$dir"
                        log_action "Ownership changed for $dir."
                    else
                        log_action "Ownership of $dir is correct (match)."
                    fi
                else
                    log_action "Home directory $dir does not exist (doesn't exist)."
                fi
            done

        elif [ "$os_name" == "almalinux" ]; then
            log_action "Checking user home directory ownership for AlmaLinux."
            awk -F: '($1!~/(halt|sync|shutdown)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1 " " $6 }' /etc/passwd | while read -r user dir; do
                if [ -d "$dir" ]; then
                    dir_owner=$(stat -c "%U" "$dir")
                    if [ "$dir_owner" != "$user" ]; then
                        log_action "Changing ownership of $dir from $dir_owner to $user."
                        chown "$user:$user" "$dir"
                        log_action "Ownership changed for $dir."
                    else
                        log_action "Ownership of $dir is correct (match)."
                    fi
                else
                    log_action "Home directory $dir does not exist (doesn't exist)."
                fi
            done

        else
            log_action "Unsupported operating system: $os_name. Exiting..."
            exit 1
        fi
    else
        log_action "Unable to determine the operating system. Exiting..."
        exit 1
    fi
}

log_action "Starting user home directory ownership check."
check_user_home_ownership
log_action "User home directory ownership check complete."
