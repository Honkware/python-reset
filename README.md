# Python Reset

A PowerShell script to uninstall and reinstall the latest stable version of Python on Windows.

**⚠️ Warning: This method might not be foolproof and could potentially remove other programs that have "Python" in their names. It's recommended to double-check the list of programs before proceeding.**

## Usage

1. Open PowerShell with administrator privileges.
2. Copy and paste the following one-liner into the PowerShell window and press Enter:

```powershell
iwr -Uri "https://raw.githubusercontent.com/Honkware/python-reset/main/PythonReset.ps1" -OutFile "PythonReset.ps1"; .\PythonReset.ps1; Remove-Item "PythonReset.ps1"
