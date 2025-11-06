#!/usr/bin/env bash
set -euo pipefail

# Sports Hub v2 Quick Start Script (모놀리식 DB 버전)
# 용도: Docker Compose 시작 및 헬스체크

REBUILD=false
TIMEOUT_SEC=180

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--rebuild) REBUILD=true; shift ;;
    -t|--timeout) TIMEOUT_SEC="${2:-180}"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/docker"
ENV_FILE="$DOCKER_DIR/.env"
ENV_EXAMPLE="$DOCKER_DIR/.env.example"

info() { echo -e "\033[36m[INFO]\033[0m  $*"; }
ok()   { echo -e "\033[32m[OK]\033[0m    $*"; }
err()  { echo -e "\033[31m[ERROR]\033[0m $*"; }

# Docker 확인
if ! command -v docker >/dev/null 2>&1; then
  err "Docker not found. Please install Docker Desktop."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  err "Docker Compose v2 not found."
  exit 1
fi

# .env 파일 확인
if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$ENV_EXAMPLE" ]]; then
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    ok ".env created from .env.example"
    
    # JWT Secret 자동 생성
    if grep -q '^AUTH_JWT_SECRET=your-super-secret' "$ENV_FILE"; then
      SECRET="$(openssl rand -base64 48 | tr -d '=' | tr '+/' '-_')"
      if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s|^AUTH_JWT_SECRET=.*$|AUTH_JWT_SECRET=${SECRET}|" "$ENV_FILE"
      else
        sed -i "s|^AUTH_JWT_SECRET=.*$|AUTH_JWT_SECRET=${SECRET}|" "$ENV_FILE"
      fi
      ok "AUTH_JWT_SECRET generated"
    fi
  else
    err ".env.example not found in $DOCKER_DIR"
    exit 1
  fi
fi

# Docker Compose 시작
cd "$DOCKER_DIR"
info "Starting containers..."
if [[ "$REBUILD" == true ]]; then
  docker compose up -d --build
else
  docker compose up -d
fi

# MySQL 헬스체크
info "Waiting for MySQL (health=healthy)..."
DEADLINE=$(( $(date +%s) + TIMEOUT_SEC ))
while true; do
  STATE="$(docker inspect --format '{{.State.Health.Status}}' sportshub-mysql 2>/dev/null || echo "")"
  [[ "$STATE" == "healthy" ]] && break
  [[ $(date +%s) -ge $DEADLINE ]] && { err "MySQL not healthy in time"; exit 1; }
  sleep 3
done
ok "MySQL is healthy"

# 백엔드 서비스 헬스체크
PING_TARGETS=(
  "auth:http://localhost:8081/ping"
  "user:http://localhost:8082/ping"
  "team:http://localhost:8083/ping"
  "recruit:http://localhost:8084/ping"
  "notification:http://localhost:8085/ping"
)

for T in "${PING_TARGETS[@]}"; do
  NAME="${T%%:*}"; URL="${T#*:}"
  info "Waiting for $NAME: $URL"
  DEADLINE=$(( $(date +%s) + TIMEOUT_SEC ))
  READY=false
  while true; do
    if curl -fsS "$URL" >/dev/null 2>&1; then READY=true; break; fi
    [[ $(date +%s) -ge $DEADLINE ]] && break
    sleep 2
  done
  [[ "$READY" == true ]] || { err "$NAME not ready"; exit 1; }
  ok "$NAME is up"
done

ok "All services are up!"
echo ""
echo "✅ Infrastructure ready:"
echo "   - MySQL: sportshub_db (23 tables)"
echo "   - Auth:   http://localhost:8081"
echo "   - User:   http://localhost:8082"
echo "   - Team:   http://localhost:8083"
echo "   - Recruit: http://localhost:8084"
echo "   - Notification: http://localhost:8085"
echo ""
echo "📝 Next steps:"
echo "   1. Run frontend: cd frontend && npm install && npm run dev"
echo "   2. Run admin:    cd admin && npm install && npm run dev"
echo "   3. Access:       http://localhost:5173 (user)"
echo "                    http://localhost:5174 (admin)"
echo ""
echo "📚 Docs: docs/DATABASE_SCHEMA_FINAL.md"
