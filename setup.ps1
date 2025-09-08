# Sports Hub v2 프로젝트 자동 설치 스크립트 (Windows PowerShell)
# 사용법: PowerShell에서 ./setup.ps1 실행

param(
    [string]$InstallPath = "sports-hub-v2"
)

Write-Host "🏈 Sports Hub v2 프로젝트 설치를 시작합니다..." -ForegroundColor Green
Write-Host "📍 설치 경로: $InstallPath" -ForegroundColor Blue

# Docker 설치 확인
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker 확인됨: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker가 설치되지 않았습니다. Docker Desktop을 먼저 설치해주세요." -ForegroundColor Red
    Write-Host "   다운로드: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Git 설치 확인
try {
    $gitVersion = git --version
    Write-Host "✅ Git 확인됨: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git이 설치되지 않았습니다. Git을 먼저 설치해주세요." -ForegroundColor Red
    Write-Host "   다운로드: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# 메인 디렉토리 생성
if (Test-Path $InstallPath) {
    Write-Host "⚠️  '$InstallPath' 디렉토리가 이미 존재합니다." -ForegroundColor Yellow
    $overwrite = Read-Host "덮어쓰시겠습니까? (y/N)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "❌ 설치가 취소되었습니다." -ForegroundColor Red
        exit 1
    }
    Remove-Item -Recurse -Force $InstallPath
}

New-Item -ItemType Directory -Name $InstallPath | Out-Null
Set-Location $InstallPath

Write-Host "`n📥 백엔드 서비스들을 다운로드합니다..." -ForegroundColor Blue

# GitHub 조직의 모든 리포지토리 클론
$repositories = @(
    @{name="backend-auth"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Backend-Auth.git"},
    @{name="backend-user"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Backend-User.git"},
    @{name="backend-team"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Backend-Team.git"},
    @{name="backend-recruit"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Backend-Recruit.git"},
    @{name="backend-notification"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Backend-Notification.git"},
    @{name="infra"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Infra.git"},
    @{name="frontend"; url="https://github.com/Sports-Hub-v2/Sports-Hub-Front.git"}
)

foreach ($repo in $repositories) {
    Write-Host "  📦 $($repo.name) 다운로드 중..." -ForegroundColor Cyan
    try {
        git clone $repo.url $repo.name --quiet
        Write-Host "    ✅ $($repo.name) 완료" -ForegroundColor Green
    } catch {
        Write-Host "    ❌ $($repo.name) 실패: $_" -ForegroundColor Red
    }
}

Write-Host "`n⚙️ 환경 설정을 준비합니다..." -ForegroundColor Blue

# 환경 설정 파일 확인 및 복사
if (Test-Path "infra/docker/.env.example") {
    Copy-Item "infra/docker/.env.example" "infra/docker/.env"
    Write-Host "  ✅ 환경 설정 파일(.env) 생성 완료" -ForegroundColor Green
    
    # 기본 설정값으로 일부 변경
    $envContent = Get-Content "infra/docker/.env" -Raw
    $envContent = $envContent -replace "changeme", "sportshub_root_2024"
    $envContent = $envContent -replace "sportshub123", "sportshub_secure_123"
    Set-Content "infra/docker/.env" $envContent
    
    Write-Host "  📝 기본 비밀번호가 설정되었습니다." -ForegroundColor Yellow
    Write-Host "     보안을 위해 실제 사용 시 비밀번호를 변경해주세요!" -ForegroundColor Yellow
} else {
    Write-Host "  ⚠️  환경 설정 파일을 찾을 수 없습니다." -ForegroundColor Yellow
}

Write-Host "`n🎉 설치가 완료되었습니다!" -ForegroundColor Green
Write-Host "`n📋 다음 단계:" -ForegroundColor Blue
Write-Host "  1. OAuth 설정 (선택사항):" -ForegroundColor White
Write-Host "     - infra/docker/.env 파일 열기" -ForegroundColor Gray
Write-Host "     - Google/Naver OAuth 클라이언트 ID/Secret 입력" -ForegroundColor Gray
Write-Host "`n  2. 백엔드 서비스 실행:" -ForegroundColor White
Write-Host "     cd infra/docker" -ForegroundColor Yellow
Write-Host "     docker compose up -d --build" -ForegroundColor Yellow
Write-Host "`n  3. 프론트엔드 실행:" -ForegroundColor White
Write-Host "     cd frontend" -ForegroundColor Yellow
Write-Host "     npm install" -ForegroundColor Yellow
Write-Host "     npm run dev" -ForegroundColor Yellow
Write-Host "`n  4. 접속 확인:" -ForegroundColor White
Write-Host "     - 프론트엔드: http://localhost:5173" -ForegroundColor Gray
Write-Host "     - API 서비스들: http://localhost:8081~8085/ping" -ForegroundColor Gray

Write-Host "`n💡 팁: 'docker compose logs -f [서비스명]'으로 로그를 확인할 수 있습니다." -ForegroundColor Cyan
Write-Host "예시: docker compose logs -f auth-service" -ForegroundColor Cyan

Write-Host "`n🔧 설치 경로: $(Get-Location)" -ForegroundColor Blue
