# Antigravity Agent Guidelines for IoT Project

Dự án Hệ thống giám sát và điều khiển IoT (NodeMCU ESP8266, Mosquitto MQTT, Node-RED, MySQL 8).

## 1. Phần cứng & Đấu nối
- **Vi điều khiển**: NodeMCU v3 (ESP8266, chip nạp CH340).
- **Cảm biến nhiệt độ & độ ẩm**: DHT11 kết nối chân dữ liệu vào **D2** (GPIO4).
- **Cảm biến ánh sáng**: Quang trở LDR (chân analog AO) nối vào chân **A0** (giá trị ADC: 0 - 1023).
- **Đèn LED 1**: Chân dương nối vào **D5** (GPIO14) qua điện trở 220Ω.
- **Đèn LED 2**: Chân dương nối vào **D6** (GPIO12) qua điện trở 220Ω.

## 2. Giao thức MQTT
- **Broker**: Mosquitto (port 8000).
- **Topic dữ liệu cảm biến**: `data/sensor` — payload JSON: `{"temp": float, "hum": float, "light": int}` (5s/lần).
- **Topic điều khiển đơn lẻ**: `device/control/led1`, `device/control/led2` — payload: `ON` hoặc `OFF`.
- **Topic điều khiển đồng thời**: `device/control/all` — payload JSON: `{"led1":"ON","led2":"OFF"}`.
- **Topic phản hồi thiết bị**: `device/response` — payload JSON: `{"id": int, "device": string, "state": string, "status": "success"|"false"}`.

## 3. Cơ sở dữ liệu (MySQL `iot_project` - 5 bảng)
Cấu trúc 5 bảng chuẩn theo ERD và các mối liên hệ:
1. **devices - actions - users**:
   - Bảng `users`: Quản lý người dùng và phân quyền (`role`: `'admin'` hoặc `'viewer'`).
   - Bảng `devices`: Danh mục thiết bị điều khiển (`led1`: ID 1, `led2`: ID 2).
   - Bảng `actions`: Lịch sử điều khiển (`device_id` FK -> `devices`, `user_id` FK -> `users`), trạng thái (`pending`, `success`, `failed`, `timeout`), thời gian phản hồi `response_ms`.
2. **sensors - data_sensors**:
   - Bảng `sensors`: Danh mục cảm biến (`dht11_temp`: ID 1, `dht11_hum`: ID 2, `ldr_light`: ID 3).
   - Bảng `data_sensors`: Lưu lịch sử đo đạc từ cảm biến (`sensor_id` FK -> `sensors`, giá trị `value`, thời gian `recorded_at`).

## 4. Tài khoản phân quyền mẫu
- **Admin**: `admin` / `admin123` (Toàn quyền bật/tắt đèn, xem dashboard, datasensor, actionhistory).
- **User**: `user` / `user123` (Quyền bật/tắt đèn, xem dashboard, datasensor, actionhistory).
- **Viewer**: `viewer` / `viewer123` (Chỉ xem dữ liệu trên dashboard; không có quyền điều khiển đèn, không được xem datasensor, actionhistory, profile).

## 5. Lệnh biên dịch & Nạp Firmware (PlatformIO)
Khi chạy lệnh trong Antigravity IDE Terminal:
```powershell
# Biên dịch
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" run

# Nạp vào NodeMCU (cắm cáp USB)
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" run -t upload

# Mở Serial Monitor
& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" device monitor
```
> **Lưu ý quan trọng**: Thư mục dự án không được chứa dấu tiếng Việt hoặc khoảng trắng để trình biên dịch Xtensa GCC không bị lỗi `Invalid argument`. Nên đặt tại `C:\iot-project` hoặc `D:\iot-project`.

