<#
  One-click dev runner for Sports Hub v2 (Windows PowerShell)
  - Ensures .env exists (copies from .env.example if missing)
  - Boots docker compose (MySQL + services)
  - Waits for health (MySQL + /ping endpoints)
  - Conditionally seeds test data if not present
  - Prints summary and quick commands

  Usage:
    pwsh -File ./infra/start.ps1
    # or in PowerShell
    ./infra/start.ps1
#>

param(
  [switch]$Rebuild = $false,
  [int]$TimeoutSec = 180
)

$ErrorActionPreference = 'Stop'

function Write-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Ok($msg)    { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Paths
$RepoRoot   = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$InfraRoot  = Join-Path $RepoRoot 'infra'
$DockerDir  = Join-Path $InfraRoot 'docker'
$EnvFile    = Join-Path $DockerDir '.env'
$EnvExample = Join-Path $DockerDir '.env.example'

Write-Info "Sports Hub v2 — Start (one-click)"

# 1) Sanity checks: Docker & Compose
try { docker version | Out-Null } catch { Write-Err "Docker is not installed or not running."; exit 1 }
try { docker compose version | Out-Null } catch { Write-Err "Docker Compose v2 not found."; exit 1 }

# 2) Ensure .env exists
if (-not (Test-Path $EnvFile)) {
  if (-not (Test-Path $EnvExample)) { Write-Err ".env and .env.example not found"; exit 1 }
  Copy-Item $EnvExample $EnvFile -Force
  Write-Ok ".env created from .env.example"

  # Generate JWT secret if placeholder is present
  $lines = Get-Content $EnvFile
  for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].StartsWith('AUTH_JWT_SECRET=')) {
      if ($lines[$i] -match 'your-super-secret') {
        $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
        $bytes = New-Object byte[] 48
        $rng.GetBytes($bytes)
        $secret = [Convert]::ToBase64String($bytes).TrimEnd('=')
        $lines[$i] = "AUTH_JWT_SECRET=$secret"
        Write-Ok "AUTH_JWT_SECRET generated"
      }
    }
  }
  Set-Content -Path $EnvFile -Value $lines -Encoding UTF8
}

Push-Location $DockerDir

# 3) Compose up
Write-Info "Starting containers..."
$composeArgs = @('up','-d')
if ($Rebuild) { $composeArgs += '--build' }
docker compose @composeArgs

# 4) Wait for MySQL healthy
Write-Info "Waiting for MySQL (health=healthy)..."
$deadline = (Get-Date).AddSeconds($TimeoutSec)
do {
  Start-Sleep -Seconds 3
  $state = docker inspect --format '{{.State.Health.Status}}' sportshub-mysql 2>$null
  if ($state -eq 'healthy') { break }
} while ((Get-Date) -lt $deadline)

if ($state -ne 'healthy') { Write-Err "MySQL not healthy in time"; Pop-Location; exit 1 }
Write-Ok "MySQL is healthy"

# 5) Wait for service /ping endpoints
$pingTargets = @(
  @{ Name='auth'; Url='http://localhost:8081/ping' },
  @{ Name='user'; Url='http://localhost:8082/ping' },
  @{ Name='team'; Url='http://localhost:8083/ping' },
  @{ Name='recruit'; Url='http://localhost:8084/ping' },
  @{ Name='notification'; Url='http://localhost:8085/ping' }
)
foreach ($t in $pingTargets) {
  Write-Info "Waiting for $($t.Name): $($t.Url)"
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  $ready = $false
  while ((Get-Date) -lt $deadline) {
    try { $res = Invoke-WebRequest -Uri $t.Url -Method GET -UseBasicParsing -TimeoutSec 5; if ($res.StatusCode -eq 200) { $ready = $true; break } } catch {}
    Start-Sleep -Seconds 2
  }
  if (-not $ready) { Write-Err "$($t.Name) not ready"; Pop-Location; exit 1 }
  Write-Ok "$($t.Name) is up"
}

# 6) Decide whether to seed
Write-Info "Checking seed existence (user1@example.com)"
$seedNeeded = $true
try { $check = Invoke-WebRequest -Uri 'http://localhost:8081/api/auth/accounts?email=user1@example.com' -Method GET -UseBasicParsing -TimeoutSec 5; if ($check.StatusCode -eq 200) { $seedNeeded = $false } } catch { $seedNeeded = $true }

if ($seedNeeded) {
  Write-Info "Seeding dev data..."
  Pop-Location
  $seedScript = Join-Path $InfraRoot 'seed/seed-dev.ps1'
  if (-not (Test-Path $seedScript)) { Write-Err "Seed script not found: $seedScript"; exit 1 }
  & $seedScript
  if ($LASTEXITCODE -ne 0) { Write-Err "Seeding failed"; exit 1 }
  Write-Ok "Seeding completed"
} else {
  Pop-Location
  Write-Ok "Seed already present. Skipping"
}

# 7) Summary
Write-Host ""; Write-Ok "All services are up. Quick links:"
Write-Host "  Frontend (dev):   http://localhost:5173/"
Write-Host "  Auth ping:        http://localhost:8081/ping"
Write-Host "  User ping:        http://localhost:8082/ping"
Write-Host "  Team ping:        http://localhost:8083/ping"
Write-Host "  Recruit ping:     http://localhost:8084/ping"
Write-Host "  Notification ping:http://localhost:8085/ping"
Write-Host ""
Write-Info "Container management:"
Write-Host "  cd infra/docker"
Write-Host "  docker compose ps"
Write-Host "  docker compose logs -f"
Write-Host "  docker compose stop"
Write-Host "  docker compose down -v   # reset volumes (will re-seed on next start)"
Write-Host ""
Write-Ok "Done."

