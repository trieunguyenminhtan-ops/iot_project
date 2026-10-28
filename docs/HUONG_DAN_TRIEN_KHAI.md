# HƯỚNG DẪN TRIỂN KHAI TỪ A–Z (Windows 11)

Hệ thống: **NodeMCU ESP8266** (DHT11 + quang trở + 2 LED) → **MQTT (Mosquitto)** → **Node-RED** → **MySQL** → **giao diện web**.
Công cụ lập trình firmware: **VS Code + PlatformIO**. Cơ sở dữ liệu: **MySQL**.

Tài liệu gồm 2 nửa:

- **Phần 1–3:** cài đặt, nạp firmware, chạy và nghiệm thu hệ thống.
- **Phần 4–7:** đưa dự án lên **GitHub**, API lên **Postman**, giao diện lên **Figma**, rồi **gán 3 liên kết đó vào mục Profile**.

> **Phạm vi đã kiểm thử.** Phần dự án (SQL trên MySQL 8, flow Node-RED, 5 API, collection Postman, mã firmware) đã được chạy thử thật.
> Các bước thao tác trên Windows và giao diện của Postman/Figma/GitHub được viết theo tài liệu chính thức nhưng **chưa chạy trên máy Windows thật**; tên nút/menu có thể khác đôi chút giữa các phiên bản.
> Mục "Lỗi thường gặp" ở cuối giúp xử lý các tình huống hay gặp.

---

## 0. Chuẩn bị

### 0.1 Quy ước

- Dùng **Command Prompt (CMD)** cho mọi lệnh, không dùng PowerShell. (PowerShell 5.1 làm hỏng dấu `"` trong JSON và hay chặn script npm.) Mở CMD: bấm phím Windows → gõ `cmd` → Enter. Những chỗ cần quyền quản trị ghi rõ **"CMD (Admin)"**: chuột phải vào Command Prompt → *Run as administrator*.
- Trong các lệnh, các từ IN HOA dưới đây là **giá trị bạn tự đặt/điền**; đừng gõ nguyên chữ. Hãy chọn trước và ghi lại:

| Ký hiệu | Ý nghĩa | Giá trị của bạn |
|---|---|---|
| `MQTT_USER` / `MQTT_PASS` | Tài khoản MQTT (tự đặt) | |
| `MYSQL_ROOT_PASS` | Mật khẩu root MySQL (đặt khi cài) | |
| `MYSQL_IOT_PASS` | Mật khẩu user `iot` của MySQL (tự đặt) | |
| `IP_MAY_TINH` | IPv4 của máy Windows trong mạng WiFi/LAN | |
| `GITHUB_USER` | Tên tài khoản GitHub | |

- Đặt dự án ở đường dẫn ngắn, không dấu, không khoảng trắng: **`C:\iot-project`**.

### 0.2 Tài khoản cần có (đều miễn phí)

GitHub (`github.com`), Postman (`postman.com`), Figma (`figma.com`).

### 0.3 Phần cứng

NodeMCU Lua WiFi V3 (ESP8266, chip CH340), cảm biến DHT11 (3 chân), module cảm biến ánh sáng (4 chân), 2 LED 5mm + 2 điện trở 220Ω, breadboard, dây nối, cáp micro-USB **có truyền dữ liệu**.

### 0.4 Mạng

- Máy tính và NodeMCU phải **cùng một mạng WiFi/LAN**. NodeMCU chỉ dùng được WiFi **2.4GHz**.
- WiFi công cộng (trường học, quán cà phê) thường chặn thiết bị nói chuyện với nhau. Nên dùng WiFi nhà hoặc **điểm phát WiFi từ điện thoại**.

### 0.5 Giải nén dự án và lấy IP

1. Giải nén `iot-project.zip` vào thẳng ổ `C:\` (chuột phải → *Extract All* → nhập `C:\`) để có thư mục `C:\iot-project`.
2. Mở CMD, gõ `ipconfig`, ghi lại **IPv4 Address** của card đang nối mạng đó (mục *Wireless LAN adapter Wi-Fi* hoặc *Ethernet*). Đó là `IP_MAY_TINH`.
   - Nếu máy có VMware/VirtualBox sẽ có thêm các card `VMnet…`, `vEthernet…`: **không lấy nhầm** các card đó.
   - IP có thể đổi mỗi lần nối lại mạng; hãy gõ lại `ipconfig` trước mỗi buổi demo.

---

# PHẦN 1. CÀI ĐẶT PHẦN MỀM

## 1.1 Git (dùng cho Phần 4)

1. Tải **Git for Windows** tại `git-scm.com/download/win`, cài với tất cả tùy chọn mặc định (đã kèm Git Credential Manager để đăng nhập GitHub).
2. Mở CMD **mới**, kiểm tra và cấu hình tên/email (dùng cùng email GitHub):
   ```bat
   git --version
   git config --global user.name "Ho Ten Cua Ban"
   git config --global user.email "email@cua-ban.com"
   ```

## 1.2 Antigravity IDE / VS Code + PlatformIO

Dự án hoàn toàn tương thích và hoạt động mượt mà trên **Antigravity IDE** (do Antigravity IDE được xây dựng trên nền tảng VS Code) hoặc **Visual Studio Code**.

1. Cài đặt **Antigravity IDE** hoặc **Visual Studio Code**.
2. Mở IDE → biểu tượng **Extensions** (hoặc `Ctrl+Shift+X`) → tìm **PlatformIO IDE** (nhà phát hành *PlatformIO*) → **Install**.
3. Chờ PlatformIO cài lõi (cần Internet). Khi có thông báo, bấm **Reload Window**. Nếu PlatformIO báo thiếu Python: cài Python 3 từ `python.org`, **tick "Add python.exe to PATH"** rồi mở lại IDE.
4. Mở dự án: *File → Open Folder…* → chọn thư mục dự án (khuyến nghị **`C:\iot-project`** hoặc **`D:\iot-project`**, không chứa dấu tiếng Việt). Khi IDE hỏi "Do you trust the authors" chọn *Yes*. Nếu hiện gợi ý cài extension khuyến nghị (PlatformIO) thì chọn *Install*.
5. Ở thanh dưới cùng sẽ có các biểu tượng của PlatformIO: **✓ Build**, **→ Upload**, **🔌 Serial Monitor**. Nếu chưa thấy, mở tab PlatformIO (biểu tượng con kiến ở thanh bên trái) → *PIO Home* và đợi khởi tạo xong.
   *(Lưu ý: Trên Antigravity IDE, bạn có thể tương tác trực tiếp với AI Agent qua thanh chat bên phải để hỗ trợ giải thích code, gỡ lỗi và tự động hóa thao tác).*

## 1.3 Mosquitto (MQTT broker)

1. Tải bản **Windows x64** tại `mosquitto.org/download` và cài mặc định. Installer tạo dịch vụ **Mosquitto Broker** tự chạy cùng Windows, cài ở `C:\Program Files\mosquitto`.
2. **CMD (Admin)**, tạo tài khoản MQTT:
   ```bat
   cd /d "C:\Program Files\mosquitto"
   mosquitto_passwd -c -b users.pwd MQTT_USER MQTT_PASS
   ```
3. Mở file cấu hình bằng Notepad quyền admin:
   ```bat
   notepad "C:\Program Files\mosquitto\mosquitto.conf"
   ```
   Kéo xuống cuối file, thêm 3 dòng sau. Nếu file đã có dòng `listener` hoặc `allow_anonymous` chưa bị comment thì xóa dòng cũ đi. Đường dẫn phải **tuyệt đối và không đặt trong dấu ngoặc kép**:
   ```
   listener 8000
   allow_anonymous false
   password_file C:\Program Files\mosquitto\users.pwd
   ```
4. Chạy thử ở chế độ hiển thị lỗi (nếu cấu hình sai, dịch vụ chỉ tắt im lặng):
   ```bat
   net stop mosquitto
   cd /d "C:\Program Files\mosquitto"
   mosquitto -c mosquitto.conf -v
   ```
   Thấy dòng `Opening ipv4 listen socket on port 8000` là đúng. Nhấn `Ctrl+C`, rồi `net start mosquitto` (hoặc mở *Services* → "Mosquitto Broker" → Start).
5. **Mở tường lửa** cho NodeMCU và cho dashboard (**CMD Admin**):
   ```bat
   netsh advfirewall firewall add rule name="IoT MQTT 8000" dir=in action=allow protocol=TCP localport=8000
   netsh advfirewall firewall add rule name="IoT Node-RED 8800" dir=in action=allow protocol=TCP localport=8800
   ```
6. **Thêm Mosquitto vào PATH** để gõ `mosquitto_pub` ở bất cứ đâu: bấm Windows → gõ "Edit the system environment variables" → *Environment Variables* → ở *System variables* chọn `Path` → *Edit* → *New* → dán `C:\Program Files\mosquitto` → OK. Mở CMD mới rồi thử:
   ```bat
   mosquitto_sub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t test -v
   ```
   Mở thêm một CMD khác: `mosquitto_pub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t test -m hello`. Cửa sổ đầu hiện `test hello` là đạt. (Ctrl+C để thoát.)

## 1.4 MySQL

> Dự án đã được kiểm thử trên **MySQL 8.0.46** (Linux) với xác thực mặc định `caching_sha2_password`. Trên Windows nên dùng **MySQL 8.4 LTS**; cú pháp SQL và cách xác thực giống nhau.

1. Vào `dev.mysql.com/downloads/installer`, tải **MySQL Installer for Windows** (file `mysql-installer-community-8.4.x.msi`) và chạy.
2. Chọn *Setup Type* = **Server only** → *Next* → *Execute* để cài. Sau đó ở bước cấu hình:
   - **Type and Networking:** Config Type = *Development Computer*, TCP/IP, Port **3306**. **Bỏ tick** ô "Open Windows Firewall port for network access" (không cần).
   - **Authentication Method:** chọn **Use Strong Password Encryption (RECOMMENDED)**.
   - **Accounts and Roles:** đặt mật khẩu **root** (`MYSQL_ROOT_PASS`) và ghi nhớ.
   - **Windows Service:** giữ tên mặc định (thường là `MySQL84`), tick **Start the MySQL Server at System Startup**.
   - *Apply Configuration* → *Finish*.
3. **Thêm MySQL vào PATH** (cách làm giống bước 1.3.6) với đường dẫn `C:\Program Files\MySQL\MySQL Server 8.4\bin`. Mở CMD mới và kiểm tra:
   ```bat
   mysql -u root -p -e "SELECT VERSION();"
   ```
   Nhập `MYSQL_ROOT_PASS`. Thấy số phiên bản là đạt. (Nếu chưa thêm PATH, dùng đường dẫn đầy đủ `"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"`.)
4. **Nạp schema** (dùng dấu `/` trong đường dẫn):
   ```bat
   mysql -u root -p -e "source C:/iot-project/database/schema.sql"
   ```
   > ⚠️ Chạy lần thứ 2 sẽ báo lỗi `already exists`. Muốn nạp lại từ đầu (**xóa hết dữ liệu**), chạy trước:
   > `mysql -u root -p -e "DROP DATABASE IF EXISTS iot_project;"`
   > Nếu thấy cảnh báo "Integer display width is deprecated" thì bỏ qua, không ảnh hưởng.
5. **Tạo user riêng cho Node-RED** (đổi `MYSQL_IOT_PASS`):
   ```bat
   mysql -u root -p
   ```
   Dán vào dấu nhắc `mysql>`:
   ```sql
   CREATE USER IF NOT EXISTS 'iot'@'localhost' IDENTIFIED BY 'MYSQL_IOT_PASS';
   CREATE USER IF NOT EXISTS 'iot'@'127.0.0.1' IDENTIFIED BY 'MYSQL_IOT_PASS';
   GRANT ALL PRIVILEGES ON iot_project.* TO 'iot'@'localhost';
   GRANT ALL PRIVILEGES ON iot_project.* TO 'iot'@'127.0.0.1';
   FLUSH PRIVILEGES;
   exit
   ```
6. **Kiểm tra:**
   ```bat
   mysql -u iot -p -h 127.0.0.1 iot_project --default-character-set=utf8mb4 -e "SHOW TABLES; SELECT device_code, device_name FROM devices; SELECT username, role FROM users;"
   ```
   Kết quả đúng: 5 bảng (`actions`, `data_sensors`, `devices`, `sensors`, `users`), 2 thiết bị `led1 | Đèn 1`, `led2 | Đèn 2`, và 2 tài khoản mẫu `admin` (role admin), `viewer` (role viewer).
   *(Tùy chọn: dùng **MySQL Workbench** để xem bảng bằng giao diện, nhưng không bắt buộc.)*

## 1.5 Node.js và Node-RED

1. Tải **Node.js bản LTS** tại `nodejs.org` (Node-RED hiện tại yêu cầu Node.js **22.9 trở lên**) và cài mặc định. Mở CMD **mới**:
   ```bat
   node -v
   npm install -g --unsafe-perm node-red
   node-red
   ```
   Lần đầu Windows hỏi cho phép `node.exe` qua tường lửa → chọn **Allow**. Thấy dòng `Started flows` là xong. Thư mục cấu hình được tạo ở `C:\Users\<tên bạn>\.node-red`. Nhấn `Ctrl+C` để dừng.
2. Cho Node-RED phục vụ giao diện web: mở file cấu hình
   ```bat
   notepad %USERPROFILE%\.node-red\settings.js
   ```
   Dùng `Ctrl+F` tìm `httpStatic`, bỏ dấu `//` ở đầu dòng và sửa thành (dùng dấu `/`):
   ```js
   httpStatic: 'D:/iot-project/frontend',
   ```
   Lưu file.
3. Chạy lại `node-red -p 8800`, mở trình duyệt vào `http://localhost:8800`.
4. Cài node MySQL: menu ☰ → *Manage palette* → tab *Install* → tìm `node-red-node-mysql` → **Install**. Nếu lỗi, dùng CMD:
   ```bat
   cd /d %USERPROFILE%\.node-red
   npm install node-red-node-mysql
   ```
   rồi chạy lại `node-red -p 8800`.

## 1.6 Import flow và điền mật khẩu

1. Menu ☰ → *Import* → *select a file to import* → chọn `D:\iot-project\node-red\flow_iot_all.json` → **Import**. Sẽ có 2 tab: "1. Ghi du lieu" và "2. API cho Dashboard".
2. Node-RED không lưu mật khẩu trong file xuất, nên điền tay 2 chỗ:
   - **MQTT:** double-click một node `mqtt in` → bấm ✏️ cạnh ô *Server* → tab *Security* → Username `MQTT_USER`, Password `MQTT_PASS` → *Update*. (Tab *Connection* đã để sẵn `127.0.0.1:8000`, vì Node-RED và Mosquitto chạy cùng máy.)
   - **MySQL:** double-click một node `mysql` (vd "INSERT data_sensors") → bấm ✏️ cạnh ô *Database* → Host `127.0.0.1`, Port `3306`, User `iot`, Password `MYSQL_IOT_PASS`, Database `iot_project` → *Update*.
3. Bấm **Deploy** (nút đỏ góc trên bên phải). Các node `mqtt in` phải hiện chấm xanh **connected**.
4. **Kiểm tra khi chưa cắm phần cứng.** Giả lập NodeMCU gửi dữ liệu (trong CMD, `\"` là cách viết dấu `"` bên trong JSON):
   ```bat
   mosquitto_pub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t data/sensor -m "{\"temp\":28.5,\"hum\":65,\"light\":320}"
   mysql -u iot -p -h 127.0.0.1 iot_project -e "SELECT * FROM data_sensors;"
   ```
   Thấy 3 dòng (nhiệt độ, độ ẩm, ánh sáng) là đạt. Mở `http://localhost:8800/dashboard.html` sẽ thấy 28.5 / 65 / 320 trên 3 thẻ số liệu.

## 1.7 Tự khởi động khi bật máy

Mosquitto và MySQL đã tự chạy như dịch vụ. Với Node-RED: bấm `Win+R` → gõ `shell:startup` → Enter. Trong thư mục vừa mở, tạo shortcut tới `C:\iot-project\scripts\windows\start-node-red.bat` (chuột phải file → *Show more options* → *Create shortcut*, rồi kéo shortcut vào thư mục Startup).
Sau mỗi lần đăng nhập Windows, một cửa sổ đen Node-RED sẽ tự mở. **Đừng đóng cửa sổ đó** khi đang dùng.

Nên tắt chế độ ngủ để không bị ngắt giữa buổi demo: *Settings → System → Power → Screen and sleep → Never* (khi cắm điện).

---

# PHẦN 2. FIRMWARE VỚI PLATFORMIO

## 2.1 Đấu nối phần cứng

| Linh kiện | Chân NodeMCU |
|---|---|
| DHT11: VCC / GND / DATA | 3V3 / GND / **D2** (GPIO4) |
| Cảm biến ánh sáng: VCC / GND / AO | 3V3 / GND / **A0** (không dùng chân DO) |
| LED 1: chân dài qua điện trở 220Ω | **D5** (GPIO14); chân ngắn nối GND |
| LED 2: chân dài qua điện trở 220Ω | **D6** (GPIO12); chân ngắn nối GND |

Tất cả GND nối chung trên breadboard.

## 2.2 Driver và cổng COM

1. Cắm NodeMCU vào máy. Windows 11 thường tự cài driver CH340.
2. Bấm `Win+X` → *Device Manager* → mở nhóm **Ports (COM & LPT)**: phải thấy `USB-SERIAL CH340 (COMx)`.
3. Nếu không thấy: thử cáp USB khác (nhiều cáp chỉ để sạc), hoặc tải driver **CH341SER** của hãng WCH rồi cài.

## 2.3 Điền thông tin WiFi/MQTT

Trong VS Code (đã mở `C:\iot-project`), mở file **`firmware/include/secrets.h`** (nếu chưa có thì sao chép từ `secrets.example.h` và đổi tên). Điền:

```cpp
const char* ssid        = "TEN_WIFI_2.4GHZ";
const char* password    = "MAT_KHAU_WIFI";
const char* mqtt_server = "IP_MAY_TINH";        // IPv4 máy Windows (bước 0.5)
inline constexpr int mqtt_port = 8000;
const char* mqtt_user   = "MQTT_USER";          // đúng tài khoản ở bước 1.3.2
const char* mqtt_pass   = "MQTT_PASS";
```

> `secrets.h` đã nằm trong `.gitignore` nên **sẽ không bị đẩy lên GitHub**. Chỉ `secrets.example.h` (không có mật khẩu thật) được đưa lên.

## 2.4 Build, nạp và xem log

1. Bấm **✓ Build** (hoặc `Ctrl+Alt+B`). Lần đầu PlatformIO tải nền tảng ESP8266 và các thư viện (PubSubClient, DHT sensor library, Adafruit Unified Sensor, ArduinoJson 6) nên mất vài phút. Kết thúc với dòng **SUCCESS** là đạt.
2. Cắm NodeMCU, bấm **→ Upload** (hoặc `Ctrl+Alt+U`). Thấy **SUCCESS** là đã nạp xong.
3. Bấm **🔌 Serial Monitor** (hoặc `Ctrl+Alt+S`; tốc độ 115200 đã đặt sẵn trong `platformio.ini`). Nhấn nút **RST** trên board để xem từ đầu. Kết quả đúng:
   ```
   Da ket noi, IP: 192.168.1.xx
   Dang ket noi MQTT broker...OK
   Da gui phan hoi: {"id":0,"device":"node","state":"ONLINE","status":"success"}
   Da gui: {"temp":..,"hum":..,"light":..}      <- lặp lại mỗi 5 giây
   ```
4. Lưu ý: **đóng Serial Monitor trước khi Upload** (cả hai cùng dùng cổng COM).

> Nếu PlatformIO chọn nhầm cổng, bỏ dấu `;` ở 2 dòng `upload_port` / `monitor_port` trong `platformio.ini` và điền đúng `COMx` (xem ở Device Manager).

---

# PHẦN 3. NGHIỆM THU HỆ THỐNG

Mở `http://localhost:8800/dashboard.html`, hoặc từ điện thoại cùng WiFi: `http://IP_MAY_TINH:8800/dashboard.html`.

| Kiểm tra | Kết quả đúng |
|---|---|
| **Đăng nhập & Phân quyền** | - Đăng nhập `admin`/`admin123`: Có quyền điều khiển 2 đèn LED.<br/>- Đăng nhập `viewer`/`viewer123`: Nút công tắc bị khóa, hiện thông báo chỉ Admin mới được điều khiển. |
| 3 thẻ Nhiệt độ / Độ ẩm / Ánh sáng | Tự cập nhật theo cảm biến thật |
| Bật/tắt **Đèn 1**, **Đèn 2** trên web (quyền Admin) | LED ngoài đời sáng/tắt theo |
| Tab **Action history** | Có dòng mới, trạng thái "Thành công", có thời gian phản hồi (ms), "Người thực hiện" ghi nhận đúng tài khoản đăng nhập |
| Tab **Data sensor** | Có bản ghi; tìm kiếm theo loại cảm biến/thời gian, đổi số dòng/trang hoạt động |
| Tắt Node-RED (đóng cửa sổ đen) | Trang hiện **banner đỏ** báo mất kết nối; bật lại thì tự hết |

**Demo 3 terminal** (đề bài): mở 3 cửa sổ CMD.

```bat
:: Terminal 1 - nhận dữ liệu cảm biến liên tục
mosquitto_sub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t data/sensor -v

:: Terminal 2 - gửi lệnh điều khiển (người thực hiện sẽ là "MQTT")
mosquitto_pub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t device/control/led1 -m "ON"
mosquitto_pub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t device/control/all -m "{\"led1\":\"OFF\",\"led2\":\"ON\"}"

:: Terminal 3 - nhận phản hồi từ thiết bị
mosquitto_sub -h localhost -p 8000 -u MQTT_USER -P MQTT_PASS -t device/response -v
```

---

# PHẦN 4. ĐƯA DỰ ÁN LÊN GITHUB

> Thứ tự khuyến nghị: **GitHub → Postman → Figma → gán link vào Profile (Phần 7)**. Làm GitHub trước để có link repo.

## 4.1 Tạo repository trống

1. Đăng nhập `github.com` → dấu **+** góc trên bên phải → **New repository**.
2. *Repository name*: `iot-nodemcu-dashboard` (hoặc tên bạn thích). Chọn **Public** để người chấm mở được (hoặc **Private** rồi thêm giảng viên ở *Settings → Collaborators*).
3. **Không** tick "Add a README", ".gitignore", "license" (dự án đã có sẵn). Bấm **Create repository**. Giữ trang này để lấy địa chỉ repo dạng `https://github.com/GITHUB_USER/iot-nodemcu-dashboard.git`.

## 4.2 Kiểm tra không lộ mật khẩu (BẮT BUỘC trước khi đẩy)

```bat
cd /d C:\iot-project
git init
git add .
git status
```

Trong danh sách file sắp commit:

- **Phải có:** `firmware/include/secrets.example.h`, `platformio.ini`, `README.md`, `database/schema.sql`, `node-red/flow_iot_all.json`, `frontend/dashboard.html`, `docs/...`.
- **KHÔNG được có:** `firmware/include/secrets.h`.

Kiểm tra lần nữa bằng lệnh:

```bat
git ls-files | findstr /i secrets
```

Chỉ được hiện đúng 1 dòng: `firmware/include/secrets.example.h`. Nếu thấy `secrets.h`, **dừng lại**, kiểm tra file `.gitignore` rồi chạy `git rm --cached firmware/include/secrets.h`.

## 4.3 Commit và đẩy lên

```bat
git commit -m "IoT dashboard: NodeMCU - MQTT - Node-RED - MySQL"
git branch -M main
git remote add origin https://github.com/GITHUB_USER/iot-nodemcu-dashboard.git
git push -u origin main
```

Lần đầu sẽ hiện cửa sổ trình duyệt để đăng nhập GitHub (Git Credential Manager): chọn *Authorize*. Thông báo `warning: LF will be replaced by CRLF` là bình thường.

> **Cách khác dùng giao diện:** trong VS Code, mở tab *Source Control* → *Publish to GitHub* → chọn Public/Private và **bỏ chọn** `secrets.h` nếu nó xuất hiện trong danh sách.

## 4.4 Kiểm tra trên GitHub

Mở trang repo: thấy README hiển thị sơ đồ kiến trúc, đủ các thư mục `firmware`, `database`, `node-red`, `frontend`, `docs`, `scripts`. Vào `firmware/include/` phải chỉ có `secrets.example.h`.

> **Nếu lỡ đẩy `secrets.h` lên:** xóa file ở commit sau là **chưa đủ** (lịch sử vẫn còn). Hãy **đổi ngay** mật khẩu WiFi và MQTT, rồi xóa repo và tạo lại, hoặc dùng `git filter-repo` để xóa khỏi lịch sử.

📋 **Ghi lại:** link repo = `https://github.com/GITHUB_USER/iot-nodemcu-dashboard`

---

# PHẦN 5. ĐƯA API LÊN POSTMAN

Dự án đã có sẵn trong `docs/postman/`:

- `IoT_Dashboard_API.postman_collection.json`: 10 request chia 5 nhóm (Dashboard, Data sensor, Action history, Điều khiển thiết bị, Profile), có mô tả tham số, test tự động và ví dụ response lấy từ hệ thống chạy thật.
- `IoT_Localhost.postman_environment.json`: biến `base_url = http://localhost:8800`.

## 5.1 Cài Postman và nhập file

1. Tải **Postman Desktop** tại `postman.com/downloads` và đăng nhập tài khoản. Dùng bản **Desktop** (bản web không gọi được `localhost` nếu không có Postman Agent).
2. Bấm nút **Import** (góc trên bên trái), kéo thả **cả 2 file** trong `C:\iot-project\docs\postman\` vào → **Import**.
3. Góc trên bên phải, ô chọn environment → chọn **IoT - Localhost**.

## 5.2 Chạy thử và kiểm tra

1. Bảo đảm Node-RED và MySQL đang chạy.
2. Mở collection → mở một request (vd "Số liệu mới nhất…") → **Send**. Tab *Body* hiện JSON; tab **Test Results** hiện các dòng xanh *PASS*.
3. Chạy cả bộ: bấm dấu **⋯** cạnh tên collection → **Run collection** → **Run**. Kết quả đúng: **10 request, 40 test, 0 failed**. (Nhóm "Điều khiển thiết bị" sẽ thật sự bật/tắt đèn.)
4. Mỗi request đã có sẵn **Examples** (response mẫu) ở mục *Examples* dưới tên request. Người xem tài liệu thấy được kết quả ngay cả khi không chạy server.

## 5.3 Xuất bản tài liệu để lấy link

1. Thanh bên trái → **Collections** → chọn collection `IoT Dashboard API…`.
2. Ở tab **Overview**, bấm **View complete documentation**.
3. Bấm **Publish docs** → chọn **Postman** (công khai).
4. Ở màn *Publish Documentation*: có thể chọn environment **IoT - Localhost** để kèm biến; với tài khoản Free có thể chọn một **public workspace** để chuyển collection vào. Bấm **Publish**.
5. Lấy link: tại *View complete documentation* → bấm **Published** → **Copy published link**.
6. Kiểm tra bằng cách mở link trong **cửa sổ ẩn danh**; phải xem được tài liệu mà không cần đăng nhập.

> Collection này **không chứa mật khẩu hay dữ liệu cá nhân** (response mẫu dùng tên "Nguyễn Văn A" giả), nên công khai là an toàn. Tài liệu xuất bản sẽ tự cập nhật khi bạn sửa collection.
> Tùy chọn khác: nút **Share** → *Via link*, hoặc đính kèm 2 file JSON trong repo GitHub (đã có sẵn ở `docs/postman/`).

📋 **Ghi lại:** link Postman = `https://documenter.getpostman.com/view/...` (hoặc dạng link Postman cung cấp)

---

# PHẦN 6. ĐƯA GIAO DIỆN LÊN FIGMA

Dùng plugin **html.to.design** để chuyển trang web đang chạy thành các layer Figma có thể chỉnh sửa. Bản miễn phí đủ cho việc này (có giới hạn "fair use").

## 6.1 Chuẩn bị

1. Đăng nhập `figma.com` → **New design file** → đặt tên `IoT Dashboard`.
2. Cài plugin trong Figma: *Resources* (menu `Shift+I`) → **Plugins** → tìm **html.to.design** → *Run/Save*.
3. Cài tiện ích Chrome **html.to.design** từ Chrome Web Store (cũng dùng được trên Edge/Brave). Cần tiện ích này vì trang của bạn chạy ở `localhost` nên plugin trên Figma không truy cập trực tiếp được.
4. Bảo đảm hệ thống đang chạy và **có dữ liệu thật** (NodeMCU đang gửi số liệu, hoặc ít nhất đã có vài bản ghi) để ảnh chụp giao diện có số liệu.

## 6.2 Chụp từng màn hình

1. Mở `http://localhost:8800/dashboard.html` bằng Chrome, **phóng to cửa sổ** ở độ rộng máy tính (khoảng 1440px) để bố cục đúng bản desktop.
2. Bấm biểu tượng tiện ích **html.to.design** trên thanh công cụ → chọn khung hiển thị (Desktop) → **Capture**. Chọn *gửi thẳng tới plugin Figma* (hoặc tải về file `.h2d`).
3. **Lặp lại cho cả 4 màn hình:** chuyển sang tab *Data sensor*, rồi *Action history*, rồi *Profile* trên giao diện, mỗi lần đều Capture lại.

## 6.3 Nhập vào Figma

1. Trong file Figma: *Plugins → html.to.design* → vào tab **Extension**: danh sách các lần chụp gần đây. (Nếu đã tải file `.h2d`, kéo thả file đó vào cửa sổ plugin.)
2. Chọn một lần chụp → chọn tùy chọn nhập (nên bật **Auto layout**; chọn tạo *Styles* nếu muốn) → xử lý font còn thiếu (chọn map font tương tự hoặc tải font) → bấm **Go**.
3. Lặp lại cho các lần chụp còn lại. Đổi tên các frame: `Dashboard`, `Data sensor`, `Action history`, `Profile`, và sắp xếp ngay hàng trên canvas.

> Plugin này cũng cho tải thẳng file `.html`/`.zip`, nhưng giao diện của bạn nạp dữ liệu bằng JavaScript và từng tab bị ẩn, nên **chụp bằng tiện ích** cho kết quả tốt hơn.
> Kết quả chuyển đổi không đảm bảo giống từng điểm ảnh; bạn có thể chỉnh lại thủ công trong Figma.

## 6.4 Chia sẻ và lấy link

1. Góc trên bên phải bấm **Share**.
2. Ở *General access* chọn **Anyone with the link** → quyền **Can view**.
3. Bấm **Copy link**. Mở thử trong cửa sổ ẩn danh để chắc người khác xem được.

📋 **Ghi lại:** link Figma = `https://www.figma.com/design/...`

---

# PHẦN 7. GÁN LIÊN KẾT VÀO MỤC PROFILE

Mục **Profile** hiển thị: họ tên, MSSV, email (lấy từ bảng `users` trong MySQL) và các mục còn lại (lớp, SĐT, đề tài, **GitHub, Postman, Figma, Báo cáo PDF**) lấy từ khối `PROFILE_EXTRA` trong `frontend/dashboard.html`. Ô nào để trống sẽ hiện "(chưa điền)"; ô có link sẽ thành liên kết bấm được.

## 7.1 Họ tên, MSSV, email (lưu trong MySQL)

```bat
mysql -u root -p --default-character-set=utf8mb4 iot_project -e "UPDATE users SET username='MSSV_CUA_BAN', full_name='Ho Ten Cua Ban', email='email@cua-ban.com' WHERE user_id=1;"
```

(`username` ở đây là MSSV; bảng này không dùng để đăng nhập.)

## 7.2 Các link và thông tin còn lại

Mở file `C:\iot-project\frontend\dashboard.html` bằng VS Code, nhấn `Ctrl+F` tìm `PROFILE_EXTRA`, điền (giữ nguyên dấu nháy):

```js
const PROFILE_EXTRA = {
    class_name: "D23CQAT01-B",                               // Lớp
    phone: "09xxxxxxxx",                                     // Số điện thoại
    project: "He thong giam sat va dieu khien IoT",          // Tên đề tài
    github: "https://github.com/GITHUB_USER/iot-nodemcu-dashboard",
    postman: "https://documenter.getpostman.com/view/...",   // link ở Phần 5
    figma: "https://www.figma.com/design/...",               // link ở Phần 6
    report_pdf: "bao-cao.pdf",                               // xem 7.3
    avatar: ""                                               // (tuỳ chọn) link ảnh đại diện
};
```

## 7.3 Báo cáo PDF

Chép file báo cáo vào `C:\iot-project\frontend\bao-cao.pdf` (đặt đúng tên này, hoặc đổi `report_pdf` cho khớp). Node-RED phục vụ file này cùng trang web, nên nút **"Xem báo cáo (PDF)"** sẽ mở được. Nếu để báo cáo ở Google Drive thì dán link chia sẻ vào `report_pdf`.

## 7.4 Kiểm tra trên giao diện

Mở lại `http://localhost:8800/dashboard.html`, nhấn **Ctrl+F5**, vào tab **Profile**: các dòng GitHub / Postman / Figma là liên kết bấm được, nút "Xem báo cáo (PDF)" mở file PDF. Bấm thử từng link ở **cửa sổ ẩn danh** để chắc rằng người ngoài xem được.

## 7.5 Cập nhật README và đẩy lại lên GitHub

1. Mở `README.md`, điền lại bảng **"Liên kết nộp bài"** ở đầu file bằng 4 link vừa có.
2. Đẩy cập nhật lên GitHub:
   ```bat
   cd /d C:\iot-project
   git add .
   git status
   git commit -m "Cap nhat link Profile (GitHub, Postman, Figma, bao cao)"
   git push
   ```
   Lại kiểm tra `git status` để chắc `secrets.h` không có trong danh sách.

---

# PHẦN 8. CHECKLIST CUỐI

- [ ] `ipconfig` → `IP_MAY_TINH` khớp với `mqtt_server` trong `secrets.h`; Serial Monitor báo `Dang ket noi MQTT broker...OK`.
- [ ] Dashboard hiển thị số liệu thật; bật/tắt 2 đèn hoạt động; Action history ghi nhận.
- [ ] Node-RED tự mở khi đăng nhập Windows; Mosquitto và MySQL đang chạy (Services).
- [ ] GitHub: repo mở được ở cửa sổ ẩn danh, **không có** `secrets.h`.
- [ ] Postman: link published docs mở được ở cửa sổ ẩn danh; chạy collection 40/40 test đạt.
- [ ] Figma: link xem được không cần đăng nhập, có đủ 4 màn hình.
- [ ] Profile: họ tên, MSSV, email, lớp, GitHub, Postman, Figma, báo cáo PDF đều hiển thị đúng.
- [ ] Đã tắt chế độ ngủ của máy; WiFi 2.4GHz ổn định.

---

# LỖI THƯỜNG GẶP

## Mạng / MQTT
| Hiện tượng | Nguyên nhân thường gặp |
|---|---|
| Serial báo `rc=-2` | NodeMCU không tới được máy: chưa mở tường lửa (1.3.5), sai `IP_MAY_TINH` (lấy nhầm card VMnet), khác mạng, hoặc WiFi chặn kết nối giữa thiết bị |
| Serial báo `rc=5` | Sai `mqtt_user` / `mqtt_pass` trong `secrets.h` |
| Dịch vụ Mosquitto vừa bật đã tắt | `mosquitto.conf` sai (đường dẫn tương đối, có ngoặc kép, dòng trùng). Chạy `mosquitto -c mosquitto.conf -v` để xem lỗi |
| Node `mqtt in` màu đỏ | Sai user/pass trong node broker, hoặc dịch vụ Mosquitto chưa chạy |
| Cổng bị chiếm (`EADDRINUSE`) | Có chương trình khác dùng 8800/8000/3306. Kiểm tra: `netstat -ano \| findstr :8000` |

## MySQL / Node-RED
| Hiện tượng | Nguyên nhân thường gặp |
|---|---|
| `Access denied for user 'iot'` | Sai mật khẩu `MYSQL_IOT_PASS` trong node cấu hình MySQL, hoặc chưa tạo user (1.4.5) |
| `ECONNREFUSED 127.0.0.1:3306` | Dịch vụ MySQL chưa chạy: `net start MySQL84` (CMD Admin) |
| Lỗi liên quan `authentication method` | Cập nhật node: *Manage palette* → cập nhật `node-red-node-mysql` lên bản mới nhất |
| Nạp `schema.sql` báo `already exists` | Đã nạp rồi; `DROP DATABASE` trước nếu muốn nạp lại (xóa dữ liệu) |
| Chữ tiếng Việt bị lỗi font | Nạp schema bằng đúng lệnh `source` ở 1.4.4 (file đã ép UTF-8) |
| `'node-red' is not recognized` | Mở lại CMD mới sau khi cài Node.js, hoặc thiếu `%APPDATA%\npm` trong PATH |
| "running scripts is disabled" | Đang dùng PowerShell, hãy dùng CMD |
| Dashboard hiện banner đỏ | Node-RED chưa chạy, flow chưa Deploy, hoặc MySQL lỗi |

## PlatformIO / phần cứng
| Hiện tượng | Nguyên nhân thường gặp |
|---|---|
| `fatal error: secrets.h: No such file` | Chưa tạo `firmware/include/secrets.h` từ `secrets.example.h` |
| Không thấy cổng COM | Cáp chỉ để sạc, thiếu driver CH340 (CH341SER), hoặc máy ảo (VMware) đang giữ USB |
| `Could not open port COMx` / "Access is denied" | Serial Monitor (hoặc chương trình khác) đang mở cổng; đóng lại rồi Upload |
| `Failed to connect to ESP8266: Timed out` | Cáp lỗi, hoặc cần giữ nút **FLASH** khi bắt đầu nạp; thử đặt `upload_speed = 115200` |
| PlatformIO tải thư viện/nền tảng lỗi | Mạng chặn tải; thử lại hoặc đổi mạng (cần Internet lần build đầu) |
| DHT11 trả về `nan` | Sai chân DATA (D2), hoặc dây lỏng; đọc cách nhau tối thiểu 2 giây |

## Postman / Figma / GitHub
| Hiện tượng | Nguyên nhân thường gặp |
|---|---|
| Postman: `Could not get response` / `ECONNREFUSED` | Node-RED chưa chạy, chưa chọn environment **IoT - Localhost**, hoặc đang dùng bản web của Postman |
| Postman: không thấy nút Publish | Collection đang gắn với một API; hoặc cần mở đúng *Overview → View complete documentation* |
| Figma: plugin nhập ra trang trống | Chụp khi trang chưa tải xong; đợi dữ liệu hiện rồi Capture lại |
| Git: `Permission denied` / `Authentication failed` | Đăng nhập GitHub qua cửa sổ trình duyệt; kiểm tra đúng `GITHUB_USER` trong địa chỉ `remote` |
| Git: `remote origin already exists` | Chạy `git remote set-url origin https://github.com/GITHUB_USER/tên-repo.git` |

---

# PHỤ LỤC

## A. Các lệnh hay dùng

```bat
:: Xem dịch vụ
net start mosquitto            & net stop mosquitto
net start MySQL84              & net stop MySQL84

:: Xem IP máy
ipconfig

:: Xem dữ liệu mới nhất
mysql -u iot -p -h 127.0.0.1 iot_project --default-character-set=utf8mb4 -e "SELECT * FROM data_sensors ORDER BY data_id DESC LIMIT 10;"
mysql -u iot -p -h 127.0.0.1 iot_project --default-character-set=utf8mb4 -e "SELECT * FROM actions ORDER BY action_id DESC LIMIT 10;"

:: Xóa dữ liệu thử trước buổi demo (giữ nguyên cấu trúc bảng)
mysql -u iot -p -h 127.0.0.1 iot_project -e "DELETE FROM actions; DELETE FROM data_sensors;"
```

## B. Cơ sở dữ liệu (5 bảng theo ERD)

| Bảng | Vai trò |
|---|---|
| `users` | Thông tin sinh viên (Profile); `actions.user_id` trỏ tới đây |
| `devices` | 2 thiết bị: `led1` (id 1), `led2` (id 2) |
| `sensors` | 3 cảm biến: nhiệt độ (id 1), độ ẩm (id 2), ánh sáng (id 3) |
| `data_sensors` | Mỗi lần đo: `sensor_id`, `value`, `recorded_at` |
| `actions` | Mỗi lệnh điều khiển: thiết bị, người thực hiện, hành động, trạng thái (`pending` → `success`/`failed`/`timeout`), thời gian gửi và phản hồi (mili-giây) |

## C. Trạng thái lệnh điều khiển

Khi gửi lệnh, Node-RED ghi một dòng `pending` vào `actions`, rồi chờ phản hồi của NodeMCU ở `device/response`:
nhận `success` → `success`; nhận `false` → `failed`; **không có phản hồi sau 5 giây** → `timeout` (hiển thị 5000ms).
Lệnh bấm trên web có "Người thực hiện" là tên trong bảng `users`; lệnh gửi thẳng qua MQTT (terminal) hiển thị là `MQTT`.
