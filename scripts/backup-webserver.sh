#!/bin/bash

###############################################################################
# Automated Backup Script with Rotation
# Backs up web files, configs, and SSL certificates
###############################################################################

# Configuration
BACKUP_DIR="/var/backups/webserver"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="web_backup_$DATE.tar.gz"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting backup process...${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Files to backup
BACKUP_ITEMS=(
    "/var/www/mywebsite"
    "/etc/nginx/conf.d/mywebsite.conf"
    "/etc/nginx/conf.d/ssl.conf"
    "/etc/pki/tls/certs/nginx-selfsigned.crt"
    "/etc/pki/tls/certs/nginx-selfsigned.key"
)

# Create backup
echo "Creating backup archive..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "${BACKUP_ITEMS[@]}" 2>/dev/null

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✅ Backup created successfully${NC}"
    echo "   Location: $BACKUP_DIR/$BACKUP_FILE"
    echo "   Size: $BACKUP_SIZE"
    
    # Create checksum
    md5sum "$BACKUP_DIR/$BACKUP_FILE" > "$BACKUP_DIR/$BACKUP_FILE.md5"
    echo "   Checksum: $(cat $BACKUP_DIR/$BACKUP_FILE.md5 | cut -d' ' -f1)"
else
    echo -e "${RED}❌ Backup failed${NC}"
    exit 1
fi

# Rotate old backups
echo ""
echo "Rotating old backups (keeping last $RETENTION_DAYS days)..."
find "$BACKUP_DIR" -name "web_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "web_backup_*.md5" -mtime +$RETENTION_DAYS -delete

# List current backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/web_backup_*.tar.gz 2>/dev/null | wc -l)
echo "Current backups: $BACKUP_COUNT"
echo ""
echo -e "${GREEN}Backup complete!${NC}"
