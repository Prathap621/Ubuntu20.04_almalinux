#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# Function to install sysstat
install_sysstat() {
    echo "Installing sysstat..."
    if [ -x "$(command -v apt-get)" ]; then
        # For Ubuntu
        if [[ $(lsb_release -sr) =~ ^(20\.04|22\.04|24\.04)$ ]]; then
            sudo apt-get install sysstat -y
            log_action "Installed sysstat on Ubuntu $(lsb_release -sr)"
        else
            log_action "Version mismatch: Ubuntu $(lsb_release -sr) does not match supported versions."
        fi
    elif [ -x "$(command -v yum)" ]; then
        # For Red Hat
        sudo yum install sysstat -y
        log_action "Installed sysstat on Red Hat system"
    else
        log_action "Package manager not found."
        echo "Error: No compatible package manager found."
        exit 1
    fi
}

# Function to modify /etc/default/sysstat
modify_sysstat_config() {
    echo "Modifying /etc/default/sysstat..."
    if [ -f /etc/default/sysstat ]; then
        if grep -q '^ENABLED="false"' /etc/default/sysstat; then
            sudo sed -i 's/^ENABLED="false"/ENABLED="true"/' /etc/default/sysstat
            log_action "Modified ENABLED parameter to true in /etc/default/sysstat (was false)"
        elif grep -q '^ENABLED="true"' /etc/default/sysstat; then
            log_action "ENABLED parameter already set to true in /etc/default/sysstat."
        else
            sudo bash -c 'echo "ENABLED=\"true\"" >> /etc/default/sysstat'
            log_action "Added ENABLED parameter set to true in /etc/default/sysstat."
        fi
    else
        log_action "/etc/default/sysstat does not exist."
        echo "Error: /etc/default/sysstat does not exist."
    fi
}

# Main function
main() {
    install_sysstat
    modify_sysstat_config
    echo "Sysstat installed and configured successfully."
    log_action "Sysstat installation and configuration completed."
}

# Execute the main function
main
