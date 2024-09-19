#!/bin/bash

# Function to create a config file and updating modprobe.d
create_config_file() {
    local config_file=$1

    if [ ! -f "$config_file" ]; then
        # Create the config file
        sudo touch "$config_file"

        # Set the permissions of the file to 755
        sudo chmod 755 "$config_file"

        # Add the configuration line to disable cramfs in the config file
        echo "install cramfs /bin/true" | sudo tee "$config_file" > /dev/null

        # Inform the user that the mounting of cramfs filesystems has been disabled
        echo "Mounting of cramfs filesystems has been disabled in $config_file."
    else
        # Inform the user that the config file already exists
        echo "$config_file already exists. No action taken."
    fi
}

# Determine the distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_NAME=$NAME
else
    echo "Cannot determine distribution."
    exit 1
fi

# Output the distribution name for clarity
echo "Running on $DISTRO_NAME"

# List of config files to check and modify
config_files=(
    "/etc/modprobe.d/freevxfs.conf"
    "/etc/modprobe.d/jffs2.conf"
    "/etc/modprobe.d/squashfs.conf"
    "/etc/modprobe.d/udf.conf"
    "/etc/modprobe.d/cramfs.conf"
    "/etc/modprobe.d/hfsplus.conf"
)

# Loop through each config file and apply the changes
for config_file in "${config_files[@]}"; do
    create_config_file "$config_file"
done
