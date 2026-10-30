#include <Arduino.h>

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println("YZ-FICustom: development environment starter");
  Serial.println("ECU control, Wi-Fi, BLE and OTA are not implemented.");
}

void loop() {
  // Keep the starter idle. Do not drive injector/ignition or other GPIO outputs.
  delay(1000);
}
