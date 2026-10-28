-- ============================================================
-- DATABASE: iot_project
-- Cấu trúc 5 bảng chuẩn theo ERD:
-- 1. devices - actions - users
-- 2. sensors - data_sensors
-- Engine: MySQL / MariaDB 10.x
-- ============================================================

-- Ép charset của phiên kết nối để tiếng Việt không bị lỗi mã hóa khi import
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS iot_project;
CREATE DATABASE iot_project
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE iot_project;

-- ------------------------------------------------------------
-- 1. Bảng: users (Quản lý người dùng & phân quyền)
-- ------------------------------------------------------------
CREATE TABLE users (
  user_id     INT(11)       NOT NULL AUTO_INCREMENT,
  username    VARCHAR(50)   NOT NULL,
  password    VARCHAR(255)  NOT NULL,
  full_name   VARCHAR(100)  NOT NULL,
  email       VARCHAR(100)  NULL,
  role        VARCHAR(20)   NOT NULL DEFAULT 'viewer',
  created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status      TINYINT(4)    NOT NULL DEFAULT 1,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 2. Bảng: devices (Danh mục thiết bị điều khiển)
-- ------------------------------------------------------------
CREATE TABLE devices (
  device_id    INT(11)      NOT NULL AUTO_INCREMENT,
  device_code  VARCHAR(50)  NOT NULL,
  device_name  VARCHAR(100) NOT NULL,
  device_type  VARCHAR(50)  NOT NULL,
  status       VARCHAR(20)  NOT NULL DEFAULT 'offline',
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME     NULL,
  PRIMARY KEY (device_id),
  UNIQUE KEY uq_devices_code (device_code)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 3. Bảng: sensors (Danh mục cảm biến)
-- ------------------------------------------------------------
CREATE TABLE sensors (
  sensor_id    BIGINT(20)   NOT NULL AUTO_INCREMENT,
  sensor_code  VARCHAR(50)  NULL,
  sensor_name  VARCHAR(100) NOT NULL,
  sensor_type  VARCHAR(30)  NOT NULL,
  unit         VARCHAR(20)  NULL,
  created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (sensor_id),
  UNIQUE KEY uq_sensors_code (sensor_code)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 4. Bảng: actions (Mối quan hệ: devices - actions - users)
-- Lưu lịch sử điều khiển của người dùng đối với thiết bị
-- ------------------------------------------------------------
CREATE TABLE actions (
  action_id      BIGINT(20)  NOT NULL AUTO_INCREMENT,
  device_id      INT(11)     NULL,
  user_id        INT(11)     NULL,
  action         TEXT        NOT NULL,
  status         TEXT        NOT NULL,
  time           DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  time_response  DATETIME(3) NULL,
  PRIMARY KEY (action_id),
  CONSTRAINT fk_actions_device FOREIGN KEY (device_id) REFERENCES devices(device_id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_actions_user FOREIGN KEY (user_id) REFERENCES users(user_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- 5. Bảng: data_sensors (Mối quan hệ: sensors - data_sensors)
-- Lưu lịch sử dữ liệu đo đạc từ các cảm biến
-- ------------------------------------------------------------
CREATE TABLE data_sensors (
  data_id      BIGINT(20)     NOT NULL AUTO_INCREMENT,
  sensor_id    BIGINT(20)     NOT NULL,
  value        DECIMAL(10,2)  NOT NULL,
  recorded_at  DATETIME       NOT NULL,
  created_at   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (data_id),
  CONSTRAINT fk_data_sensors_sensor FOREIGN KEY (sensor_id) REFERENCES sensors(sensor_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- SEED DATA (DỮ LIỆU BAN ĐẦU)
-- ============================================================

-- 1. Tài khoản mẫu: Admin, User và Viewer
INSERT INTO users (username, password, full_name, email, role, status) VALUES
  ('admin', 'admin123', 'Quản trị viên', 'admin@iot.local', 'admin', 1),
  ('user', 'user123', 'Người dùng', 'user@iot.local', 'user', 1),
  ('viewer', 'viewer123', 'Người xem (Chỉ xem)', 'viewer@iot.local', 'viewer', 1);

-- 2. Thiết bị điều khiển (led1, led2)
INSERT INTO devices (device_code, device_name, device_type, status) VALUES
  ('led1', 'Đèn 1', 'LED', 'off'),
  ('led2', 'Đèn 2', 'LED', 'off');

-- 3. Cảm biến (1: Nhiệt độ, 2: Độ ẩm, 3: Ánh sáng)
INSERT INTO sensors (sensor_code, sensor_name, sensor_type, unit) VALUES
  ('dht11_temp', 'Cảm biến Nhiệt độ DHT11', 'temperature', '°C'),
  ('dht11_hum',  'Cảm biến Độ ẩm DHT11',    'humidity',    '%'),
  ('ldr_light',  'Quang trở LDR',           'light',       'lux');
