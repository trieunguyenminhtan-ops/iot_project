-- ============================================================
-- MIGRATION: 003_fix_sensor_display_names.sql
-- Chuẩn hóa tên hiển thị tiếng Việt và loại cảm biến (Idempotent)
-- ============================================================

USE iot_project;

UPDATE sensors SET sensor_name = 'Cảm biến Nhiệt độ DHT11', unit = '°C' WHERE sensor_code = 'dht11_temp';
UPDATE sensors SET sensor_name = 'Cảm biến Độ ẩm DHT11', unit = '%' WHERE sensor_code = 'dht11_hum';
UPDATE sensors SET sensor_name = 'Quang trở LDR', unit = 'lux' WHERE sensor_code = 'ldr_light';
UPDATE sensors SET sensor_name = 'Cảm biến 1', unit = 'đv' WHERE sensor_code = 'RND1';
UPDATE sensors SET sensor_name = 'Cảm biến 2', unit = '%' WHERE sensor_code = 'RND2';
UPDATE sensors SET sensor_name = 'Cảm biến 3', unit = 'pts' WHERE sensor_code = 'RND3';
