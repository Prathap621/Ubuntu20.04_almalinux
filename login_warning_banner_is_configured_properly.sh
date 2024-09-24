#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Define the new content for the /etc/issue file
new_content="Authorized uses only. All activity may be monitored and reported."

# Remove any instances of \m, \r, \s, \v, or references to the OS platform from the new content
new_content=$(echo "$new_content" | sed -e 's/\\[mrsSv]//g' -e 's/\\[osOS]//g')

# Check the OS and architecture
os=$(lsb_release -si 2>/dev/null)
version=$(lsb_release -sr 2>/dev/null)
arch=$(uname -m)

if [[ "$os" == "Ubuntu" && "$version" =~ ^(20\.04|22\.04|24\.04)$ ]]; then
    log "Match: Ubuntu $version ($arch)"
    update_needed=1
elif [[ "$os" == "RedHat" || "$os" == "CentOS" ]]; then
    log "Match: $os $version ($arch)"
    update_needed=1
else
    log "Doesn't match: OS is $os version $version ($arch)"
    update_needed=0
fi

# Check if /etc/issue file exists and needs updating
if [[ $update_needed -eq 1 ]]; then
    if [[ -f /etc/issue ]]; then
        current_content=$(cat /etc/issue)
        if [[ "$current_content" == "$new_content" ]]; then
            log "Exists: /etc/issue content matches the new content."
        else
            log "Updating: /etc/issue content does not match. Updating now."
            echo "$new_content" | sudo tee /etc/issue > /dev/null
            log "The /etc/issue file has been updated."
        fi
    else
        log "Doesn't exist: /etc/issue file doesn't exist. Creating and writing new content."
        echo "$new_content" | sudo tee /etc/issue > /dev/null
        log "The /etc/issue file has been created and updated."
    fi
else
    log "No update performed: Unsupported OS/version."
fi
