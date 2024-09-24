#!/bin/bash

log_file="/root/output.log"
storage_size_mb=100

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Check the operating system and architecture
check_os_and_arch() {
    os_id=$(grep -oP 'ID=\K\w+' /etc/os-release)
    os_version=$(grep -oP 'VERSION_ID=\K\w+' /etc/os-release)
    arch=$(uname -m)

    case "$os_id" in
        ubuntu)
            if [[ "$os_version" == "20.04" || "$os_version" == "22.04" || "$os_version" == "24.04" ]]; then
                if [[ "$arch" == "x86_64" || "$arch" == "aarch64" ]]; then
                    log_message "Match: Supported OS: Ubuntu $os_version on $arch."
                    return 0
                else
                    log_message "Doesn't Match: Unsupported architecture: $arch for Ubuntu $os_version."
                    echo "Unsupported architecture for Ubuntu. Exiting."
                    exit 1
                fi
            else
                log_message "Doesn't Match: Unsupported Ubuntu version: $os_version."
                echo "Unsupported Ubuntu version. Exiting."
                exit 1
            fi
            ;;
        almalinux | centos | rhel)
            log_message "Match: Supported OS: $os_id $os_version."
            return 0
            ;;
        *)
            log_message "Doesn't Match: Unsupported operating system: $os_id."
            echo "Unsupported operating system. Exiting."
            exit 1
            ;;
    esac
}

# Check if auditd package is installed
check_and_install_auditd() {
    if ! dpkg -s auditd >/dev/null 2>&1; then
        log_message "Doesn't Exist: auditd is not installed. Installing..."
        sudo apt update
        if sudo apt install -y auditd; then
            log_message "Installed: Successfully installed auditd."
        else
            log_message "Failed: Error installing auditd."
            echo "Error installing auditd. Check the log for details."
            exit 1
        fi
    else
        log_message "Exists: auditd is already installed."
    fi
}

# Check if audispd-plugins package is installed
check_and_install_audispd_plugins() {
    if ! dpkg -s audispd-plugins >/dev/null 2>&1; then
        log_message "Doesn't Exist: audispd-plugins is not installed. Installing..."
        sudo apt update
        if sudo apt install -y audispd-plugins; then
            log_message "Installed: Successfully installed audispd-plugins."
        else
            log_message "Failed: Error installing audispd-plugins."
            echo "Error installing audispd-plugins. Check the log for details."
            exit 1
        fi
    else
        log_message "Exists: audispd-plugins is already installed."
    fi
}

# Update the auditd.conf file with the storage size configuration
update_auditd_conf() {
    if sudo sed -i "s/^max_log_file = .*/max_log_file = ${storage_size_mb}/" /etc/audit/auditd.conf; then
        log_message "Updated: Successfully updated max_log_file to ${storage_size_mb} MB in /etc/audit/auditd.conf."
    else
        log_message "Failed: Error updating /etc/audit/auditd.conf."
        echo "Error updating auditd configuration. Check the log for details."
        exit 1
    fi
}

# Restart the auditd service to apply the changes
restart_auditd_service() {
    if sudo service auditd restart; then
        log_message "Restarted: Successfully restarted the auditd service."
    else
        log_message "Failed: Error restarting the auditd service."
        echo "Error restarting auditd service. Check the log for details."
        exit 1
    fi
}

# Check if auditd is enabled
check_and_enable_auditd() {
    if systemctl is-enabled auditd | grep -q "enabled"; then
        log_message "Exists: auditd is already enabled."
        echo "auditd is already enabled."
    else
        log_message "Doesn't Exist: Enabling auditd..."
        echo "Enabling auditd..."
        if systemctl --now enable auditd; then
            log_message "Enabled: Successfully enabled auditd."
            echo "auditd has been enabled."
        else
            log_message "Failed: Error enabling auditd."
            echo "Error enabling auditd. Check the log for details."
            exit 1
        fi
    fi

    # Verify the status
    if systemctl is-enabled auditd; then
        log_message "Verified: auditd is enabled."
    else
        log_message "Failed: auditd is not enabled after attempting to enable it."
        echo "Error: auditd is not enabled. Check the log for details."
        exit 1
    fi
}

# Check if the audit=1 parameter is set in the GRUB configuration
check_and_set_grub_audit() {
    if grep -q "^\s*linux" "/boot/grub/grub.cfg" | grep -qv "audit=1"; then
        # Add the audit=1 parameter to GRUB_CMDLINE_LINUX in /etc/default/grub
        sudo sed -i 's/^GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 audit=1"/' /etc/default/grub

        # Update the grub configuration
        if sudo update-grub; then
            log_message "Updated: audit=1 parameter added to GRUB configuration. Auditing for pre-auditd processes is enabled."
            echo "audit=1 parameter added to GRUB configuration. Auditing for pre-auditd processes is enabled."
        else
            log_message "Failed: Error updating GRUB configuration."
            echo "Error updating GRUB configuration. Check the log for details."
            exit 1
        fi
    else
        log_message "Exists: audit=1 parameter is already set in the GRUB configuration."
        echo "audit=1 parameter is already set in the GRUB configuration."
    fi
}

# Execute the checks and updates
check_os_and_arch
check_and_install_auditd
check_and_install_audispd_plugins
update_auditd_conf
restart_auditd_service
check_and_enable_auditd
check_and_set_grub_audit

# Inform the user that the audit log storage size has been configured
echo "Audit log storage size has been configured to ${storage_size_mb} MB."
log_message "Audit log storage size configured to ${storage_size_mb} MB."
