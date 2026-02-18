#!/bin/bash

###############################################################################
# Setup Automated Tasks (Cron Jobs)
###############################################################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Setting up automated tasks..."

# Create cron jobs
(crontab -l 2>/dev/null; echo "# Web Server Automated Tasks") | crontab -

# Daily backup at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * $PROJECT_DIR/scripts/backup-webserver.sh >> /var/log/webserver-backup.log 2>&1") | crontab -

# Health check every hour
(crontab -l 2>/dev/null; echo "0 * * * * $PROJECT_DIR/scripts/health-check.sh >> /var/log/webserver-health.log 2>&1") | crontab -

# Monitor every 30 minutes
(crontab -l 2>/dev/null; echo "*/30 * * * * $PROJECT_DIR/scripts/monitor-webserver.sh >> /var/log/webserver-monitor.log 2>&1") | crontab -

echo "✅ Cron jobs configured:"
crontab -l | grep -v "^#"

echo ""
echo "Logs will be written to:"
echo "  - /var/log/webserver-backup.log"
echo "  - /var/log/webserver-health.log"
echo "  - /var/log/webserver-monitor.log"
