#include <Arduino.h>
#include <SoftwareSerial.h>
#include <Arduino_JSON.h>

// const value seriaul bate and led pin
const unsigned long SERIAL_BAUD_RATE = 9600;
const int ledPin = 13;     

// value for Moisture Sensor v1.2
const int dry = 510; // value for dry sensor
const int wet = 210; // value for wet sensor

#define BT Serial3 // Bluetooch serial

// Serial number and verison firmware
#define serialNumber "0000-0000-0000-0001"
#define versionFirmware "0.1"


void setup() 
{
  Serial.begin(SERIAL_BAUD_RATE);

  // Bluetooth module
  BT.begin(SERIAL_BAUD_RATE);

  // init pinMode
  pinMode(ledPin, OUTPUT);      

  // wait 2 saecond for init
  delay(2000);
  Serial.println("ENTER AT Commands:");
}// void setup()

 
void loop() 
{
  int moistureSensorValue = analogRead(A0);
  int percentageHumididy = map(moistureSensorValue, wet, dry, 100, 0);

  //Serial.print(percentageHumididy);
  //Serial.println("%");
  sendSensorData(percentageHumididy);

  // сheck data from Bluetooth module and send to Serial Monitor
  if (BT.available()) 
  {
    while (BT.available())
    {
      char c = BT.read();

      Serial.write(c);

      if (c == '1')
      {
        digitalWrite(ledPin, HIGH);
      }
      
      if (c == '0')
      {
        digitalWrite(ledPin, LOW);
      }
    }
  }

  // сheck data from Serial Monitor and send to Bluetooth module
  if (Serial.available()) 
  {
    while (Serial.available())
    {
      char c = Serial.read();
      BT.write(c);
    }
  }

  delay(1000);
}// void loop() 


void sendSensorData(int soilMoisture) 
{
  // сreate and send JSON
  if (BT) 
  {
    // Create JSON object
    JSONVar jsonData;

    // serial number and firmware ver
    jsonData["serialNumber"] = serialNumber;
    jsonData["versionFirmware"] = versionFirmware;
    
    // data from sensor
    jsonData["soilMoisture"] = soilMoisture;
    jsonData["airHumidity"] = 0;//airHumidity;
    jsonData["lightLevel"] = 0;//lightLevel;
    jsonData["airTemperature"] = 0;//airTemperature;

    // Converting a JSON object to text
    String jsonString = JSON.stringify(jsonData);

    BT.print(jsonString);
    BT.print("\n");

    Serial.println("Data sent to Bluetooth: " + jsonString);
  } 
  else 
  {
    Serial.println("Bluetooth module not connected");
  }
}// void sendSensorData(int soilMoisture) 
