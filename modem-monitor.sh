#!/bin/bash

# Telstra Smart Modem Internet Connection Status Checker
# Checks every 2.5 minutes, logs every 15 minutes or on status change

MODEM_IP="192.168.0.1"
API_ENDPOINT="http://${MODEM_IP}/api/v1/device/open"
LOG_FILE="$HOME/modem-status.log"

# Variables to track previous status
prev_internet_status=""
prev_connection_type=""
prev_ipv4=""

# Counter for 15-minute interval (15 min / 2.5 min = 6 checks)
check_count=0
LOG_INTERVAL=6  # Log every 6 checks = 15 minutes

# Function to fetch and log modem status
check_modem_status() {
    # Fetch the data from the API
    response=$(curl -s "$API_ENDPOINT")

    # Extract the internet connection status using jq
    internet_status=$(echo "$response" | jq -r '.[0].device.wan_status.status')
    connection_type=$(echo "$response" | jq -r '.[0].device.wan_status.connection_type')
    ipv4=$(echo "$response" | jq -r '.[0].device.wan_status.ipv4_address')

    # Check if any status has changed
    status_changed=false
    if [[ "$internet_status" != "$prev_internet_status" ]] || \\
       [[ "$connection_type" != "$prev_connection_type" ]] || \\
       [[ "$ipv4" != "$prev_ipv4" ]]; then
        status_changed=true
    fi

    # Increment check counter
    ((check_count++))

    # Log if: status changed OR 15-minute interval reached
    if [[ "$status_changed" == true ]] || [[ $check_count -ge $LOG_INTERVAL ]]; then
        # Get timestamp
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')

        # Add change indicator if status changed
        if [[ "$status_changed" == true ]] && [[ -n "$prev_internet_status" ]]; then
            echo "$timestamp | Internet Connection: $internet_status | Type: $connection_type | IPv4: $ipv4 | [STATUS CHANGED]" >> "$LOG_FILE"
        else
            echo "$timestamp | Internet Connection: $internet_status | Type: $connection_type | IPv4: $ipv4" >> "$LOG_FILE"
        fi

        # Reset counter after logging
        check_count=0
    fi

    # Update previous values
    prev_internet_status="$internet_status"
    prev_connection_type="$connection_type"
    prev_ipv4="$ipv4"
}

# Infinite loop that runs every 2.5 minutes
while true; do
    check_modem_status
    sleep 150  # 150 seconds = 2.5 minutes
done
