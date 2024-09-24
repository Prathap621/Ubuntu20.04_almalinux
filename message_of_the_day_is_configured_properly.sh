#!/bin/bash

# Log file location
LOGFILE="/root/output.log"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to check the architecture and OS
check_os() {
    OS=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    ARCH=$(uname -m)

    if [[ "$OS" == "Ubuntu" && ( "$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04" ) && ( "$ARCH" == "x86_64" || "$ARCH" == "arm64" ) ]]; then
        log "Ubuntu $VERSION $ARCH - Match"
        return 0
    elif [[ "$OS" == "RedHat" || "$OS" == "CentOS" ]]; then
        log "Red Hat - Match"
        return 0
    else
        log "OS or architecture mismatch - Unmatch"
        return 1
    fi
}

# Check if the motd file exists
if check_os; then
    if [ -f /etc/motd ]; then
        # Remove the motd file
        sudo rm -f /etc/motd
        log "The message of the day (motd) file has been removed."
    else
        log "The message of the day (motd) file is not present."
    fi
else
    log "This script is not supported on this OS or architecture."
fi
