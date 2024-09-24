#!/bin/bash

# Log file
LOG_FILE="/root/output.log"

# Function to log actions
log_action() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check for supported OS versions
if [[ "$(lsb_release -si)" == "Ubuntu" ]]; then
    VERSION=$(lsb_release -sr)
    if [[ "$VERSION" == "20.04" || "$VERSION" == "22.04" || "$VERSION" == "24.04" ]]; then
        log_action "Ubuntu version $VERSION supported."
    else
        log_action "Ubuntu version $VERSION not supported. Exiting."
        exit 1
    fi
elif [[ "$(lsb_release -si)" == "RedHat" || "$(lsb_release -si)" == "CentOS" ]]; then
    log_action "Red Hat flavor detected."
else
    log_action "Unsupported OS. Exiting."
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]]; then
    log_action "Architecture $ARCH supported."
else
    log_action "Unsupported architecture $ARCH. Exiting."
    exit 1
fi

# Define the contents to be written to sysctl.conf
SYSCTL_CONTENTS=$(cat <<END
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
#net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#

###################################################################
# Magic system request Key
# 0=disable, 1=enable all, >1 bitmask of sysrq functions
# See https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
# for what other values do
#kernel.sysrq=438

net.ipv4.ip_forward = 1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
fs.suid_dumpable = 0
kernel.randomize_va_space = 2
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 60000
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_window_scaling = 1
fs.file-max = 5000000
net.core.netdev_max_backlog = 400000
net.core.optmem_max = 10000000
net.core.rmem_default = 10000000
net.core.rmem_max = 10000000
net.core.somaxconn = 100000
net.core.wmem_default = 10000000
net.core.wmem_max = 10000000
net.ipv4.ip_local_port_range = 10000 61000
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_max_syn_backlog = 12000
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mem = 30000000 30000000 30000000
net.ipv4.tcp_rmem = 30000000 30000000 30000000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_wmem = 30000000 30000000 30000000
kernel.pid_max = 4194303
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
vm.overcommit_memory = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.route.flush = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
END
)

# Backup the existing sysctl.conf if it exists
if [ -f /etc/sysctl.conf ]; then
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    log_action "Backup of /etc/sysctl.conf created as /etc/sysctl.conf.bak."
else
    log_action "/etc/sysctl.conf does not exist; no backup created."
fi

# Write the contents to sysctl.conf if it doesn't exist
if [ ! -f /etc/sysctl.conf ]; then
    echo "$SYSCTL_CONTENTS" | sudo tee /etc/sysctl.conf > /dev/null
    log_action "/etc/sysctl.conf created."
else
    log_action "/etc/sysctl.conf already exists."
fi

# Check if the content matches
if ! cmp -s <(echo "$SYSCTL_CONTENTS") /etc/sysctl.conf; then
    echo "$SYSCTL_CONTENTS" | sudo tee /etc/sysctl.conf > /dev/null
    log_action "/etc/sysctl.conf updated."
else
    log_action "/etc/sysctl.conf is up to date."
fi

# Flush the sysctl settings
sudo sysctl -p
log_action "Sysctl settings flushed."
