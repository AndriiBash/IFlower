#include <Arduino.h>
#include <SoftwareSerial.h>
#include <Arduino_JSON.h>

#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <DHT_U.h>

// include AUnit test's
#line 2 "AUnitTest.ino"
#include <AUnit.h>
using namespace aunit;

// const value seriaul bate
const unsigned long SERIAL_BAUD_RATE = 9600;

// value for Moisture Sensor v1.2
const int dry = 510;          // value for dry sensor
const int wet = 210;          // value for wet sensor

#define BT Serial3            // Bluetooth serial
#define DHTTYPE DHT11         //DH11 Version sensor

// Pin's
#define DHT_PIN 52            // pin where include DH11 sensor for get data
#define RELAY_PIN 50          // pin where controll realy
#define LED_PIN 13            // pin led
#define PIN_SOIL_SENSOR A0    // pin where soil sensor (analog in)
#define PIN_PHOTO_SENSOR A5   // pin where photo sensor (analog in)

// Serial number and verison firmware
#define serialNumber "0000-0000-0000-0001"
#define versionFirmware "0.3a"


// Base abstract class for all sensors
class Sensor 
{
  protected:
      int pin;  // Pin for connecting the sensor
  public:
    Sensor(int pin) : pin(pin) {}
    virtual int readValue() = 0;  // Just virtual method for reading data
};// class Sensor


// Base abstract class for all sensors
class Equipment 
{
  protected:
      int pin;   // Pin for connecting the equimpent
      bool isOn; // Flag to check if the equipment is on or off
  public:
    // Constructor to initialize pin and default state
    Equipment(int pin) : pin(pin), isOn(false) {}

    // Method to turn on the equipment
    virtual void turnOn() 
    {
        // Assuming HIGH is the state to turn on the equipment
        //digitalWrite(pin, HIGH);
        isOn = true;
    }// virtual void turnOn()

    // Method to turn off the equipment
    virtual void turnOff() 
    {
        // Assuming LOW is the state to turn off the equipment
        //digitalWrite(pin, LOW);
        isOn = false;
    }// virtual void turnOff()

    // Check if the equipment is on
    bool isEquipmentOn()
    {
      return isOn;
    }// bool isEquipmentOn()
};// class Sensor


// Class for soil moisture sensor
class SoilMoistureSensor : public Sensor 
{
  public:
    SoilMoistureSensor(int pin) : Sensor(pin) {}

    int readValue() override 
    {
        int moistureSensorValue = analogRead(pin);
        return map(moistureSensorValue, wet, dry, 100, 0);  // Converting Soil Moisture Value
    }
};// class SoilMoistureSensor : public Sensor


// Class for temperature and humidity sensor (DHT)
class AirTemperatureHumiditySensor : public Sensor 
{
  private:
    DHT_Unified dht;  // DHT sensor object created within the class
  public:
    AirTemperatureHumiditySensor(int pin, int dhtType) : Sensor(pin), dht(pin, dhtType) 
    {
        dht.begin();  // Initialize the DHT sensor
    }

    // Implementing the readValue method
    int readValue() override 
    {
        return 0; // null
    }

    // Method for obtaining air temperature
    int readTemperature() 
    {
        sensors_event_t event;
        dht.temperature().getEvent(&event);
        if (isnan(event.temperature)) 
        {
            Serial.println(F("Error reading temperature!"));
            return 0;
        }
        else 
        {
            return round(event.temperature);  // Returning the rounded temperature value
        }
    }

    // Method for obtaining air humidity
    int readHumidity() 
    {
        sensors_event_t event;
        dht.humidity().getEvent(&event);
        if (isnan(event.relative_humidity))
        {
            Serial.println(F("Error reading humidity!"));
            return 0;
        }
        else 
        {
          return round(event.relative_humidity);  // Returning the rounded humidity value
        }
    }
};// class AirTemperatureHumiditySensor : public Sensor


// Class LightSensor
class LightSensor : public Sensor 
{
  public:
    LightSensor(int pin) : Sensor(pin) {}

    int readValue() override 
    {
      return ((1000 - analogRead(pin)) / 1000.0) * 1000.0;  // Convert illuminance value
    }
};// class LightSensor : public Sensor 


struct ClimateFactors 
{
    int soilMoisture;
    int airTemperature;
    int airHumidity;
    int lightLevel;
};// struct ClimateFactors 

// GrennHouse
class GreenHouse
{
    private:
      ClimateFactors *climateFactors;
      SoilMoistureSensor *moistureSensor;
      AirTemperatureHumiditySensor *tempHumiditySensor;
      LightSensor *lightSensor;

      Equipment *wateringSystem;    

    public:
      GreenHouse(SoilMoistureSensor *ms, AirTemperatureHumiditySensor *ths, LightSensor *ls, Equipment *lsys) 
      {
        climateFactors = new ClimateFactors();
        moistureSensor = ms;
        tempHumiditySensor = ths;
        lightSensor = ls;

        wateringSystem = lsys;
      }

      ~GreenHouse() 
      {
        delete climateFactors;
      }

      // Method to collect data from sensors
      void collectData() 
      {
        climateFactors->soilMoisture = moistureSensor->readValue();
        climateFactors->airTemperature = tempHumiditySensor->readTemperature();
        climateFactors->airHumidity = tempHumiditySensor->readHumidity();
        climateFactors->lightLevel = lightSensor->readValue();
      }

      void turnOnWateringSystem()
      {
        wateringSystem->turnOn();
        Serial.println("Watering system is turned on.");
      }

      void turnOffWateringSystem()
      {
        wateringSystem->turnOff();
        Serial.println("Watering system is turned off.");
      }

      // Getters
      int getSoilMoisture() const
      {
        return climateFactors->soilMoisture;
      }

      int getAirTemperature() const 
      {
        return climateFactors->airTemperature;
      }

      int getAirHumidity() const 
      {
        return climateFactors->airHumidity;
      }

      int getLightLevel() const 
      {
        return climateFactors->lightLevel;
      }

      // Setters
      void setSoilMoisture(int moisture) 
      {
        climateFactors->soilMoisture = moisture;
      }

      void setAirTemperature(int temperature) 
      {
        climateFactors->airTemperature = temperature;
      }

      void setAirHumidity(int humidity) 
      {
        climateFactors->airHumidity = humidity;
      }

      void setLightLevel(int light) 
      {
        climateFactors->lightLevel = light;
      }

      // Method to send data via Bluetooth
      void sendDataToBluetooth() 
      {
          JSONVar jsonData;
          // serial number and firmware ver
          jsonData["serialNumber"] = serialNumber;
          jsonData["versionFirmware"] = versionFirmware;
    
          // data from sensor
          jsonData["soilMoisture"] = climateFactors->soilMoisture;
          jsonData["airTemperature"] = climateFactors->airTemperature;
          jsonData["airHumidity"] = climateFactors->airHumidity;
          jsonData["lightLevel"] = climateFactors->lightLevel;
          
          String jsonString = JSON.stringify(jsonData);
          BT.print(jsonString);  // Send data via Bluetooth
          BT.print("\n");

          // debug
          //Serial.println("Data sent via Bluetooth: " + jsonString);
      }

      void processCommandFromBluetooth(const String& data)
      {
        Serial.println("Received Bluetooth Data: " + data);

        if (data == "turnOnWatering")
        {
          digitalWrite(RELAY_PIN, LOW);
          //turnOnWateringSystem();
          Serial.println("Watering system turned ON via Bluetooth.");
        }
        else if (data == "turnOffWatering")
        {
          digitalWrite(RELAY_PIN, HIGH);
          //turnOffWateringSystem();
          Serial.println("Watering system turned OFF via Bluetooth.");
        }
        else if (data == "getStatus")
        {
          collectData();
          sendDataToBluetooth();
          Serial.println("Status sent via Bluetooth.");
        }
        else
        {
          Serial.println("Unknown command received.");
        }
      }// void processCommandFromBluetooth(const String& data)
};// class greenHouse

// init GreenHouse
GreenHouse *greenHouse;

void setup() 
{
  Serial.begin(SERIAL_BAUD_RATE);

  // Init sensor
  SoilMoistureSensor soilMoistureSensor(PIN_SOIL_SENSOR); // Soil moisture sensor on pin 
  AirTemperatureHumiditySensor airSensor(DHT_PIN, DHT11); // Temperature and humidity sensor
  LightSensor lightSensor(PIN_PHOTO_SENSOR);              // Light sensor on analog pin 

  // init equipment
  Equipment wateringSystem(RELAY_PIN);

  // new init GreenGouse
  greenHouse = new GreenHouse(&soilMoistureSensor, &airSensor, &lightSensor, &wateringSystem); // GreenHouse

  // get data
  greenHouse->collectData();

  // sending data via bluetooth
  greenHouse->sendDataToBluetooth();

  // Bluetooth module
  BT.begin(SERIAL_BAUD_RATE);

  // init pinMode
  pinMode(LED_PIN, OUTPUT);  

  digitalWrite(RELAY_PIN, HIGH);  //off relay
  pinMode(RELAY_PIN, OUTPUT);  
  digitalWrite(RELAY_PIN, HIGH);  //off relay

  // wait 2 saecond for init
  delay(2000);
  Serial.println("ENTER AT Commands:");
}// void setup()

void loop() 
{
  // for start test's
  //TestRunner::run();
  
  // Collect data from sensors
  greenHouse->collectData();
  greenHouse->sendDataToBluetooth();

  String receivedData = "";

  while(BT.available() > 0)
  {
    char c = BT.read();

    if (c == '\n') 
    {
      greenHouse->processCommandFromBluetooth(receivedData);
      receivedData = "";
    }
    else
    {
      receivedData += c;
    }
  }

  delay(1000); // Wait for 1 second before the next loop
}// void loop()

// for debug data analysis 
void debugMode()
{
  // Collect data from sensors
  greenHouse->collectData();

  // Output the collected data to the serial monitor
  Serial.print("Soil Moisture: ");
  Serial.print(greenHouse->getSoilMoisture());
  Serial.println("%"); // Output as percentage

  Serial.print("Air Temperature: ");
  Serial.print(greenHouse->getAirTemperature());
  Serial.println("°C"); // Output in degrees Celsius

  Serial.print("Air Humidity: ");
  Serial.print(greenHouse->getAirHumidity());
  Serial.println("%"); // Output as percentage

  Serial.print("Light Level: ");
  Serial.print(greenHouse->getLightLevel());
  Serial.println("Lux"); // Output as percentage

  // Send data via Bluetooth (optional)
  greenHouse->sendDataToBluetooth();
}// void debugMode()


// Unit test's
// test for SoilMoistureSensor
test(SoilMoistureSensorTest) 
{
  SoilMoistureSensor sensor(PIN_SOIL_SENSOR);

  int result = sensor.readValue();

  assertTrue(result >= 0 && result <= 100); // Ensure the value is in percentage range (0-100)
}// test(SoilMoistureSensorTest) 

// test for WateringSystem
test(WateringSystemTest) 
{
  Equipment wateringSystem(RELAY_PIN);
  
  wateringSystem.turnOn();
  assertTrue(wateringSystem.isEquipmentOn()); // Check if the watering system is on

  wateringSystem.turnOff();
  assertFalse(wateringSystem.isEquipmentOn()); // Check if the watering system is off
}// test(WateringSystemTest) 

// test for GreenHouse
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
  assertTrue(greenhouse.getAirHumidity() >= 0 && greenhouse.getAirHumidity() <= 100); // Check humidity range
  assertTrue(greenhouse.getLightLevel() >= 0 && greenhouse.getLightLevel() <= 1000); // Check light level range

  // Test watering system control
  greenhouse.turnOnWateringSystem();
  assertTrue(wateringSystem.isEquipmentOn()); // Check if watering system is turned on

  greenhouse.turnOffWateringSystem();
  assertFalse(wateringSystem.isEquipmentOn()); // Check if watering system is turned off
}// test(GreenHouseTest) 
