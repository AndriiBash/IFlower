#include <Arduino.h>
#include <SoftwareSerial.h>

// const value seriaul bate and led pin
const unsigned long SERIAL_BAUD_RATE = 9600;
const int ledPin = 13;     

// value for Moisture Sensor v1.2
const int dry = 510; // value for dry sensor
const int wet = 210; // value for wet sensor

#define BT Serial3 // Bluetooch serial



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
}

 
void loop() 
{
  int moistureSensorValue = analogRead(A0);
  int percentageHumididy = map(moistureSensorValue, wet, dry, 100, 0);

  Serial.print(percentageHumididy);
  Serial.println("%");
  sendHumidityData(percentageHumididy);


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
}


void sendHumidityData(int humidity) 
{
  if (BT) 
  {
    BT.print(humidity);
    Serial.println("Data sent to Bluetooth");
  } 
  else 
  {
    Serial.println("Bluetooth module not connected");
  }
}
