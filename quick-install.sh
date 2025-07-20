#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_step() { echo -e "${BLUE}🚀 $1${NC}"; }

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons"
   print_info "Please run as a regular user with sudo privileges"
   exit 1
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    print_error "sudo is required but not installed"
    exit 1
fi

print_step "Starting Push Notifications API Installation"
echo "=================================================="

# Update system packages
print_step "Step 1: Updating system packages..."
sudo apt update

# Install build-essential
print_step "Step 2: Installing build tools..."
sudo apt install -y build-essential
print_success "Build tools installed"

# Setup swap file
print_step "Step 3: Setting up swap file (2GB)..."
if [ ! -f /swapfile ]; then
    print_info "Creating 2GB swap file..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab > /dev/null
    print_success "Swap file created and enabled"
else
    print_warning "Swap file already exists, skipping creation"
fi

# Verify swap
print_info "Current swap status:"
swapon --show

# Install Node.js if not present
print_step "Step 4: Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    print_warning "Node.js not found. Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js installed"
else
    print_info "Node.js is already installed ($(node --version))"
fi

# Clone repository
print_step "Step 5: Cloning Push Notifications API repository..."
if [ -d "push-notifications-api" ]; then
    print_warning "Repository directory already exists, updating..."
    cd push-notifications-api
    git pull origin main
else
    git clone https://github.com/Robmobius/push-notifications-api.git
    cd push-notifications-api
fi

print_success "Repository ready"

# Install Node.js dependencies
print_step "Step 6: Installing Node.js dependencies..."
cd server
npm install
print_success "Dependencies installed"

# Run security audit
print_step "Step 7: Running security audit..."
npm audit fix
print_success "Security audit completed"

# Generate a sample API key
print_step "Step 8: Generating sample API key..."
API_KEY=$(openssl rand -base64 32)
echo ""
print_info "Sample API key generated: $API_KEY"
print_warning "Add this to your server/.env file:"
echo "API_KEY=$API_KEY"

# Create .env file with sample configuration
if [ ! -f ".env" ]; then
    cat > .env << EOL
HOST=0.0.0.0
PORT=3000

# API Key for authentication (uncomment to enable security)
# API_KEY=$API_KEY
EOL
    print_success ".env file created with sample configuration"
else
    print_info ".env file already exists, not overwriting"
fi

echo ""
echo "=================================================="
print_success "Installation completed successfully!"
echo ""
print_step "🎉 Your Push Notifications API is ready!"
echo ""
print_info "Next steps:"
echo "  1. Edit server/.env to configure your settings"
echo "  2. Uncomment API_KEY in .env to enable security"
echo "  3. Start the server: cd server && npm start"
echo "  4. Connect your Android app to: http://$(hostname -I | awk '{print $1}'):3000/events"
echo ""
print_info "Documentation:"
echo "  • README.md - Getting started guide"
echo "  • server/API_SECURITY.md - Security configuration"
echo ""
print_info "Health check: curl http://$(hostname -I | awk '{print $1}'):3000/health"
echo "=================================================="
