#!/bin/bash

echo "🚀 Setting up Push Notifications API server environment..."
echo "================================================"

# Install system dependencies
echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y build-essential

echo "✅ System dependencies installed successfully!"

# Setup swap file (important for low-memory systems)
echo "💾 Setting up swap file (2GB)..."
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

# Install Node.js dependencies if in server directory
if [ -f "package.json" ]; then
    echo "📋 Installing Node.js dependencies..."
    npm install
    
    echo "🔒 Running security audit and fixes..."
    npm audit fix
    
    echo "✅ Node.js setup completed!"
elif [ -d "server" ]; then
    echo "📋 Installing Node.js dependencies in server directory..."
    cd server
    npm install
    
    echo "🔒 Running security audit and fixes..."
    npm audit fix
    
    echo "✅ Node.js setup completed!"
    cd ..
else
    echo "⚠️  No package.json found. Run this script from the project root or server directory."
fi

echo "================================================"
echo "🎉 Setup completed successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Configure your .env file if needed"
echo "   2. Start the server with: npm start"
echo "   3. Connect your Android app to: http://your-server-ip:3000/events"
