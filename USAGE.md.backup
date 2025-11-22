# 🚀 Sports Hub v2 Infra 사용 가이드

## 📊 시스템 구조 (2025-10-31 업데이트)

### 데이터베이스 아키텍처

**모놀리식 통합 DB**
```
sportshub_db (1개 통합 데이터베이스)
├── 23개 테이블
├── 30+ 외래키
├── 60+ 인덱스
└── FULLTEXT 검색 지원
```

**변경 이유:**
- 외래키 제약조건 지원
- JOIN 쿼리 가능
- 관리자 페이지 통합 쿼리 필요

---

## 🚀 즉시 시작하기

### 1. Docker Desktop 실행

Windows 시작 메뉴 → Docker Desktop 실행

### 2. 컨테이너 시작

```bash
cd infra/docker
docker compose down -v   # 기존 삭제
docker compose up -d     # 새로 시작
```

### 3. 초기화 확인

자동 실행되는 스크립트:
1. `01_create_databases.sql` - sportshub_db 생성
2. `02_create_tables.sql` - 23개 테이블 생성

### 4. 접속 테스트

```bash
# 백엔드 서비스 헬스체크
curl http://localhost:8081/ping  # auth
curl http://localhost:8082/ping  # user
curl http://localhost:8083/ping  # team
curl http://localhost:8084/ping  # recruit
curl http://localhost:8085/ping  # notification

# MySQL 접속
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw

# 테이블 확인
USE sportshub_db;
SHOW TABLES;  # 23개 확인
```

---

## 📊 데이터베이스 구조

### 23개 테이블 요약

| 도메인 | 테이블 수 | 테이블명 |
|--------|----------|---------|
| 인증/계정 | 2 | accounts, refresh_tokens |
| 사용자 | 1 | profiles |
| 팀 | 2 | teams, team_memberships |
| 콘텐츠 | 4 | posts, comments, applications, notifications |
| 경기 | 4 | matches, match_lineups, match_management_logs, match_notes |
| 신고/제재 | 3 | reports, report_evidences, sanctions |
| 평가/통계 | 2 | post_edit_history, peer_surveys |
| 통계/로그 | 4 | user_stats_summary, user_activity_logs, team_activity_logs, admin_action_logs |
| 기타 | 1 | venues |

**상세 문서:** `docs/DATABASE_SCHEMA_FINAL.md`

---

## 🛠️ 일상적인 관리

### 서비스 관리

```bash
cd infra/docker

# 시작
docker compose up -d

# 중지
docker compose down

# 재시작
docker compose restart

# 특정 서비스만 재시작
docker compose restart auth-service
docker compose restart mysql

# 완전 초기화 (볼륨 삭제)
docker compose down -v
docker compose up -d
```

### 로그 확인

```bash
# 전체 로그
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f mysql
docker compose logs -f auth-service
docker compose logs -f user-service

# 마지막 100줄만
docker compose logs --tail=100 mysql
```

### 데이터베이스 관리

```bash
# MySQL 접속
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw

# 데이터베이스 선택
USE sportshub_db;

# 테이블 목록
SHOW TABLES;

# 테이블 구조 확인
DESC accounts;
DESC profiles;
DESC matches;

# 외래키 확인
SELECT TABLE_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'sportshub_db'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

# 인덱스 확인
SHOW INDEX FROM posts;

# FULLTEXT 인덱스 확인
SHOW INDEX FROM posts WHERE Index_type = 'FULLTEXT';
```

---

## 🧪 샘플 데이터

### 수동 샘플 데이터 삽입

```sql
USE sportshub_db;

-- 1. 계정 생성
INSERT INTO accounts (email, password_hash, role, email_verified)
VALUES
('admin@sportshub.com', '$2a$10$...', 'ADMIN', TRUE),
('user@sportshub.com', '$2a$10$...', 'USER', TRUE);

-- 2. 프로필 생성
INSERT INTO profiles (account_id, name, region, preferred_position)
VALUES
(1, '관리자', '서울 강남구', 'GK'),
(2, '사용자', '서울 강남구', 'MF');

-- 3. 팀 생성
INSERT INTO teams (team_name, captain_id, region, description)
VALUES ('FC 강남', 1, '서울 강남구', '주말 조기축구 팀');

-- 4. 게시물 생성
INSERT INTO posts (author_id, author_name, post_type, title, content)
VALUES (1, '관리자', 'RECRUIT', '용병 구함', '이번 주 토요일 오전 7시');
```

---

## 📋 접속 주소

| 서비스 | URL | 설명 |
|--------|-----|------|
| Frontend (User) | http://localhost:5173 | 사용자 페이지 |
| Frontend (Admin) | http://localhost:5174 | 관리자 대시보드 |
| Auth Service | http://localhost:8081 | 인증 서비스 |
| User Service | http://localhost:8082 | 사용자 서비스 |
| Team Service | http://localhost:8083 | 팀 서비스 |
| Recruit Service | http://localhost:8084 | 모집 서비스 |
| Notification Service | http://localhost:8085 | 알림 서비스 |

---

## 🎯 주요 기능

### 1. 노쇼 추적 시스템

**테이블:** `match_lineups`
```sql
-- 노쇼 처리
UPDATE match_lineups
SET is_no_show = TRUE, attendance_status = 'NO_SHOW'
WHERE match_id = ? AND profile_id = ?;

-- 프로필 통계 업데이트
UPDATE profiles
SET no_show_count = no_show_count + 1
WHERE id = ?;
```

### 2. 매너 온도 계산

**테이블:** `peer_surveys`, `profiles`
```sql
-- 동료 평가 삽입
INSERT INTO peer_surveys (match_id, evaluator_id, evaluated_id, teamwork, communication, ...)
VALUES (?, ?, ?, 4.5, 4.0, ...);

-- 매너 온도 = 36.5 + (평균 점수 - 3) × 3
-- 예: 평균 4.5 → 36.5 + (4.5 - 3) × 3 = 41.0°C
```

### 3. 신고/제재 시스템

**테이블:** `reports`, `sanctions`
```sql
-- 신고 접수
INSERT INTO reports (report_type, target_id, reporter_id, reported_id, category, description)
VALUES ('USER', ?, ?, ?, 'NO_SHOW', '3회 연속 노쇼');

-- 제재 조치
INSERT INTO sanctions (target_type, target_id, sanction_type, reason, duration_days)
VALUES ('USER', ?, 'SUSPENSION', '노쇼 3회', 7);
```

---

## 🔍 문제 해결

### Q: 포트가 이미 사용 중

```bash
# Windows
netstat -ano | findstr :3306
netstat -ano | findstr :8081

# Linux/macOS
lsof -i :3306
lsof -i :8081

# 프로세스 종료 후 재시도
```

### Q: 데이터베이스 연결 오류

```bash
# 컨테이너 상태 확인
docker ps -a

# MySQL 로그 확인
docker logs sportshub-mysql

# 재시작
docker compose restart mysql
```

### Q: 테이블이 생성되지 않음

```bash
# 초기화 스크립트 확인
docker logs sportshub-mysql | grep "01_create_databases"
docker logs sportshub-mysql | grep "02_create_tables"

# 완전 초기화
docker compose down -v
docker compose up -d
```

---

## 📚 추가 문서

- **DATABASE_SCHEMA_FINAL.md** - 데이터베이스 스키마 상세 문서 (1,622줄)
  - 전체 개요
  - 23개 테이블 상세 설명
  - 테이블 사용 위치 매핑
  - 인덱스/외래키/비정규화 전략
  - 핵심 데이터 흐름

- **TABLE_USAGE_MAPPING.md** - 테이블 사용 위치 매핑
  - 관리자 페이지별 테이블 사용
  - 사용자 기능별 테이블 사용
  - 테이블 간 관계도

---

## 🎊 성공!

축하합니다! Sports Hub v2 인프라가 성공적으로 실행되었습니다.

**다음 단계:**
1. ✅ 인프라 실행 완료
2. 🔄 프론트엔드 실행: `cd frontend && npm install && npm run dev`
3. 🔄 관리자 실행: `cd admin && npm install && npm run dev`
4. 🚀 개발 시작!

---

**최종 업데이트:** 2025-10-31
**버전:** 2.0 (Monolithic DB)
