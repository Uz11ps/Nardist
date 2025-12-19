#!/bin/bash

set -e

echo "🚀 Initializing server for Nardist deployment..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "📦 Installing required packages..."
apt install -y curl git ufw

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Добавляем пользователя в группу docker
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker $SUDO_USER
    else
        usermod -aG docker $USER
    fi
    echo "✅ Docker installed. You may need to log out and log back in for group changes to take effect."
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose V2
if ! docker compose version &> /dev/null; then
    echo "🐳 Installing Docker Compose V2..."
    apt install -y docker-compose-plugin
    echo "✅ Docker Compose V2 installed"
else
    echo "✅ Docker Compose already installed"
fi

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Create application directory
echo "📁 Creating application directory..."
mkdir -p /opt/nardist
if [ -n "$SUDO_USER" ]; then
    chown -R $SUDO_USER:$SUDO_USER /opt/nardist
else
    chown -R $USER:$USER /opt/nardist
fi

echo "✅ Server initialization completed!"
echo ""
echo "📝 Next steps:"
echo "   1. cd /opt/nardist"
echo "   2. git clone https://github.com/Uz11ps/Nardist.git ."
echo "   3. Create .env file (see DEPLOY.md for details)"
echo "   4. Run ./deploy.sh"
echo ""
echo "📖 For detailed instructions, see DEPLOY.md"

