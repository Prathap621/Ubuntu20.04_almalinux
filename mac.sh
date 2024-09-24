#!/bin/bash

# Define the desired MACs and Key Exchange Algorithms
desired_macs="umac-64-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-64@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512,hmac-sha1,hmac-sha1-96,hmac-sha1-etm@openssh.com,hmac-sha1-96-etm@openssh.com"
desired_kex="curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1,diffie-hellman-group-exchange-sha1"

# Define the SSHD config file path
sshd_config_file="/etc/ssh/sshd_config"
log_file="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function to update SSHD configuration
update_config() {
    local key="$1"
    local desired_value="$2"
    local config_file="$3"
    local current_value

    current_value=$(grep "^${key}" "$config_file" | head -n 1 | awk '{$1=""; print $0}' | xargs)

    if [[ -z "$current_value" ]]; then
        # Key does not exist, add it
        echo "Adding ${key} to $config_file."
        echo "${key} ${desired_value}" >> "$config_file"
        log_action "Added ${key} to $config_file."
    else
        # Key exists, check if update is needed
        if [[ ! "$current_value" == *"$desired_value"* ]]; then
            # Update needed, append missing values
            echo "Updating ${key} in $config_file."
            sed -i "/^${key}/ s/$/,${desired_value}/" "$config_file"
            log_action "Updated ${key} in $config_file."
        else
            echo "${key} is already up to date in $config_file."
            log_action "${key} is already up to date in $config_file."
        fi
    fi
}

# Check for supported architectures and operating systems
supported_os=("Ubuntu" "Red Hat")
architecture=$(uname -m)

if [[ "$architecture" != "x86_64" && "$architecture" != "aarch64" ]]; then
    log_action "Unsupported architecture: $architecture. Exiting."
    exit 1
fi

os_name=$(lsb_release -si 2>/dev/null || echo "Red Hat")

if [[ ! " ${supported_os[@]} " =~ " ${os_name} " ]]; then
    log_action "Unsupported OS: $os_name. Exiting."
    exit 1
fi

# Ensure the MACs and Key Exchange Algorithms lines exist or add them
update_config "MACs" "$desired_macs" "$sshd_config_file"
update_config "KexAlgorithms" "$desired_kex" "$sshd_config_file"

# Restart the sshd service to apply changes
echo "Restarting SSHD service to apply changes."
systemctl restart sshd
log_action "Restarted SSHD service to apply changes."

echo "Update complete."
log_action "Update complete."
