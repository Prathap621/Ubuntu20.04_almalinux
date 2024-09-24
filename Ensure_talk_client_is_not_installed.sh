#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

check_talk_client() {
    # Check the OS
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            ubuntu)
                log_action "Detected Ubuntu OS."
                # Check if Talk client is installed
                if dpkg -s talk &> /dev/null; then
                    log_action "Talk Client is installed (exists). Uninstalling..."
                    sudo apt-get purge talk -y
                    if [[ $? -eq 0 ]]; then
                        log_action "Talk Client has been uninstalled."
                    else
                        log_action "Failed to uninstall Talk Client."
                    fi
                else
                    log_action "Talk Client is not installed (doesn't exist)."
                fi
                ;;
            almalinux|rhel|centos)
                log_action "Detected Red Hat flavor OS."
                # Check if Talk client is installed (use appropriate command for RPM-based systems)
                if rpm -q talk &> /dev/null; then
                    log_action "Talk Client is installed (exists). Uninstalling..."
                    sudo dnf remove talk -y
                    if [[ $? -eq 0 ]]; then
                        log_action "Talk Client has been uninstalled."
                    else
                        log_action "Failed to uninstall Talk Client."
                    fi
                else
                    log_action "Talk Client is not installed (doesn't exist)."
                fi
                ;;
            *)
                log_action "Unsupported operating system: $ID."
                exit 1
                ;;
        esac
    else
        log_action "Failed to detect the operating system."
        exit 1
    fi

    log_action "Talk Client check completed."
}

# Execute the function
log_action "Starting Talk Client check."
check_talk_client
log_action "Script execution completed."
