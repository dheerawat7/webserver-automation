# 🚀 Automated Web Server Deployment

Professional-grade automated deployment and management of Nginx web server on RHEL Linux with comprehensive monitoring, backup, and security features.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![RHCSA](https://img.shields.io/badge/RHCSA-Certified-red.svg)
![Nginx](https://img.shields.io/badge/nginx-1.20+-green.svg)

## 📋 Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Usage](#usage)
- [Automation](#automation)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Skills Demonstrated](#skills-demonstrated)

## ✨ Features

- ✅ **Fully Automated Deployment** - One-command installation and configuration
- ✅ **SSL/TLS Support** - Self-signed certificates with secure ciphers
- ✅ **Security Hardening** - SELinux, firewall, security headers
- ✅ **Automated Backups** - Daily backups with rotation
- ✅ **Health Monitoring** - Continuous service monitoring
- ✅ **Log Management** - Automated log rotation
- ✅ **Error Handling** - Comprehensive logging and error detection
- ✅ **Resource Monitoring** - CPU, memory, disk tracking

## 🔧 Prerequisites

- RHEL 9
- Root/sudo access
- Minimum 1GB RAM
- 10GB available disk space
- Basic understanding of Linux commands

## 🚀 Quick Start
```bash
# Clone the repository
git clone https://github.com/dheerawat7/webserver-automation.git
cd webserver-automation

# Run the deployment
sudo ./deploy-webserver.sh

# Access your website
# HTTP:  http://YOUR_SERVER_IP
# HTTPS: https://YOUR_SERVER_IP
```

## 📁 Project Structure
```
webserver-automation/
├── deploy-webserver.sh          # Main deployment script
├── scripts/
│   ├── backup-webserver.sh      # Automated backup
│   ├── health-check.sh          # Health monitoring
│   ├── monitor-webserver.sh     # Performance monitoring
│   ├── setup-cron.sh            # Cron job configuration
│   └── troubleshoot.sh          # Troubleshooting tool
├── configs/
│   └── logrotate-nginx.conf     # Log rotation config
├── logs/                        # Deployment logs
├── ssl/                         # SSL certificates
└── README.md                    # This file
```

## 📖 Usage

### Deploy Web Server
```bash
sudo ./deploy-webserver.sh
```

### Create Backup
```bash
sudo ./scripts/backup-webserver.sh
```

### Monitor Performance
```bash
sudo ./scripts/monitor-webserver.sh
```

### Health Check
```bash
sudo ./scripts/health-check.sh
```

### Troubleshoot Issues
```bash
sudo ./scripts/troubleshoot.sh
```

### Setup Automation
```bash
sudo ./scripts/setup-cron.sh
```

## ⚙️ Automation

The project includes cron jobs for:
- **Daily Backups** - 2:00 AM every day
- **Hourly Health Checks** - Every hour
- **Monitoring Reports** - Every 30 minutes

Setup automation:
```bash
sudo ./scripts/setup-cron.sh
```

View scheduled jobs:
```bash
crontab -l
```

## 📊 Monitoring

The monitoring script provides:
- Service status and uptime
- Active connections count
- Resource usage (CPU, memory)
- Disk space monitoring
- Error log analysis
- Top accessing IPs
- HTTP response codes
- Firewall and SELinux status

## 🔍 Troubleshooting

Common issues and solutions:

### Cannot Access Website
```bash
# Run troubleshooting script
sudo ./scripts/troubleshoot.sh

# Check if service is running
sudo systemctl status nginx

# Check if port is listening
sudo ss -tuln | grep :80

# Check firewall
sudo firewall-cmd --list-all
```

### Configuration Errors
```bash
# Test configuration
sudo nginx -t

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### High Resource Usage
```bash
# Monitor in real-time
sudo ./scripts/monitor-webserver.sh

# Check nginx processes
ps aux | grep nginx
```

## 💡 Skills Demonstrated

### Linux System Administration (RHCSA)
- Package management (DNF/YUM)
- Service management (systemd)
- User and permission management
- File system operations

### Shell Scripting & Automation
- Bash scripting best practices
- Error handling and logging
- Automated deployment
- Cron job scheduling

### Web Server Configuration
- Nginx installation and configuration
- Virtual host setup
- SSL/TLS implementation
- Performance optimization

### Security
- Firewall configuration (firewalld)
- SELinux context management
- SSL certificate generation
- Security headers implementation

### Monitoring & Troubleshooting
- Log analysis
- Performance monitoring
- Health checks
- Diagnostic scripting

### DevOps Practices
- Infrastructure as Code
- Automated backups
- Version control (Git)
- Documentation

## 🔐 Security Features

- SELinux enforcing mode support
- Firewall rules (HTTP/HTTPS)
- Security headers (X-Frame-Options, X-XSS-Protection, etc.)
- SSL/TLS encryption
- Regular security updates

## 📝 Logs

All logs are stored in:
- Deployment: `logs/deployment_YYYYMMDD_HHMMSS.log`
- Nginx Access: `/var/log/nginx/mywebsite_access.log`
- Nginx Error: `/var/log/nginx/mywebsite_error.log`
- Backup: `/var/log/webserver-backup.log`
- Health Check: `/var/log/webserver-health.log`
- Monitoring: `/var/log/webserver-monitor.log`

## 🤝 Contributing

This is a learning project, but suggestions are welcome!

## 👤 Author

Pradhyuman Singh Dheerawat
- RHCSA Certified https://rhtapps.redhat.com/verify?certId=260-021-035
- Aspiring DevOps Engineer
- LinkedIn: https://www.linkedin.com/in/pradhyuman7/
- GitHub: https://github.com/dheerawat7

## 📄 License

MIT License - feel free to use this project for learning and portfolio purposes.

## 🙏 Acknowledgments

- Red Hat for RHCSA certification training
- Nginx community for excellent documentation
- DevOps community for best practices

---

**Note:** This project uses self-signed SSL certificates suitable for testing. For production, use certificates from a trusted Certificate Authority (Let's Encrypt, etc.).
