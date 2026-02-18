#!/bin/bash

###############################################################################
# Web Server Monitoring Script
# Monitors Nginx performance and generates reports
###############################################################################

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Web Server Monitoring Report${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# 1. Service Status
echo -e "${GREEN}1. Service Status:${NC}"
if systemctl is-active --quiet nginx; then
    echo -e "   Status: ${GREEN}✅ Running${NC}"
    UPTIME=$(systemctl show nginx --property=ActiveEnterTimestamp --value)
    echo -e "   Uptime: Since $UPTIME"
else
    echo -e "   Status: ${RED}❌ Stopped${NC}"
fi
echo ""

# 2. Port Status
echo -e "${GREEN}2. Listening Ports:${NC}"
if sudo ss -tuln | grep -q ':80'; then
    echo -e "   HTTP (80):  ${GREEN}✅ Listening${NC}"
else
    echo -e "   HTTP (80):  ${RED}❌ Not listening${NC}"
fi

if sudo ss -tuln | grep -q ':443'; then
    echo -e "   HTTPS (443): ${GREEN}✅ Listening${NC}"
else
    echo -e "   HTTPS (443): ${YELLOW}⚠ Not listening${NC}"
fi
echo ""

# 3. Active Connections
echo -e "${GREEN}3. Connection Statistics:${NC}"
TOTAL_CONN=$(ss -tuna | grep ':80\|:443' | grep ESTAB | wc -l)
HTTP_CONN=$(ss -tuna | grep ':80' | grep ESTAB | wc -l)
HTTPS_CONN=$(ss -tuna | grep ':443' | grep ESTAB | wc -l)
TIME_WAIT=$(ss -tuna | grep ':80\|:443' | grep TIME-WAIT | wc -l)

echo -e "   Total Active Connections: $TOTAL_CONN"
echo -e "   HTTP Connections:  $HTTP_CONN"
echo -e "   HTTPS Connections: $HTTPS_CONN"
echo -e "   TIME-WAIT State:   $TIME_WAIT"
echo ""

# 4. Resource Usage
echo -e "${GREEN}4. Resource Usage:${NC}"
# CPU and Memory for nginx processes
NGINX_PID=$(pgrep -o nginx)
if [ ! -z "$NGINX_PID" ]; then
    CPU=$(ps -p $NGINX_PID -o %cpu --no-headers | xargs)
    MEM=$(ps -p $NGINX_PID -o %mem --no-headers | xargs)
    echo -e "   CPU Usage: ${CPU}%"
    echo -e "   Memory Usage: ${MEM}%"
else
    echo -e "   ${RED}Nginx process not found${NC}"
fi
echo ""

# 5. Disk Usage
echo -e "${GREEN}5. Disk Usage:${NC}"
WEB_DISK=$(df -h /var/www 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
LOG_DISK=$(df -h /var/log/nginx 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
echo -e "   Web Directory: ${WEB_DISK}% used"
echo -e "   Log Directory: ${LOG_DISK}% used"

if [ "$WEB_DISK" -gt 80 ]; then
    echo -e "   ${YELLOW}⚠ Warning: Disk usage above 80%${NC}"
fi
echo ""

# 6. Recent Errors
echo -e "${GREEN}6. Recent Errors (Last 5):${NC}"
if [ -f /var/log/nginx/error.log ]; then
    ERROR_COUNT=$(tail -100 /var/log/nginx/error.log 2>/dev/null | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "   ${YELLOW}Found $ERROR_COUNT errors in last 100 lines${NC}"
        tail -5 /var/log/nginx/error.log 2>/dev/null | sed 's/^/   /'
    else
        echo -e "   ${GREEN}✅ No recent errors${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠ Error log not found${NC}"
fi
echo ""

# 7. Top Accessing IPs
echo -e "${GREEN}7. Top 5 Accessing IPs:${NC}"
if [ -f /var/log/nginx/access.log ]; then
    awk '{print $1}' /var/log/nginx/access.log 2>/dev/null | sort | uniq -c | sort -rn | head -5 | while read count ip; do
        echo -e "   $ip: $count requests"
    done
else
    echo -e "   ${YELLOW}⚠ Access log not found${NC}"
fi
echo ""

# 8. HTTP Response Codes
echo -e "${GREEN}8. Response Code Distribution:${NC}"
if [ -f /var/log/nginx/access.log ]; then
    echo -e "   2xx (Success): $(grep -c ' 2[0-9][0-9] ' /var/log/nginx/access.log 2>/dev/null || echo 0)"
    echo -e "   3xx (Redirect): $(grep -c ' 3[0-9][0-9] ' /var/log/nginx/access.log 2>/dev/null || echo 0)"
    echo -e "   4xx (Client Error): $(grep -c ' 4[0-9][0-9] ' /var/log/nginx/access.log 2>/dev/null || echo 0)"
    echo -e "   5xx (Server Error): $(grep -c ' 5[0-9][0-9] ' /var/log/nginx/access.log 2>/dev/null || echo 0)"
fi
echo ""

# 9. Firewall Status
echo -e "${GREEN}9. Firewall Status:${NC}"
if systemctl is-active --quiet firewalld; then
    HTTP_ALLOWED=$(sudo firewall-cmd --list-services 2>/dev/null | grep -q http && echo "Yes" || echo "No")
    HTTPS_ALLOWED=$(sudo firewall-cmd --list-services 2>/dev/null | grep -q https && echo "Yes" || echo "No")
    echo -e "   Firewall: ${GREEN}Active${NC}"
    echo -e "   HTTP allowed: $HTTP_ALLOWED"
    echo -e "   HTTPS allowed: $HTTPS_ALLOWED"
else
    echo -e "   ${YELLOW}⚠ Firewall not running${NC}"
fi
echo ""

# 10. SELinux Status
echo -e "${GREEN}10. SELinux Status:${NC}"
SELINUX_STATUS=$(getenforce 2>/dev/null)
if [ "$SELINUX_STATUS" = "Enforcing" ]; then
    echo -e "   Status: ${GREEN}Enforcing (Secure)${NC}"
elif [ "$SELINUX_STATUS" = "Permissive" ]; then
    echo -e "   Status: ${YELLOW}Permissive (Warning)${NC}"
else
    echo -e "   Status: Disabled"
fi
echo ""

# Summary
echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Overall Health: "
if systemctl is-active --quiet nginx && [ "$TOTAL_CONN" -ge 0 ]; then
    echo -e "   ${GREEN}✅ HEALTHY${NC}"
else
    echo -e "   ${RED}❌ NEEDS ATTENTION${NC}"
fi
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "Report generated at: $(date)"
