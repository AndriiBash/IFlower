#include <Arduino.h>
#include <SoftwareSerial.h>
#include <Arduino_JSON.h>

#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

// const value seriaul bate and led pin
const unsigned long SERIAL_BAUD_RATE = 9600;
const int ledPin = 13;     

// value for Moisture Sensor v1.2
const int dry = 510; // value for dry sensor
const int wet = 210; // value for wet sensor

#define BT Serial3 // Bluetooth serial

#define DHTPIN 52     // pin where include DH11 sensor for get data
#define DHTTYPE DHT11 //DH11 Version sensor

// obj dht sensor
DHT_Unified dht(DHTPIN, DHTTYPE);

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

  // init power supply with electricity module 
  //pinMode(53, OUTPUT); 
  //digitalWrite(53, HIGH);

  dht.begin();


  // wait 2 saecond for init
  delay(2000);
  Serial.println("ENTER AT Commands:");
}// void setup()

 
void loop() 
{
  int moistureSensorValue = analogRead(A0);
  int percentageHumididy = map(moistureSensorValue, wet, dry, 100, 0);

  int airTemperature = 0;
  int airHumidity = 0;

  //Serial.print(percentageHumididy);
  //Serial.println("%");

  sensors_event_t event;
  dht.temperature().getEvent(&event);

  //float humidity = dht.readHumidity();
  //float temperature = dht.readTemperature();

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

  sendSensorData(percentageHumididy, airTemperature, airHumidity);

  // сheck data from Bluetooth module and send to Serial Monitor for get command
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


void sendSensorData(int soilMoisture, int airTemperature, int airHumidity) 
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
    jsonData["airHumidity"] = airHumidity;
    jsonData["airTemperature"] = airTemperature;
    jsonData["lightLevel"] = 0;//lightLevel;

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
