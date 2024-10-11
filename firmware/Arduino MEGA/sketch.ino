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

#define BT Serial3    // Bluetooth serial
#define DHTTYPE DHT11 //DH11 Version sensor

// Pin's
#define DHT_PIN 52            // pin where include DH11 sensor for get data
#define RELAY_PIN 50          // pin where realy
#define LED_PIN 13            // pin led
#define PIN_SOIL_SENSOR A0    // pin where soil sensor (analog in)
#define PIN_PHOTO_SENSOR A5   // pin where photo sensor (analog in)

// Serial number and verison firmware
#define serialNumber "0000-0000-0000-0001"
#define versionFirmware "0.25b"

// Base abstract class for all sensors
class Sensor 
{
  protected:
      int pin;  // Pin for connecting the sensor
  public:
    Sensor(int pin) : pin(pin) {}
    virtual int readValue() = 0;  // Just virtual method for reading data
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


// Класс для датчика освещенности
class LightSensor : public Sensor 
{
  public:
    LightSensor(int pin) : Sensor(pin) {}

    int readValue() override 
    {
        return ((1000 - analogRead(pin)) / 1000.0) * 1000.0;  // Convert illuminance value
    }
};

struct ClimateFactors 
{
    int soilMoisture;
    int airTemperature;
    int airHumidity;
    int lightLevel;
};// struct ClimateFactors 

class GreenHouse
{
    private:
      ClimateFactors *climateFactors;
      SoilMoistureSensor *moistureSensor;
      AirTemperatureHumiditySensor *tempHumiditySensor;
      LightSensor *lightSensor;

    public:
      GreenHouse(SoilMoistureSensor *ms, AirTemperatureHumiditySensor *ths, LightSensor *ls) 
      {
        climateFactors = new ClimateFactors();
        moistureSensor = ms;
        tempHumiditySensor = ths;
        lightSensor = ls;
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
          Serial.println("Data sent via Bluetooth: " + jsonString);
      }
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

  // new init GreenGouse
  greenHouse = new GreenHouse(&soilMoistureSensor, &airSensor, &lightSensor); // Создаем объект GreenHouse

  // get data
  greenHouse->collectData();

  // sending data via bluetooth
  greenHouse->sendDataToBluetooth();

  // Bluetooth module
  BT.begin(SERIAL_BAUD_RATE);

  // init pinMode
  pinMode(LED_PIN, OUTPUT);   
  pinMode(RELAY_PIN, OUTPUT);  
  digitalWrite(RELAY_PIN, HIGH);

  // wait 2 saecond for init
  delay(2000);
  Serial.println("ENTER AT Commands:");
}// void setup()


void loop() 
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

  delay(1000); // Wait for 1 second before the next loop
}// void loop()
