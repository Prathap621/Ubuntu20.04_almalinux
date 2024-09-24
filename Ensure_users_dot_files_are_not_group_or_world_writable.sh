#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

check_user_dot_file_permissions() {
    os_release_file="/etc/os-release"

    if [ -f "$os_release_file" ]; then
        os_name=$(grep -oP '(?<=^ID=).+' "$os_release_file")
        log_action "Detected operating system: $os_name."

        if [ "$os_name" == "ubuntu" ]; then
            log_action "Checking user dot file permissions for Ubuntu."
            awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $6 }' /etc/passwd | while read -r dir; do
                if [ -d "$dir" ]; then
                    for file in "$dir"/.[!.]*; do
                        if [ ! -h "$file" ] && [ -f "$file" ]; then
                            fileperm=$(stat -L -c "%A" "$file")
                            if [ "$(echo "$fileperm" | cut -c6)" != "-" ] || [ "$(echo "$fileperm" | cut -c9)" != "-" ]; then
                                log_action "Changing permissions for $file."
                                chmod go-w "$file"
                                log_action "Permissions updated for $file."
                            else
                                log_action "Permissions for $file are already correct (match)."
                            fi
                        fi
                    done
                else
                    log_action "Directory $dir does not exist (doesn't exist)."
                fi
            done

        elif [ "$os_name" == "almalinux" ]; then
            log_action "Checking user dot file permissions for AlmaLinux."
            awk -F: '($1!~/(halt|sync|shutdown)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1 " " $6 }' /etc/passwd | while read -r user dir; do
                if [ -d "$dir" ]; then
                    for file in "$dir"/.[!.]*; do
                        if [ ! -h "$file" ] && [ -f "$file" ]; then
                            fileperm=$(stat -L -c "%A" "$file")
                            if [ "$(echo "$fileperm" | cut -c6)" != "-" ] || [ "$(echo "$fileperm" | cut -c9)" != "-" ]; then
                                log_action "Changing permissions for $file."
                                chmod go-w "$file"
                                log_action "Permissions updated for $file."
                            else
                                log_action "Permissions for $file are already correct (match)."
                            fi
                        fi
                    done
                else
                    log_action "Directory $dir does not exist (doesn't exist)."
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

log_action "Starting user dot file permissions check."
check_user_dot_file_permissions
log_action "User dot file permissions check complete."
