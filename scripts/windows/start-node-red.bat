@echo off
title Node-RED - IoT project
echo Dang khoi dong Node-RED... (dong cua so nay se tat Node-RED)
echo Giao dien: http://localhost:8800/dashboard.html
cd /d "%USERPROFILE%"
call node-red -p 8800
pause
