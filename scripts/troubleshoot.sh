#!/bin/bash

###############################################################################
# Web Server Troubleshooting Script
# Diagnoses common issues
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Web Server Troubleshooting ==="
echo ""

# Check 1: Is Nginx installed?
echo -n "Checking if Nginx is installed... "
if command -v nginx &> /dev/null; then
    echo -e "${GREEN}✅ Yes${NC}"
else
    echo -e "${RED}❌ No - Run: sudo dnf install nginx${NC}"
    exit 1
fi

# Check 2: Is Nginx running?
echo -n "Checking if Nginx is running... "
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✅ Yes${NC}"
else
    echo -e "${RED}❌ No${NC}"
    echo "   Fix: sudo systemctl start nginx"
fi

# Check 3: Is Nginx enabled?
echo -n "Checking if Nginx is enabled... "
if systemctl is-enabled --quiet nginx; then
    echo -e "${GREEN}✅ Yes${NC}"
else
    echo -e "${YELLOW}⚠ No (won't start on boot)${NC}"
    echo "   Fix: sudo systemctl enable nginx"
fi

# Check 4: Configuration valid?
echo -n "Checking Nginx configuration... "
if nginx -t &> /dev/null; then
    echo -e "${GREEN}✅ Valid${NC}"
else
    echo -e "${RED}❌ Invalid${NC}"
    echo "   Run 'nginx -t' to see errors"
fi

# Check 5: Listening on port 80?
echo -n "Checking if listening on port 80... "
if sudo ss -tuln | grep -q ':80'; then
    echo -e "${GREEN}✅ Yes${NC}"
else
    echo -e "${RED}❌ No${NC}"
fi

# Check 6: Firewall allows HTTP?
echo -n "Checking firewall (HTTP)... "
if sudo firewall-cmd --list-services 2>/dev/null | grep -q http; then
    echo -e "${GREEN}✅ Allowed${NC}"
else
    echo -e "${RED}❌ Blocked${NC}"
    echo "   Fix: sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload"
fi

# Check 7: SELinux blocking?
echo -n "Checking SELinux status... "
if [ "$(getenforce)" = "Enforcing" ]; then
    echo -e "${YELLOW}Enforcing${NC}"
    echo "   If issues, check: sudo ausearch -m avc -ts recent"
else
    echo -e "${GREEN}Permissive/Disabled${NC}"
fi

# Check 8: Disk space
echo -n "Checking disk space... "
DISK_USAGE=$(df -h /var | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 90 ]; then
    echo -e "${GREEN}✅ OK ($DISK_USAGE% used)${NC}"
else
    echo -e "${RED}❌ Low space ($DISK_USAGE% used)${NC}"
fi

# Check 9: Can curl localhost?
echo -n "Checking if web page loads locally... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q 200; then
    echo -e "${GREEN}✅ Yes${NC}"
else
    echo -e "${RED}❌ No${NC}"
fi

echo ""
echo "=== Summary ==="
if systemctl is-active --quiet nginx && sudo ss -tuln | grep -q ':80'; then
    echo -e "${GREEN}✅ Web server appears healthy${NC}"
else
    echo -e "${RED}❌ Web server has issues - review above${NC}"
fi
