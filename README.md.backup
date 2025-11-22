# Sports Hub v2 Infrastructure

조기축구 플랫폼의 통합 인프라 시스템입니다.

## 🏗️ 아키텍처

### 데이터베이스 구조

**모놀리식 통합 DB** (2025-10-31 변경)
- **sportshub_db** - 통합 데이터베이스 (23개 테이블)
- 외래키 제약조건 지원
- JOIN 쿼리 지원
- 관리자 페이지 통합 쿼리 가능

```
[기존] 마이크로서비스 (5개 분리 DB)
auth_db, user_db, team_db, recruit_db, notification_db

↓ 통합

[현재] 모놀리식 (1개 통합 DB)
sportshub_db (23개 테이블)
```

### 백엔드 서비스들 (Spring Boot)

애플리케이션 레벨은 마이크로서비스 유지:

- **backend-auth** (8081) - 인증/OAuth/JWT 관리
- **backend-user** (8082) - 사용자 프로필 서비스
- **backend-team** (8083) - 팀/멤버십 관리
- **backend-recruit** (8084) - 모집글/신청서 서비스
- **backend-notification** (8085) - 알림 서비스

**모든 서비스가 동일한 sportshub_db 사용**

---

## 🚀 빠른 시작

### 1. Docker Desktop 실행

먼저 Docker Desktop을 실행하세요.

### 2. 인프라 시작

```bash
cd infra/docker
docker compose down -v
docker compose up -d
```

### 3. 초기화 확인

컨테이너 시작 시 자동 실행:
1. `01_create_databases.sql` - sportshub_db 생성
2. `02_create_tables.sql` - 23개 테이블 생성

### 4. 접속 확인

**백엔드:** http://localhost:8081/ping ~ 8085/ping
**프론트엔드:** http://localhost:5173

---

## 📊 데이터베이스 구조 (23개 테이블)

| 도메인 | 테이블 | 설명 |
|--------|-------|------|
| 인증/계정 | accounts, refresh_tokens | 로그인, JWT |
| 사용자 | profiles | 프로필 및 통계 |
| 팀 | teams, team_memberships | 팀 정보, 멤버 관계 |
| 콘텐츠 | posts, comments, applications, notifications | 게시물, 댓글, 신청, 알림 |
| 경기 | matches, match_lineups, match_management_logs, match_notes | 경기 관리, 노쇼 추적 |
| 신고/제재 | reports, report_evidences, sanctions | 신고, 증거, 제재 |
| 평가/통계 | post_edit_history, peer_surveys, user_stats_summary | 수정이력, 동료평가, 통계 |
| 활동로그 | user_activity_logs, team_activity_logs, admin_action_logs | 활동 추적 |
| 기타 | venues | 경기장 |

**상세 스키마:** `docs/DATABASE_SCHEMA_FINAL.md` (1,622줄)

---

## 🛠️ 개발자 도구

### 데이터베이스 접속
```bash
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw
USE sportshub_db;
SHOW TABLES;  -- 23개
```

### 로그 확인
```bash
docker compose logs -f
docker compose logs -f mysql
```

### 서비스 재시작
```bash
docker compose restart
docker compose restart auth-service
```

---

## 🎯 주요 변경 사항 (2025-10-31)

**데이터베이스 재설계:**
- 5개 DB → 1개 통합 DB (sportshub_db)
- 외래키 30개 설정
- 노쇼 추적, 동료 평가, 신고/제재 시스템
- 관리자 페이지 전용 기능 추가

**상세 문서:**
- `docs/DATABASE_SCHEMA_FINAL.md` - 스키마 상세
- `docs/TABLE_USAGE_MAPPING.md` - 테이블 사용 위치

---

**작성일:** 2025-10-31  
**버전:** 2.0 (Monolithic DB)
