#!/bin/bash

echo "🚀 Setting up Push Notifications API server..."
echo "=============================================="

# Install Node.js dependencies
echo "📋 Installing Node.js dependencies..."
npm install

# Run security audit and fixes
echo "🔒 Running security audit and fixes..."
npm audit fix

# Show server info
echo "=============================================="
echo "✅ Server setup completed!"
echo ""
echo "📝 Server Information:"
echo "   • Port: 3000 (configurable in .env)"
echo "   • Events endpoint: /events"
echo "   • Health check: /health"
echo "   • Keep-alive interval: 30 seconds"
echo ""
echo "🚀 Start the server with:"
echo "   npm start"
echo ""
echo "📱 Connect your Android app to:"
echo "   http://your-server-ip:3000/events"
