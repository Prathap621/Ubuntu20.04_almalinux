#!/bin/bash

# Log file path
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    local action=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action: $message" >> "$LOG_FILE"
}

# Function to install sysstat
install_sysstat() {
    if command -v apt-get &> /dev/null; then
        echo "Installing sysstat using apt..."
        sudo apt-get install sysstat -y
    elif command -v yum &> /dev/null; then
        echo "Installing sysstat using yum..."
        sudo yum install sysstat -y
    else
        log_action "doesn't exist" "Package manager not found. sysstat installation failed."
        exit 1
    fi
}

# Function to modify /etc/default/sysstat (for Ubuntu)
modify_sysstat_config() {
    if [ -f /etc/default/sysstat ]; then
        log_action "exists" "Modifying /etc/default/sysstat..."
        # Check if ENABLED parameter exists and set it to true if found
        if grep -q '^ENABLED="false"' /etc/default/sysstat; then
            sudo sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
            log_action "unmatch" "Set ENABLED parameter to true in /etc/default/sysstat."
        elif ! grep -q '^ENABLED=' /etc/default/sysstat; then
            # Add ENABLED parameter if it doesn't exist
            sudo bash -c 'echo "ENABLED=\"true\"" >> /etc/default/sysstat'
            log_action "unmatch" "Added ENABLED parameter to /etc/default/sysstat."
        else
            log_action "match" "No changes needed for /etc/default/sysstat."
        fi
    else
        log_action "doesn't exist" "/etc/default/sysstat does not exist. Unable to modify."
    fi
}

# Main function
main() {
    # Check OS version and architecture
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS_NAME=$ID
        OS_VERSION=$VERSION_ID
    else
        log_action "doesn't exist" "Unsupported OS detected."
        exit 1
    fi

    ARCH=$(uname -m)

    # Supported OS and architecture checks
    if { [[ "$OS_NAME" == "ubuntu" && "$OS_VERSION" =~ ^(20\.04|22\.04|24\.04)$ ]] && [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; } || \
       { [[ "$OS_NAME" == "rhel" || "$OS_NAME" == "centos" || "$OS_NAME" == "fedora" ]]; }; then
        log_action "exists" "Supported $OS_NAME version $OS_VERSION and architecture $ARCH detected."
    else
        log_action "doesn't exist" "Unsupported OS version or architecture. Detected version: $OS_VERSION, architecture: $ARCH."
        exit 1
    fi

    # Install sysstat
    install_sysstat

    # Modify sysstat configuration
    modify_sysstat_config

    # Define the new content for the /etc/cron.d/sysstat file
    NEW_CONTENT="
# The first element of the path is a directory where the debian-sa1
# script is located
PATH=/usr/lib/sysstat:/usr/sbin:/usr/bin:/sbin:/bin

# Activity reports every 5 minutes every day
*/5 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1

# Additional run at 23:59 to rotate the statistics file
59 23 * * * root command -v debian-sa1 > /dev/null && debian-sa1 60 2
"

    # Update the /etc/cron.d/sysstat file with the new content
    if [ -f /etc/cron.d/sysstat ]; then
        if cmp -s <(echo "$NEW_CONTENT") /etc/cron.d/sysstat; then
            log_action "match" "No changes needed for /etc/cron.d/sysstat."
        else
            echo "$NEW_CONTENT" | sudo tee /etc/cron.d/sysstat >/dev/null
            log_action "unmatch" "Updated /etc/cron.d/sysstat with new content."
        fi
    else
        echo "$NEW_CONTENT" | sudo tee /etc/cron.d/sysstat >/dev/null
        log_action "unmatch" "/etc/cron.d/sysstat created and updated with new content."
    fi

    # Restart the sysstat service if it exists
    if command -v systemctl &> /dev/null; then
        if sudo systemctl restart sysstat; then
            log_action "match" "Successfully restarted sysstat service."
        else
            log_action "unmatch" "Failed to restart sysstat service."
        fi
    else
        log_action "doesn't exist" "Systemd is not available. Unable to restart sysstat service."
    fi

    echo "Sysstat installed and configured successfully."
}

# Execute the main function
main
