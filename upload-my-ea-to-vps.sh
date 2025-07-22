#!/bin/bash
# -- Upload your GOLDEX_AI_ENHANCED.mq5 to your Linode's MT5 folder automatically --

# --- CONFIG ---
LOCAL_EA_PATH="/Users/keonta/Documents/Planet ProTrader/MT5_EA/GOLDEX_AI_ENHANCED.mq5"
REMOTE_IP="172.234.201.231"
REMOTE_USER="root"        # replace with your VPS username if not root
REMOTE_MT5_PATH="/home/$REMOTE_USER/MT5/MQL5/Experts" # or the correct path on your VPS

# --- UPLOAD ---

echo "Uploading $LOCAL_EA_PATH to $REMOTE_USER@$REMOTE_IP:$REMOTE_MT5_PATH ..."
scp "$LOCAL_EA_PATH" "$REMOTE_USER@$REMOTE_IP:$REMOTE_MT5_PATH"

echo "Upload complete! Now, SSH in and open MetaEditor on your VPS, compile, and you're set!"