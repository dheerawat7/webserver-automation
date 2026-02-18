#!/bin/bash

echo "=== Web Server Health Check ==="
echo ""

# Check Nginx status
echo "1. Nginx Service Status:"
systemctl is-active nginx && echo "✅ Running" || echo "❌ Stopped"
echo ""

# Check if ports are listening
echo "2. Port Status:"
ss -tuln | grep -E ':80|:443' && echo "✅ Ports are open" || echo "❌ Ports not listening"
echo ""

# Check disk space
echo "3. Disk Space:"
df -h /var/www | tail -1
echo ""

# Check recent errors
echo "4. Recent Nginx Errors (last 10):"
tail -10 /var/log/nginx/error.log 2>/dev/null || echo "No errors found"
