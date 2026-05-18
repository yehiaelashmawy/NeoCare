#include <WiFi.h>
#include <WebServer.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <DHT.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "HX711.h"

// ============================
// WiFi Configuration
// ============================
const char* ssid = "YOUR_WIFI_NAME";
const char* password = "YOUR_WIFI_PASSWORD";

// ============================
// HTTP Server
// ============================
WebServer server(80);

// ============================
// Pins
// ============================
#define DHTPIN 4
#define DHTTYPE DHT22

#define DS18B20_PIN 5

#define MQ135_PIN 34
#define SOUND_PIN 35

#define HX711_DOUT 18
#define HX711_SCK 19

#define LED_RED 25
#define LED_GREEN 26
#define BUZZER 27

// ============================
// Sensors Setup
// ============================
DHT dht(DHTPIN, DHTTYPE);

OneWire oneWire(DS18B20_PIN);
DallasTemperature sensors(&oneWire);

HX711 scale;

LiquidCrystal_I2C lcd(0x27, 16, 2);

// ============================
// Variables
// ============================
float calib_factor = 420.0;

// Sensor values
float airT = 0;
float airH = 0;
float babyT = 0;
int gasVal = 0;
int soundVal = 0;
float weight = 0;

bool danger = false;
String errorMsg = "Normal";

// ============================
// Function: Read Sensors
// ============================
void readSensors() {

  airT = dht.readTemperature();
  airH = dht.readHumidity();

  sensors.requestTemperatures();
  babyT = sensors.getTempCByIndex(0);

  gasVal = analogRead(MQ135_PIN);
  soundVal = analogRead(SOUND_PIN);

  scale.set_scale(calib_factor);
  weight = scale.get_units(5);
}

// ============================
// Function: Check Danger
// ============================
void checkDanger() {

  danger = false;
  errorMsg = "Normal";

  if (airT < 25.0 || airT > 37.0) {
    danger = true;
    errorMsg = "Air Temp Error";
  }

  else if (airH < 50.0 || airH > 70.0) {
    danger = true;
    errorMsg = "Humidity Error";
  }

  else if (babyT != -127.0 &&
           (babyT < 36.5 || babyT > 37.5)) {

    danger = true;
    errorMsg = "Baby Temp Error";
  }

  else if (gasVal > 500) {
    danger = true;
    errorMsg = "Gas Detected";
  }

  else if (soundVal > 600) {
    danger = true;
    errorMsg = "Baby Crying";
  }
}

// ============================
// Function: Alarm System
// ============================
void handleAlarm() {

  if (danger) {

    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_RED, HIGH);

    tone(BUZZER, 2500);

  } else {

    digitalWrite(LED_RED, LOW);
    digitalWrite(LED_GREEN, HIGH);

    noTone(BUZZER);
  }
}

// ============================
// Function: LCD Display
// ============================
void updateLCD() {

  static unsigned long lastPageUpdate = 0;
  static int page = 0;

  if (millis() - lastPageUpdate > 3000) {

    lcd.clear();

    if (danger) {

      lcd.setCursor(0, 0);
      lcd.print("!! DANGER !!");

      lcd.setCursor(0, 1);
      lcd.print(errorMsg);
    }

    else {

      if (page == 0) {

        lcd.print("Air:");
        lcd.print(airT, 1);
        lcd.print("C ");

        lcd.print(airH, 0);
        lcd.print("%");

        lcd.setCursor(0, 1);

        lcd.print("Baby:");
        lcd.print(babyT, 1);
        lcd.print("C");

        page = 1;

      } else {

        lcd.print("W:");
        lcd.print(weight, 1);
        lcd.print("kg");

        lcd.setCursor(0, 1);

        lcd.print("Gas:");
        lcd.print(gasVal);

        page = 0;
      }
    }

    lastPageUpdate = millis();
  }
}

// ============================
// Function: Serial Monitor
// ============================
void printSerial() {

  Serial.print("AirT: ");
  Serial.print(airT);

  Serial.print(" | Humidity: ");
  Serial.print(airH);

  Serial.print(" | BabyT: ");
  Serial.print(babyT);

  Serial.print(" | Gas: ");
  Serial.print(gasVal);

  Serial.print(" | Sound: ");
  Serial.print(soundVal);

  Serial.print(" | Weight: ");
  Serial.print(weight);

  Serial.print(" | Danger: ");
  Serial.println(danger);
}

// ============================
// API Endpoint
// ============================
void handleData() {

  String json = "{";

  json += "\"airTemp\":" + String(airT, 1) + ",";
  json += "\"humidity\":" + String(airH, 1) + ",";
  json += "\"babyTemp\":" + String(babyT, 1) + ",";
  json += "\"gas\":" + String(gasVal) + ",";
  json += "\"sound\":" + String(soundVal) + ",";
  json += "\"weight\":" + String(weight, 1) + ",";
  json += "\"danger\":" + String(danger ? "true" : "false") + ",";
  json += "\"message\":\"" + errorMsg + "\"";

  json += "}";

  server.send(200, "application/json", json);
}

// ============================
// Setup
// ============================
void setup() {

  Serial.begin(115200);

  // Outputs
  pinMode(LED_RED, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(BUZZER, OUTPUT);

  // LCD
  lcd.init();
  lcd.backlight();

  lcd.setCursor(0, 0);
  lcd.print("Smart Incubator");

  lcd.setCursor(0, 1);
  lcd.print("Starting...");

  // Sensors
  dht.begin();
  sensors.begin();

  scale.begin(HX711_DOUT, HX711_SCK);

  scale.set_scale();
  scale.tare();

  // WiFi
  WiFi.begin(ssid, password);

  lcd.clear();
  lcd.print("Connecting WiFi");

  while (WiFi.status() != WL_CONNECTED) {

    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi Connected");

  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  lcd.clear();
  lcd.print("WiFi Connected");

  delay(2000);

  // API
  server.on("/data", handleData);

  server.begin();

  Serial.println("HTTP Server Started");

  lcd.clear();
}

// ============================
// Loop
// ============================
void loop() {

  readSensors();

  checkDanger();

  handleAlarm();

  updateLCD();

  printSerial();

  server.handleClient();

  delay(500);
}