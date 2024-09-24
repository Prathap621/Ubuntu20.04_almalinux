#!/bin/bash

LOG_FILE="/root/output.log"  # Log file location in /root/output.log

# Function to log actions
log_action() {
    local action="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action - $message" | tee -a $LOG_FILE
}

audit_system_file_permissions() {
    os_release_file="/etc/os-release"

    if [ -f "$os_release_file" ]; then
        . "$os_release_file"  # Source the OS release file
        os_name="$ID"
        os_version="$VERSION_ID"
        arch=$(uname -m)

        log_action "INFO" "Detected OS: $os_name, Version: $os_version, Architecture: $arch"

        # Check if the OS is Ubuntu with specific versions or Red Hat flavors
        if [[ "$os_name" == "ubuntu" && ("$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04") ]]; then
            if [[ "$arch" == "x86_64" || "$arch" == "arm64" ]]; then
                log_action "INFO" "Ubuntu $os_version with supported architecture ($arch) detected."
            else
                log_action "ERROR" "Unsupported architecture for Ubuntu: $arch. Exiting..."
                exit 1
            fi
        elif [[ "$os_name" == "almalinux" || "$os_name" == "rhel" || "$os_name" == "centos" ]]; then
            log_action "INFO" "Red Hat flavor ($os_name) detected."
        else
            log_action "ERROR" "Unsupported operating system: $os_name. Exiting..."
            exit 1
        fi

        # Define the system files to audit
        system_files=(
            "/etc/passwd"
            "/etc/shadow"
            "/etc/group"
            "/etc/gshadow"
            "/etc/sudoers"
            "/etc/crontab"
            "/etc/cron.allow"
            "/etc/cron.deny"
            "/etc/at.allow"
            "/etc/at.deny"
            "/etc/securetty"
            "/etc/login.defs"
            "/etc/pam.d/"
            "/etc/ssh/sshd_config"
        )

        # Perform the audit
        log_action "INFO" "Auditing system file permissions..."
        for file in "${system_files[@]}"; do
            if [ -e "$file" ]; then
                permissions=$(stat -c "%a" "$file")
                owner=$(stat -c "%U" "$file")
                group=$(stat -c "%G" "$file")
                log_action "MATCH" "File: $file exists. Permissions: $permissions, Owner: $owner, Group: $group."
            else
                log_action "DOESN'T EXIST" "File: $file does not exist."
            fi
        done
        log_action "INFO" "System file permissions audit complete."

    else
        log_action "ERROR" "Unable to determine the operating system. Exiting..."
        exit 1
    fi
}

# Run the audit
audit_system_file_permissions
