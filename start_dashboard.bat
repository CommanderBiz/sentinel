@echo off
cd /d "C:\Users\comma\sentinel"
"C:\Users\comma\sentinel\venv\Scripts\python.exe" -m streamlit run app.py --server.address=0.0.0.0 --server.headless=true > "C:\Users\comma\sentinel\dashboard_service.log" 2>&1
pause
