#!/bin/bash

# Log file location
LOG_FILE="/root/output.log"

# Function to log messages
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check if a package is installed
is_installed() {
    if dpkg -l | grep -q "$1"; then
        log_action "$1 exists (match)."
        return 0
    else
        log_action "$1 doesn't exist (unmatch)."
        return 1
    fi
}

# Function to install a package for Ubuntu
install_ubuntu_package() {
    log_action "Installing $1..."
    apt update
    apt install -y "$1"
    log_action "$1 installed successfully."
}

# Function to install a package for Red Hat
install_rhel_package() {
    log_action "Installing $1..."
    yum install -y "$1"
    log_action "$1 installed successfully."
}

# Check if the OS is Ubuntu or Red Hat
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME="$ID"
    OS_VERSION="$VERSION_ID"
else
    log_action "Unsupported OS."
    exit 1
fi

# Validate OS version
if [[ "$OS_NAME" == "ubuntu" && ( "$OS_VERSION" == "20.04" || "$OS_VERSION" == "22.04" || "$OS_VERSION" == "24.04" ) ]]; then
    # Check if nfs-common is installed
    if is_installed "nfs-common"; then
        log_action "nfs-common is already installed."
    else
        install_ubuntu_package "nfs-common"
    fi
elif [[ "$OS_NAME" == "rhel" || "$OS_NAME" == "centos" ]]; then
    # Check if nfs-utils is installed
    if is_installed "nfs-utils"; then
        log_action "nfs-utils is already installed."
    else
        install_rhel_package "nfs-utils"
    fi
else
    log_action "OS version not supported: $OS_NAME $OS_VERSION"
    exit 1
fi

# Function to disable rpcbind if it's running
disable_rpcbind() {
    if systemctl is-active --quiet rpcbind; then
        log_action "Disabling rpcbind..."
        systemctl stop rpcbind
        systemctl disable rpcbind
        systemctl stop rpcbind.socket
        systemctl disable rpcbind.socket
        log_action "rpcbind disabled."
    else
        log_action "rpcbind is not running."
    fi
}

# Create the script and systemd service to ensure it runs on startup
create_disable_rpcbind_service() {
    cat << 'EOF' > /usr/local/bin/disable-rpcbind.sh
#!/bin/bash
systemctl stop rpcbind
systemctl disable rpcbind
systemctl stop rpcbind.socket
systemctl disable rpcbind.socket
EOF

    chmod +x /usr/local/bin/disable-rpcbind.sh

    cat << 'EOF' > /etc/systemd/system/disable-rpcbind.service
[Unit]
Description=Disable RPCBind Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/disable-rpcbind.sh

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable disable-rpcbind.service
    log_action "Created and enabled disable-rpcbind service."
}

# Disable rpcbind if necessary
disable_rpcbind
create_disable_rpcbind_service

log_action "Setup complete."
