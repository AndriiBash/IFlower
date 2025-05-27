#include <Arduino.h>
#include <SoftwareSerial.h>
#include <Arduino_JSON.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>
#include <EEPROM.h>

#line 2 "AUnitTest.ino"
#include <AUnit.h>
using namespace aunit;

// Constants
const unsigned long SERIAL_BAUD_RATE = 9600;
const int dry = 1023;          // value for dry sensor
const int wet = 350;          // value for wet sensor

#define BT Serial3            // Bluetooth serial
#define DHTTYPE DHT11         // DHT11 sensor type

// Pin definitions
#define DHT_PIN 52            // DHT sensor pin
#define RELAY_PIN 50          // Relay control pin
#define LED_PIN 13            // LED pin
#define PIN_SOIL_SENSOR A0    // Soil moisture sensor pin
#define PIN_PHOTO_SENSOR A5   // Light sensor pin

#define EEPROM_START_ADDRESS 0
#define TEMPERATURE_ARRAY_SIZE 24

// Serial number and firmware version
#define serialNumber "0000-0000-0000-0001"
#define versionFirmware "0.5a"

#define isTestMode 0

// Base Sensor Class
class Sensor
{
protected:
  int pin;

public:
  Sensor(int pin) : pin(pin) {}

  virtual int readValue() = 0;
};

// Soil Moisture Sensor Class
class SoilMoistureSensor : public Sensor
{
public:
  SoilMoistureSensor(int pin) : Sensor(pin) {}

  int readValue() override
  {
    int rawValue = analogRead(pin);
    rawValue = constrain(rawValue, wet, dry);
    return map(rawValue, wet, dry, 100, 0);
  }
};

// Air Temperature and Humidity Sensor Class
class AirTemperatureHumiditySensor : public Sensor
{
private:
  DHT_Unified dht;

public:
  AirTemperatureHumiditySensor(int pin, int dhtType) : Sensor(pin), dht(pin, dhtType) {
    dht.begin();
  }

  int readValue() override {
    return 0; // Not used, temperature and humidity have separate methods
  }

  int readTemperature() {
    sensors_event_t event;
    dht.temperature().getEvent(&event);
    if (isnan(event.temperature)) {
      Serial.println(F("Error reading temperature!"));
      return 0;
    }
    return round(event.temperature);
  }

  int readHumidity() {
    sensors_event_t event;
    dht.humidity().getEvent(&event);
    if (isnan(event.relative_humidity)) {
      Serial.println(F("Error reading humidity!"));
      return 0;
    }
    return round(event.relative_humidity);
  }
};

// Light Sensor Class
class LightSensor : public Sensor
{
public:
  LightSensor(int pin) : Sensor(pin) {}

  int readValue() override
  {
    return 1023 - analogRead(pin);
  }
};

// Climate Factors Structure
struct ClimateFactors
{
  int soilMoisture;
  int airTemperature;
  int airHumidity;
  int lightLevel;

  int maxSoilMoisture;  // Maximum soil moisture value
  int minSoilMoisture;  // Minimum soil moisture value
};

// Equipment Class
class Equipment
{
protected:
  int pin;
  bool isOn;

public:
  Equipment(int pin) : pin(pin), isOn(false) {}

  void turnOn()
  {
    digitalWrite(pin, LOW);
    isOn = true;
  }

  void turnOff()
  {
    digitalWrite(pin, HIGH);
    isOn = false;
  }

  bool isEquipmentOn()
  {
    return isOn;
  }
};

// GreenHouse Class
class GreenHouse
{
private:
  int temperatures[TEMPERATURE_ARRAY_SIZE];
  int temperaturesYesterday[TEMPERATURE_ARRAY_SIZE];

  ClimateFactors *climateFactors;
  SoilMoistureSensor *moistureSensor;
  AirTemperatureHumiditySensor *tempHumiditySensor;
  LightSensor *lightSensor;
  Equipment *wateringSystem;

public:
  GreenHouse(SoilMoistureSensor *ms, AirTemperatureHumiditySensor *ths, LightSensor *ls, Equipment *ws)
      : moistureSensor(ms), tempHumiditySensor(ths), lightSensor(ls), wateringSystem(ws)
  {
    climateFactors = new ClimateFactors();
  }


  ~GreenHouse()
  {
    delete climateFactors;
  }


  void collectData()
  {
    climateFactors->soilMoisture = moistureSensor->readValue();
    climateFactors->airTemperature = tempHumiditySensor->readTemperature();
    climateFactors->airHumidity = tempHumiditySensor->readHumidity();
    climateFactors->lightLevel = lightSensor->readValue();
  }


  void readTemperatureArray() 
  {
    for (int i = 0; i < TEMPERATURE_ARRAY_SIZE; i++) 
    {
      int address = EEPROM_START_ADDRESS + i * sizeof(int);
      EEPROM.get(address, temperatures[i]);
    }
    
    int yesterdayStartAddress = EEPROM_START_ADDRESS + TEMPERATURE_ARRAY_SIZE * sizeof(int);
    for (int i = 0; i < TEMPERATURE_ARRAY_SIZE; i++) 
    {
        int address = yesterdayStartAddress + i * sizeof(int);
        EEPROM.get(address, temperaturesYesterday[i]);
    }
  }


  void writeTemperatureArray()
  {
    for (int i = 0; i < TEMPERATURE_ARRAY_SIZE; i++)
    {
      temperatures[i] = random(15, 35);
      temperaturesYesterday[i] = random(15, 35);
    }

    for (int i = 0; i < TEMPERATURE_ARRAY_SIZE; i++) 
    {
      int address = EEPROM_START_ADDRESS + i * sizeof(int);
      EEPROM.put(address, temperatures[i]);
    }

    int yesterdayStartAddress = EEPROM_START_ADDRESS + TEMPERATURE_ARRAY_SIZE * sizeof(int);
    for (int i = 0; i < TEMPERATURE_ARRAY_SIZE; i++) 
    {
        int address = yesterdayStartAddress + i * sizeof(int);
        EEPROM.put(address, temperaturesYesterday[i]);
    }

    if (isTestMode)
    {
      Serial.println("Temperature array saved to EEPROM.");
    }
  }


  int getSoilMoisture() const { return climateFactors->soilMoisture; }
  int getAirTemperature() const { return climateFactors->airTemperature; }
  int getAirHumidity() const { return climateFactors->airHumidity; }
  int getLightLevel() const { return climateFactors->lightLevel; }


  void turnOnWateringSystem()
  {
    wateringSystem->turnOn();
  }

  void turnOffWateringSystem()
  {
    wateringSystem->turnOff();
  }
  
  void writeSoilMoistureValues()
  {
    int soilMoistureStartAddress = EEPROM_START_ADDRESS + TEMPERATURE_ARRAY_SIZE * sizeof(int) + TEMPERATURE_ARRAY_SIZE * sizeof(int);

    EEPROM.put(soilMoistureStartAddress, climateFactors->minSoilMoisture);
    EEPROM.put(soilMoistureStartAddress + sizeof(int), climateFactors->maxSoilMoisture);
  }

  void readSoilMoistureValues()
  {
    int soilMoistureStartAddress = EEPROM_START_ADDRESS + TEMPERATURE_ARRAY_SIZE * sizeof(int) + TEMPERATURE_ARRAY_SIZE * sizeof(int);

    EEPROM.get(soilMoistureStartAddress, climateFactors->minSoilMoisture);
    EEPROM.get(soilMoistureStartAddress + sizeof(int), climateFactors->maxSoilMoisture);
  }


  void sendDataToBluetooth()
  {
    JSONVar jsonData;
    jsonData["serialNumber"] = serialNumber;
    jsonData["versionFirmware"] = versionFirmware;
    jsonData["soilMoisture"] = climateFactors->soilMoisture;
    jsonData["airTemperature"] = climateFactors->airTemperature;
    jsonData["airHumidity"] = climateFactors->airHumidity;
    jsonData["lightLevel"] = climateFactors->lightLevel;
    jsonData["isWatering"] = wateringSystem->isEquipmentOn();

    jsonData["minSoilMoisture"] = climateFactors->minSoilMoisture;
    jsonData["maxSoilMoisture"] = climateFactors->maxSoilMoisture;

    JSONVar temperatureArray;
    JSONVar yesterdayTemperatureArray;
    
    for (int i = 0; i < TEMPERATURE_ARRAY_SIZE; i++)
    {
      temperatureArray[i] = temperatures[i];
      yesterdayTemperatureArray[i] = temperaturesYesterday[i];
    }

    jsonData["temperatureArray"] = temperatureArray;
    jsonData["yesterdayTemperatureArray"] = yesterdayTemperatureArray;

    String jsonString = JSON.stringify(jsonData);
    BT.print(jsonString);
    BT.print("\n");
  }


  void processCommandFromBluetooth(const String &data)
  {
    Serial.println("data received:" + data);

    if (data == "turnOnWatering")
    {
      turnOnWateringSystem();
    }
    else if (data == "turnOffWatering")
    {
      turnOffWateringSystem();
    }
    else
    {
      JSONVar doc = JSON.parse(data);

      if (doc.hasOwnProperty("max") && doc.hasOwnProperty("min"))
      {
        int maxSM = doc["max"];
        int minSM = doc["min"];

        climateFactors->maxSoilMoisture = maxSM;
        climateFactors->minSoilMoisture = minSM;

        writeSoilMoistureValues();
        Serial.print("Max Soil Moisture: ");
        Serial.println(climateFactors->maxSoilMoisture);
        Serial.print("Min Soil Moisture: ");
        Serial.println(climateFactors->minSoilMoisture);
      }
      else
      {
        Serial.println("Unknown command received.");
      }
    }
  }

  void receiveBluetoothCommand()
  {
    String receivedData = "";
    while (BT.available() > 0)
    {
      char c = BT.read();
      if (c == '\n')
      {
        processCommandFromBluetooth(receivedData);
        receivedData = "";
      }
      else
      {
        receivedData += c;
      }
    }
  }
};

// Initialize sensors and equipment
SoilMoistureSensor soilMoistureSensor(PIN_SOIL_SENSOR);
AirTemperatureHumiditySensor airSensor(DHT_PIN, DHT11);
LightSensor lightSensor(PIN_PHOTO_SENSOR);
Equipment wateringSystem(RELAY_PIN);
GreenHouse *greenHouse;

void setup()
{
  Serial.begin(SERIAL_BAUD_RATE);
  BT.begin(SERIAL_BAUD_RATE);
  pinMode(LED_PIN, OUTPUT);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, HIGH); // Turn off relay initially

  greenHouse = new GreenHouse(&soilMoistureSensor, &airSensor, &lightSensor, &wateringSystem);
  greenHouse->collectData();
  greenHouse->writeTemperatureArray();
  greenHouse->readTemperatureArray();
  greenHouse->readSoilMoistureValues();
  greenHouse->sendDataToBluetooth();
}

void loop()
{
  // for start test's
  if (isTestMode)
  {
    TestRunner::run();
  }
  else
  {
    greenHouse->receiveBluetoothCommand();
    greenHouse->collectData();
    greenHouse->sendDataToBluetooth();
  }

  delay(1000);
}

// Unit test's
// Test for SoilMoistureSensor
test(SoilMoistureSensorTest)
{
  SoilMoistureSensor sensor(PIN_SOIL_SENSOR);

  int result = sensor.readValue();

  assertTrue(result >= 0 && result <= 100); // Ensure the value is in percentage range (0-100)
}

// Test for AirTemperatureHumiditySensor
test(AirTemperatureHumiditySensorTest)
{
  AirTemperatureHumiditySensor airSensor(DHT_PIN, DHT11);

  int temperature = airSensor.readTemperature();
  int humidity = airSensor.readHumidity();

  assertTrue(temperature >= -50 && temperature <= 50); // Check temperature range
  assertTrue(humidity >= 0 && humidity <= 100); // Check humidity range
}

// Test for LightSensor
test(LightSensorTest)
{
  LightSensor sensor(PIN_PHOTO_SENSOR);

  int result = sensor.readValue();

  assertTrue(result >= 0 && result <= 1000); // Ensure light level is in valid range
}

// Test for WateringSystem
test(WateringSystemTest)
{
  Equipment wateringSystem(RELAY_PIN);

  wateringSystem.turnOn();
  assertTrue(wateringSystem.isEquipmentOn()); // Check if the watering system is on

  wateringSystem.turnOff();
  assertFalse(wateringSystem.isEquipmentOn()); // Check if the watering system is off
}

// Test for GreenHouse
test(GreenHouseTest)
{
  // Initialize sensors and equipment
  SoilMoistureSensor moistureSensor(PIN_SOIL_SENSOR);
  AirTemperatureHumiditySensor airSensor(DHT_PIN, DHT11);
  LightSensor lightSensor(PIN_PHOTO_SENSOR);
  Equipment wateringSystem(RELAY_PIN);

  // Create an instance of the GreenHouse
  GreenHouse greenhouse(&moistureSensor, &airSensor, &lightSensor, &wateringSystem);

  // Collect data from sensors
  greenhouse.collectData();

  assertTrue(greenhouse.getSoilMoisture() >= 0 && greenhouse.getSoilMoisture() <= 100); // Check soil moisture range
  assertTrue(greenhouse.getAirTemperature() >= -50 && greenhouse.getAirTemperature() <= 50); // Check air temperature range
  assertTrue(greenhouse.getAirHumidity() >= 0 && greenhouse.getAirHumidity() <= 100); // Check air humidity range
  assertTrue(greenhouse.getLightLevel() >= 0 && greenhouse.getLightLevel() <= 1000); // Check light level range

  // Test watering system control
  greenhouse.turnOnWateringSystem();
  assertTrue(wateringSystem.isEquipmentOn()); // Check if watering system is turned on

  greenhouse.turnOffWateringSystem();
  assertFalse(wateringSystem.isEquipmentOn()); // Check if watering system is turned off
}

// Test for Bluetooth Command Processing
test(BluetoothCommandProcessingTest)
{
  SoilMoistureSensor moistureSensor(PIN_SOIL_SENSOR);
  AirTemperatureHumiditySensor airSensor(DHT_PIN, DHT11);
  LightSensor lightSensor(PIN_PHOTO_SENSOR);
  Equipment wateringSystem(RELAY_PIN);
  GreenHouse greenhouse(&moistureSensor, &airSensor, &lightSensor, &wateringSystem);

  // Test turnOnWatering command
  greenhouse.processCommandFromBluetooth("turnOnWatering");
  assertTrue(wateringSystem.isEquipmentOn()); // Watering system should be ON

  // Test turnOffWatering command
  greenhouse.processCommandFromBluetooth("turnOffWatering");
  assertFalse(wateringSystem.isEquipmentOn()); // Watering system should be OFF

  // Test getStatus command
  greenhouse.processCommandFromBluetooth("getStatus");
  assertTrue(greenhouse.getSoilMoisture() >= 0); // Ensure data collection works
}