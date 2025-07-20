#!/bin/bash

# Install Push Notifications API as systemd service

echo "🔧 Installing Push Notifications API as systemd service..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root or with sudo"
    exit 1
fi

# Get the current directory path
CURRENT_DIR=$(pwd)
SERVER_DIR="$CURRENT_DIR/server"

# Check if server directory exists
if [ ! -d "$SERVER_DIR" ]; then
    echo "❌ Server directory not found. Please run this script from the repository root."
    exit 1
fi

# Find npm and node paths
NPM_PATH=$(which npm)
NODE_PATH=$(which node)

if [ -z "$NPM_PATH" ] || [ -z "$NODE_PATH" ]; then
    echo "❌ npm or node not found. Please install Node.js first."
    exit 1
fi

# Get the PATH environment variable
FULL_PATH=$(echo $PATH)

echo "📝 Creating systemd service file..."

cat > /etc/systemd/system/push-notifications.service << EOL
[Unit]
Description=Push Notifications API Server
Documentation=https://github.com/user/push-notifications-api
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$SERVER_DIR
Environment=NODE_ENV=production
Environment=PATH=$FULL_PATH
ExecStart=$NPM_PATH start
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10
StandardOutput=append:/var/log/push-notifications.log
StandardError=append:/var/log/push-notifications-error.log

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=$CURRENT_DIR
ReadWritePaths=/var/log
ReadWritePaths=/tmp

[Install]
WantedBy=multi-user.target
EOL

echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

echo "✅ Enabling service..."
systemctl enable push-notifications.service

echo "🚀 Starting service..."
systemctl start push-notifications.service

echo ""
echo "✅ Push Notifications API service installed successfully!"
echo ""
echo "📋 Service Management Commands:"
echo "   Start:   sudo systemctl start push-notifications"
echo "   Stop:    sudo systemctl stop push-notifications"
echo "   Restart: sudo systemctl restart push-notifications"
echo "   Status:  sudo systemctl status push-notifications"
echo "   Logs:    sudo journalctl -u push-notifications -f"
echo ""
echo "📄 Log files:"
echo "   Output:  /var/log/push-notifications.log"
echo "   Errors:  /var/log/push-notifications-error.log"
echo ""

# Show current status
systemctl status push-notifications.service --no-pager
