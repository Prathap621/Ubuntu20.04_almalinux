# Function to check if sysstat is already installed
check_sysstat_installed() {
    if [ "$OS" = "ubuntu" ]; then
        dpkg -l | grep -qw sysstat  # Check if sysstat is installed on Ubuntu
    elif [ "$OS" = "almalinux" ]; then
        rpm -q sysstat &>/dev/null  # Check if sysstat is installed on AlmaLinux
    else
        echo "Unsupported OS for sysstat check."
        exit 1
    fi
}

# Function to install sysstat
install_sysstat() {
    echo "Installing sysstat..."
    if [ "$OS" = "ubuntu" ]; then
        sudo apt-get install sysstat -y  # Install sysstat on Ubuntu
    elif [ "$OS" = "almalinux" ]; then
        sudo dnf install sysstat -y  # Install sysstat on AlmaLinux
    else
        echo "Unsupported OS for sysstat installation."
        exit 1
    fi
}

# Main function
main() {
    detect_os
    if check_sysstat_installed; then
        echo "Sysstat is already installed."
    else
        install_sysstat
    fi
    
    # Further config and steps...
}

# Execute the main function
main
