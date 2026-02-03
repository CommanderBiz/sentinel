# Building Sentinel Windows Executable

This guide explains how to create a standalone `.exe` installer for Windows users.

## Method 1: Using ps2exe (PowerShell to EXE)

### Installation

```powershell
# Install ps2exe module
Install-Module ps2exe -Scope CurrentUser
```

### Build the EXE

```powershell
# Navigate to Sentinel directory
cd path\to\sentinel

# Convert PowerShell script to EXE
Invoke-ps2exe -inputFile setup_windows.ps1 -outputFile SentinelSetup.exe -title "Sentinel Setup" -version "1.0.0.0" -company "Sentinel Project" -product "Sentinel Miner Monitor" -copyright "MIT License" -iconFile sentinel.ico -requireAdmin
```

### Options Explained

- `-inputFile`: The PowerShell setup script
- `-outputFile`: The output executable name
- `-title`: Window title
- `-version`: Version number
- `-requireAdmin`: Request admin privileges (optional)
- `-iconFile`: Custom icon (create one or omit this)

## Method 2: Using NSIS (Nullsoft Scriptable Install System)

NSIS creates professional Windows installers.

### Installation

1. Download NSIS: https://nsis.sourceforge.io/Download
2. Install NSIS

### Create NSIS Script

Create `sentinel_installer.nsi`:

```nsis
; Sentinel Installer Script
!define PRODUCT_NAME "Sentinel"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "Sentinel Project"
!define PRODUCT_WEB_SITE "https://github.com/yourusername/sentinel"

SetCompressor lzma

!include "MUI2.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "LICENSE"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language
!insertmacro MUI_LANGUAGE "English"

; Installer details
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "SentinelSetup_${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES64\Sentinel"
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  SetOverwrite ifnewer
  
  ; Copy all files
  File /r "*.py"
  File /r "*.md"
  File "requirements.txt"
  File ".gitignore"
  
  ; Create uninstaller
  WriteUninstaller "$INSTDIR\uninst.exe"
  
  ; Create desktop shortcut
  CreateShortCut "$DESKTOP\Sentinel Setup.lnk" "powershell.exe" '-ExecutionPolicy Bypass -File "$INSTDIR\setup_windows.ps1"'
  
  ; Add to Programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "DisplayName" "${PRODUCT_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}" "UninstallString" "$INSTDIR\uninst.exe"
SectionEnd

Section Uninstall
  Delete "$INSTDIR\*.*"
  Delete "$DESKTOP\Sentinel Setup.lnk"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
SectionEnd
```

### Build the Installer

```bash
# Compile the NSIS script
makensis sentinel_installer.nsi
```

## Method 3: Using PyInstaller (Bundle Python + Script)

This creates a standalone executable with Python embedded.

### Installation

```bash
pip install pyinstaller
```

### Create a Python Wrapper

Create `setup_launcher.py`:

```python
#!/usr/bin/env python3
import subprocess
import sys
import os

def main():
    # Get the directory where the exe is located
    if getattr(sys, 'frozen', False):
        application_path = os.path.dirname(sys.executable)
    else:
        application_path = os.path.dirname(os.path.abspath(__file__))
    
    # Path to the PowerShell script
    ps_script = os.path.join(application_path, 'setup_windows.ps1')
    
    # Run PowerShell script
    subprocess.run([
        'powershell.exe',
        '-ExecutionPolicy', 'Bypass',
        '-File', ps_script
    ])

if __name__ == '__main__':
    main()
```

### Build with PyInstaller

```bash
# Create the executable
pyinstaller --onefile --windowed --name SentinelSetup --icon=sentinel.ico setup_launcher.py

# The exe will be in dist/SentinelSetup.exe
```

## Method 4: Batch File Wrapper (Simplest)

Create `SentinelSetup.bat`:

```batch
@echo off
echo Starting Sentinel Setup...
echo.

REM Check for Python
python --version >nul 2>&1
if errorlevel 1 (
    echo Python not found! Please install Python 3.8+ first.
    echo Download from: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Run the PowerShell setup script
powershell -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"

pause
```

This is the simplest method and doesn't require building an exe.

## Recommended Approach

**For GitHub Release:**

1. **Create a ZIP archive** containing:
   - All Python files
   - `setup_windows.ps1`
   - `SentinelSetup.bat` (batch wrapper)
   - `requirements.txt`
   - Documentation files
   - `README_WINDOWS.md`

2. **Provide two options:**
   - **Easy:** Run `SentinelSetup.bat`
   - **Advanced:** Run PowerShell script directly

3. **Optional:** Also provide an `.exe` using ps2exe for users who prefer it

## Creating the Release Archive

### Windows Release ZIP

```powershell
# Create release directory
New-Item -ItemType Directory -Force -Path "release\sentinel-windows"

# Copy files
Copy-Item *.py release\sentinel-windows\
Copy-Item *.ps1 release\sentinel-windows\
Copy-Item *.md release\sentinel-windows\
Copy-Item requirements.txt release\sentinel-windows\
Copy-Item .gitignore release\sentinel-windows\

# Create batch launcher
@"
@echo off
echo Sentinel Setup for Windows
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"
pause
"@ | Out-File -FilePath "release\sentinel-windows\SentinelSetup.bat" -Encoding ASCII

# Create README for Windows
@"
# Sentinel for Windows

## Quick Start

1. Double-click `SentinelSetup.bat`
2. Follow the setup wizard
3. Access dashboard at http://localhost:8501

## Requirements

- Windows 10 or later
- Python 3.8+ (installer will check)

## Manual Installation

If the batch file doesn't work:

1. Open PowerShell as Administrator
2. Run: ``powershell -ExecutionPolicy Bypass -File setup_windows.ps1``

## Troubleshooting

**Python not found:**
- Download from https://www.python.org/downloads/
- Make sure to check "Add Python to PATH"

**PowerShell execution error:**
- Run PowerShell as Administrator
- Run: ``Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser``

## Support

See README.md for full documentation
"@ | Out-File -FilePath "release\sentinel-windows\README_WINDOWS.md"

# Create the ZIP
Compress-Archive -Path "release\sentinel-windows\*" -DestinationPath "sentinel-windows-v1.0.0.zip"

Write-Host "✓ Windows release created: sentinel-windows-v1.0.0.zip"
```

## Testing the Installer

1. Copy the built installer to a clean Windows VM
2. Run the installer
3. Verify all features work:
   - Python detection
   - Dependency installation
   - Configuration
   - Database creation
   - Dashboard launch
   - Scheduled tasks (if applicable)

## Digital Signature (Optional but Recommended)

For production releases, consider signing the executable:

1. Obtain a code signing certificate
2. Sign the exe:
   ```powershell
   signtool sign /f certificate.pfx /p password /t http://timestamp.digicert.com SentinelSetup.exe
   ```

This prevents Windows SmartScreen warnings.

## Final Checklist

- [ ] Test on clean Windows 10
- [ ] Test on clean Windows 11
- [ ] Test with Python not installed
- [ ] Test with Python already installed
- [ ] Test admin vs non-admin
- [ ] Verify all shortcuts work
- [ ] Verify scheduled tasks work
- [ ] Check file permissions
- [ ] Test uninstaller (if using NSIS)
- [ ] Create release notes
- [ ] Update version numbers
- [ ] Sign executable (optional)

## Distribution

Upload to GitHub Releases with:
- `sentinel-windows-v1.0.0.zip` (main archive)
- `SentinelSetup.exe` (optional, if built)
- `CHANGELOG.md`
- `README_WINDOWS.md`
