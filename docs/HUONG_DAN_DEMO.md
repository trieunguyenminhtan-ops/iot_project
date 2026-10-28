# QUY TRÌNH CHUẨN BỊ VÀ THỰC HIỆN DEMO ĐỒ ÁN IOT
> **Dự án**: Hệ thống Giám sát & Điều khiển IoT (NodeMCU ESP8266 · Mosquitto MQTT · Node-RED · MySQL · Web Dashboard)  
> **Thời gian chuẩn bị**: ~2 phút từ lúc mở máy tính.

---

## MỤC LỤC
1. [Sơ đồ kết nối & Chuẩn bị phần cứng](#1-sơ-đồ-kết-nối--chuẩn-bị-phần-cứng)
2. [Các bước khởi động hệ thống khi vừa bật máy tính](#2-các-bước-khởi-động-hệ-thống-khi-vừa-bật-máy-tính)
3. [Kịch bản 5 bước trình diễn trước giảng viên / ban giám khảo](#3-kịch-bản-5-bước-trình-diễn-trước-giảng-viên)
4. [Bảng tài khoản & Thông số kỹ thuật nhanh](#4-bảng-tài-khoản--thông-số-kỹ-thuật-nhanh)
5. [Cẩm nang xử lý sự cố khẩn cấp (Troubleshooting)](#5-cẩm-nang-xử-lý-sự-cố-khẩn-cấp)

---

## 1. SƠ ĐỒ KẾT NỐI & CHUẨN BỊ PHẦN CỨNG

Trước khi cắm nguồn, kiểm tra nhanh các chân cắm trên Breadboard:

| Linh kiện | Chân linh kiện | Chân NodeMCU | Ghi chú |
|---|---|---|---|
| **DHT11** | VCC / GND / DATA | `3V3` / `GND` / **`D2`** (GPIO4) | Cảm biến Nhiệt độ & Độ ẩm |
| **Quang trở LDR** | VCC / GND / AO | `3V3` / `GND` / **`A0`** (ADC0) | Đo ánh sáng (0 - 1023) |
| **Đèn LED 1** | (+) Anode / (-) Cathode | **`D5`** (GPIO14) qua trở 220Ω / `GND` | Đèn số 1 |
| **Đèn LED 2** | (+) Anode / (-) Cathode | **`D6`** (GPIO12) qua trở 220Ω / `GND` | Đèn số 2 |

---

## 2. CÁC BƯỚC KHỞI ĐỘNG HỆ THỐNG (KHI VỪA BẬT MÁY TÍNH)

Thực hiện theo đúng thứ tự 4 bước sau (mất khoảng 1 - 2 phút):

### Bước 2.1: Kết nối WiFi
1. Bật điểm phát sóng WiFi (Hotspot điện thoại hoặc kết nối chung WiFi phòng học/lab).
   *(Ví dụ: WiFi tên `Hash`, băng tần 2.4 GHz).*
2. Kết nối máy tính vào mạng WiFi này.
3. Mở CMD, gõ `ipconfig` để kiểm tra IPv4 của máy tính (đảm bảo khớp với `mqtt_server` trong file `secrets.h`, ví dụ `10.177.124.5`).

### Bước 2.2: Đảm bảo Mosquitto Broker & MySQL đang chạy
- Mosquitto (port 8000) và MySQL 8 (port 3306) đã được cài đặt tự chạy cùng Windows.
- Nếu muốn chắc chắn, mở **CMD (Admin)** gõ nhanh:
  ```cmd
  net start mosquitto
  net start MySQL80
  ```
  *(Nếu hiện "The requested service has already been started" là đã chạy sẵn).*

### Bước 2.3: Khởi động Backend Node-RED (Port 8800)
1. Vào thư mục dự án `D:\iot-project\scripts\windows\`.
2. **Nhấp đúp chuột chạy file: `start-node-red.bat`**.
3. Cửa sổ màu đen Node-RED hiện lên với thông báo:
   ```text
   [info] Server now running at http://127.0.0.1:8800/
   [info] HTTP Static : D:\iot-project\frontend
   ```
4. **Thu nhỏ (Minimize `_`) cửa sổ đen này xuống thanh Taskbar** (KHÔNG ĐƯỢC TẮT).

### Bước 2.4: Cấp nguồn NodeMCU & Kiểm tra kết nối
1. Cắm cáp USB nối NodeMCU vào máy tính (Cổng **`COM6`**).
2. Mở trình duyệt web truy cập:
   👉 **`http://localhost:8800/dashboard.html`**
3. Trên giao diện web, quan sát 3 thẻ **Nhiệt độ**, **Độ ẩm**, **Ánh sáng** bắt đầu nhảy số liệu thực tế mỗi 5 giây ➔ **Hệ thống đã online 100%!**

*(Tùy chọn: Muốn xem log vi điều khiển, trong Antigravity IDE bấm biểu tượng phích cắm `🔌` hoặc chạy `& "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe" device monitor`)*.

---

## 3. KỊCH BẢN 5 BƯỚC TRÌNH DIỄN TRƯỚC GIẢNG VIÊN

Hãy thực hiện theo kịch bản mạch lạc sau để đạt điểm tối đa:

### 🟢 Màn 1: Giới thiệu kiến trúc tổng quan (30 giây)
- Mở Dashboard tại `http://localhost:8800/dashboard.html`.
- Giới thiệu ngắn:
  > *"Hệ thống gồm NodeMCU ESP8266 đọc cảm biến DHT11 và quang trở, đẩy dữ liệu qua giao thức MQTT tới Mosquitto Broker (port 8000). Backend Node-RED (port 8800) lắng nghe, lưu vào cơ sở dữ liệu MySQL và phân phối lên giao diện Web Dashboard theo thời gian thực."*

### 🟢 Màn 2: Giám sát cảm biến theo thời gian thực (1 phút)
1. Chỉ vào 3 thẻ số liệu lớn (Nhiệt độ, Độ ẩm, Ánh sáng) và biểu đồ đường bên dưới: số liệu tự động cập nhật mỗi 5 giây mà không cần reload trang.
2. **Tác động vật lý:** Thổi hơi ấm vào cảm biến DHT11 ➔ Chỉ vào màn hình để thấy độ ẩm và nhiệt độ tăng lên rõ rệt.
3. Chuyển sang tab **"Data sensor"**: Trình diễn tính năng tìm kiếm lịch sử, lọc theo loại cảm biến (Nhiệt độ / Độ ẩm / Ánh sáng) và phân trang.

### 🟢 Màn 3: Điều khiển bật/tắt 2 đèn LED & Phân quyền RBAC (1.5 phút)
1. **Kiểm tra trạng thái Admin:**
   - Nhìn sang góc trái trên thanh điều hướng: Đang có huy hiệu màu đỏ **`ADMIN`**.
   - Bấm nút công tắc **Đèn 1** ➔ Đèn LED 1 trên mạch sáng ngay lập tức.
   - Bấm nút công tắc **Đèn 2** ➔ Đèn LED 2 trên mạch sáng.
   - Bấm tắt cả 2 đèn ➔ LED thực tế tắt theo.
2. **Kiểm tra nhật ký kiểm toán (Audit Log):**
   - Chuyển sang tab **"Action history"**.
   - Chỉ cho giảng viên thấy: Mỗi lần bật/tắt đều lưu lại rõ ràng:
     - *Người thực hiện: `admin`*
     - *Thiết bị: `led1` / `led2`*
     - *Hành động: `ON` / `OFF`*
     - *Thời gian phản hồi từ mạch: `... ms`* (phản ánh độ trễ mạng thực tế).
3. **Thử nghiệm phân quyền Viewer (Người xem):**
   - Bấm nút **"Đổi sang Viewer"** ở thanh menu bên trái.
   - Huy hiệu đổi sang màu xanh **`VIEWER`**, 2 công tắc đèn bị khóa mờ, hiện thông báo *"Chế độ chỉ xem"*.
   - Thử bấm vào công tắc ➔ Hệ thống hiện cảnh báo: *"Chỉ tài khoản Admin mới có quyền điều khiển!"*.
   - Bấm lại nút **"Đổi sang Admin"** để lấy lại toàn quyền.

### 🟢 Màn 4: Trang Profile sinh viên & Báo cáo đồ án (30 giây)
- Bấm vào tab **"Profile"**.
- Hiển thị thông tin sinh viên, lớp, đề tài, các đường liên kết nộp bài (GitHub, Postman API Docs, Figma Prototype) và nút mở file Báo cáo PDF.

---

## 4. BẢNG TÀI KHOẢN & THÔNG SỐ KỸ THUẬT NHANH

| Hạng mục | Thông số |
|---|---|
| **URL Giao diện Web** | `http://localhost:8800/dashboard.html` |
| **Tài khoản Admin** | `admin` / `admin123` (Toàn quyền bật/tắt thiết bị, xem Data sensor & Action history) |
| **Tài khoản User** | `user` / `user123` (Quyền bật/tắt thiết bị, xem Data sensor & Action history) |
| **Tài khoản Viewer** | `viewer` / `viewer123` (Chỉ xem Dashboard; không được điều khiển và không được xem Data sensor, Action history, Profile) |
| **Mosquitto MQTT Broker** | Port `8000` (User: `b23dcat271` / Pass: `trieunguyenminhtan`) |
| **Node-RED Backend** | Port `8800` (Chạy bằng file `scripts/windows/start-node-red.bat`) |
| **Cơ sở dữ liệu MySQL** | Database: `iot_project` (User: `iot` / Pass: `iot123`) |
| **Cổng nạp NodeMCU** | `COM6` (Baud rate: `115200`) |

---

## 5. CẨM NANG XỬ LÝ SỰ CỐ KHẨN CẤP (NẾU GẶP LỖI KHI DEMO)

### ❓ Tình huống 1: Mở web báo "This site can't be reached" (Lỗi 404 / Không tải được trang)
- **Nguyên nhân:** Cửa sổ đen Node-RED chưa được bật hoặc vô tình bị đóng.
- **Xử lý:** Nhấp đúp chuột chạy lại file `D:\iot-project\scripts\windows\start-node-red.bat`.

### ❓ Tình huống 2: Đổi mạng WiFi mới (ví dụ mang laptop và mạch lên lớp phát hotspot khác)
- **Nguyên nhân:** Địa chỉ IPv4 của máy tính bị thay đổi.
- **Xử lý:**
  1. Mở CMD gõ `ipconfig` xem IPv4 mới (ví dụ thành `192.168.43.10`).
  2. Mở file `firmware/include/secrets.h`:
     - Sửa `ssid` và `password` thành tên/mật khẩu WiFi mới.
     - Sửa `mqtt_server` thành IPv4 mới.
  3. Bấm **Upload `→`** để nạp lại vào NodeMCU (mất ~15 giây).

### ❓ Tình huống 3: Số liệu cảm biến trên Dashboard đứng yên không nhảy số
- **Kiểm tra 1:** Nhìn cửa sổ đen Node-RED, kiểm tra xem có báo lỗi MySQL không.
- **Kiểm tra 2:** Mở CMD (Admin) kiểm tra Mosquitto:
  ```cmd
  net start mosquitto
  ```
- **Kiểm tra 3:** Bấm nút **RST** trên mạch NodeMCU một lần để mạch khởi động lại kết nối.

### ❓ Tình huống 4: Khi bấm bật/tắt đèn hiện bảng đăng nhập cản trở
- **Xử lý:** Bấm vào nút màu đỏ **`Admin (Toàn quyền)`** trên bảng đăng nhập. Hệ thống sẽ tự động đăng nhập tài khoản `admin` / `admin123` và không bao giờ hỏi lại nữa.

