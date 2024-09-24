#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

check_and_remove_rsh() {
    if command -v dpkg &> /dev/null; then
        # Ubuntu system
        if dpkg -s rsh-client &> /dev/null; then
            log_action "RSH Client found on Ubuntu. Uninstalling..."
            sudo apt-get purge rsh-client -y && log_action "RSH Client has been uninstalled." || log_action "Failed to uninstall RSH Client."
        else
            log_action "RSH Client is not installed on Ubuntu."
        fi
    elif command -v rpm &> /dev/null; then
        # Red Hat system
        if rpm -q rsh &> /dev/null; then
            log_action "RSH Client found on Red Hat. Uninstalling..."
            sudo yum remove rsh -y && log_action "RSH Client has been uninstalled." || log_action "Failed to uninstall RSH Client."
        else
            log_action "RSH Client is not installed on Red Hat."
        fi
    else
        log_action "Unsupported operating system."
    fi
}

check_architecture() {
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        log_action "Architecture is x86_64."
    elif [[ "$ARCH" == "aarch64" && "$(lsb_release -is)" == "Ubuntu" ]]; then
        log_action "Architecture is arm64 (aarch64) on Ubuntu."
    else
        log_action "Unsupported architecture."
    fi
}

# Ensure this script runs only on Ubuntu 20.04, 22.04, 24.04 or Red Hat
check_os_and_version() {
    if [[ "$(lsb_release -is)" == "Ubuntu" ]]; then
        UBUNTU_VERSION=$(lsb_release -rs)
        case $UBUNTU_VERSION in
            "20.04"|"22.04"|"24.04")
                log_action "Running on supported Ubuntu version: $UBUNTU_VERSION"
                check_architecture
                check_and_remove_rsh
                ;;
            *)
                log_action "Unsupported Ubuntu version: $UBUNTU_VERSION"
                ;;
        esac
    elif [[ -f /etc/redhat-release ]]; then
        log_action "Running on Red Hat flavor."
        check_and_remove_rsh
    else
        log_action "Unsupported OS."
    fi
}

# Start script
log_action "Script execution started."

# Check OS and version
check_os_and_version

log_action "Script execution completed."
