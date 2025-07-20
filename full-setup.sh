#!/bin/bash

# Full setup for Push Notifications API
echo "🚀 Starting full setup for Push Notifications API"

# Update and install build-essential
echo "📦 Installing system dependencies..."
sudo apt update && sudo apt install -y build-essential

echo "✅ System dependencies installed successfully!"

# Setup swap file (2GB)
echo "💾 Setting up swap file..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "✅ Swap file created and enabled!"
else
    echo "ℹ️  Swap file already exists, skipping..."
fi

# Verify swap is active
echo "📊 Current swap status:"
swapon --show

echo "📦 Cloning the repository..."
git clone https://github.com/Robmobius/push-notifications-api.git
cd push-notifications-api

# Running setup script in server directory
echo "📋 Setting up Node.js server..."
cd server
npm install
npm audit fix

echo "🚀 Full setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Configure your .env file if needed"
echo "   2. Start the server with: npm start"
echo "   3. Connect your Android app to: http://your-server-ip:3000/events"
