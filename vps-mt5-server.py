#!/usr/bin/env python3
"""
MT5 Command Server for Planet ProTrader
Receives commands from iOS app and executes them on MT5
Deploy this on your VPS at 172.234.201.231
"""

from flask import Flask, request, jsonify
import os
import subprocess
import tempfile
from datetime import datetime

app = Flask(__name__)

# Configuration for YOUR setup
MT5_PATH = "/home/root/MT5"  # Adjust to your MT5 installation path
SCRIPTS_PATH = f"{MT5_PATH}/MQL5/Scripts"
LOG_PATH = f"{MT5_PATH}/Logs"

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "message": "Planet ProTrader MT5 Server Running"
    })

@app.route('/upload-script', methods=['POST'])
def upload_script():
    """Upload MQL5 script to MT5 Scripts folder"""
    try:
        data = request.json
        script_content = data['script']
        filename = data['filename']
        account = data['account']
        
        print(f"📝 Uploading script for account #{account}: {filename}")
        
        # Create scripts directory if it doesn't exist
        os.makedirs(SCRIPTS_PATH, exist_ok=True)
        
        # Write script to file
        script_path = os.path.join(SCRIPTS_PATH, filename)
        with open(script_path, 'w', encoding='utf-8') as f:
            f.write(script_content)
        
        print(f"✅ Script uploaded: {script_path}")
        
        # Compile the script
        compile_result = compile_mql5_script(filename)
        
        return jsonify({
            "status": "success",
            "message": f"Script uploaded and compiled for account #{account}",
            "filename": filename,
            "compiled": compile_result
        })
        
    except Exception as e:
        print(f"❌ Upload failed: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/execute-script', methods=['POST'])
def execute_script():
    """Execute MQL5 script on MT5 terminal"""
    try:
        data = request.json
        script_name = data['script_name']
        account = data['account']
        
        print(f"▶️ Executing script for account #{account}: {script_name}")
        
        # Execute the compiled script
        execution_result = execute_mql5_script(script_name, account)
        
        return jsonify({
            "status": "success" if execution_result else "failed",
            "message": f"Script executed for account #{account}",
            "script": script_name,
            "result": execution_result
        })
        
    except Exception as e:
        print(f"❌ Execution failed: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/get-logs', methods=['GET'])
def get_logs():
    """Get MT5 terminal logs"""
    try:
        # Read the latest MT5 log file
        log_files = []
        if os.path.exists(LOG_PATH):
            log_files = [f for f in os.listdir(LOG_PATH) if f.endswith('.log')]
            log_files.sort(key=lambda x: os.path.getmtime(os.path.join(LOG_PATH, x)), reverse=True)
        
        if log_files:
            latest_log = os.path.join(LOG_PATH, log_files[0])
            with open(latest_log, 'r', encoding='utf-8', errors='ignore') as f:
                # Get last 100 lines
                lines = f.readlines()[-100:]
                log_content = ''.join(lines)
        else:
            log_content = "No log files found"
        
        return jsonify({
            "status": "success",
            "logs": log_content,
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

def compile_mql5_script(filename):
    """Compile MQL5 script using MetaEditor"""
    try:
        script_path = os.path.join(SCRIPTS_PATH, filename)
        
        # Try to compile using metaeditor
        compile_cmd = [
            f"{MT5_PATH}/metaeditor64.exe",  # Adjust path as needed
            "/compile", script_path
        ]
        
        result = subprocess.run(compile_cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print(f"✅ Script compiled successfully: {filename}")
            return True
        else:
            print(f"❌ Compilation failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Compilation error: {str(e)}")
        return False

def execute_mql5_script(script_name, account):
    """Execute compiled MQL5 script on MT5 terminal"""
    try:
        # Create a temporary script execution command
        exe_path = os.path.join(SCRIPTS_PATH, f"{script_name}.ex5")
        
        if not os.path.exists(exe_path):
            print(f"❌ Compiled script not found: {exe_path}")
            return False
        
        # Execute via MT5 terminal
        # This depends on your MT5 setup - you might need to adjust this
        execute_cmd = [
            f"{MT5_PATH}/terminal64.exe",  # Adjust path as needed
            "/script", exe_path
        ]
        
        result = subprocess.run(execute_cmd, capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            print(f"✅ Script executed successfully: {script_name}")
            return True
        else:
            print(f"❌ Execution failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Execution error: {str(e)}")
        return False

if __name__ == '__main__':
    print("🚀 Starting Planet ProTrader MT5 Server")
    print(f"📁 MT5 Path: {MT5_PATH}")
    print(f"📁 Scripts Path: {SCRIPTS_PATH}")
    print("🌐 Server will run on port 8080")
    
    # Create necessary directories
    os.makedirs(SCRIPTS_PATH, exist_ok=True)
    os.makedirs(LOG_PATH, exist_ok=True)
    
    app.run(host='0.0.0.0', port=8080, debug=True)