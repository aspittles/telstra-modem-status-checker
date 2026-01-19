#!/bin/bash

# Telstra Smart Modem Internet Connection Status Checker
# Logs internet connection status every 5 minutes

MODEM_IP="192.168.0.1"
API_ENDPOINT="http://${MODEM_IP}/api/v1/device/open"
LOG_FILE="$HOME/modem-status.log"

# Function to fetch and log modem status
log_modem_status() {
    # Fetch the data from the API
    response=$(curl -s "$API_ENDPOINT")

    # Extract the internet connection status using jq
    internet_status=$(echo "$response" | jq -r '.[0].device.wan_status.status')
    connection_type=$(echo "$response" | jq -r '.[0].device.wan_status.connection_type')
    ipv4=$(echo "$response" | jq -r '.[0].device.wan_status.ipv4_address')

    # Get timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Combine into single line and append to log file
    echo "$timestamp | Internet Connection: $internet_status | Type: $connection_type | IPv4: $ipv4" >> "$LOG_FILE"
}

# Infinite loop that runs every 5 minutes
while true; do
    log_modem_status
    sleep 300  # 300 seconds = 5 minutes
done
