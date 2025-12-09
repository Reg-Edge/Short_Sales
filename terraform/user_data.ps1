# user_data.ps1
# PowerShell script to install Power BI Desktop silently
# See: https://www.appdeploynews.com/app-tips/microsoft-powerbi-desktop-2-130-754-0/

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$dest = "C:\\Temp\\PBIDesktopSetup_x64.exe"
$pbid_url = "${env:PBID_URL}"
if (-not $pbid_url) { $pbid_url = "https://download.microsoft.com/download/1/2/3/12345678-abcd-1234-abcd-1234567890ab/PBIDesktopSetup_x64.exe" }

New-Item -Path "C:\\Temp" -ItemType Directory -Force | Out-Null
Invoke-WebRequest -Uri $pbid_url -OutFile $dest
Start-Process -FilePath $dest -ArgumentList "-quiet -norestart ACCEPT_EULA=1 INSTALLDESKTOPSHORTCUT=0 DISABLE_UPDATE_NOTIFICATION=1" -Wait
