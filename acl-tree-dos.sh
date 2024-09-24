#!/bin/bash
set -e

LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    local message="$1"
    echo "$(date): $message" | tee -a "$LOG_FILE"
}

# Function to check if a package is installed
is_package_installed() {
    local package_name="$1"
    if dpkg -l | grep -q "ii  $package_name "; then
        return 0 # Package is installed
    else
        return 1 # Package is not installed
    fi
}

# Function to install a package
install_package() {
    local package_name="$1"
    local install_command="$2"
    
    if ! is_package_installed "$package_name"; then
        log_action "Installing $package_name..."
        eval "$install_command"
        log_action "$package_name has been installed."
    else
        log_action "$package_name is already installed."
    fi
}

# Main script
main() {
    # Check for the OS type
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS="$ID"
    else
        log_action "Unsupported operating system."
        exit 1
    fi

    # Install commands based on OS type
    case "$OS" in
        ubuntu)
            install_package "dos2unix" "sudo apt install -y dos2unix"
            install_package "tree" "sudo apt install -y tree"
            install_package "acl" "sudo apt install -y acl"
            install_package "nmap" "sudo apt install -y nmap"
            ;;
        almalinux|centos|fedora)
            install_package "dos2unix" "sudo yum install -y dos2unix"
            install_package "tree" "sudo yum install -y tree"
            install_package "acl" "sudo yum install -y acl"
            install_package "nmap" "sudo yum install -y nmap"
            ;;
        *)
            log_action "Unsupported OS distribution: $OS"
            exit 1
            ;;
    esac

    log_action "Installation completed."
}

# Run the main function
main
