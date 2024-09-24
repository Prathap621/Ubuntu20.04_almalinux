#!/bin/bash

LOG_FILE="/root/output.log"
UBUNTU_ARCH=$(uname -m)
OS=$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
VERSION=$(grep 'VERSION_ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')

log_action() {
    local action=$1
    local details=$2
    echo "$(date) - $action: $details" | tee -a "$LOG_FILE"
}

# Check if we are running on Ubuntu or Red Hat
if [[ "$OS" == "ubuntu" ]]; then
    log_action "OS Check" "Ubuntu detected"
    
    # Check if the architecture is supported
    if [[ "$UBUNTU_ARCH" != "x86_64" && "$UBUNTU_ARCH" != "arm64" ]]; then
        log_action "Architecture Check" "Unsupported architecture: $UBUNTU_ARCH"
        exit 1
    else
        log_action "Architecture Check" "Supported architecture: $UBUNTU_ARCH"
    fi
    
    # Backup sources.list
    if [[ -f /etc/apt/sources.list ]]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
        log_action "Backup" "/etc/apt/sources.list backed up"
    else
        log_action "Backup" "No sources.list found to backup"
    fi

    # Determine the appropriate repository based on the Ubuntu version
    case "$VERSION" in
        "20.04")
            ubuntu_codename="focal"
            ;;
        "22.04")
            ubuntu_codename="jammy"
            ;;
        "24.04")
            ubuntu_codename="next-ubuntu-codename" # Update with actual codename when available
            ;;
        *)
            log_action "Version Check" "Unsupported Ubuntu version: $VERSION"
            exit 1
            ;;
    esac

    main_repo="http://archive.ubuntu.com/ubuntu/"
    security_repo="http://security.ubuntu.com/ubuntu/"

    # Update the sources.list file
    sudo tee /etc/apt/sources.list > /dev/null <<EOL
deb ${main_repo} ${ubuntu_codename} main restricted universe multiverse
deb ${main_repo} ${ubuntu_codename}-updates main restricted universe multiverse
deb ${main_repo} ${ubuntu_codename}-backports main restricted universe multiverse
deb ${security_repo} ${ubuntu_codename}-security main restricted universe multiverse
EOL

    log_action "Repository Update" "Updated sources.list for Ubuntu $VERSION"

    # Update the package lists
    sudo apt update && log_action "Package Update" "Package list updated" || log_action "Package Update" "Failed to update package list"

elif [[ "$OS" == "rhel" || "$OS" == "centos" || "$OS" == "fedora" ]]; then
    log_action "OS Check" "Red Hat-based OS detected"
    
    # Red Hat/CentOS/Fedora repository setup (customize as needed)
    sudo yum update && log_action "Package Update" "Packages updated via yum" || log_action "Package Update" "Failed to update packages via yum"

else
    log_action "OS Check" "Unsupported OS: $OS"
    exit 1
fi

# Inform the user that the repositories have been configured
log_action "Completion" "Package manager repositories have been configured."
