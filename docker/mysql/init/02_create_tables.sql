-- =====================================================
-- Sports Hub Unified Database Schema
-- =====================================================
-- Purpose: Complete database schema for monolithic architecture
-- Tables: 25 tables (8 redesigned + 17 new)
-- Engine: InnoDB
-- Charset: utf8mb4_unicode_ci
-- =====================================================

USE sportshub_db;

-- =====================================================
-- 1. AUTHENTICATION & ACCOUNTS
-- =====================================================

CREATE TABLE accounts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Login credentials
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,

    -- Role and status
    role VARCHAR(20) NOT NULL COMMENT 'USER, ADMIN, SUPER_ADMIN',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE, SUSPENDED, BANNED, DELETED',

    -- Verification
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,

    -- Login tracking
    last_login_at DATETIME,
    last_login_ip VARCHAR(45) COMMENT 'IPv6 support',
    last_device_info VARCHAR(255),

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME COMMENT 'Soft delete',

    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User accounts';

CREATE TABLE refresh_tokens (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id BIGINT NOT NULL,

    token_hash VARCHAR(255) NOT NULL UNIQUE,

    expires_at DATETIME NOT NULL,
    revoked_at DATETIME,

    device_info VARCHAR(255),
    ip_address VARCHAR(45),

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    INDEX idx_account (account_id),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Refresh tokens';

-- =====================================================
-- 2. USER PROFILES
-- =====================================================

CREATE TABLE profiles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id BIGINT NOT NULL UNIQUE,

    -- Basic info
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20),
    birth_date DATE,

    -- Location
    region VARCHAR(100),
    sub_region VARCHAR(100) COMMENT 'District/neighborhood',

    -- Soccer info
    preferred_position VARCHAR(30) COMMENT 'GK, DF, MF, FW',
    skill_level VARCHAR(20) COMMENT 'BEGINNER, INTERMEDIATE, ADVANCED',
    is_professional BOOLEAN DEFAULT FALSE COMMENT 'Has professional experience',
    height INT COMMENT 'Height in cm',
    weight INT COMMENT 'Weight in kg',

    -- Morning soccer stats (denormalized for performance)
    total_matches INT DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0,
    punctuality_rate DECIMAL(5,2) DEFAULT 100,
    manner_temperature DECIMAL(5,2) DEFAULT 36.5,
    no_show_count INT DEFAULT 0,
    consecutive_attendance INT DEFAULT 0,

    -- Activity period
    activity_start_date DATE,
    activity_end_date DATE,

    -- Activity stats (denormalized)
    posts_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,

    FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE,
    INDEX idx_region (region),
    INDEX idx_skill_level (skill_level),
    INDEX idx_manner_temp (manner_temperature)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User profiles';

-- =====================================================
-- 3. TEAMS
-- =====================================================

CREATE TABLE teams (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    team_name VARCHAR(100) NOT NULL UNIQUE,
    captain_id BIGINT COMMENT 'Captain profile ID',

    -- Location
    region VARCHAR(100),
    sub_region VARCHAR(100),
    home_ground VARCHAR(200),

    -- Team info
    description TEXT,
    logo_url VARCHAR(500),
    max_members INT DEFAULT 25,
    age_group VARCHAR(50) COMMENT '20-30, 30-40',
    skill_level VARCHAR(20) COMMENT 'BEGINNER, INTERMEDIATE, ADVANCED',
    activity_type VARCHAR(30) COMMENT 'REGULAR, WEEKEND, MORNING',

    -- Team stats (denormalized)
    total_members INT DEFAULT 0,
    total_matches INT DEFAULT 0,
    wins INT DEFAULT 0,
    draws INT DEFAULT 0,
    losses INT DEFAULT 0,
    goals_scored INT DEFAULT 0,
    goals_conceded INT DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0,
    avg_age DECIMAL(4,1) DEFAULT 0,

    -- Relationships
    rival_teams JSON COMMENT 'Array of rival team IDs',

    -- Status
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT 'ACTIVE, INACTIVE, DISBANDED',
    verified BOOLEAN DEFAULT FALSE COMMENT 'Verified team flag',
    founded_date DATE,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,

    FOREIGN KEY (captain_id) REFERENCES profiles(id) ON DELETE SET NULL,
    INDEX idx_region (region),
    INDEX idx_skill_level (skill_level),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Teams';

CREATE TABLE team_memberships (
    team_id BIGINT NOT NULL,
    profile_id BIGINT NOT NULL,

    role_in_team VARCHAR(20) NOT NULL COMMENT 'CAPTAIN, MEMBER, COACH',

    joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    left_at DATETIME,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (team_id, profile_id),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_profile_active (profile_id, is_active),
    INDEX idx_team_active (team_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Team memberships';

-- =====================================================
-- 4. POSTS (Unified: team_notices + recruit_posts + new)
-- =====================================================

CREATE TABLE posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Author
    author_id BIGINT NOT NULL COMMENT 'Author profile ID',
    author_name VARCHAR(100) COMMENT 'Denormalized for performance',

    -- Post type
    post_type VARCHAR(30) NOT NULL COMMENT 'TEAM_NOTICE, RECRUIT, COMMUNITY, EVENT, ANNOUNCEMENT',

    -- Related entity
    team_id BIGINT COMMENT 'For TEAM_NOTICE, RECRUIT types',

    -- Content
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),

    -- Metadata
    category VARCHAR(50) COMMENT 'MATCH, TRAINING, SOCIAL, FREE',
    tags JSON COMMENT 'Array of tags',

    -- RECRUIT type specific fields
    match_date DATE COMMENT 'Match schedule',
    target_type VARCHAR(30) COMMENT 'TEAM, INDIVIDUAL',
    region VARCHAR(100) COMMENT 'Recruit region',

    -- Statistics
    views INT DEFAULT 0,
    likes INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    shares INT DEFAULT 0,

    -- Status
    status VARCHAR(20) DEFAULT 'PUBLISHED' COMMENT 'DRAFT, PUBLISHED, CLOSED, DELETED',
    is_pinned BOOLEAN DEFAULT FALSE,
    is_reported BOOLEAN DEFAULT FALSE,

    -- Timestamps
    published_at DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME,

    FOREIGN KEY (author_id) REFERENCES profiles(id),
    FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
    INDEX idx_type_status (post_type, status),
    INDEX idx_team (team_id),
    INDEX idx_region_status (region, status),
    INDEX idx_created_desc (created_at DESC),
    FULLTEXT idx_search (title, content)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Unified posts table';

-- =====================================================
-- 5. APPLICATIONS
-- =====================================================

CREATE TABLE applications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    post_id BIGINT NOT NULL,
    applicant_id BIGINT NOT NULL COMMENT 'Applicant profile ID',

    message TEXT COMMENT 'Application message',

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING, ACCEPTED, REJECTED, CANCELLED',

    reviewed_at DATETIME,
    reviewer_id BIGINT COMMENT 'Reviewer profile ID',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (applicant_id) REFERENCES profiles(id),
    FOREIGN KEY (reviewer_id) REFERENCES profiles(id),
    INDEX idx_post (post_id),
    INDEX idx_applicant_status (applicant_id, status),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Applications';

-- =====================================================
-- 6. NOTIFICATIONS
-- =====================================================

CREATE TABLE notifications (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    receiver_id BIGINT NOT NULL COMMENT 'Receiver profile ID',

    type VARCHAR(50) NOT NULL COMMENT 'APPLICATION, MATCH, TEAM, COMMENT, LIKE',
    title VARCHAR(255),
    message TEXT NOT NULL,

    -- Related entity
    related_type VARCHAR(30) COMMENT 'POST, APPLICATION, MATCH, TEAM',
    related_id BIGINT,

    -- Status
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at DATETIME,

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME COMMENT 'Auto-delete after 90 days',

    FOREIGN KEY (receiver_id) REFERENCES profiles(id) ON DELETE CASCADE,
    INDEX idx_receiver_read (receiver_id, is_read),
    INDEX idx_created_desc (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Notifications';

-- =====================================================
-- 7. COMMENTS
-- =====================================================

CREATE TABLE comments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,

    -- Author
    author_id BIGINT NOT NULL COMMENT 'Author profile ID',
    author_name VARCHAR(100) COMMENT 'Denormalized',

    -- Content
    content TEXT NOT NULL,
    parent_comment_id BIGINT COMMENT 'For nested comments',

    -- Statistics
    likes INT DEFAULT 0,

    -- Status
    is_reported BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE COMMENT 'Soft delete',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES profiles(id),
    FOREIGN KEY (parent_comment_id) REFERENCES comments(id),
    INDEX idx_post (post_id),
    INDEX idx_author (author_id),
    INDEX idx_parent (parent_comment_id),
    INDEX idx_created_desc (created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Comments';

-- =====================================================
-- 8. MATCHES (NEW)
-- =====================================================

CREATE TABLE matches (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Match info
    match_date DATE NOT NULL,
    match_time TIME NOT NULL,
    venue VARCHAR(200) NOT NULL,
    venue_id BIGINT COMMENT 'Venue ID (future venues table)',
    venue_url VARCHAR(500) COMMENT 'External venue link',

    -- Teams
    home_team_id BIGINT NOT NULL,
    away_team_id BIGINT NOT NULL,
    home_score INT,
    away_score INT,

    -- Status
    status VARCHAR(30) DEFAULT 'SCHEDULED' COMMENT 'SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED',

    -- Operations
    referee VARCHAR(100),
    weather VARCHAR(50),
    temperature INT COMMENT 'Temperature in Celsius',

    -- Timestamps
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (home_team_id) REFERENCES teams(id),
    FOREIGN KEY (away_team_id) REFERENCES teams(id),
    INDEX idx_match_date (match_date),
    INDEX idx_status (status),
    INDEX idx_home_team (home_team_id),
    INDEX idx_away_team (away_team_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Matches';

CREATE TABLE match_lineups (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,
    profile_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL,

    -- Player info
    jersey_number INT,
    position VARCHAR(30),
    is_starter BOOLEAN DEFAULT TRUE,

    -- Match record
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    red_cards INT DEFAULT 0,
    rating DECIMAL(3,1) COMMENT 'Rating 0.0 ~ 10.0',

    -- Attendance
    is_no_show BOOLEAN DEFAULT FALSE,
    attendance_status VARCHAR(30) DEFAULT 'PRESENT' COMMENT 'PRESENT, NO_SHOW, LATE',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    FOREIGN KEY (profile_id) REFERENCES profiles(id),
    FOREIGN KEY (team_id) REFERENCES teams(id),
    UNIQUE KEY uk_match_profile (match_id, profile_id),
    INDEX idx_profile (profile_id),
    INDEX idx_team (team_id),
    INDEX idx_attendance (attendance_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Match lineups';

CREATE TABLE match_management_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,

    -- Management action
    action_type VARCHAR(50) NOT NULL COMMENT 'CREATE, UPDATE, STATUS_CHANGE, SCORE_INPUT, MEMO, NO_SHOW, CANCEL',
    action VARCHAR(100) NOT NULL,
    description TEXT,

    -- Admin info
    admin_id BIGINT,
    admin_name VARCHAR(100),

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    INDEX idx_match (match_id),
    INDEX idx_action_type (action_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Match management logs';

CREATE TABLE match_notes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,

    note_text TEXT NOT NULL,
    author_id BIGINT,
    author_name VARCHAR(100),

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (match_id) REFERENCES matches(id) ON DELETE CASCADE,
    INDEX idx_match (match_id),
    INDEX idx_author (author_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Match notes';

-- =====================================================
-- 9. REPORTS & SANCTIONS (NEW)
-- =====================================================

CREATE TABLE reports (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Report info
    report_type VARCHAR(50) NOT NULL COMMENT 'USER, TEAM, POST, COMMENT, MATCH',
    target_type VARCHAR(50) NOT NULL,
    target_id BIGINT NOT NULL,

    -- Reporter/Reported
    reporter_id BIGINT NOT NULL,
    reported_id BIGINT NOT NULL,

    -- Report content
    reason VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL COMMENT 'NO_SHOW, ABUSE, CHEATING, HARASSMENT, OTHER',
    description TEXT NOT NULL,
    severity VARCHAR(30) DEFAULT 'MEDIUM' COMMENT 'LOW, MEDIUM, HIGH, CRITICAL',

    -- Processing
    status VARCHAR(30) DEFAULT 'PENDING' COMMENT 'PENDING, IN_PROGRESS, RESOLVED, REJECTED',
    assigned_admin_id BIGINT,
    resolution TEXT,
    resolved_at DATETIME,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_status (status),
    INDEX idx_reporter (reporter_id),
    INDEX idx_reported (reported_id),
    INDEX idx_category (category),
    INDEX idx_severity (severity),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Reports';

CREATE TABLE report_evidences (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    report_id BIGINT NOT NULL,

    evidence_type VARCHAR(30) NOT NULL COMMENT 'IMAGE, VIDEO, CHAT_LOG, SCREENSHOT',
    file_url VARCHAR(500) NOT NULL,
    description TEXT,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
    INDEX idx_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Report evidences';

CREATE TABLE sanctions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Sanction target
    target_type VARCHAR(30) NOT NULL COMMENT 'USER, TEAM',
    target_id BIGINT NOT NULL,

    -- Sanction info
    sanction_type VARCHAR(30) NOT NULL COMMENT 'WARNING, SUSPENSION, PERMANENT_BAN',
    reason TEXT NOT NULL,
    duration_days INT,

    -- Related report
    report_id BIGINT,

    -- Admin info
    admin_id BIGINT NOT NULL,
    admin_name VARCHAR(100),

    -- Status
    status VARCHAR(30) DEFAULT 'ACTIVE' COMMENT 'ACTIVE, LIFTED, EXPIRED',
    lifted_at DATETIME,
    expires_at DATETIME,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (report_id) REFERENCES reports(id),
    INDEX idx_target (target_type, target_id),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sanctions';

-- =====================================================
-- 10. ADDITIONAL TABLES (NEW)
-- =====================================================

CREATE TABLE post_edit_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,

    edit_type VARCHAR(30) NOT NULL COMMENT 'CREATE, UPDATE, STATUS_CHANGE, DELETE',
    editor_id BIGINT,
    editor_name VARCHAR(100),
    editor_type VARCHAR(30) COMMENT 'AUTHOR, ADMIN',

    changes JSON COMMENT 'Changed fields',
    description TEXT,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    INDEX idx_post (post_id),
    INDEX idx_edit_type (edit_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Post edit history';

CREATE TABLE peer_surveys (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    match_id BIGINT NOT NULL,

    evaluator_id BIGINT NOT NULL,
    evaluated_id BIGINT NOT NULL,

    -- Rating items (out of 5.00)
    teamwork DECIMAL(3,2),
    communication DECIMAL(3,2),
    skill_level DECIMAL(3,2),
    sportsmanship DECIMAL(3,2),
    punctuality DECIMAL(3,2),
    attitude DECIMAL(3,2),

    -- Tags
    tags JSON COMMENT 'Evaluation tags',

    -- Overall
    overall_rating DECIMAL(3,2),
    comment TEXT,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (match_id) REFERENCES matches(id),
    FOREIGN KEY (evaluator_id) REFERENCES profiles(id),
    FOREIGN KEY (evaluated_id) REFERENCES profiles(id),
    UNIQUE KEY uk_survey (match_id, evaluator_id, evaluated_id),
    INDEX idx_evaluated (evaluated_id),
    INDEX idx_evaluator (evaluator_id),
    INDEX idx_match (match_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Peer surveys';

CREATE TABLE user_stats_summary (
    profile_id BIGINT PRIMARY KEY,

    -- Match stats
    total_matches INT DEFAULT 0,
    wins INT DEFAULT 0,
    draws INT DEFAULT 0,
    losses INT DEFAULT 0,
    win_rate DECIMAL(5,2) DEFAULT 0,

    -- Morning soccer metrics
    manner_temperature DECIMAL(5,2) DEFAULT 36.5,
    no_show_count INT DEFAULT 0,
    consecutive_attendance INT DEFAULT 0,
    morning_participation_rate DECIMAL(5,2) DEFAULT 0,

    -- Peer evaluation averages
    avg_teamwork DECIMAL(3,2),
    avg_communication DECIMAL(3,2),
    avg_skill_level DECIMAL(3,2),
    avg_sportsmanship DECIMAL(3,2),
    avg_punctuality DECIMAL(3,2),

    -- Activity stats
    posts_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,

    last_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User statistics summary';

CREATE TABLE user_activity_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    profile_id BIGINT NOT NULL,

    activity_type VARCHAR(50) NOT NULL COMMENT 'POST, COMMENT, APPLICATION, TEAM_JOIN, MATCH, PAYMENT',
    activity_title VARCHAR(255),
    activity_description TEXT,

    status VARCHAR(30) COMMENT 'SUCCESS, PENDING, REJECTED',

    related_type VARCHAR(50),
    related_id BIGINT,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (profile_id) REFERENCES profiles(id),
    INDEX idx_profile (profile_id),
    INDEX idx_activity_type (activity_type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User activity logs';

CREATE TABLE team_activity_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id BIGINT NOT NULL,

    activity_type VARCHAR(50) NOT NULL COMMENT 'MEMBER_JOIN, MEMBER_LEAVE, MATCH_WIN, MATCH_DRAW, MATCH_LOSS, PRACTICE',
    activity_title VARCHAR(255),
    activity_description TEXT,

    related_type VARCHAR(50),
    related_id BIGINT,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (team_id) REFERENCES teams(id),
    INDEX idx_team (team_id),
    INDEX idx_activity_type (activity_type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Team activity logs';

CREATE TABLE admin_action_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    admin_id BIGINT NOT NULL,
    admin_name VARCHAR(100),

    action_type VARCHAR(50) NOT NULL COMMENT 'USER_BAN, POST_DELETE, MATCH_CANCEL, REPORT_RESOLVE',
    target_type VARCHAR(50) NOT NULL,
    target_id BIGINT,

    action_description TEXT,
    changes_made JSON,
    reason TEXT,

    ip_address VARCHAR(45),
    device_info VARCHAR(255),

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_admin (admin_id),
    INDEX idx_action_type (action_type),
    INDEX idx_target (target_type, target_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Admin action logs';

CREATE TABLE venues (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Basic info
    name VARCHAR(200) NOT NULL,
    address VARCHAR(500),
    detail_address VARCHAR(200),
    region VARCHAR(100),
    sub_region VARCHAR(100),

    -- Facility info
    venue_type VARCHAR(30) COMMENT 'INDOOR, OUTDOOR',
    surface VARCHAR(50) COMMENT 'Artificial turf, natural grass, urethane',
    capacity INT,
    facilities JSON COMMENT 'Array of facility names',

    -- Operations
    operating_hours JSON,
    pricing JSON,

    -- Contact
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_name VARCHAR(100),

    -- Stats
    total_matches INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,

    -- Status
    status VARCHAR(30) DEFAULT 'ACTIVE' COMMENT 'ACTIVE, INACTIVE, MAINTENANCE',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_name (name),
    INDEX idx_region (region),
    INDEX idx_venue_type (venue_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Venues';

-- =====================================================
-- End of Schema Creation
-- =====================================================
