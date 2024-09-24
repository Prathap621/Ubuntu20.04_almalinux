#!/bin/bash
set -e

LOG_FILE="/root/output.log"  # Log file location in /root/output.log

# Function to log messages
log_action() {
    local action="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action - $message" | tee -a $LOG_FILE
}

# Function to check if a package is installed (for Ubuntu or Debian-based)
is_package_installed_apt() {
    local package_name="$1"
    if dpkg -l | grep -q "ii  $package_name "; then
        return 0 # Package is installed
    else
        return 1 # Package is not installed
    fi
}

# Function to purge apparmor (for Ubuntu/Debian-based)
purge_apparmor_apt() {
    log_action "INFO" "Purging apparmor..."
    sudo apt purge apparmor -y
}

# Function to purge ufw (for Ubuntu/Debian-based)
purge_ufw_apt() {
    log_action "INFO" "Purging ufw..."
    sudo apt purge ufw -y
}

# Function to update package list (for Ubuntu/Debian-based)
update_package_list_apt() {
    log_action "INFO" "Updating package list..."
    sudo apt update
}

# Function to perform apt autoremove (for Ubuntu/Debian-based)
perform_autoremove_apt() {
    log_action "INFO" "Performing apt autoremove..."
    sudo apt autoremove -y
}

# Main script logic
main() {
    # Detect the OS, version, and architecture
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        ARCH=$(uname -m)
    else
        log_action "ERROR" "Cannot detect operating system. Exiting."
        exit 1
    fi

    log_action "INFO" "Detected OS: $OS, Version: $VERSION, Architecture: $ARCH"

    # Check if the OS is Ubuntu with supported versions and architectures
    if [[ "$OS" == "ubuntu" && ("$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04") ]]; then
        if [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; then
            log_action "INFO" "Ubuntu version $VERSION and architecture $ARCH are supported."

            # Run the package management commands for supported Ubuntu systems
            update_package_list_apt

            if is_package_installed_apt "apparmor"; then
                purge_apparmor_apt
            else
                log_action "INFO" "apparmor is not installed."
            fi

            if is_package_installed_apt "ufw"; then
                purge_ufw_apt
            else
                log_action "INFO" "ufw is not installed."
            fi

            perform_autoremove_apt
            log_action "INFO" "Tasks completed for Ubuntu $VERSION ($ARCH)."
        else
            log_action "ERROR" "Unsupported architecture: $ARCH"
            exit 1
        fi
    else
        log_action "ERROR" "Unsupported OS or version: $OS $VERSION"
        exit 1
    fi
}

# Run the main function
main
