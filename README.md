# Sports Hub v2 Infrastructure

조기축구 플랫폼의 통합 인프라 시스템입니다.

---

## 📖 문서 가이드

**목적별 문서 선택**:

| 문서 | 대상 | 내용 |
|------|------|------|
| **[QUICKSTART.md](./QUICKSTART.md)** | 🔰 처음 사용자 | **지금 바로 실행하기** (권장) |
| **README.md** (현재) | 📐 아키텍처 이해 | 시스템 구조 및 변경 이력 |
| **[USAGE.md](./USAGE.md)** | 🔧 고급 사용자 | 상세 관리 및 트러블슈팅 |

**⚡ 지금 실행하고 싶다면**: [QUICKSTART.md](./QUICKSTART.md)로 이동하세요!

---

## 🏗️ 아키텍처

### 데이터베이스 구조

**모놀리식 통합 DB** (2025-10-31 설계, 2025-11-08 업데이트)
- **sportshub_db** - 통합 데이터베이스 (**27개 테이블**)
- 외래키 제약조건 지원
- JOIN 쿼리 지원
- 관리자 페이지 통합 쿼리 가능

```
[기존] 마이크로서비스 (5개 분리 DB)
auth_db, user_db, team_db, recruit_db, notification_db

↓ 통합

[현재] 모놀리식 (1개 통합 DB)
sportshub_db (27개 테이블)
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

**상세한 실행 방법**: [QUICKSTART.md](./QUICKSTART.md) 참조

### 자동화 스크립트 (권장)

```powershell
cd C:\github\fixproject\sports-hub-v2\infra
.\start.ps1
```

### 수동 실행

```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker
docker compose up -d
```

### 접속 확인

**백엔드:** http://localhost:8081/ping ~ 8085/ping
**프론트엔드:** http://localhost:5173

**⚠️ 주의**: `docker compose down -v`는 모든 DB 데이터를 삭제합니다!

---

## 📊 데이터베이스 구조 (27개 테이블)

| 도메인 | 테이블 | 설명 |
|--------|-------|------|
| 인증/계정 | accounts, refresh_tokens | 로그인, JWT |
| 사용자 | profiles, user_stats_summary, user_activity_logs | 프로필, 통계, 활동로그 |
| 팀 | teams, team_memberships, **team_rivals**, team_activity_logs, **team_notices** | 팀 정보, 멤버, 라이벌, 활동, 공지 |
| 콘텐츠 | posts, comments, applications, notifications, post_edit_history | 게시물, 댓글, 신청, 알림, 수정이력 |
| 경기 | matches, match_lineups, match_management_logs, match_notes | 경기 관리, 노쇼 추적 |
| 신고/제재 | reports, report_evidences, sanctions | 신고, 증거, 제재 |
| 평가 | peer_surveys | 동료평가, 매너온도 |
| 관리 | admin_action_logs | 관리자 활동 추적 |
| 기타 | venues | 경기장 |

**상세 스키마:** `docs/DATABASE_SCHEMA_FINAL.md`

---

## 🛠️ 개발자 도구

### 데이터베이스 접속
```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw
# MySQL 프롬프트에서:
# USE sportshub_db;
# SHOW TABLES;  -- 27개
```

### 테이블 수 확인
```powershell
docker exec -it sportshub-mysql mysql -u sportshub -psportshub_pw -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='sportshub_db';"
```

### 로그 확인
```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 전체 로그
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f auth-service
```

### 서비스 재시작
```powershell
cd C:\github\fixproject\sports-hub-v2\infra\docker

# 전체 재시작
docker compose restart

# 특정 서비스 재시작
docker compose restart auth-service
```

---

## 🎯 주요 변경 사항

### 2025-11-08 업데이트
- **테이블 수**: 23개 → **27개**
- **rival_teams 정규화**: JSON 필드 → `team_rivals` 중간 테이블
- **team_notices 추가**: 팀 공지사항 테이블
- **Flyway 비활성화**: MySQL init scripts만 사용
- **ddl-auto**: validate → update 변경
- **OAuth2 비활성화**: 기본 인증만 사용

### 2025-10-31 초기 설계
- 5개 DB → 1개 통합 DB (sportshub_db)
- 외래키 30개 설정
- 노쇼 추적, 동료 평가, 신고/제재 시스템
- 관리자 페이지 전용 기능 추가

**상세 문서:**
- **[QUICKSTART.md](./QUICKSTART.md)** - 빠른 시작 가이드 (처음 사용자)
- **[USAGE.md](./USAGE.md)** - 상세 사용법 및 트러블슈팅
- `docs/PROJECT_STATUS.md` - 프로젝트 현황
- `docs/claudegem.md` - DB 평가 보고서
- `docs/DATABASE_SCHEMA_FINAL.md` - 스키마 상세

---

**작성일:** 2025-10-31
**최종 업데이트:** 2025-11-13
**버전:** 2.1 (27 Tables)
