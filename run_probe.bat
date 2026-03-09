@echo off
cd /d "%~dp0"

:loop
python probe.py --host 127.0.0.1 --port 18088 --p2pool-miner-address YOUR_P2POOL_WALLET_ADDRESS_HERE --p2pool-network mini
timeout /t 300 /nobreak > nul
goto loop
