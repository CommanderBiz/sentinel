@echo off
cd /d "C:\Users\comma\sentinel"

:loop
"C:\Users\comma\sentinel\venv\Scripts\python.exe" probe.py --host 127.0.0.1 --port 8000 --p2pool-miner-address 48tqgAhkjCnV2AUoTc5QztTrKSn1KVzvcHJ931sV2zWRG5MbMoipXAUBdY3JLn7SMRDLmTCCwa64ZHFqnThAwwzK1RhJM7W --p2pool-network nano
timeout /t 300 /nobreak > nul
goto loop
