#!/bin/bash

LOG_FILE="/root/output.log"
ARCH=$(uname -m)

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_ubuntu_unowned_files() {
    log_action "Checking unowned files on Ubuntu (${VERSION_ID}) - Architecture: ${ARCH}"

    unowned_files=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    if [[ -n "$unowned_files" ]]; then
        log_action "Unowned files and directories found:"
        echo "$unowned_files" | tee -a "$LOG_FILE"
        log_action "Review and assign appropriate ownership."
    else
        log_action "No unowned files or directories found."
    fi
}

check_redhat_unowned_files() {
    log_action "Checking unowned files on Red Hat flavor (${ID})"

    unowned_files=$(find / -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    if [[ -n "$unowned_files" ]]; then
        log_action "Unowned files and directories found:"
        echo "$unowned_files" | tee -a "$LOG_FILE"
        log_action "Review and assign appropriate ownership."
    else
        log_action "No unowned files or directories found."
    fi
}

# Check the operating system
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    os_name="${ID,,}"
else
    log_action "Unable to determine the operating system."
    exit 1
fi

# Check architecture compatibility for Ubuntu
if [[ "$os_name" == "ubuntu" && ( "$VERSION_ID" == "20.04" || "$VERSION_ID" == "22.04" || "$VERSION_ID" == "24.04" ) ]]; then
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]]; then
        check_ubuntu_unowned_files
    else
        log_action "Unsupported architecture: ${ARCH} for Ubuntu."
        exit 1
    fi
elif [[ "$os_name" == "rhel" || "$os_name" == "centos" || "$os_name" == "almalinux" || "$os_name" == "rocky" ]]; then
    check_redhat_unowned_files
else
    log_action "Unsupported operating system: $os_name"
    exit 1
fi

log_action "Script execution completed."
