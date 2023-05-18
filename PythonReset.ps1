# Uninstall existing Python installations
Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse | 
ForEach-Object { Get-ItemProperty $_.PSPath } | 
Where-Object { $_.DisplayName -match "Python" } | 
ForEach-Object { Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($_.PSChildName) /qn" -Wait }

# Download and install the latest Python version
iwr -Uri "https://www.python.org/downloads/windows/" -OutFile "python-page.html"
$url = (Select-String -Path "python-page.html" -Pattern 'https:\/\/www\.python\.org\/ftp\/python\/\d+\.\d+\.\d+\/python-\d+\.\d+\.\d+-amd64\.exe' -AllMatches).Matches[0].Value
iwr -Uri $url -OutFile "python-installer.exe"
Start-Process -FilePath "python-installer.exe" -ArgumentList "/passive InstallAllUsers=1 PrependPath=1" -Wait
Remove-Item "python-installer.exe"
Remove-Item "python-page.html"

# Refresh environment variables in the current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Test Python installation
$pythonExe = (Get-Command python).Source
$pythonVersion = & $pythonExe --version 2>&1
if ($pythonVersion -match "Python") {
    Write-Host "Python installation successful! Version: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "Python installation failed. Please try again or check the installation manually." -ForegroundColor Red
}
