#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    local action="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action" >> "$LOG_FILE"
}

# Function to update or add SSH configuration settings uniquely
update_sshd_config_unique() {
    local key="$1"
    local value="$2"
    local sshd_config="/etc/ssh/sshd_config"
    local tmp_file=$(mktemp)

    # Check if the parameter already exists in the file
    if grep -qE "^[#\s]*${key}\b" "$sshd_config"; then
        # Configuration parameter already exists
        log_action "$key: exists (match)"
        # Remove all occurrences
        sed -e "/^[#\s]*${key}\b/d" "$sshd_config" > "$tmp_file"
    else
        # Configuration parameter doesn't exist yet
        log_action "$key: does not exist (unmatch)"
        cp "$sshd_config" "$tmp_file"
    fi

    # Append new parameter if not duplicated
    if ! grep -qE "^[#\s]*${key}\b" "$tmp_file"; then
        echo "${key} ${value}" >> "$tmp_file"
        log_action "Added: ${key} ${value}"
    else
        log_action "Skipped (duplicate): ${key} ${value}"
    fi

    # Replace the original config file with the modified one
    mv "$tmp_file" "$sshd_config"
    chmod 600 "$sshd_config" # Ensure the file permissions are secure
}

# Example usage for Ubuntu and Red Hat
echo "Configuring SSH parameters..."

# List of parameters to update
declare -A ssh_params=(
    ["ClientAliveInterval"]="120"
    ["ClientAliveCountMax"]="3"
    ["X11Forwarding"]="no"
    ["AllowTcpForwarding"]="yes"
    ["PrintMotd"]="no"
    ["MaxStartups"]="10:30:100"
    ["PubkeyAuthentication"]="yes"
    ["RevokedKeys"]="/home/deploy/.ssh/revoked_keys"
)

# Loop through each parameter and update
for key in "${!ssh_params[@]}"; do
    update_sshd_config_unique "$key" "${ssh_params[$key]}"
done

echo "SSH configuration updated. Restarting SSH service..."

# Restart SSH service to apply changes
if systemctl restart sshd; then
    log_action "SSH service restarted successfully."
    echo "SSH service restarted successfully."
else
    log_action "Failed to restart SSH service."
    echo "Failed to restart SSH service."
fi
