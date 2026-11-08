-- ============================================================
-- MIGRATION: 002_add_alert_threshold.sql
-- Thêm cột alert_threshold vào bảng sensors và gán giá trị mặc định (Idempotent)
-- ============================================================

USE iot_project;

-- 1. Thêm cột alert_threshold nếu chưa có (chỉ cho phép INT, mặc định NULL)
SET @dbname = DATABASE();
SET @tablename = 'sensors';
SET @columnname = 'alert_threshold';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = @columnname
  ) > 0,
  'SELECT 1',
  'ALTER TABLE sensors ADD COLUMN alert_threshold INT NULL AFTER unit'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 2. Đặt giá trị ngưỡng mặc định cho 3 cảm biến ngẫu nhiên khi giá trị đang NULL:
--    - RND1: 5   (dải 0..10, mặc định 50% max)
--    - RND2: 50  (dải 0..100, mặc định 50% max)
--    - RND3: 500 (dải 0..1000, mặc định 50% max)
-- Các cảm biến khác (dht11_temp, dht11_hum, ldr_light) giữ nguyên NULL.
UPDATE sensors SET alert_threshold = 5 WHERE sensor_code = 'RND1' AND alert_threshold IS NULL;
UPDATE sensors SET alert_threshold = 50 WHERE sensor_code = 'RND2' AND alert_threshold IS NULL;
UPDATE sensors SET alert_threshold = 500 WHERE sensor_code = 'RND3' AND alert_threshold IS NULL;
