Invoke-WebRequest -Uri https://raw.githubusercontent.com/Noson5434/Windows-Network-Reset/main/code/Reset.bat -OutFile C:\Windows\Temp\NetworkReset.bat
Start-Process C:\Windows\Temp\NetworkReset.bat
exit