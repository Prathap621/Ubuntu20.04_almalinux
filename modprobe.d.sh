#!/bin/bash

LOG_FILE="/root/output.log"  # Log file location in /root/output.log

# Function to log actions
log_action() {
    local action="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action - $message" | tee -a $LOG_FILE
}

# Function to create and configure modprobe.d config files
create_config_file() {
    local config_file=$1
    local module_name=$2

    # Check if the config file already exists
    if [ ! -f "$config_file" ]; then
        # Create the config file
        sudo touch "$config_file"
        log_action "CREATE" "Config file $config_file created."

        # Set the permissions of the file to 644
        sudo chmod 644 "$config_file"
        log_action "PERMISSIONS" "Permissions for $config_file set to 644."

        # Add the configuration line to disable the specified module
        echo "install $module_name /bin/true" | sudo tee "$config_file" > /dev/null
        log_action "UPDATE" "Disabled $module_name in $config_file."
    else
        # Inform the user that the config file already exists
        log_action "EXISTS" "Config file $config_file already exists. No action taken."
    fi
}

# Function to disable DCCP if necessary
disable_dccp() {
    local dccp_config="/etc/modprobe.d/dccp.conf"

    # Check if the dccp.conf file exists
    if [ ! -f "$dccp_config" ]; then
        # Create and configure dccp.conf
        sudo touch "$dccp_config"
        sudo chmod 644 "$dccp_config"
        echo "install dccp /bin/true" | sudo tee "$dccp_config" > /dev/null
        log_action "DISABLE" "DCCP has been disabled in $dccp_config."
    else
        log_action "EXISTS" "DCCP is already disabled in $dccp_config."
    fi
}

# Determine the distribution and architecture
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_NAME=$ID
    VERSION=$VERSION_ID
    ARCH=$(uname -m)
else
    log_action "ERROR" "Cannot determine the operating system. Exiting."
    exit 1
fi

log_action "INFO" "Running on $DISTRO_NAME, Version: $VERSION, Architecture: $ARCH"

# Check if the OS is Ubuntu or Red Hat-based
if [[ "$DISTRO_NAME" == "ubuntu" && ("$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04") ]]; then
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "arm64" ]]; then
        log_action "INFO" "Supported Ubuntu version ($VERSION) with architecture ($ARCH). Proceeding with configuration."
        disable_dccp
    else
        log_action "ERROR" "Unsupported architecture for Ubuntu: $ARCH. Exiting."
        exit 1
    fi
elif [[ "$DISTRO_NAME" == "almalinux" || "$DISTRO_NAME" == "rhel" || "$DISTRO_NAME" == "centos" ]]; then
    log_action "INFO" "Supported Red Hat flavor ($DISTRO_NAME) detected. Proceeding with configuration."
else
    log_action "ERROR" "Unsupported operating system: $DISTRO_NAME. Exiting."
    exit 1
fi

# List of config files and associated modules to check and modify
declare -A config_files=(
    ["/etc/modprobe.d/freevxfs.conf"]="freevxfs"
    ["/etc/modprobe.d/jffs2.conf"]="jffs2"
    ["/etc/modprobe.d/squashfs.conf"]="squashfs"
    ["/etc/modprobe.d/udf.conf"]="udf"
    ["/etc/modprobe.d/cramfs.conf"]="cramfs"
    ["/etc/modprobe.d/hfsplus.conf"]="hfsplus"
)

# Loop through each config file and apply the changes
for config_file in "${!config_files[@]}"; do
    create_config_file "$config_file" "${config_files[$config_file]}"
done

log_action "INFO" "System configuration tasks completed."
