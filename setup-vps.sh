#!/bin/bash
# Setup script for Planet ProTrader VPS Integration
# Run this on your VPS at 172.234.201.231

echo "🚀 Setting up Planet ProTrader VPS Integration..."

# Install Python and Flask
sudo apt update
sudo apt install -y python3 python3-pip

# Install Flask
pip3 install flask

# Create MT5 server directory
mkdir -p ~/planet-protrader
cd ~/planet-protrader

# Copy the server script (you'll need to upload it)
echo "📝 Please upload vps-mt5-server.py to ~/planet-protrader/"

# Make it executable
chmod +x vps-mt5-server.py

# Create systemd service for auto-start
sudo tee /etc/systemd/system/planet-protrader.service > /dev/null <<EOF
[Unit]
Description=Planet ProTrader MT5 Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/planet-protrader
ExecStart=/usr/bin/python3 /root/planet-protrader/vps-mt5-server.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl enable planet-protrader
sudo systemctl start planet-protrader

# Open firewall port
sudo ufw allow 8080

echo "✅ Planet ProTrader VPS setup complete!"
echo "🌐 Server will be accessible at http://172.234.201.231:8080"
echo "📋 Check status with: sudo systemctl status planet-protrader"