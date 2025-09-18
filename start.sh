#!/usr/bin/env bash
set -euo pipefail

# One-click dev runner for Sports Hub v2 (macOS/Linux)
# - Ensures .env exists (copies from .env.example if missing)
# - Boots docker compose (MySQL + services)
# - Waits for health (MySQL + /ping endpoints)
# - Conditionally seeds test data if not present

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
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKER_DIR="$SCRIPT_DIR/docker"
ENV_FILE="$DOCKER_DIR/.env"
ENV_EXAMPLE="$DOCKER_DIR/.env.example"

info() { echo -e "\033[36m[INFO]\033[0m  $*"; }
ok()   { echo -e "\033[32m[OK]\033[0m    $*"; }
err()  { echo -e "\033[31m[ERROR]\033[0m $*"; }

if ! command -v docker >/dev/null 2>&1; then err "Docker not found"; exit 1; fi
if ! docker compose version >/dev/null 2>&1; then err "Docker Compose v2 not found"; exit 1; fi

if [[ ! -f "$ENV_FILE" ]]; then
  [[ -f "$ENV_EXAMPLE" ]] || { err ".env.example missing in $DOCKER_DIR"; exit 1; }
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  ok ".env created from .env.example"
  if grep -q '^AUTH_JWT_SECRET=your-super-secret' "$ENV_FILE"; then
    # generate 48 bytes url-safe secret
    SECRET="$(openssl rand -base64 48 | tr -d '=' | tr '+/' '-_')"
    sed -i.bak "s|^AUTH_JWT_SECRET=.*$|AUTH_JWT_SECRET=${SECRET}|" "$ENV_FILE" && rm -f "$ENV_FILE.bak"
    ok "AUTH_JWT_SECRET generated"
  fi
fi

cd "$DOCKER_DIR"
info "Starting containers..."
if [[ "$REBUILD" == true ]]; then
  docker compose up -d --build
else
  docker compose up -d
fi

info "Waiting for MySQL (health=healthy)..."
DEADLINE=$(( $(date +%s) + TIMEOUT_SEC ))
while true; do
  STATE="$(docker inspect --format '{{.State.Health.Status}}' sportshub-mysql 2>/dev/null || echo "")"
  [[ "$STATE" == "healthy" ]] && break
  [[ $(date +%s) -ge $DEADLINE ]] && { err "MySQL not healthy in time"; exit 1; }
  sleep 3
done
ok "MySQL is healthy"

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

info "Checking seed existence (user1@example.com)"
if curl -fsS "http://localhost:8081/api/auth/accounts?email=user1@example.com" >/dev/null 2>&1; then
  ok "Seed present. Skipping"
else
  info "Seeding dev data..."
  bash "$SCRIPT_DIR/seed/seed-dev.sh"
  ok "Seeding completed"
fi

ok "All services are up."
echo "  Frontend (dev):    http://localhost:5173/"
echo "  Auth ping:         http://localhost:8081/ping"
echo "  User ping:         http://localhost:8082/ping"
echo "  Team ping:         http://localhost:8083/ping"
echo "  Recruit ping:      http://localhost:8084/ping"
echo "  Notification ping: http://localhost:8085/ping"

