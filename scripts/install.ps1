# Memlog Windows Installer
# Run with: iwr -useb https://raw.githubusercontent.com/RuturajS/memlog/main/scripts/install.ps1 | iex

$ErrorActionPreference = "Stop"

Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║     Memlog Installer v1.0.0          ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Detect architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
Write-Host "Detected Architecture: $arch" -ForegroundColor Yellow
Write-Host ""

# GitHub release URL
$githubUser = "RuturajS"
$repo = "memlog"
$version = "latest"
$binaryName = "memlog-windows-$arch.exe"

if ($version -eq "latest") {
    $downloadUrl = "https://github.com/$githubUser/$repo/releases/latest/download/$binaryName"
} else {
    $downloadUrl = "https://github.com/$githubUser/$repo/releases/download/$version/$binaryName"
}

# Create temp directory
$tempDir = [System.IO.Path]::GetTempPath()
$tempFile = Join-Path $tempDir "memlog.exe"

Write-Host "Downloading memlog..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
} catch {
    Write-Host "Error downloading memlog: $_" -ForegroundColor Red
    exit 1
}

# Install directory
$installDir = "$env:LOCALAPPDATA\memlog"
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

$installPath = Join-Path $installDir "memlog.exe"
Move-Item -Path $tempFile -Destination $installPath -Force

Write-Host "✓ Installed to $installPath" -ForegroundColor Green

# Add to PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    $env:Path = "$env:Path;$installDir"
    Write-Host "✓ Added to PATH" -ForegroundColor Green
}

# Create log directory
$logDir = "$env:USERPROFILE\.memlog\logs"
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
Write-Host "✓ Created log directory" -ForegroundColor Green

# Add PowerShell profile hook
$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

$hookCode = @'

# Memlog hook
function Invoke-MemlogHook {
    param($Command)
    if ($Command -and $Command -notlike "*memlog*") {
        Start-Job -ScriptBlock {
            param($cmd)
            & memlog exec $cmd
        } -ArgumentList $Command | Out-Null
    }
}

# Note: PowerShell doesn't have a direct preexec equivalent
# Users should manually wrap commands: memlog exec "your-command"
'@

if (!(Get-Content $profilePath -Raw -ErrorAction SilentlyContinue | Select-String "Invoke-MemlogHook")) {
    Add-Content -Path $profilePath -Value $hookCode
    Write-Host "✓ Added hook to PowerShell profile" -ForegroundColor Green
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Installation Complete! 🎉          ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  memlog exec 'your command'  - Execute and log a command"
Write-Host "  memlog logs --last 10       - View last 10 commands"
Write-Host "  memlog stats                - View statistics"
Write-Host "  memlog report               - Generate HTML report"
Write-Host ""
Write-Host "Restart PowerShell or run:" -ForegroundColor Yellow
Write-Host "  . `$PROFILE"
Write-Host ""
