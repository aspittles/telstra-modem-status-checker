# telstra-modem-status-checker
This will check the status of the Telstra Smart Modem 4 and log the Connection status and Connection type to a log file.

You can run this manually from the command line or add it as a service to auto start if your linux box restarts

It requires curl and jq to be installed

**To set up and run:**

1. Save as `modem-monitor.sh`
2. Make executable: `chmod +x modem-monitor.sh`
3. Run in background: `./modem-monitor.sh &`
4. View the log file: `tail -f ~/modem-status.log`

If you want it to run automatically on system startup, create
/etc/systemd/system/modem-monitor.service:

Then enable and start the service:
`sudo systemctl enable modem-monitor.service`
`sudo systemctl start modem-monitor.service`
