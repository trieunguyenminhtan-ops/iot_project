// Firmware NodeMCU (ESP8266) - biên dịch bằng PlatformIO (xem platformio.ini ở thư mục gốc).
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <ArduinoJson.h>

// Thông tin WiFi / MQTT nằm trong firmware/include/secrets.h (KHÔNG đưa lên GitHub).
// Sao chép secrets.example.h thành secrets.h rồi điền giá trị thật.
#include "secrets.h"

// ==== TOPIC ====
// Topic 1: dữ liệu cảm biến
const char* topic_data = "data/sensor";

// Topic 2: điều khiển
// - Mỗi LED có 1 subtopic riêng để điều khiển RIÊNG LẺ từng đèn
const char* topic_control_led1 = "device/control/led1"; // gửi ON/OFF chỉ cho LED 1
const char* topic_control_led2 = "device/control/led2"; // gửi ON/OFF chỉ cho LED 2
// - Thêm 1 subtopic để điều khiển NHIỀU đèn CÙNG LÚC bằng 1 lệnh duy nhất (payload JSON)
const char* topic_control_all  = "device/control/all";  // vd: {"led1":"ON","led2":"OFF"}

// Topic 3: phản hồi — dùng CHUNG cho mọi thiết bị.
// Payload chuẩn hóa dạng JSON: {"id":<int>,"device":"<ten>","state":"ON"/"OFF","status":"success"/"false"}
const char* topic_response = "device/response";

// ==== CHÂN CẮM ====
#define DHTPIN 4        // D2 trên board NodeMCU
#define DHTTYPE DHT11
#define LIGHT_PIN A0    // chân AO của module cảm biến ánh sáng
#define LED1_PIN 14     // D5 trên board NodeMCU -> LED 1 (+)
#define LED2_PIN 12     // D6 trên board NodeMCU -> LED 2 (+)

// ID định danh riêng cho từng thiết bị, dùng trong field "id" của phản hồi
#define DEVICE_ID_NODE 0
#define DEVICE_ID_LED1 1
#define DEVICE_ID_LED2 2

DHT dht(DHTPIN, DHTTYPE);
WiFiClient espClient;
PubSubClient client(espClient);

unsigned long lastMsg = 0;
const unsigned long INTERVAL = 5000; // gửi dữ liệu mỗi 5 giây

void setup_wifi() {
  delay(10);
  Serial.print("Dang ket noi WiFi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("Da ket noi, IP: ");
  Serial.println(WiFi.localIP());
}

// Đóng gói và gửi phản hồi theo đúng format yêu cầu:
// {"id":<id>, "device":"<ten thiet bi>", "state":"ON"/"OFF"/..., "status":"success"/"false"}
void publishResponse(int id, const String& device, const String& state, bool success) {
  StaticJsonDocument<160> doc;
  doc["id"] = id;
  doc["device"] = device;
  doc["state"] = state;
  doc["status"] = success ? "success" : "false";

  char buffer[160];
  serializeJson(doc, buffer);
  client.publish(topic_response, buffer);
  Serial.print("Da gui phan hoi: ");
  Serial.println(buffer);
}

// Áp dụng lệnh ON/OFF cho 1 LED cụ thể + gửi phản hồi chuẩn hóa tương ứng
void applyLedCommand(int id, int ledPin, const String& deviceName, const String& action) {
  if (action == "ON" || action == "1") {
    digitalWrite(ledPin, HIGH);
    publishResponse(id, deviceName, "ON", true);
  } else if (action == "OFF" || action == "0") {
    digitalWrite(ledPin, LOW);
    publishResponse(id, deviceName, "OFF", true);
  } else {
    // Lệnh không hợp lệ -> status = false, state trả về đúng giá trị lệnh gây lỗi để dễ debug
    publishResponse(id, deviceName, action, false);
  }
}

// Xử lý khi nhận được lệnh điều khiển LED.
// - device/control/led1, device/control/led2: điều khiển RIÊNG từng đèn, payload chỉ cần "ON"/"OFF"
// - device/control/all: điều khiển NHIỀU đèn CÙNG LÚC trong 1 lệnh, payload là JSON, vd:
//     mosquitto_pub -h localhost -p 8000 -u <user> -P <pass> -t "device/control/all" -m '{"led1":"ON","led2":"OFF"}'
void callback(char* topic, byte* payload, unsigned int length) {
  String msg;
  for (unsigned int i = 0; i < length; i++) msg += (char)payload[i];
  Serial.println("Nhan lenh [" + String(topic) + "]: " + msg);

  String t = String(topic);

  if (t == topic_control_led1) {
    applyLedCommand(DEVICE_ID_LED1, LED1_PIN, "led1", msg);
  } else if (t == topic_control_led2) {
    applyLedCommand(DEVICE_ID_LED2, LED2_PIN, "led2", msg);
  } else if (t == topic_control_all) {
    StaticJsonDocument<128> doc;
    DeserializationError err = deserializeJson(doc, msg);
    if (err) {
      publishResponse(DEVICE_ID_NODE, "all", "ERROR", false);
      Serial.println("Loi parse JSON: " + String(err.c_str()));
      return;
    }
    if (doc.containsKey("led1")) {
      applyLedCommand(DEVICE_ID_LED1, LED1_PIN, "led1", String((const char*)doc["led1"]));
    }
    if (doc.containsKey("led2")) {
      applyLedCommand(DEVICE_ID_LED2, LED2_PIN, "led2", String((const char*)doc["led2"]));
    }
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Dang ket noi MQTT broker...");
    String clientId = "NodeMCU-" + String(ESP.getChipId());
    // Last Will: nếu mất kết nối đột ngột, broker tự gửi phản hồi node OFFLINE theo đúng format chuẩn
    const char* lwt = "{\"id\":0,\"device\":\"node\",\"state\":\"OFFLINE\",\"status\":\"success\"}";
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass,
                        topic_response, 0, true, lwt)) {
      Serial.println("OK");
      publishResponse(DEVICE_ID_NODE, "node", "ONLINE", true);
      client.subscribe(topic_control_led1);
      client.subscribe(topic_control_led2);
      client.subscribe(topic_control_all);
    } else {
      Serial.print("that bai, rc=");
      Serial.print(client.state());
      Serial.println(" thu lai sau 2s");
      delay(2000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  delay(500);
  Serial.println();
  Serial.println("\n=== NodeMCU ESP8266 Khoi Dong ===");
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  dht.begin();
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
  client.setKeepAlive(5); // Keepalive 5s -> Mosquitto phat hien mat ket noi sau ~7.5s
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  unsigned long now = millis();
  if (now - lastMsg > INTERVAL) {
    lastMsg = now;

    float h = dht.readHumidity();
    float t = dht.readTemperature();
    int light = 1023 - analogRead(LIGHT_PIN); // Đảo chiều: Càng sáng số càng lớn (0-1023)

    if (isnan(h) || isnan(t)) {
      Serial.println("Loi doc cam bien DHT11!");
      return;
    }

    String payload = "{\"temp\":" + String(t, 1) +
                      ",\"hum\":" + String(h, 1) +
                      ",\"light\":" + String(light) + "}";

    client.publish(topic_data, payload.c_str());
    Serial.println("Da gui: " + payload);
  }
}
