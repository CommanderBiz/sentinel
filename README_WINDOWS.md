# Sentinel for Windows - Quick Start

## Automated Setup (Recommended)

1. **Extract the ZIP file**
2. **Double-click `SentinelSetup.bat`**
3. **Follow the setup wizard**

The wizard will:
- Check for Python
- Install dependencies
- Configure your miner settings
- Create desktop shortcuts
- Set up scheduled tasks (optional)

## Requirements

- Windows 10 or later (Windows 11 supported)
- Python 3.8 or later
  - Download from: https://www.python.org/downloads/
  - **Important:** Check "Add Python to PATH" during installation!

## Manual Setup

If the automated setup doesn't work:

1. **Install Python** (if not already installed)

2. **Open PowerShell as Administrator:**
   - Right-click Start button
   - Select "Windows PowerShell (Admin)"

3. **Navigate to Sentinel folder:**
   ```powershell
   cd C:\path\to\sentinel
   ```

4. **Allow script execution:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

5. **Run setup:**
   ```powershell
   .\setup_windows.ps1
   ```

## After Installation

### Start Dashboard

- Double-click the "Sentinel Dashboard" desktop shortcut
- OR visit http://localhost:8501 in your browser

### Run Probe Manually

- Double-click the "Sentinel Probe" desktop shortcut
- OR open PowerShell and run:
  ```powershell
  cd C:\Users\YourName\sentinel
  python probe.py --host 127.0.0.1 --port 18088
  ```

### View Statistics

```powershell
cd C:\Users\YourName\sentinel
python probe.py --stats
```

## Scheduled Tasks

If you set up scheduled tasks during installation:

1. Press `Win + R`
2. Type `taskschd.msc`
3. Look for "SentinelProbe" task
4. You can enable/disable or modify the schedule

## Troubleshooting

### Python Not Found

- Install from https://www.python.org/downloads/
- During installation, check "Add Python to PATH"
- Restart your computer after installation

### PowerShell Execution Error

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### XMRig Connection Failed

1. Check XMRig is running
2. Verify XMRig API port (usually 18088)
3. Check XMRig access token in `config.json`
4. Update Sentinel's `config.py` with correct token

### Dashboard Won't Start

- Check if port 8501 is available
- Try: `netstat -ano | findstr :8501`
- If in use, stop that process or change the port in `config.py`

## Firewall

If accessing dashboard from another computer:

1. Open Windows Firewall
2. Allow inbound connections on port 8501
3. Access via: http://YOUR_PC_IP:8501

## Documentation

- `README.md` - Complete documentation
- `P2POOL_TROUBLESHOOTING.md` - P2Pool setup help
- `BUILDING_WINDOWS_EXE.md` - For developers

## Support

- GitHub Issues: https://github.com/yourusername/sentinel/issues
- Monero Mining Subreddit: r/MoneroMining

## Uninstall

1. Delete the Sentinel folder
2. Remove scheduled tasks (if created):
   - Open Task Scheduler
   - Delete "SentinelProbe" task
3. Remove desktop shortcuts
