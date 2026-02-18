#!/bin/bash

###############################################################################
# Automated Web Server Deployment Script
# Author: Your Name
# Description: Automates Nginx installation, configuration, and SSL setup
# Date: $(date +%Y-%m-%d)
###############################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file
LOGFILE="logs/deployment_$(date +%Y%m%d_%H%M%S).log"

# Function to log messages
log_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOGFILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOGFILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

log_message "Starting web server deployment..."

# Step 1: Install Nginx
log_message "Installing Nginx..."
dnf install -y nginx >> "$LOGFILE" 2>&1

if [ $? -eq 0 ]; then
    log_message "Nginx installed successfully"
else
    log_error "Failed to install Nginx"
    exit 1
fi

# Step 2: Configure Firewall
log_message "Configuring firewall..."
firewall-cmd --permanent --add-service=http >> "$LOGFILE" 2>&1
firewall-cmd --permanent --add-service=https >> "$LOGFILE" 2>&1
firewall-cmd --reload >> "$LOGFILE" 2>&1
log_message "Firewall configured successfully"

# Step 3: Create custom web directory
WEB_DIR="/var/www/mywebsite"
log_message "Creating web directory: $WEB_DIR"
mkdir -p "$WEB_DIR"

# Step 4: Create a sample index page
log_message "Creating sample website..."
cat > "$WEB_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Automated Deployment Success</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: rgba(255,255,255,0.1);
            padding: 50px;
            border-radius: 10px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
        }
        h1 { font-size: 3em; margin: 0; }
        p { font-size: 1.2em; }
        .info { 
            background: rgba(255,255,255,0.2);
            padding: 20px;
            border-radius: 5px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Deployment Successful!</h1>
        <p>Automated Nginx Web Server</p>
        <div class="info">
            <p><strong>Server:</strong> Nginx on RHEL Linux</p>
            <p><strong>Deployed:</strong> <span id="date"></span></p>
            <p><strong>Status:</strong> ✅ Active</p>
        </div>
    </div>
    <script>
        document.getElementById('date').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Step 5: Set proper permissions
log_message "Setting permissions..."
chown -R nginx:nginx "$WEB_DIR"
chmod -R 755 "$WEB_DIR"
restorecon -Rv "$WEB_DIR" >> "$LOGFILE" 2>&1

# Step 6: Create Nginx configuration
log_message "Creating Nginx configuration..."
cat > /etc/nginx/conf.d/mywebsite.conf << EOF
server {
    listen 80;
    server_name localhost;
    
    root $WEB_DIR;
    index index.html;
    
    access_log /var/log/nginx/mywebsite_access.log;
    error_log /var/log/nginx/mywebsite_error.log;
    
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

# Step 7: Test Nginx configuration
log_message "Testing Nginx configuration..."
nginx -t >> "$LOGFILE" 2>&1

if [ $? -eq 0 ]; then
    log_message "Nginx configuration is valid"
else
    log_error "Nginx configuration test failed"
    exit 1
fi

# Step 8: Enable and start Nginx
log_message "Starting Nginx service..."
systemctl enable nginx >> "$LOGFILE" 2>&1
systemctl restart nginx >> "$LOGFILE" 2>&1

if [ $? -eq 0 ]; then
    log_message "Nginx service started successfully"
else
    log_error "Failed to start Nginx service"
    exit 1
fi

# Step 9: Configure SELinux (if enabled)
if [ $(getenforce) != "Disabled" ]; then
    log_message "Configuring SELinux..."
    setsebool -P httpd_can_network_connect 1 >> "$LOGFILE" 2>&1
    semanage fcontext -a -t httpd_sys_content_t "$WEB_DIR(/.*)?" >> "$LOGFILE" 2>&1 || true
fi

# Step 10: Create SSL certificate (self-signed for testing)
log_message "Generating self-signed SSL certificate..."
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/nginx-selfsigned.key \
    -out ssl/nginx-selfsigned.crt \
    -subj "/C=IN/ST=Rajasthan/L=Jaipur/O=MyOrg/CN=localhost" >> "$LOGFILE" 2>&1

if [ $? -eq 0 ]; then
    log_message "SSL certificate generated successfully"
    
    # Copy to nginx directory
    cp ssl/nginx-selfsigned.* /etc/pki/tls/certs/
    
    # Create SSL configuration
    cat > /etc/nginx/conf.d/ssl.conf << 'EOF'
server {
    listen 443 ssl http2;
    server_name localhost;
    
    ssl_certificate /etc/pki/tls/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/pki/tls/certs/nginx-selfsigned.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    root /var/www/mywebsite;
    index index.html;
    
    access_log /var/log/nginx/mywebsite_ssl_access.log;
    error_log /var/log/nginx/mywebsite_ssl_error.log;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF
    
    systemctl reload nginx >> "$LOGFILE" 2>&1
    log_message "SSL configuration applied"
fi

# Final status check
echo ""
echo "=========================================="
log_message "✅ Web Server Deployment Complete!"
echo "=========================================="
echo ""
echo "Access your website at:"
echo "  HTTP:  http://$(hostname -I | awk '{print $1}')"
echo "  HTTPS: https://$(hostname -I | awk '{print $1}') (self-signed certificate)"
echo ""
echo "Logs available at: $LOGFILE"
echo ""
log_message "Deployment completed successfully"
