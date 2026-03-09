# Sentinel Setup Script for Windows
# PowerShell script for automated installation

# Requires PowerShell 5.0+
#Requires -Version 5.0

# Colors
$Host.UI.RawUI.ForegroundColor = "Cyan"

# Banner
Clear-Host
Write-Host @"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║    ███████╗███████╗███╗   ██╗████████╗██╗███╗   ██╗███████╗██╗    ║
║    ██╔════╝██╔════╝████╗  ██║╚══██╔══╝██║████╗  ██║██╔════╝██║    ║
║    ███████╗█████╗  ██╔██╗ ██║   ██║   ██║██╔██╗ ██║█████╗  ██║    ║
║    ╚════██║██╔══╝  ██║╚██╗██║   ██║   ██║██║╚██╗██║██╔══╝  ██║    ║
║    ███████║███████╗██║ ╚████║   ██║   ██║██║ ╚████║███████╗███████╗║
║    ╚══════╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝║
║                                                           ║
║        Monero Miner Monitoring & Security System          ║
║                   Windows Setup                           ║
╚═══════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

Write-Host "Welcome to the Sentinel Setup Wizard for Windows!" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 2

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  WARNING: Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some features may not work properly." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
        exit 1
    }
}

# Function to prompt yes/no
function Prompt-YesNo {
    param([string]$Question)
    
    do {
        $response = Read-Host "$Question (y/n)"
    } while ($response -notmatch '^[yn]$')
    
    return $response -eq 'y'
}

# Function to prompt with default
function Prompt-WithDefault {
    param(
        [string]$Question,
        [string]$Default
    )
    
    $response = Read-Host "$Question [$Default]"
    if ([string]::IsNullOrWhiteSpace($response)) {
        return $Default
    }
    return $response
}

# ============================================================================
# STEP 1: Installation Directory
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📁 Step 1: Installation Directory" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$defaultInstallDir = Join-Path $env:USERPROFILE "sentinel"
$installDir = Prompt-WithDefault "Where should Sentinel be installed?" $defaultInstallDir
Write-Host ""

if (Test-Path $installDir) {
    Write-Host "⚠️  Directory already exists: $installDir. Proceeding..." -ForegroundColor Yellow
}

New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Set-Location $installDir

Write-Host "✓ Installation directory: $installDir" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 1

# ============================================================================
# STEP 2: Check Python
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🐍 Step 2: Python Installation" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
$pythonCmd = $null
$pythonCommands = @("python", "python3", "py")

foreach ($cmd in $pythonCommands) {
    try {
        $version = & $cmd --version 2>&1
        if ($version -match "Python 3\.[89]|Python 3\.1[0-9]") {
            $pythonCmd = $cmd
            Write-Host "✓ Found Python: $version" -ForegroundColor Green
            break
        }
    }
    catch {
        continue
    }
}

if (-not $pythonCmd) {
    Write-Host "❌ Python 3.8+ not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Python from:" -ForegroundColor Yellow
    Write-Host "  https://www.python.org/downloads/" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Make sure to check 'Add Python to PATH' during installation!" -ForegroundColor Yellow
    Write-Host ""
    
    if (Prompt-YesNo "Open Python download page now?") {
        Start-Process "https://www.python.org/downloads/"
    }
    
    Write-Host ""
    Write-Host "After installing Python, please run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Start-Sleep -Seconds 1

# ============================================================================
# STEP 3: Download Sentinel Files
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "⬇️  Step 3: Sentinel Files" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if files exist
if ((Test-Path "probe.py") -and (Test-Path "app.py")) {
    Write-Host "✓ Sentinel files found in current directory" -ForegroundColor Green
}
else {
    Write-Host "Sentinel files not found."
    Write-Host ""
    
    $archivePath = Read-Host "Enter path to Sentinel archive (.zip)"
    
    if (Test-Path $archivePath) {
        Write-Host "Extracting archive..."
        Expand-Archive -Path $archivePath -DestinationPath $installDir -Force
        Write-Host "✓ Files extracted" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Archive not found: $archivePath" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Start-Sleep -Seconds 1

# ============================================================================
# STEP 4: Python Virtual Environment
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🐍 Step 4: Python Environment" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (Prompt-YesNo "Create Python virtual environment? (Recommended)") {
    Write-Host "Creating virtual environment..."
    & $pythonCmd -m venv venv
    
    # Activate venv
    $venvActivate = Join-Path $installDir "venv\Scripts\Activate.ps1"
    if (Test-Path $venvActivate) {
        & $venvActivate
        $pythonCmd = Join-Path $installDir "venv\Scripts\python.exe"
    }
    
    Write-Host "Installing Python packages..."
    & $pythonCmd -m pip install --upgrade pip --quiet
    & $pythonCmd -m pip install -r requirements.txt --quiet
    
    Write-Host "✓ Virtual environment created" -ForegroundColor Green
}
else {
    Write-Host "Installing Python packages..."
    & $pythonCmd -m pip install -r requirements.txt
    Write-Host "✓ Python packages installed" -ForegroundColor Green
}

Write-Host ""
Start-Sleep -Seconds 1

# ============================================================================
# STEP 5: Configuration
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "⚙️  Step 5: Configuration" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# XMRig API Configuration
Write-Host "XMRig API Configuration:"
Write-Host "─────────────────────────"
$minerPort = Prompt-WithDefault "XMRig API port" "18088"

Write-Host ""
Write-Host "To find your XMRig access token:"
Write-Host "  • Open XMRig folder"
Write-Host "  • Open config.json"
Write-Host "  • Look for 'access-token'"
Write-Host ""
$minerToken = Read-Host "XMRig API access token"

# P2Pool Configuration
Write-Host ""
$useP2Pool = Prompt-YesNo "Do you use P2Pool?"

if ($useP2Pool) {
    Write-Host ""
    Write-Host "P2Pool Configuration:"
    Write-Host "─────────────────────"
    $p2poolAddress = Read-Host "Your Monero wallet address"
    
    Write-Host ""
    Write-Host "P2Pool Network:"
    Write-Host "  1. main (default, most hashrate)"
    Write-Host "  2. mini (lower difficulty)"
    Write-Host "  3. nano (lowest difficulty)"
    $networkChoice = Read-Host "Select network [1-3]"
    
    $p2poolNetwork = switch ($networkChoice) {
        "2" { "mini" }
        "3" { "nano" }
        default { "main" }
    }
}

# Create config.py
Write-Host ""
Write-Host "Writing configuration..."

$configContent = @"
#!/usr/bin/env python3
"""
Configuration file for Sentinel monitoring system.
Generated by setup script on $(Get-Date)
"""

import os

# Database Configuration
DB_PATH = os.path.join(os.path.dirname(__file__), "sentinel.db")

# Miner API Configuration
DEFAULT_MINER_PORT = $minerPort
MINER_API_TOKEN = "$minerToken"
MINER_API_TIMEOUT = 2  # seconds

# P2Pool Configuration
P2POOL_NETWORKS = {
    "main": "https://p2pool.observer/",
    "mini": "https://mini.p2pool.observer/",
    "nano": "https://nano.p2pool.observer/",
}
P2POOL_API_TIMEOUT = 5  # seconds
P2POOL_WINDOW_SIZE = 2160

# Data Retention
DATA_RETENTION_DAYS = 30

# Dashboard Configuration
DASHBOARD_REFRESH_INTERVAL = 30  # seconds
DASHBOARD_PORT = 8501
"@

Set-Content -Path "config.py" -Value $configContent

Write-Host "✓ Configuration saved" -ForegroundColor Green
Write-Host ""
Start-Sleep -Seconds 1

# ============================================================================
# STEP 6: Test Installation
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🧪 Step 6: Test Installation" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (Prompt-YesNo "Run test scan now?") {
    Write-Host ""
    Write-Host "Running test scan..."
    
    $probeArgs = @("probe.py", "--host", "127.0.0.1", "--port", $minerPort)
    
    if ($useP2Pool) {
        $probeArgs += "--p2pool-miner-address"
        $probeArgs += $p2poolAddress
        $probeArgs += "--p2pool-network"
        $probeArgs += $p2poolNetwork
    }
    
    & $pythonCmd @probeArgs
    
    Write-Host ""
    Write-Host "Checking database..."
    & $pythonCmd probe.py --stats
    
    Write-Host ""
    Write-Host "✓ Test scan complete" -ForegroundColor Green
}

Write-Host ""
Start-Sleep -Seconds 1

# ============================================================================
# STEP 7: Background Services (NSSM)
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "⚙️ Step 7: Background Services (NSSM)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if (Prompt-YesNo "Set up Sentinel background services? (Recommended)") {
    Write-Host ""
    Write-Host "Checking for NSSM (Non-Sucking Service Manager)..."
    
    $nssmPath = ""
    $wingetLinks = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\nssm.exe"
    
    if (Get-Command "nssm" -ErrorAction SilentlyContinue) {
        $nssmPath = (Get-Command "nssm").Source
        Write-Host "✓ NSSM found at: $nssmPath" -ForegroundColor Green
    } elseif (Test-Path $wingetLinks) {
        $nssmPath = $wingetLinks
        Write-Host "✓ NSSM found at: $nssmPath" -ForegroundColor Green
    } else {
        Write-Host "NSSM not found. Installing via WinGet..." -ForegroundColor Yellow
        try {
            # Try to install NSSM via winget
            winget install nssm.nssm --silent --accept-package-agreements --accept-source-agreements
            
            if (Test-Path $wingetLinks) {
                $nssmPath = $wingetLinks
                Write-Host "✓ NSSM installed successfully" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Could not locate NSSM after installation." -ForegroundColor Yellow
                Write-Host "⚠️  Skipping service creation." -ForegroundColor Yellow
                $nssmPath = $null
            }
        } catch {
            Write-Host "⚠️  Failed to install NSSM: $_" -ForegroundColor Red
            Write-Host "⚠️  Skipping service creation." -ForegroundColor Yellow
            $nssmPath = $null
        }
    }
    
    if ($nssmPath) {
        # 1. Create Dashboard Service
        Write-Host "Creating Sentinel Dashboard service..."
        $dashboardBat = Join-Path $installDir "start_dashboard.bat"
        
        # Stop and remove if exists
        if (Get-Service -Name "sentinel-dash" -ErrorAction SilentlyContinue) {
            & $nssmPath stop sentinel-dash
            & $nssmPath remove sentinel-dash confirm
        }
        
        & $nssmPath install sentinel-dash "$dashboardBat"
        & $nssmPath set sentinel-dash AppDirectory "$installDir"
        & $nssmPath set sentinel-dash Description "Sentinel Web Dashboard"
        & $nssmPath start sentinel-dash
        Write-Host "✓ Dashboard service (sentinel-dash) created and started" -ForegroundColor Green
        
        # Add Firewall Rule
        Write-Host "Adding Firewall rule for Dashboard (Port 8501)..."
        $ruleName = "Sentinel Dashboard (Port 8501)"
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        if (-not $existingRule) {
            New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort 8501 -Protocol TCP -Action Allow -Profile Any | Out-Null
            Write-Host "✓ Firewall rule added." -ForegroundColor Green
        }
        
        # 2. Create Probe Service
        Write-Host "Creating Sentinel Probe service..."
        $probeBat = Join-Path $installDir "run_probe.bat"
        
        # Stop and remove old scheduled task if it exists
        Unregister-ScheduledTask -TaskName "SentinelProbe" -Confirm:$false -ErrorAction SilentlyContinue
        
        # Stop and remove old service if exists
        if (Get-Service -Name "sentinel-probe" -ErrorAction SilentlyContinue) {
            & $nssmPath stop sentinel-probe
            & $nssmPath remove sentinel-probe confirm
        }
        
        & $nssmPath install sentinel-probe "$probeBat"
        & $nssmPath set sentinel-probe AppDirectory "$installDir"
        & $nssmPath set sentinel-probe Description "Sentinel Miner Monitoring Probe"
        & $nssmPath start sentinel-probe
        Write-Host "✓ Probe service (sentinel-probe) created and started" -ForegroundColor Green
    }
}

Write-Host ""
Start-Sleep -Seconds 1


# ============================================================================
# STEP 8: Create Scripts & Shortcuts
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🔗 Step 8: Scripts & Shortcuts" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Always generate the batch scripts needed for the services
# Dashboard batch script
$dashboardBat = Join-Path $installDir "start_dashboard.bat"
$dashboardContent = @"
@echo off
cd /d "$installDir"
"$pythonCmd" -m streamlit run app.py --server.address=0.0.0.0 --server.headless=true > "$installDir\dashboard_service.log" 2>&1
pause
"@
Set-Content -Path $dashboardBat -Value $dashboardContent
Write-Host "✓ Dashboard runner script created" -ForegroundColor Green

# Probe batch script
$probeBat = Join-Path $installDir "run_probe.bat"

$probeArgs = "--host 127.0.0.1 --port $minerPort"
if ($useP2Pool) {
    $probeArgs += " --p2pool-miner-address $p2poolAddress --p2pool-network $p2poolNetwork"
}

$probeContent = @"
@echo off
cd /d "$installDir"

:loop
"$pythonCmd" probe.py $probeArgs
timeout /t 300 /nobreak > nul
goto loop
"@
Set-Content -Path $probeBat -Value $probeContent
Write-Host "✓ Probe runner script created" -ForegroundColor Green

# Desktop Shortcuts
if (Prompt-YesNo "Create desktop shortcuts?") {
    Write-Host ""
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $WshShell = New-Object -comObject WScript.Shell
    
    $shortcut = $WshShell.CreateShortcut("$desktopPath\Sentinel Dashboard.lnk")
    $shortcut.TargetPath = "http://localhost:8501"
    $shortcut.IconLocation = "$installDir\python.exe, 0" # Fallback icon
    $shortcut.Description = "Sentinel Monitoring Dashboard"
    $shortcut.Save()
    Write-Host "✓ Dashboard web shortcut created" -ForegroundColor Green
    
    $shortcut2 = $WshShell.CreateShortcut("$desktopPath\Sentinel Probe.lnk")
    $shortcut2.TargetPath = $probeBat
    $shortcut2.WorkingDirectory = $installDir
    $shortcut2.Description = "Run Sentinel Probe (Manual)"
    $shortcut2.Save()
    Write-Host "✓ Probe manual shortcut created" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# INSTALLATION COMPLETE
# ============================================================================
Clear-Host
Write-Host @"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                 ✓ Installation Complete!                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Green

Write-Host ""
Write-Host "Installation Summary:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host "📁 Install Location:   " -NoNewline
Write-Host $installDir -ForegroundColor Green
Write-Host "🐍 Python:             " -NoNewline
Write-Host $pythonCmd -ForegroundColor Green
Write-Host "⚙️  Config File:        " -NoNewline
Write-Host "$installDir\config.py" -ForegroundColor Green
Write-Host "💾 Database:           " -NoNewline
Write-Host "$installDir\sentinel.db" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Write-Host ""

Write-Host "Quick Start Guide:" -ForegroundColor Cyan
Write-Host ""

Write-Host "Start Dashboard:" -ForegroundColor Yellow
Write-Host "  • Double-click 'Sentinel Dashboard' shortcut on desktop"
Write-Host "  OR"
Write-Host "  • Open: http://localhost:8501"
Write-Host ""

Write-Host "Run Probe Manually:" -ForegroundColor Yellow
Write-Host "  • Double-click 'Sentinel Probe' shortcut"
Write-Host "  OR"
if ($useP2Pool) {
    Write-Host "  cd $installDir"
    Write-Host "  $pythonCmd probe.py --host 127.0.0.1 --port $minerPort \"
    Write-Host "    --p2pool-miner-address $p2poolAddress \"
    Write-Host "    --p2pool-network $p2poolNetwork"
}
else {
    Write-Host "  cd $installDir"
    Write-Host "  $pythonCmd probe.py --host 127.0.0.1 --port $minerPort"
}

Write-Host ""
Write-Host "View Statistics:" -ForegroundColor Yellow
Write-Host "  cd $installDir"
Write-Host "  $pythonCmd probe.py --stats"

Write-Host ""
Write-Host "📖 Documentation:" -ForegroundColor Yellow
Write-Host "  • README.md - Complete guide"
Write-Host "  • P2POOL_TROUBLESHOOTING.md - P2Pool help"

Write-Host ""
Write-Host "🎉 Happy Mining!" -ForegroundColor Green
Write-Host "If you find Sentinel useful, consider starring us on GitHub!" -ForegroundColor Cyan
Write-Host ""

# Keep window open
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
