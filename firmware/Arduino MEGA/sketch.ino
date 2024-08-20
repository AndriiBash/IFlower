#include <Arduino.h>
#include <SoftwareSerial.h>
#include <Arduino_JSON.h>

#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

// const value seriaul bate
const unsigned long SERIAL_BAUD_RATE = 9600;

// value for Moisture Sensor v1.2
const int dry = 510; // value for dry sensor
const int wet = 210; // value for wet sensor

#define BT Serial3 // Bluetooth serial

#define DHTTYPE DHT11 //DH11 Version sensor

// Pin's
#define DHT_PIN 52            // pin where include DH11 sensor for get data
#define RELAY_PIN 50          // pin where realy
#define LED_PIN 13            // pin led
#define PIN_PHOTO_SENSOR A5   // pin where photo sensor (analog in)

// obj dht sensor
DHT_Unified dht(DHT_PIN, DHTTYPE);

// Serial number and verison firmware
#define serialNumber "0000-0000-0000-0001"
#define versionFirmware "0.25b"


void setup() 
{
  Serial.begin(SERIAL_BAUD_RATE);

  // Bluetooth module
  BT.begin(SERIAL_BAUD_RATE);

  // init pinMode
  pinMode(LED_PIN, OUTPUT);   
  pinMode(RELAY_PIN, OUTPUT);  
  digitalWrite(RELAY_PIN, HIGH);

  dht.begin();

  // wait 2 saecond for init
  delay(2000);
  Serial.println("ENTER AT Commands:");
}// void setup()

 
void loop() 
{
  int moistureSensorValue = analogRead(A0);
  int percentageHumididy = map(moistureSensorValue, wet, dry, 100, 0);

  int lightSensorValue = ((1000 - analogRead(PIN_PHOTO_SENSOR)) / 1000.0) * 1000.0;

  int airTemperature = 0;
  int airHumidity = 0;

  sensors_event_t event;
  dht.temperature().getEvent(&event);

  // get temperature
  if (isnan(event.temperature))
  {
    Serial.println(F("Error reading temperature!"));
  }
  else 
  {
    airTemperature = round(event.temperature);
  }

  dht.humidity().getEvent(&event);

  // get humidity
  if (isnan(event.relative_humidity))
  {
    Serial.println(F("Error reading humidity!"));
  }
  else
  {
    airHumidity = round(event.relative_humidity);
  }

  sendSensorData(percentageHumididy, airTemperature, airHumidity, lightSensorValue);

  // сheck data from Bluetooth module and send to Serial Monitor for get command
  if (BT.available()) 
  {
    while (BT.available())
    {
      char c = BT.read();

      Serial.write(c);

      if (c == '1')
      {
        digitalWrite(LED_PIN, HIGH);
        digitalWrite(RELAY_PIN, LOW);
      }
      
      if (c == '0')
      {
        digitalWrite(LED_PIN, LOW);
        digitalWrite(RELAY_PIN, HIGH);
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


void sendSensorData(int soilMoisture, int airTemperature, int airHumidity, int lightLevel) 
{
  if (BT) 
  {
    // Create JSON object
    JSONVar jsonData;

    // serial number and firmware ver
    jsonData["serialNumber"] = serialNumber;
    jsonData["versionFirmware"] = versionFirmware;
    
    // data from sensor
    jsonData["soilMoisture"] = soilMoisture;
    jsonData["airHumidity"] = airHumidity;
    jsonData["airTemperature"] = airTemperature;
    jsonData["lightLevel"] = lightLevel;

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
}// void sendSensorData(int soilMoisture, int airTemperature, int airHumidity)  
