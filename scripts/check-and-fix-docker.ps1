<#
check-and-fix-docker.ps1

Safe diagnostic and helper script to check Docker status on Windows and attempt common fixes.
Run in PowerShell (preferably as Administrator for service start/stop operations):

    # To run in current session (unblocked):
    .\scripts\check-and-fix-docker.ps1

What it does:
- Shows Docker-related environment variables
- Checks for Docker service `com.docker.service` and attempts to start it
- Attempts to start Docker Desktop.exe if it's installed and not running
- Re-checks `docker version` and `docker info` and reports the outcome

This script does not change persistent user environment variables except when trying to remove DOCKER_HOST from the current session.
#>

function Write-Title($t){
    Write-Host "`n=== $t ===" -ForegroundColor Cyan
}

# Show DOCKER-related environment variables
Write-Title "Docker-related environment variables"
Get-ChildItem Env: | Where-Object { $_.Name -match 'DOCKER' } | ForEach-Object { "{0}={1}" -f $_.Name, $_.Value }

# Unset DOCKER_HOST for the current session if it's set to a named pipe or unexpected value
if ($env:DOCKER_HOST) {
    Write-Host "Found DOCKER_HOST: $env:DOCKER_HOST" -ForegroundColor Yellow
    Write-Host "Unsetting DOCKER_HOST for this session to try local engine..."
    Remove-Item Env:\DOCKER_HOST -ErrorAction SilentlyContinue
} else {
    Write-Host "DOCKER_HOST not set in this session." -ForegroundColor Green
}

# Check Docker service
Write-Title "Docker service status"
$svc = Get-Service -Name com.docker.service -ErrorAction SilentlyContinue
if ($null -eq $svc) {
    Write-Host "Service 'com.docker.service' not found. Docker Desktop may not be installed." -ForegroundColor Yellow
} else {
    Write-Host "Service 'com.docker.service' status: $($svc.Status)" -ForegroundColor Cyan
    if ($svc.Status -ne 'Running') {
        Write-Host "Attempting to start 'com.docker.service' (requires admin)..." -ForegroundColor Yellow
        try {
            Start-Service -Name com.docker.service -ErrorAction Stop
            Write-Host "Service started." -ForegroundColor Green
        } catch {
            Write-Host "Failed to start service. Try running this script as Administrator or start Docker Desktop from the Start menu." -ForegroundColor Red
        }
    }
}

# Check for Docker Desktop process
Write-Title "Docker Desktop process"
$ddProc = Get-Process -Name 'Docker Desktop' -ErrorAction SilentlyContinue
if ($null -ne $ddProc) {
    Write-Host "Docker Desktop process is running (Id=$($ddProc.Id))." -ForegroundColor Green
} else {
    Write-Host "Docker Desktop process not found. Attempting to start Docker Desktop if installed..." -ForegroundColor Yellow
    # Try common install paths
    $candidates = @(
        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$Env:ProgramFiles(x86)\Docker\Docker\Docker Desktop.exe"
    )
    $started = $false
    foreach ($path in $candidates) {
        if (Test-Path $path) {
            Write-Host "Found Docker Desktop at: $path" -ForegroundColor Cyan
            try {
                Start-Process -FilePath $path -WindowStyle Hidden
                Write-Host "Launched Docker Desktop. It may take 10-30s to initialize." -ForegroundColor Green
                $started = $true
                break
            } catch {
                Write-Host "Failed to launch $path : $_" -ForegroundColor Red
            }
        }
    }
    if (-not $started) {
        Write-Host "Could not find Docker Desktop executable in standard locations. Please start Docker Desktop from Start Menu or reinstall Docker Desktop." -ForegroundColor Yellow
    }
}

# Wait and poll Docker CLI for up to 60s
Write-Title "Polling Docker CLI (waiting up to 60s)"
$timeout = 60
$end = (Get-Date).AddSeconds($timeout)
$ok = $false
while ((Get-Date) -lt $end) {
    try {
        $ver = docker version --format '{{.Server.Version}}' 2>$null
        if ($LASTEXITCODE -eq 0 -or $ver) {
            Write-Host "Docker daemon is reachable. Server version: $ver" -ForegroundColor Green
            $ok = $true
            break
        }
    } catch {
        # swallow
    }
    Start-Sleep -Seconds 2
}

if (-not $ok) {
    Write-Host "Docker daemon is still not reachable. Final 'docker info' output (if any):" -ForegroundColor Red
    try {
        docker info
    } catch {
        Write-Host "docker info failed or returned no output. Review Docker Desktop or service logs and ensure Docker is installed and running." -ForegroundColor Red
    }
    Write-Host "Common fixes:" -ForegroundColor Cyan
    Write-Host " - Start Docker Desktop from the Start Menu and wait until it says 'Docker is running'." -ForegroundColor White
    Write-Host " - Ensure WSL2 backend is enabled if using WSL (Docker Desktop settings -> Resources -> WSL Integration)." -ForegroundColor White
    Write-Host " - If DOCKER_HOST was set globally to a remote engine, remove or update it in System Environment Variables." -ForegroundColor White
    Write-Host " - Check Windows Services: if 'com.docker.service' exists, try starting it as Administrator." -ForegroundColor White
    Write-Host " - Reboot Windows if Docker Desktop installation was just completed or if services are in inconsistent state." -ForegroundColor White
} else {
    Write-Host "Docker CLI can reach the daemon. You can now run 'docker-compose up' or 'docker run'." -ForegroundColor Green
}

Write-Title "End of script"

