#include <TimeLib.h>

unsigned long previousMillis = 0;        // will store last time ADC queried
int ADCpin = A0;

const byte numStamps = 5; //n
const byte averagePeriod = 5; //t

// constants won't change:
const int sampleRate = 120;
const int slowestPulse = 3;
const long interval = 1/sampleRate;           // interval at which to blink (milliseconds)
const int windowSize=sampleRate*slowestPulse;


float sampleWindow[windowSize]={0};
float RR=0;
float SMA=0;
time_t stamps[numStamps];

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
}

float calcSMA()
{
  float temp=0;
  for (int i=0;i<windowSize;i++)
  {
    temp+=sampleWindow[i];
  }
  SMA=temp/windowSize;
}

float appendWindow(float val)
{
  for (int i=0;i<windowSize-1;i++)
  {
    sampleWindow[i]=sampleWindow[i+1];
  }
  sampleWindow[windowSize-1]=val;
  
}

void detect(float val)
{
  if(val>SMA)
  {
    for (int i=0;i<numStamps-1;i++)
    {
      stamps[i]=stamps[i+1];
    }
    stamps[numStamps-1] = now();
  }
}
void updateRR()
{
  time_t cur = now();

  int count=0;

  for(int i=0; i<numStamps;i++)
  {
    if( (cur-stamps[i])<averagePeriod )
    {
      count++;
    }
  }
  RR=(count/averagePeriod)*(60/numStamps); //convert to BPM
  
}

void loop() {
  unsigned long currentMillis = millis();
   if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    int sensorValue = analogRead(A0);
    float voltage = sensorValue * (5.0 / 1023.0);
    appendWindow(voltage);
    calcSMA();
    
    Serial.println(SMA);
  }
  // put your main code here, to run repeatedly:

}
