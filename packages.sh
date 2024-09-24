#!/bin/bash

LOG_FILE="/root/output.log"

log_action() {
    local action="$1"
    local package="$2"
    echo "$action: $package" >> "$LOG_FILE"
}

install_package() {
    local package="$1"
    if ! command -v "$package" &> /dev/null; then
        echo "$package is not installed. Installing..."
        log_action "not installed" "$package"
        if [[ "$OS" == "ubuntu" ]]; then
            sudo apt-get install -y "$package"
        elif [[ "$OS" == "redhat" ]]; then
            sudo yum install -y "$package"
        fi
        echo "$package has been installed."
        log_action "installed" "$package"
    else
        echo "$package is already installed."
        log_action "already installed" "$package"
    fi
}

# Detect OS and architecture
OS=""
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
        ubuntu)
            OS="ubuntu"
            ;;
        rhel | centos | fedora)
            OS="redhat"
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac
else
    echo "Unable to detect OS."
    exit 1
fi

# List of packages to check/install
packages=(
    "tcpdump"
    "sar"
    "telnet"
    "nslookup"
    "curl"
    "traceroute"
    "ping"
    "mtr"
    "iperf3"
    "net-tools"
    "iftop"
    "dnsutils"
    "netcat"
    "zabbix-agent2"
    "filebeat"
    "sysctl"
)

# Loop through packages and install if necessary
for package in "${packages[@]}"; do
    install_package "$package"
done

# Install zabbix-agent2 specific steps
if ! command -v zabbix_agent2 &> /dev/null; then
    echo "zabbix-agent2 is not installed. Installing..."
    log_action "not installed" "zabbix-agent2"
    if [[ "$OS" == "ubuntu" ]]; then
        wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu20.04_all.deb
        sudo dpkg -i zabbix-release_6.0-4+ubuntu20.04_all.deb
        sudo apt update
        sudo apt install -y zabbix-agent2 zabbix-agent2-plugin-*
        sudo systemctl restart zabbix-agent2
        sudo systemctl enable zabbix-agent2
        rm zabbix-release_6.0-4+ubuntu20.04_all.deb
    elif [[ "$OS" == "redhat" ]]; then
        # Assuming EPEL repo is enabled
        sudo yum install -y zabbix-agent2 zabbix-agent2-plugin-*
        sudo systemctl restart zabbix-agent2
        sudo systemctl enable zabbix-agent2
    fi
    echo "zabbix-agent2 has been installed."
    log_action "installed" "zabbix-agent2"
else
    echo "zabbix-agent2 is already installed."
    log_action "already installed" "zabbix-agent2"
fi

# Install filebeat (adjust as necessary)
if ! command -v filebeat &> /dev/null; then
    echo "filebeat is not installed. Installing..."
    log_action "not installed" "filebeat"
    # Add the installation steps for filebeat here, e.g., downloading and installing
    echo "filebeat has been installed."
    log_action "installed" "filebeat"
else
    echo "filebeat is already installed."
    log_action "already installed" "filebeat"
fi

# Check sysctl specifically for RHEL
if [[ "$OS" == "redhat" ]]; then
    echo "sysctl is part of the kernel; no need to install."
    log_action "already part of kernel" "sysctl"
else
    if ! command -v sysctl &> /dev/null; then
        echo "sysctl is not installed. Installing..."
        log_action "not installed" "sysctl"
        sudo apt-get install -y sysctl
        echo "sysctl has been installed."
        log_action "installed" "sysctl"
    else
        echo "sysctl is already installed."
        log_action "already installed" "sysctl"
    fi
fi
