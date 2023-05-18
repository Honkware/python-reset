# Find and uninstall Python installations from registry
$uninstallKeys = Get-ChildItem -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" -Recurse |
    ForEach-Object { Get-ItemProperty $_.PSPath } |
    Where-Object { $_.DisplayName -match "Python" }

foreach ($uninstallKey in $uninstallKeys) {
    $uninstallString = $uninstallKey.PSChildName
    if ($uninstallString) {
        Write-Host "Uninstalling $($uninstallKey.DisplayName)" -ForegroundColor Cyan
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $uninstallString /qn" -Wait
    }
}

# Remove Python directories manually
$pythonDirectories = Get-ChildItem -Path "C:\", "D:\", "E:\" -Directory -Recurse -Exclude "C:\Program Files\Windows Defender Advanced Threat Protection", "C:\Windows\CSC", "C:\Windows\System32\LogFiles\WMI\RtBackup" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "Python" -and $_.Name -notlike "*Python27-x64*" }

foreach ($directory in $pythonDirectories) {
    Write-Host "Removing $($directory.FullName)" -ForegroundColor Cyan
    Remove-Item -Path $directory.FullName -Recurse -Force -ErrorAction SilentlyContinue
}

# Find and remove pip and related files
$pipFiles = Get-ChildItem -Path "C:\", "D:\", "E:\" -Include "pip*", "easy_install*", "wheel" -File -Recurse -ErrorAction SilentlyContinue

foreach ($file in $pipFiles) {
    Write-Host "Removing $($file.FullName)" -ForegroundColor Cyan
    Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
}

# Clean up environment variables
$envVarsToRemove = @(
    "Path",
    "PYTHONPATH",
    "PYTHONSTARTUP",
    "PYTHONHOME",
    "PYTHONCASEOK",
    "PYTHONIOENCODING",
    "PY_HOME",
    "PY_PYTHON"
)

foreach ($envVar in $envVarsToRemove) {
    $currentValue = [System.Environment]::GetEnvironmentVariable($envVar, "Machine")
    $newValue = $currentValue -split ";" | Where-Object { $_ -notlike "*python*" } -join ";"
    [System.Environment]::SetEnvironmentVariable($envVar, $newValue, "Machine")
    Write-Host "Removed Python references from $envVar" -ForegroundColor Green
}

# Remove Python-related paths from PATH variable in user profiles
$userProfiles = Get-ChildItem -Path "C:\Users" -Directory -ErrorAction SilentlyContinue

foreach ($profile in $userProfiles) {
    $profilePath = Join-Path -Path $profile.FullName -ChildPath ".\AppData\Roaming\Python"
    if (Test-Path -Path $profilePath) {
        Write-Host "Removing Python references from PATH in user profile $($profile.Name)" -ForegroundColor Cyan
        $pathFile = Join-Path -Path $profilePath -ChildPath "pth"
        if (Test-Path -Path $pathFile) {
            $pathLines = Get-Content -Path $pathFile -ErrorAction SilentlyContinue
            $pathLines = $pathLines | Where-Object { $_ -notlike "*python*" }
            $pathLines | Set-Content -Path $pathFile -ErrorAction SilentlyContinue
        }
    }
}

# Restart computer
Write-Host "Please restart your computer to complete the uninstallation process." -ForegroundColor Cyan
