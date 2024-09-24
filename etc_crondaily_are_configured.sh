#!/bin/bash

# Log function to print messages to /root/output.log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /root/output.log
}

# Check if the OS is Ubuntu or Red Hat flavor
if [[ -f /etc/lsb-release && $(grep -c "Ubuntu" /etc/lsb-release) -gt 0 ]]; then
    VERSION=$(lsb_release -sr)
    if [[ "$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04" ]]; then
        CRON_DIR="/etc/cron.daily"
        log "Ubuntu $VERSION detected."
    else
        log "Unsupported Ubuntu version: $VERSION."
        exit 1
    fi
elif [[ -f /etc/os-release && $(grep -c "AlmaLinux" /etc/os-release) -gt 0 ]]; then
    CRON_DIR="/etc/cron.daily"
    log "AlmaLinux detected."
else
    log "Unsupported operating system."
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
    log "Unsupported architecture: $ARCH."
    exit 1
fi

# Check the permissions on /etc/cron.daily
PERMISSIONS=$(stat -c "%a" "$CRON_DIR")
if [[ $PERMISSIONS != "700" ]]; then
    # Set the correct permissions on /etc/cron.daily
    sudo chmod 700 "$CRON_DIR"
    log "Permissions on /etc/cron.daily have been configured to 700."
else
    log "Permissions on /etc/cron.daily are already properly configured."
fi

# End of script
