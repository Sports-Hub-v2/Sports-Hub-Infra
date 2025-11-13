# ⚡ Sports Hub v2 빠른 시작 가이드

**최종 업데이트**: 2025-11-13

이 문서는 혼란을 줄이기 위한 **단순하고 명확한** 실행 가이드입니다.

---

## 🎯 당신이 원하는 것

- [ ] 처음 실행하기
- [ ] 코드 수정 후 재시작하기
- [ ] 데이터만 초기화하기
- [ ] 완전히 처음부터 시작하기

---

## 1️⃣ 처음 실행하기

### 전제 조건
- Docker Desktop 설치 및 실행 중
- PowerShell (Windows 기본 제공)

### 실행 명령

```powershell
# 프로젝트 루트에서
cd C:\github\fixproject\sports-hub-v2\infra
pwsh -File start.ps1
```

**자동으로 실행되는 것들**:
1. ✅ .env 파일 생성 (없으면)
2. ✅ JWT Secret 자동 생성
3. ✅ Docker 컨테이너 시작 (MySQL + 5개 백엔드)
4. ✅ MySQL 헬스체크 대기
5. ✅ 백엔드 서비스 헬스체크 (/ping)
6. ✅ 테스트 데이터 자동 삽입 (선택)

**완료 후 접속**:
- Recruit API: http://localhost:8084/api/recruit/posts
- Auth API: http://localhost:8081
- Frontend (별도 실행): http://localhost:5173

---

## 2️⃣ 코드 수정 후 재시작

### 모든 서비스 재빌드

```powershell
cd C:\github\fixproject\sports-hub-v2\infra
pwsh -File start.ps1 -Rebuild
```

### 특정 서비스만 재빌드

```bash
cd C:\github\fixproject\sports-hub-v2\infra\docker

# recruit 서비스만 재빌드
docker compose up -d --build recruit-service

# 여러 서비스 동시 재빌드
docker compose up -d --build recruit-service auth-service
```

### 데이터 보존하고 재시작

```bash
cd C:\github\fixproject\sports-hub-v2\infra\docker

# ✅ 안전: 데이터 보존
docker compose restart

# 또는 특정 서비스만
docker compose restart recruit-service
```

---

## 3️⃣ DB 데이터만 초기화

**경고**: 모든 DB 데이터가 삭제됩니다!

```bash
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 방법 1: MySQL 컨테이너만 재시작
docker compose down mysql
docker volume rm sportshub_mysql-data
docker compose up -d

# 방법 2: 전체 재시작 (더 확실함)
docker compose down -v
docker compose up -d
```

자동 실행:
- `01_create_databases.sql` - sportshub_db 생성
- `02_create_tables.sql` - 27개 테이블 생성

---

## 4️⃣ 완전히 처음부터 시작

모든 컨테이너, 볼륨, 이미지 삭제 후 재시작:

```bash
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 1. 모든 것 삭제
docker compose down -v --rmi all

# 2. 처음부터 빌드 및 시작
docker compose up -d --build

# 또는 start.ps1 사용
cd ..
pwsh -File start.ps1 -Rebuild
```

---

## 🛠️ 유용한 명령어

### 상태 확인

```bash
# 컨테이너 상태
docker compose ps

# 로그 확인 (전체)
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f recruit-service

# MySQL 접속
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw

# 테이블 확인
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw -e "USE sportshub_db; SHOW TABLES;"
```

### API 테스트

```bash
# 헬스체크
curl http://localhost:8084/ping

# 모집글 목록
curl http://localhost:8084/api/recruit/posts

# 특정 모집글
curl http://localhost:8084/api/recruit/posts/1

# 신청 목록
curl http://localhost:8084/api/recruit/posts/1/applications
```

---

## ⚠️ 주의사항

### `-v` 플래그는 위험합니다

```bash
# ❌ 위험: 모든 DB 데이터 삭제
docker compose down -v

# ✅ 안전: 컨테이너만 중지
docker compose down

# ✅ 안전: 재시작
docker compose restart
```

`-v` = `--volumes` = MySQL 볼륨 삭제 = **모든 데이터 날아감**

### 포트 충돌 확인

```bash
# Windows에서 포트 사용 확인
netstat -ano | findstr :8084
netstat -ano | findstr :3306

# 프로세스 종료 (관리자 권한)
taskkill /PID <PID> /F
```

---

## 📊 시스템 구조

### 서비스 포트

| 서비스 | 포트 | 설명 |
|--------|------|------|
| MySQL | 3306 | sportshub_db (27개 테이블) |
| Auth | 8081 | 인증/OAuth/JWT |
| User | 8082 | 사용자 프로필 |
| Team | 8083 | 팀 관리 |
| **Recruit** | **8084** | **모집글/신청** |
| Notification | 8085 | 알림 |

### 데이터베이스

- **통합 DB**: sportshub_db
- **테이블 수**: 27개
- **위치**: Docker 볼륨 `sportshub_mysql-data`
- **초기화**: `infra/docker/mysql/init/*.sql`

---

## 📚 관련 문서

**인프라 관련**:
- `README.md` - 아키텍처 개요 및 변경 이력
- `USAGE.md` - 상세 사용법 및 트러블슈팅
- `QUICKSTART.md` - 이 문서 (빠른 시작)

**데이터베이스**:
- `docs/DATABASE_SCHEMA_FINAL.md` - 전체 스키마 상세
- `docs/TABLE_USAGE_MAPPING.md` - 테이블 사용처 매핑

**프로젝트**:
- `docs/PROJECT_STATUS.md` - 프로젝트 현황

---

## 🆘 문제 해결

### MySQL이 시작 안 될 때

```bash
# 로그 확인
docker compose logs mysql

# 볼륨 삭제 후 재시작
docker compose down -v
docker compose up -d
```

### 백엔드 서비스가 안 뜰 때

```bash
# 특정 서비스 로그
docker compose logs recruit-service --tail 100

# 재빌드
docker compose up -d --build recruit-service
```

### 연결이 안 될 때

```bash
# 헬스체크
curl http://localhost:8084/ping

# MySQL 확인
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw -e "SELECT 1;"

# 네트워크 확인
docker network ls
docker network inspect sportshub_sportshub-net
```

---

**작성일**: 2025-11-13
**버전**: 1.0
