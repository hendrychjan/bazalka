#include <EEPROM.h>

namespace pin {
const uint8_t SENSOR_ENABLE = 4;
const uint8_t PUMP_ENABLE = 3;
const uint8_t SENSOR_DATA = A7;
}  // namespace pin

struct Config {
  uint8_t moistureThreshold;
  uint8_t moistureTarget;
  bool autoModeEnabled;
};

void ard_pinSetup();
void ard_logicSetup();
void ard_loadConfig();
uint8_t pot_readSensor();
void pot_waterAuto();
void pot_waterManual();

Config config;

void setup() {
  Serial.begin(9600);
  ard_pinSetup();
  ard_logicSetup();
  ard_loadConfig();
}

void loop() {
  if (Serial.available()) {
    String command = Serial.readStringUntil('\n');
    if (command == "CM+WTA") {
      pot_waterAuto();
      return;
    }
    if (command == "CM+WTM") {
      pot_waterManual();
      return;
    }
    if (command == "CM+STA") {
      uint8_t moisture = pot_readSensor();
      Serial.println(moisture);
      return;
    }
    if (command == "CF+GET") {
      Serial.print("C:");
      Serial.print(config.moistureThreshold);
      Serial.print(",");
      Serial.print(config.moistureTarget);
      Serial.print(",");
      Serial.println(config.autoModeEnabled);
      return;
    }
    if (command.startsWith("CF+AUT")) {
      if (command.equalsIgnoreCase("CF+AUT=ON")) {
        config.autoModeEnabled = true;
        EEPROM.put(1, config);
        return;
      }
      if (command.equalsIgnoreCase("CF+AUT=OFF")) {
        config.autoModeEnabled = false;
        EEPROM.put(1, config);
        return;
      }
    }
    if (command.startsWith("CF+THR")) {
      uint8_t threshold = command.substring(7).toInt();
      config.moistureThreshold = threshold;
      EEPROM.put(1, config);
      return;
    }
    if (command.startsWith("CF+TAR")) {
      uint8_t target = command.substring(7).toInt();
      config.moistureTarget = target;
      EEPROM.put(1, config);
      return;
    }
  }

  if (millis() % 60000 == 0) {
    uint8_t moisture = pot_readSensor();
    Serial.println(moisture);
    if (config.autoModeEnabled && moisture < config.moistureThreshold) {
      pot_waterAuto();
    }
  }
}

// ===== ARD =====

void ard_pinSetup() {
  pinMode(pin::SENSOR_ENABLE, OUTPUT);
  pinMode(pin::PUMP_ENABLE, OUTPUT);
  pinMode(pin::SENSOR_DATA, INPUT);
}

void ard_logicSetup() {
  digitalWrite(pin::SENSOR_ENABLE, LOW);
  digitalWrite(pin::PUMP_ENABLE, LOW);
}

void ard_resetEEPROM() {
  Serial.println("Resetting EEPROM");
  for (uint16_t i = 0; i < EEPROM.length(); i++) {
    EEPROM.write(i, 0xFF);
  }
}

void ard_loadConfig() {
  if (EEPROM.read(0) == 0xFF) {
    // Generate the default configuration
    config.autoModeEnabled = false;
    config.moistureTarget = 0;
    config.moistureThreshold = 0;

    // Write the default configuration to EEPROM
    EEPROM.write(0, 0x00);
    EEPROM.put(1, config);
    return;
  }

  // Read the configuration from EEPROM
  EEPROM.get(1, config);
}

// ===== POT =====

uint8_t pot_readSensor() {
  // Enable the sensor power supply
  digitalWrite(pin::SENSOR_ENABLE, HIGH);
  delay(10);

  // Read the sensor value
  uint16_t value = analogRead(pin::SENSOR_DATA);
  uint8_t percentage = map(value, 0, 1023, 100, 0);

  // Disable the sensor power supply
  digitalWrite(pin::SENSOR_ENABLE, LOW);

  return percentage;
}

void pot_waterAuto() {
  uint8_t moisture = pot_readSensor();
  Serial.println(moisture);
  while (moisture < config.moistureTarget) {
    Serial.println(moisture);
    digitalWrite(pin::PUMP_ENABLE, HIGH);
    delay(1000);
    digitalWrite(pin::PUMP_ENABLE, LOW);
    delay(5000);
    moisture = pot_readSensor();
  }
}

void pot_waterManual() {
  digitalWrite(pin::PUMP_ENABLE, HIGH);
  uint8_t moisture = pot_readSensor();
  while (true) {
    Serial.println(moisture);
    delay(300);
    if (Serial.available()) {
      String command = Serial.readStringUntil('\n');
      if (command == "CM+HALT") {
        digitalWrite(pin::PUMP_ENABLE, LOW);
        return;
      }
    }
  }
}
