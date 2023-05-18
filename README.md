# Python Reset

A PowerShell script to uninstall and reinstall the latest stable version of Python on Windows.

**⚠️ Warning: This method might not be foolproof and could potentially remove other programs that have "Python" in their names. It's recommended to double-check the list of programs before proceeding.**

## Usage

1. Open PowerShell with administrator privileges.
2. Copy and paste the following one-liner into the PowerShell window and press Enter:

```powershell
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Python" } | ForEach-Object { $_.Uninstall() }; iwr -Uri "https://www.python.org/downloads/windows/" -OutFile "python-page.html"; $url = (Select-String -Path "python-page.html" -Pattern 'https:\/\/www\.python\.org\/ftp\/python\/\d+\.\d+\.\d+\/python-\d+\.\d+\.\d+-amd64\.exe' -AllMatches).Matches[0].Value; iwr -Uri $url -OutFile "python-installer.exe"; Start-Process -FilePath "python-installer.exe" -ArgumentList "/passive InstallAllUsers=1 PrependPath=1" -Wait; Remove-Item "python-installer.exe"; Remove-Item "python-page.html"
