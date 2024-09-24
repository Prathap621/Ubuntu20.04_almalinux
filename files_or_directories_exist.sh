#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$message"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

check_ubuntu_unowned_files() {
    unowned_files=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    if [[ -n "$unowned_files" ]]; then
        log_action "Unowned files and directories found (match):"
        log_action "$unowned_files"
        log_action "To remediate, review files and assign appropriate ownership."
    else
        log_action "No unowned files or directories found (unmatch)."
    fi
}

check_redhat_unowned_files() {
    unowned_files=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    if [[ -n "$unowned_files" ]]; then
        log_action "Unowned files and directories found (match):"
        log_action "$unowned_files"
        log_action "To remediate, review files and assign appropriate ownership."
    else
        log_action "No unowned files or directories found (unmatch)."
    fi
}

# Check the architecture and OS version for Ubuntu
check_architecture_and_version() {
    arch=$(uname -m)
    if [[ "$ID" == "ubuntu" ]]; then
        if [[ "$VERSION_ID" =~ ^(20\.04|22\.04|24\.04)$ ]]; then
            if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
                log_action "Ubuntu $VERSION_ID on $arch is supported (match)."
                check_ubuntu_unowned_files
            else
                log_action "Unsupported architecture for Ubuntu: $arch (unmatch)."
                exit 1
            fi
        else
            log_action "Unsupported Ubuntu version: $VERSION_ID (unmatch)."
            exit 1
        fi
    elif [[ "$ID" == "rhel" || "$ID" == "almalinux" || "$ID" == "centos" ]]; then
        log_action "$PRETTY_NAME is supported (match)."
        check_redhat_unowned_files
    else
        log_action "Unsupported operating system: $PRETTY_NAME (unmatch)."
        exit 1
    fi
}

# Check if /etc/os-release exists
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    check_architecture_and_version
else
    log_action "Unable to determine the operating system (doesn't exist)."
    exit 1
fi
