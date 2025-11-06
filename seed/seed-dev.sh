#!/usr/bin/env bash
set -euo pipefail

# Sports Hub v2 Development Seed Data
# 용도: sportshub_db에 샘플 데이터 삽입
# 요구사항: Docker MySQL 컨테이너 실행 중

info() { echo -e "\033[36m[INFO]\033[0m  $*"; }
ok()   { echo -e "\033[32m[OK]\033[0m    $*"; }
err()  { echo -e "\033[31m[ERROR]\033[0m $*"; }

# MySQL 접속 정보
MYSQL_CONTAINER="sportshub-mysql"
MYSQL_USER="sportshub"
MYSQL_PASSWORD="sportshub_pw"
MYSQL_DB="sportshub_db"

# MySQL 컨테이너 확인
if ! docker ps | grep -q "$MYSQL_CONTAINER"; then
  err "MySQL container not running. Please start infra first."
  exit 1
fi

info "Seeding development data to sportshub_db..."

# SQL 실행 헬퍼 함수
mysql_exec() {
  docker exec -i "$MYSQL_CONTAINER" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DB" <<< "$1"
}

# 기존 데이터 확인
EXISTING=$(mysql_exec "SELECT COUNT(*) FROM accounts;" 2>/dev/null | tail -1 || echo "0")
if [[ "$EXISTING" -gt 0 ]]; then
  info "Data already exists ($EXISTING accounts). Skipping seed."
  exit 0
fi

# ===== 1. ACCOUNTS =====
info "Seeding accounts..."
mysql_exec "
INSERT INTO accounts (email, password_hash, role, email_verified, status) VALUES
('admin@sportshub.com', '\$2a\$10\$YourHashedPasswordHere', 'ADMIN', TRUE, 'ACTIVE'),
('captain@sportshub.com', '\$2a\$10\$YourHashedPasswordHere', 'USER', TRUE, 'ACTIVE'),
('user1@sportshub.com', '\$2a\$10\$YourHashedPasswordHere', 'USER', TRUE, 'ACTIVE'),
('user2@sportshub.com', '\$2a\$10\$YourHashedPasswordHere', 'USER', TRUE, 'ACTIVE');
"
ok "Accounts created (4)"

# ===== 2. PROFILES =====
info "Seeding profiles..."
mysql_exec "
INSERT INTO profiles (account_id, name, region, sub_region, preferred_position, skill_level, manner_temperature) VALUES
(1, '관리자', '서울', '강남구', 'GK', 'ADVANCED', 36.5),
(2, '팀장 김철수', '서울', '서초구', 'DF', 'INTERMEDIATE', 38.0),
(3, '사용자 이영희', '경기', '성남시', 'MF', 'BEGINNER', 37.5),
(4, '사용자 박민수', '서울', '강남구', 'FW', 'INTERMEDIATE', 36.0);
"
ok "Profiles created (4)"

# ===== 3. TEAMS =====
info "Seeding teams..."
mysql_exec "
INSERT INTO teams (team_name, captain_id, region, sub_region, description, max_members, skill_level, status, verified) VALUES
('FC 강남', 2, '서울', '강남구', '주말 조기축구 팀', 20, 'INTERMEDIATE', 'ACTIVE', TRUE),
('서초 FC', 2, '서울', '서초구', '평일 저녁 축구 팀', 15, 'BEGINNER', 'ACTIVE', FALSE);
"
ok "Teams created (2)"

# ===== 4. TEAM_MEMBERSHIPS =====
info "Seeding team memberships..."
mysql_exec "
INSERT INTO team_memberships (team_id, profile_id, role_in_team, is_active) VALUES
(1, 2, 'CAPTAIN', TRUE),
(1, 3, 'MEMBER', TRUE),
(1, 4, 'MEMBER', TRUE),
(2, 2, 'CAPTAIN', TRUE);
"
ok "Team memberships created (4)"

# ===== 5. POSTS =====
info "Seeding posts..."
mysql_exec "
INSERT INTO posts (author_id, author_name, post_type, team_id, title, content, status, views) VALUES
(2, '팀장 김철수', 'TEAM_NOTICE', 1, '이번 주 훈련 공지', '토요일 오전 7시 강남 운동장', 'PUBLISHED', 15),
(2, '팀장 김철수', 'RECRUIT', 1, '용병 구함 (MF 1명)', '일요일 오후 2시 경기, MF 포지션 1명 구합니다', 'PUBLISHED', 25),
(3, '사용자 이영희', 'COMMUNITY', NULL, '축구화 추천 부탁드려요', '입문자인데 어떤 축구화가 좋을까요?', 'PUBLISHED', 8);
"
ok "Posts created (3)"

# ===== 6. COMMENTS =====
info "Seeding comments..."
mysql_exec "
INSERT INTO comments (post_id, author_id, author_name, content, is_deleted) VALUES
(1, 3, '사용자 이영희', '참석하겠습니다!', FALSE),
(2, 4, '사용자 박민수', '신청합니다. 연락 부탁드립니다.', FALSE),
(3, 2, '팀장 김철수', '나이키 팬텀이 좋습니다.', FALSE);
"
ok "Comments created (3)"

# ===== 7. APPLICATIONS =====
info "Seeding applications..."
mysql_exec "
INSERT INTO applications (post_id, applicant_id, message, status) VALUES
(2, 4, 'MF 포지션 가능합니다. 5년 경력입니다.', 'PENDING');
"
ok "Applications created (1)"

# ===== 8. NOTIFICATIONS =====
info "Seeding notifications..."
mysql_exec "
INSERT INTO notifications (receiver_id, type, title, message, is_read) VALUES
(2, 'APPLICATION', '신청 도착', '사용자 박민수님이 용병 신청을 했습니다.', FALSE),
(3, 'COMMENT', '댓글 알림', '팀장 김철수님이 댓글을 남겼습니다.', FALSE),
(4, 'APPLICATION', '신청 완료', '용병 신청이 완료되었습니다.', TRUE);
"
ok "Notifications created (3)"

# ===== 9. VENUES =====
info "Seeding venues..."
mysql_exec "
INSERT INTO venues (name, address, region, sub_region, venue_type, surface, capacity, status) VALUES
('강남 종합 운동장', '서울시 강남구 역삼동 123', '서울', '강남구', 'OUTDOOR', '인조잔디', 22, 'ACTIVE'),
('서초 풋살장', '서울시 서초구 서초동 456', '서울', '서초구', 'INDOOR', '우레탄', 14, 'ACTIVE');
"
ok "Venues created (2)"

# ===== 10. MATCHES =====
info "Seeding matches..."
mysql_exec "
INSERT INTO matches (match_date, match_time, venue, home_team_id, away_team_id, status) VALUES
('2025-11-10', '07:00:00', '강남 종합 운동장', 1, 2, 'SCHEDULED');
"
ok "Matches created (1)"

# ===== 통계 업데이트 =====
info "Updating statistics..."
mysql_exec "
UPDATE teams SET total_members = 3 WHERE id = 1;
UPDATE teams SET total_members = 1 WHERE id = 2;
UPDATE profiles SET posts_count = 2 WHERE id = 2;
UPDATE profiles SET posts_count = 1 WHERE id = 3;
UPDATE profiles SET comments_count = 1 WHERE id = 2;
UPDATE profiles SET comments_count = 1 WHERE id = 3;
UPDATE profiles SET comments_count = 1 WHERE id = 4;
UPDATE posts SET comments_count = 1 WHERE id IN (1, 2, 3);
"
ok "Statistics updated"

ok "✅ Seed data complete!"
echo ""
echo "📊 Created:"
echo "   - 4 Accounts (admin, captain, user1, user2)"
echo "   - 4 Profiles"
echo "   - 2 Teams"
echo "   - 4 Team memberships"
echo "   - 3 Posts (notice, recruit, community)"
echo "   - 3 Comments"
echo "   - 1 Application"
echo "   - 3 Notifications"
echo "   - 2 Venues"
echo "   - 1 Match (scheduled)"
echo ""
echo "🔑 Test credentials (password hashing required):"
echo "   admin@sportshub.com"
echo "   captain@sportshub.com"
echo "   user1@sportshub.com"
echo "   user2@sportshub.com"
