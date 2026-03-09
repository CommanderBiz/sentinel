@echo off
cd /d "%~dp0"
python -m streamlit run app.py --server.address=0.0.0.0 --server.headless=true > dashboard_service.log 2>&1
pause
