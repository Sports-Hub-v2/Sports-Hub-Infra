-- Initialize unified database for Sports Hub (Monolithic Architecture)
-- Changed from microservice-specific databases to single unified database

CREATE DATABASE IF NOT EXISTS sportshub_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- The user 'sportshub' is created by the official image when MYSQL_USER/MYSQL_PASSWORD are provided.
-- Grant access to the unified database for that user.
GRANT ALL PRIVILEGES ON sportshub_db.* TO 'sportshub'@'%';
FLUSH PRIVILEGES;
