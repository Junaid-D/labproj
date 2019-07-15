#include <TimeLib.h>
#include <math.h>
#include <LiquidCrystal.h>
unsigned long previousMillis = 0;        // will store last time ADC queried
int ADCpin = A0;
byte flag =0;

const byte numStamps = 6; //n
const byte averagePeriod = 10; //t

// constants won't change:
const byte sampleRate = 120;
const byte scaledSampleRate = 30;
const byte slowestPulse = 6;
byte decimCtr = 0;

const byte scaleFac = sampleRate/scaledSampleRate;

const long interval = (1/(float)sampleRate) *1000;           // interval at which to blink (milliseconds)
const int windowSize=scaledSampleRate*slowestPulse;



const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;        


float sampleWindow[windowSize] = {0};

float decimWindow[scaleFac] = {0};

float RR=0;
float SMA=0;
int stamps[numStamps];

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  lcd.begin(16, 2);
}

void fillDecim(float val)
{
    for (int i=0;i<scaleFac-1;i++)
    {
      decimWindow[i]=decimWindow[i+1];
    }
    decimWindow[scaleFac-1] = val;
  
}

float decimate()
{
  float temp=0;
  for (int i=0;i<scaleFac;i++)
    {
      temp+=decimWindow[i];
    }
    return temp/scaleFac;
}


void calcSMA()
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
  if(val>SMA && flag==0)
  {
    flag=1;
    for (int i=0;i<numStamps-1;i++)
    {
      stamps[i]=stamps[i+1];
    }
    stamps[numStamps-1] = millis();
  }
  
  if(val<SMA && flag==1)
  {
    flag=0;
  }
  
}
void updateRR()
{

  int avg=0;

  for(int i=0; i<numStamps-1;i++)
  {
    avg += stamps[i+1]-stamps[i];

  }
  avg/=(numStamps-1);// in millisec

  float freq=avg/((float)1000);
  Serial.println(1/freq);
  RR=(60)/freq; //convert to BPM
  
}

void loop() {
  unsigned long currentMillis = millis();
  float t = currentMillis/((float)1000);
   if (currentMillis - previousMillis >= interval) {
    decimCtr++;
    previousMillis = currentMillis;
    //int sensorValue = analogRead(A0);
    float freq = 2*M_PI*0.2;
    float voltage = 3.2 +  0.2*sin (freq*t);

    fillDecim(voltage);
  }
  
  if(decimCtr==scaleFac){
    appendWindow(decimate());
    calcSMA();
    detect(decimate());
    updateRR();
    decimCtr=0;
  }
  
   if (currentMillis - dispMillis >= dispInterval) {
    dispMillis = currentMillis;
    lcd.setCursor(0, 0);
    lcd.print(F("RR: "));
    lcd.print(RR,5);

    lcd.setCursor(0, 1);
    lcd.print(F("SMA: "));
    lcd.print(SMA,5);
    lcd.print(F("S:"));
    lcd.print(interval);

  }
}
