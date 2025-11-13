# 🚀 Sports Hub v2 Infra 사용 가이드

**최종 업데이트**: 2025-11-08

## 📊 시스템 구조

### 데이터베이스 아키텍처

**모놀리식 통합 DB**
```
sportshub_db (1개 통합 데이터베이스)
├── 27개 테이블 (23개 → 27개로 확장)
├── 30+ 외래키
├── 60+ 인덱스
└── FULLTEXT 검색 지원
```

**변경 이유:**
- 외래키 제약조건 지원
- JOIN 쿼리 가능
- 관리자 페이지 통합 쿼리 필요

**최근 변경 (2025-11-08):**
- ✅ rival_teams JSON → `team_rivals` 중간 테이블 정규화
- ✅ `team_notices` 테이블 추가
- ✅ Flyway 비활성화 (MySQL init scripts 사용)

---

## 🚀 즉시 시작하기

### 1. Docker Desktop 실행

Windows 시작 메뉴 → Docker Desktop 실행

### 2. 컨테이너 시작

```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker
docker compose down -v   # 기존 삭제
docker compose up -d     # 새로 시작
```

### 3. 초기화 확인

자동 실행되는 스크립트:
1. `01_create_database.sql` - sportshub_db 생성
2. `02_create_tables.sql` - **27개 테이블 생성**

### 4. 접속 테스트

```powershell
# 백엔드 서비스 헬스체크
Invoke-WebRequest -Uri http://localhost:8081/ping  # auth ✅
Invoke-WebRequest -Uri http://localhost:8082/ping  # user ✅
Invoke-WebRequest -Uri http://localhost:8083/ping  # team ✅
Invoke-WebRequest -Uri http://localhost:8084/ping  # recruit ✅
Invoke-WebRequest -Uri http://localhost:8085/ping  # notification ✅

# MySQL 접속
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw

# MySQL 프롬프트에서:
# USE sportshub_db;
# SHOW TABLES;  -- 27개 확인
# SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='sportshub_db';
```

---

## 📊 데이터베이스 구조

### 27개 테이블 요약

| 도메인 | 테이블 수 | 테이블명 |
|--------|----------|---------|
| 인증/계정 | 2 | accounts, refresh_tokens |
| 사용자 | 3 | profiles, user_stats_summary, user_activity_logs |
| 팀 | 5 | teams, team_memberships, **team_rivals**, team_activity_logs, **team_notices** |
| 콘텐츠 | 5 | posts, comments, applications, notifications, post_edit_history |
| 경기 | 4 | matches, match_lineups, match_management_logs, match_notes |
| 신고/제재 | 3 | reports, report_evidences, sanctions |
| 평가 | 1 | peer_surveys |
| 관리 | 1 | admin_action_logs |
| 기타 | 1 | venues |

**총 27개** (기존 23개 + 신규 4개)

**상세 문서:** `docs/DATABASE_SCHEMA_FINAL.md`

---

## 🛠️ 일상적인 관리

### 서비스 관리

```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 시작
docker compose up -d

# 중지
docker compose down

# 중지 + DB 초기화 (주의!)
docker compose down -v

# 재시작
docker compose restart

# 특정 서비스만 재시작
docker compose restart auth-service

# 상태 확인
docker compose ps

# 로그 확인
docker compose logs -f
docker compose logs -f auth-service
```

### 데이터베이스 관리

```powershell
# MySQL 접속
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw

# MySQL 프롬프트에서:
# USE sportshub_db;
# SHOW TABLES;
# DESCRIBE teams;
# DESCRIBE team_rivals;
# SELECT * FROM accounts LIMIT 10;
# SELECT * FROM team_rivals;
```

### 백업 및 복원

```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 데이터베이스 백업
docker exec sportshub-mysql mysqldump -u sportshub -psportshub_pw sportshub_db > backup.sql

# 데이터베이스 복원
Get-Content backup.sql | docker exec -i sportshub-mysql mysql -u sportshub -psportshub_pw sportshub_db
```

---

## 🔧 트러블슈팅

### MySQL 컨테이너가 시작되지 않을 때

```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 로그 확인
docker compose logs mysql

# 볼륨 삭제 후 재시작
docker compose down -v
docker compose up -d
```

### 백엔드 서비스가 시작되지 않을 때

```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 특정 서비스 로그 확인
docker compose logs auth-service --tail 100

# 서비스 재빌드
docker compose up -d --build auth-service
```

### 포트 충돌 문제

```powershell
# 사용 중인 포트 확인
netstat -ano | findstr :8081
netstat -ano | findstr :3306

# PowerShell 방식
Get-NetTCPConnection -LocalPort 8081,3306

# Docker 컨테이너 중지
cd C:\github\fixproject\sports-hub-v2\infra\docker
docker compose down
```

---

## 📝 환경 변수 (.env)

현재 설정:
```bash
# MySQL
MYSQL_ROOT_PASSWORD=changeme
MYSQL_USER=sportshub
MYSQL_PASSWORD=sportshub_pw

# DataSource
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/sportshub_db

# JWT
AUTH_JWT_EXPIRE_MS=900000         # 15분
AUTH_REFRESH_EXPIRE_MS=604800000  # 7일

# OAuth2 (비활성화)
# 주석 처리됨
```

---

## 🎯 API 테스트

### 회원가입
```powershell
$body = @{
    email = "test@example.com"
    password = "test1234"
    role = "USER"
    userid = "testuser"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8081/api/auth/accounts" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### 로그인 (Email)
```powershell
$body = @{
    loginId = "test@example.com"
    password = "test1234"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8081/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### 로그인 (UserID)
```powershell
$body = @{
    loginId = "testuser"
    password = "test1234"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8081/api/auth/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

---

## 📚 관련 문서

- **docs/PROJECT_STATUS.md** - 프로젝트 현황
- **docs/claudegem.md** - DB 평가 보고서
- **docs/DATABASE_SCHEMA_FINAL.md** - DB 스키마 상세
- **infra/README.md** - 인프라 개요
- **infra/USAGE.md** - 사용법 (현재 문서)

---

**작성일:** 2025-10-31  
**최종 업데이트:** 2025-11-08  
**버전:** 2.1
