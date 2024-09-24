#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Function to check and set permissions on a file
check_and_set_permissions() {
    local file="$1"
    local expected_owner="$2"
    local expected_group="$3"
    local expected_permissions="$4"
    local file_name="$(basename "$file")"

    if [[ -f "$file" ]]; then
        owner=$(stat -c "%U" "$file")
        group=$(stat -c "%G" "$file")
        permissions=$(stat -c "%a" "$file")

        if [[ "$owner" != "$expected_owner" || "$group" != "$expected_group" || "$permissions" != "$expected_permissions" ]]; then
            log_action "Unmatched: Incorrect ownership/permissions on $file_name"
            log_action "Setting ownership and permissions on $file_name"
            sudo chown "$expected_owner:$expected_group" "$file"
            sudo chmod "$expected_permissions" "$file"
            log_action "Fixed: Ownership/permissions on $file_name corrected"
        else
            log_action "Matched: Ownership/permissions on $file_name are correct"
        fi
    else
        log_action "File $file_name does not exist"
    fi
}

# Function to handle both architectures on Ubuntu
check_ubuntu() {
    arch=$(uname -m)
    if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
        log_action "OS: Ubuntu $VERSION_ID ($arch)"
    else
        log_action "Unsupported architecture: $arch"
        exit 1
    fi
}

# Function for Red Hat-based distros
check_redhat() {
    log_action "OS: $ID ($VERSION_ID)"
}

# Check the operating system
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
else
    log_action "Unable to determine the operating system"
    exit 1
fi

# Main execution based on OS
case "$ID" in
    ubuntu)
        check_ubuntu
        check_and_set_permissions "/etc/crontab" "root" "root" "600"
        check_and_set_permissions "/etc/group" "root" "root" "644"
        check_and_set_permissions "/etc/gshadow" "root" "shadow" "640"
        check_and_set_permissions "/etc/issue" "root" "root" "644"
        check_and_set_permissions "/etc/issue.net" "root" "root" "644"
        check_and_set_permissions "/etc/passwd" "root" "root" "644"
        check_and_set_permissions "/etc/shadow" "root" "root" "640"
        ;;
    almalinux|rhel|centos)
        check_redhat
        check_and_set_permissions "/etc/crontab" "root" "root" "600"
        check_and_set_permissions "/etc/group" "root" "root" "644"
        check_and_set_permissions "/etc/gshadow" "root" "shadow" "640"
        check_and_set_permissions "/etc/issue" "root" "root" "644"
        check_and_set_permissions "/etc/issue.net" "root" "root" "644"
        check_and_set_permissions "/etc/passwd" "root" "root" "644"
        check_and_set_permissions "/etc/shadow" "root" "root" "640"
        ;;
    *)
        log_action "Unsupported operating system: $ID"
        exit 1
        ;;
esac

# Check if /etc/motd exists and remove it
if [ -f /etc/motd ]; then
    log_action "/etc/motd exists, removing it"
    sudo rm /etc/motd
    log_action "/etc/motd removed"
else
    log_action "/etc/motd does not exist"
fi
