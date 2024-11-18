#!/bin/bash

# Exit script if any command fails
set -e

# Variables
ZABBIX_DEB="zabbix-agent2_6.0.0-1+ubuntu20.04_amd64.deb"
ZABBIX_URL="https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix/zabbix/${ZABBIX_DEB}"

# Step 1: Download the Zabbix agent package
echo "Downloading Zabbix agent package..."
wget "$ZABBIX_URL" -O "$ZABBIX_DEB"

# Step 2: Install the downloaded package
echo "Installing the Zabbix agent package..."
sudo dpkg -i "$ZABBIX_DEB"

# Step 3: Install software-properties-common for repository management
echo "Installing required package: software-properties-common..."
sudo apt install -y software-properties-common

# Step 4: Add the Zabbix repository
echo "Adding Zabbix repository..."
sudo add-apt-repository -y "deb https://repo.zabbix.com/zabbix/6.0/ubuntu $(lsb_release -cs) main"

# Step 5: Update the package list
echo "Updating package list..."
sudo apt update

# Step 6: List upgradable packages
echo "Listing upgradable packages..."
apt list --upgradable

# Step 7: Upgrade all packages
echo "Upgrading packages..."
sudo apt upgrade -y

# Step 8: Install Zabbix agent2 and plugins
echo "Installing Zabbix agent2 and plugins..."
sudo apt install -y zabbix-agent2 zabbix-agent2-plugin-*

# Step 9: Check the status of the Zabbix agent service
echo "Displaying the status of the Zabbix agent service..."
sudo systemctl status zabbix-agent2.service
