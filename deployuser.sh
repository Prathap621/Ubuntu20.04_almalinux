#!/bin/bash

# Directory and file path
ssh_dir="/home/deploy/.ssh"
revoked_keys_file="${ssh_dir}/revoked_keys"
log_file="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Ensure .ssh directory exists
if [ ! -d "$ssh_dir" ]; then
    mkdir -p "$ssh_dir"
    log_action "Created .ssh directory: $ssh_dir"
else
    log_action ".ssh directory already exists: $ssh_dir"
fi

# Check the OS version and architecture
os_version=$(lsb_release -sr)
architecture=$(uname -m)

# Supported OS versions and architectures
if { [ "$os_version" == "20.04" ] || [ "$os_version" == "22.04" ] || [ "$os_version" == "24.04" ]; } && \
   { [ "$architecture" == "x86_64" ] || [ "$architecture" == "aarch64" ]; }; then

    # Create or update revoked_keys file
    if [ ! -f "$revoked_keys_file" ]; then
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoi480+wu9b3gUNEDCGG4cCC7dSUNrHNyCoRkzIgtDhPf/nQbgRqr8dKAE9OOh9uaCFMZ/jqP61gHziHEO84lSeBGV72sKQ7rX2VkoPQm+mtcuF7+qlytD91Y934DSc/QiG+SOFAOnIfxViqLyERLJefgk5qlUjaBLagpaioW8uDUB+YUcldFPRR2o915Ijr+vdCGsE76sk1Gc04sfrszScEhB/aZ8EUEBqW/OBIRGcOyFRiXyd/y2kUmn4FEmqGzGHxXGG9NDIXzwiKp5UE0IzfeBgnL1KKVmq/KsN/lo2l2gZwNHmhwyk3tH45I3mcmNaVh0X4kaD77arWccgsSIvXlVEHQLHr/NEnp5nwPmxOubi/uJM7lqhWmpN6MubbymrfQdEK4GwBUJpWIf0Y9634Lfbf6y8bzTu48BDN9L1WuufSdeCBUUH4wriL632X+jUt4U+WP9iITFj0IXx4cQiBxf9WXFljFZAeqGO44Fup7GVoFNprAaxvoEKGYxlL+dgXkP99cXcqaDHPSgzT1AHQdlagD9q3J9lPdiiINUooJ2dauk9wO8TfzdgAdODvHMMLGAsCM2jbWDnxPbZK0X61nPPer9xc/2MF0tV6Gr6fOtt/VJfhna01DH0HftAz/FL88NvSG+3Ud1Z9O/nIBliriWt3XcMaqlcw4aAEWrgw==" > "$revoked_keys_file"
        log_action "Created revoked_keys file: $revoked_keys_file"
    else
        log_action "revoked_keys file already exists: $revoked_keys_file"
    fi

    # Ensure correct permissions on revoked_keys file
    chmod 600 "$revoked_keys_file"
    log_action "Set permissions on revoked_keys file to 600."

    echo "revoked_keys file updated successfully."
else
    log_action "Unsupported OS version or architecture. Version: $os_version, Architecture: $architecture"
    echo "This script only supports Ubuntu 20.04, 22.04, 24.04 and Red Hat with x86_64 or arm64 architectures."
    exit 1
fi
