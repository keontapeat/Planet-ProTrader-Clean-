#!/bin/bash
# Complete Planet ProTrader REAL Trading Setup
# This will set up EVERYTHING for real trading on your Coinexx Demo #845638

echo "🚀 Planet ProTrader REAL Trading Setup"
echo "======================================="
echo ""
echo "Setting up REAL trading on your Coinexx Demo #845638"
echo "VPS: 172.234.201.231"
echo ""

# Create local setup directory
mkdir -p ~/planet-protrader-setup
cd ~/planet-protrader-setup

# Copy all necessary files
cp "/Users/keonta/Documents/Planet ProTrader (Clean)/vps-mt5-server.py" .
cp "/Users/keonta/Documents/Planet ProTrader (Clean)/setup-vps.sh" .

echo "📁 Files prepared for upload to your VPS"
echo ""
echo "NEXT STEPS:"
echo "==========="
echo "1. Upload files to your VPS:"
echo "   scp -r ~/planet-protrader-setup/* root@172.234.201.231:~/"
echo ""
echo "2. Run this command to connect to your VPS:"
echo "   ssh root@172.234.201.231"
echo ""
echo "3. Once connected to your VPS, run:"
echo "   chmod +x setup-vps.sh"
echo "   ./setup-vps.sh"
echo ""
echo "4. Start the MT5 server:"
echo "   cd ~/planet-protrader"
echo "   python3 vps-mt5-server.py"
echo ""
echo "🎯 After this setup, your iPhone app will place REAL trades!"