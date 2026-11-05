-- ============================================================
-- MIGRATION: 001_add_random_sensors.sql
-- Thêm 3 cảm biến ngẫu nhiên vào bảng sensors (Idempotent)
-- ============================================================

USE iot_project;

-- Thêm RND1 (0..10) nếu chưa có
INSERT INTO sensors (sensor_code, sensor_name, sensor_type, unit)
SELECT 'RND1', 'Cảm biến Ngẫu nhiên 1', 'random', 'đv'
WHERE NOT EXISTS (
    SELECT 1 FROM sensors WHERE sensor_code = 'RND1'
);

-- Thêm RND2 (0..100) nếu chưa có
INSERT INTO sensors (sensor_code, sensor_name, sensor_type, unit)
SELECT 'RND2', 'Cảm biến Ngẫu nhiên 2', 'random', '%'
WHERE NOT EXISTS (
    SELECT 1 FROM sensors WHERE sensor_code = 'RND2'
);

-- Thêm RND3 (0..1000) nếu chưa có
INSERT INTO sensors (sensor_code, sensor_name, sensor_type, unit)
SELECT 'RND3', 'Cảm biến Ngẫu nhiên 3', 'random', 'pts'
WHERE NOT EXISTS (
    SELECT 1 FROM sensors WHERE sensor_code = 'RND3'
);

