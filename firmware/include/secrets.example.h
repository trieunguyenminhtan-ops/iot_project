#ifndef SECRETS_H
#define SECRETS_H

// Sao chép file này thành secrets.h và điền thông tin thật.
inline constexpr const char *ssid = "TEN_WIFI";
inline constexpr const char *password = "MAT_KHAU_WIFI";
inline constexpr const char *mqtt_server =
    "192.168.1.100"; // IPv4 của máy chạy Mosquitto (Windows: gõ ipconfig)
inline constexpr int mqtt_port = 8000;
inline constexpr const char *mqtt_user = "MQTT_USERNAME";
inline constexpr const char *mqtt_pass = "MQTT_PASSWORD";

#endif
