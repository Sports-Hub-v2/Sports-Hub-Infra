# 🚀 Sports Hub v2 Infra 사용 가이드

## 🎯 완료된 작업

통합 인프라 시스템이 성공적으로 구축되었습니다! 이제 복잡하게 분산되어 있던 설정들이 하나로 통합되어 쉽게 관리할 수 있습니다.

## 📁 새로운 구조

```
sports-hub-v2/infra/
├── 🚀 quick-start.sh       # Linux/macOS 원클릭 설치
├── 🚀 quick-start.ps1      # Windows 원클릭 설치  
├── 📖 README.md           # 상세 가이드
├── 📋 USAGE.md           # 이 파일
├── 
├── environments/         # 환경별 설정 (자동 생성)
│   ├── dev/             # 개발 환경
│   ├── staging/         # 스테이징 환경
│   └── prod/           # 프로덕션 환경
├── 
├── database/           # DB 관리 (자동 생성)
│   ├── init/          # 초기 스키마
│   └── seed/          # 테스트 데이터
├── 
├── scripts/           # 관리 도구
│   └── manage.sh      # 통합 관리 스크립트
├── 
└── backups/          # DB 백업 (자동 생성)
```

## 🚀 즉시 시작하기

### Windows에서 실행

```powershell
# 1. PowerShell 실행 정책 설정
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 2. 개발 환경 설치 및 실행
powershell -ExecutionPolicy Bypass .\quick-start.ps1 dev

# 3. 설치 완료 후 접속 테스트
# 브라우저에서 http://localhost:8081/ping 확인
```

### Linux/macOS에서 실행

```bash
# 1. 실행 권한 부여
chmod +x quick-start.sh
chmod +x scripts/manage.sh

# 2. 개발 환경 설치 및 실행
./quick-start.sh dev

# 3. 설치 완료 후 접속 테스트
curl http://localhost:8081/ping
```

## 🛠️ 일상적인 관리

설치 후에는 `manage.sh` 스크립트로 모든 것을 관리할 수 있습니다:

```bash
# 서비스 관리
./scripts/manage.sh start      # 시작
./scripts/manage.sh stop       # 중지  
./scripts/manage.sh restart    # 재시작
./scripts/manage.sh status     # 상태 확인

# 모니터링
./scripts/manage.sh health     # 헬스체크
./scripts/manage.sh logs       # 전체 로그
./scripts/manage.sh logs auth-service  # 특정 서비스 로그

# 데이터베이스
./scripts/manage.sh db         # DB 접속
./scripts/manage.sh db-backup  # 백업
./scripts/manage.sh seed       # 테스트 데이터 재삽입
```

## 🧪 테스트 계정 (개발 환경)

자동으로 생성된 테스트 계정들:

| 이메일 | 비밀번호 | 역할 |
|--------|----------|------|
| user1@example.com | Secret123! | 일반 사용자 |
| captain@example.com | Captain123! | 팀 캐프틴 |
| admin@example.com | Admin123! | 관리자 |

## 📊 접속 주소

설치 완료 후 다음 주소들로 접속 가능:

- **🌐 프론트엔드**: http://localhost:5173
- **🔐 Auth Service**: http://localhost:8081
- **👤 User Service**: http://localhost:8082  
- **👥 Team Service**: http://localhost:8083
- **📋 Recruit Service**: http://localhost:8084
- **🔔 Notification Service**: http://localhost:8085

## 🎉 주요 개선사항

### ✅ 이전 vs 현재

**이전 (복잡한 분산 구조):**
```
❌ 여러 개의 개별 스크립트들
❌ 수동으로 각 서비스 설정
❌ 테스트 데이터 별도 설치
❌ 환경별 설정 혼재
❌ 복잡한 관리 절차
```

**현재 (통합 인프라):**
```
✅ 원클릭 설치 스크립트
✅ 자동 환경 설정
✅ 테스트 데이터 자동 생성  
✅ 환경별 깔끔한 분리
✅ 통합 관리 도구
```

## 🔄 업그레이드 방법

기존 복잡한 설정에서 새로운 통합 구조로 이전:

```bash
# 1. 기존 서비스들 중지
cd old-infra-location
docker compose down

# 2. 새로운 통합 인프라로 전환
cd sports-hub-v2/infra
./quick-start.sh dev

# 3. 데이터 마이그레이션이 필요한 경우
./scripts/manage.sh db-restore /path/to/backup.sql
```

## 🤝 팀 협업

이제 팀원들은 다음과 같이 간단하게 개발 환경을 구축할 수 있습니다:

1. **리포지토리 클론**
```bash
git clone [your-repo] sports-hub-v2
cd sports-hub-v2/infra
```

2. **원클릭 설치**
```bash
./quick-start.sh dev
```

3. **개발 시작** 🎉

## 📞 문제 해결

### 자주 묻는 질문

**Q: 포트가 이미 사용 중이라고 나와요**
```bash
# 포트 사용 중인 프로세스 확인
netstat -ano | findstr :8081
# 또는
lsof -i :8081

# 해당 프로세스 종료 후 재시도
```

**Q: 데이터베이스 연결 오류**
```bash
# 컨테이너 상태 확인
docker ps -a

# MySQL 컨테이너 재시작
./scripts/manage.sh restart
```

**Q: 스크립트 실행 권한 오류 (Linux/macOS)**
```bash
chmod +x *.sh scripts/*.sh
```

## 🎊 성공!

축하합니다! 이제 Sports Hub v2의 통합 인프라 시스템을 사용할 준비가 완료되었습니다.

**다음 단계:**
1. ✅ 인프라 설치 완료
2. 🔄 프론트엔드 실행: `cd ../frontend && npm install && npm run dev`
3. 🚀 개발 시작!

---
*만든 사람: Claude (with ❤️)*
## ��Ŭ�� ���� (Windows)

`powershell
# PowerShell ���� ��å (���� 1ȸ)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# ��Ŭ�� ����: .env �غ� �� compose up �� �ｺüũ �� (�ʿ� ��) �õ� ����
./infra/start.ps1

# ����尡 �ʿ��� ��
./infra/start.ps1 -Rebuild
`

���� ����:
- .env�� ������ .env.example�� �����ϰ� AUTH_JWT_SECRET�� �ڵ� �����մϴ�.
- Docker Compose�� MySQL�� �鿣�� ���񽺵��� �⵿ �� �� /ping ��������Ʈ�� Ȯ���մϴ�.
- uth ���񽺿��� user1@example.com ���� ���� ���θ� ������, ������ infra/seed/seed-dev.ps1�� �׽�Ʈ �����͸� �����մϴ�.
- docker compose down -v�� ���� ���� �� �ٽ� �����ϸ� �ڵ� ��õ�˴ϴ�.

