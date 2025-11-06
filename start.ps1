<#
  Sports Hub v2 Quick Start (Windows PowerShell)
  모놀리식 DB 버전 (2025-10-31)
  
  - .env 파일 자동 생성 및 JWT Secret 생성
  - Docker Compose 실행 (MySQL + 5개 백엔드 서비스)
  - 헬스체크 (MySQL healthy + /ping 엔드포인트)
  - 샘플 데이터 자동 삽입 (선택사항)
  
  데이터베이스: sportshub_db (통합 DB, 23개 테이블)

  Usage:
    pwsh -File ./infra/start.ps1
    pwsh -File ./infra/start.ps1 -Rebuild
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

Write-Host ""
Write-Info "Sports Hub v2 Quick Start (Monolithic DB)"
Write-Host ""

# 1) Docker 확인
try { docker version | Out-Null } catch { Write-Err "Docker is not installed or not running."; exit 1 }
try { docker compose version | Out-Null } catch { Write-Err "Docker Compose v2 not found."; exit 1 }

# 2) .env 파일 생성
if (-not (Test-Path $EnvFile)) {
  if (-not (Test-Path $EnvExample)) { Write-Err ".env and .env.example not found in $DockerDir"; exit 1 }
  Copy-Item $EnvExample $EnvFile -Force
  Write-Ok ".env created from .env.example"

  # JWT Secret 자동 생성
  $lines = Get-Content $EnvFile
  for ($i=0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].StartsWith('AUTH_JWT_SECRET=')) {
      if ($lines[$i] -match 'your-super-secret') {
        $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
        $bytes = New-Object byte[] 48
        $rng.GetBytes($bytes)
        $secret = [Convert]::ToBase64String($bytes).Replace('=','').Replace('+','-').Replace('/','_')
        $lines[$i] = "AUTH_JWT_SECRET=$secret"
        Write-Ok "AUTH_JWT_SECRET generated (256-bit)"
      }
    }
  }
  Set-Content -Path $EnvFile -Value $lines -Encoding UTF8
}

Push-Location $DockerDir

# 3) Docker Compose 시작
Write-Info "Starting containers..."
$composeArgs = @('up','-d')
if ($Rebuild) { $composeArgs += '--build' }
docker compose @composeArgs

# 4) MySQL 헬스체크
Write-Info "Waiting for MySQL (health=healthy)..."
$deadline = (Get-Date).AddSeconds($TimeoutSec)
do {
  Start-Sleep -Seconds 3
  $state = docker inspect --format '{{.State.Health.Status}}' sportshub-mysql 2>$null
  if ($state -eq 'healthy') { break }
} while ((Get-Date) -lt $deadline)

if ($state -ne 'healthy') { Write-Err "MySQL not healthy in time"; Pop-Location; exit 1 }
Write-Ok "MySQL is healthy (sportshub_db with 23 tables)"

# 5) 백엔드 서비스 헬스체크
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
    try { 
      $res = Invoke-WebRequest -Uri $t.Url -Method GET -UseBasicParsing -TimeoutSec 5
      if ($res.StatusCode -eq 200) { $ready = $true; break }
    } catch {}
    Start-Sleep -Seconds 2
  }
  if (-not $ready) { Write-Err "$($t.Name) not ready"; Pop-Location; exit 1 }
  Write-Ok "$($t.Name) is up"
}

Pop-Location

# 6) 샘플 데이터 확인 (선택사항)
Write-Info "Checking if seed data is needed..."
$seedNeeded = $true
try { 
  $check = Invoke-WebRequest -Uri 'http://localhost:8081/api/auth/accounts?email=user1@sportshub.com' -Method GET -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
  if ($check.StatusCode -eq 200) { $seedNeeded = $false }
} catch { $seedNeeded = $true }

if ($seedNeeded) {
  Write-Info "Seeding dev data (optional - you can skip this)..."
  $seedScript = Join-Path $InfraRoot 'seed/seed-dev.ps1'
  if (Test-Path $seedScript) {
    try {
      & $seedScript
      if ($LASTEXITCODE -eq 0) {
        Write-Ok "Seeding completed"
      } else {
        Write-Warn "Seeding failed (non-critical)"
      }
    } catch {
      Write-Warn "Seeding failed: $($_.Exception.Message)"
    }
  } else {
    Write-Warn "Seed script not found: $seedScript (skip)"
  }
} else {
  Write-Ok "Seed data already present. Skipping."
}

# 7) 최종 요약
Write-Host ""
Write-Ok "Infrastructure is ready!"
Write-Host ""
Write-Host "DATABASE:" -ForegroundColor Yellow
Write-Host "  - sportshub_db (MySQL 8.0)"
Write-Host "  - 23 tables (unified schema)"
Write-Host "  - 30+ foreign keys"
Write-Host ""
Write-Host "BACKEND SERVICES:" -ForegroundColor Yellow
Write-Host "  - Auth:         http://localhost:8081"
Write-Host "  - User:         http://localhost:8082"
Write-Host "  - Team:         http://localhost:8083"
Write-Host "  - Recruit:      http://localhost:8084"
Write-Host "  - Notification: http://localhost:8085"
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Run frontend:  cd frontend && npm install && npm run dev"
Write-Host "  2. Run admin:     cd admin && npm install && npm run dev"
Write-Host "  3. Access:        http://localhost:5173 (user)"
Write-Host "                    http://localhost:5174 (admin)"
Write-Host ""
Write-Host "DOCS:" -ForegroundColor Yellow
Write-Host "  - docs/DATABASE_SCHEMA_FINAL.md (1,622 lines)"
Write-Host "  - docs/TABLE_USAGE_MAPPING.md"
Write-Host ""
Write-Host "MANAGEMENT:" -ForegroundColor Yellow
Write-Host "  cd infra/docker"
Write-Host "  docker compose ps             # Check status"
Write-Host "  docker compose logs -f        # View logs"
Write-Host "  docker compose restart        # Restart all"
Write-Host "  docker compose down -v        # Reset (delete volumes)"
Write-Host ""
Write-Ok "Done! Happy coding!"
Write-Host ""
