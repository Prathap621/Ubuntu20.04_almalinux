#!/bin/bash

log_file="/root/output.log"

log() {
    echo "$(date): $1" >> "$log_file"
}

check_ubuntu_unowned_files() {
    log "Checking for unowned files and directories on Ubuntu"
    unowned_files=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    if [[ -n "$unowned_files" ]]; then
        log "Unowned files and directories found:"
        log "$unowned_files"
        log "To remediate the issue, review the listed files and directories and assign appropriate ownership."
    else
        log "No unowned files or directories found."
    fi
}

check_redhat_unowned_files() {
    log "Checking for unowned files and directories on Red Hat-based OS"
    unowned_files=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    if [[ -n "$unowned_files" ]]; then
        log "Unowned files and directories found:"
        log "$unowned_files"
        log "To remediate the issue, review the listed files and directories and assign appropriate ownership."
    else
        log "No unowned files or directories found."
    fi
}

# Check architecture
check_architecture() {
    arch=$(uname -m)
    if [[ "$arch" == "x86_64" ]]; then
        log "Architecture: x86_64"
    elif [[ "$arch" == "aarch64" ]]; then
        log "Architecture: arm64"
    else
        log "Unsupported architecture: $arch"
        exit 1
    fi
}

# Check the operating system and version
check_os_version() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        os_name="${ID,,}"
        os_version="${VERSION_ID}"
        log "OS detected: $os_name $os_version"
    else
        log "Unable to determine the operating system."
        exit 1
    fi
}

# Run the appropriate function based on the operating system and architecture
run_checks() {
    check_architecture

    if [[ "$os_name" == "ubuntu" ]]; then
        if [[ "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04" ]]; then
            if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
                check_ubuntu_unowned_files
            else
                log "Unsupported architecture for Ubuntu: $arch"
                exit 1
            fi
        else
            log "Unsupported Ubuntu version: $os_version"
            exit 1
        fi
    elif [[ "$os_name" == "almalinux" || "$os_name" == "rhel" ]]; then
        check_redhat_unowned_files
    else
        log "Unsupported operating system: $os_name"
        exit 1
    fi
}

# Start script execution
log "Script started"
check_os_version
run_checks
log "Script finished"
