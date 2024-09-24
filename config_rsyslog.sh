#!/bin/bash

# Define paths
BASHRC="/etc/bash.bashrc"
RSYSLOG_CONF="/etc/rsyslog.d/bash.conf"
LOGROTATE_CONF="/etc/logrotate.d/rsyslog"
LOG_FILE="/root/output.log"

# Function to log messages
log_action() {
    local action="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action" >> "$LOG_FILE"
}

# Function to check and update a file
check_and_update_file() {
    local file="$1"
    local search_string="$2"
    local add_string="$3"
    
    if ! grep -q "$search_string" "$file"; then
        echo "Adding line to $file"
        echo "$add_string" | sudo tee -a "$file" > /dev/null
        log_action "Added line to $file: $add_string"
    else
        log_action "Line exists in $file: $search_string"
    fi
}

# Check for supported OS
if ! [[ "$(lsb_release -si)" =~ ^(Ubuntu|RedHat)$ ]] || ! [[ "$(lsb_release -sr)" =~ ^(20.04|22.04|24.04|7|8)$ ]]; then
    log_action "Unsupported OS version: $(lsb_release -si) $(lsb_release -sr)"
    echo "Unsupported OS version. Exiting."
    exit 1
fi

# Check and update /etc/bash.bashrc
check_and_update_file "$BASHRC" "export PROMPT_COMMAND='RETRN_VAL=\$?;logger -p local6.debug \"\$(whoami) [\$\$]: \$(history 1 | sed \"s/[ ][0-9]+[ ]//\" ) [\$RETRN_VAL]\"'" \
"export PROMPT_COMMAND='RETRN_VAL=\$?;logger -p local6.debug \"\$(whoami) [\$\$]: \$(history 1 | sed \"s/[ ][0-9]+[ ]//\" ) [\$RETRN_VAL]\"'"

# Check and update /etc/rsyslog.d/bash.conf
check_and_update_file "$RSYSLOG_CONF" "local6.*    /var/log/commands.log" \
"local6.*    /var/log/commands.log"

# Check and update /etc/logrotate.d/rsyslog
check_and_update_file "$LOGROTATE_CONF" "/var/log/commands.log" \
"/var/log/commands.log"

# Restart rsyslog
sudo /etc/init.d/rsyslog restart
log_action "Restarted rsyslog service."

echo "Script execution completed."
log_action "Script execution completed."
