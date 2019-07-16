#include <TimeLib.h>
#include <LiquidCrystal.h>
unsigned long previousMillis = 0;        // will store last time ADC queried
int ADCpin = A0;
byte flag =0;

const byte numStamps = 5; //n
const byte averagePeriod = 5; //t

// constants won't change:
const int sampleRate = 120;
const float slowRate = 0.1;
const long interval = (1/(float)sampleRate) *1000;           // interval at which to blink (milliseconds)




const int windowSize=(sampleRate/slowRate)/32;

const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;        


float sampleWindow[windowSize]={0};
float RR=0;
float Grad = 0;
unsigned long stamps[numStamps];

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  lcd.begin(16, 2);
}


float appendWindow(float val)
{
  for (int i=0;i<windowSize-1;i++)
  {
    sampleWindow[i]=sampleWindow[i+1];
  }
  sampleWindow[windowSize-1]=val;
  
}


void calcGrad()
{
  float xx = 0;
  float xy = 0;
  float x = 0;
  float y = 0;
  
  for (int i=0;i<windowSize;i++)
  {
    x+=i;
    y+=sampleWindow[i];
    xx+= i*i;
    xy+= sampleWindow[i]*i;
  }

  Grad = (windowSize*xy - x*y)/(windowSize*xx-x*x);
  Serial.println(Grad);

}

void detect()
{ 
  if(Grad<0 && flag==0)
  {
    flag=1;
    for (int i=0;i<numStamps-1;i++)
    {
      stamps[i]=stamps[i+1];
    }
    stamps[numStamps-1] = millis();
  }
  
  if(Grad>0 && flag==1)
  {
    flag=0;
  }
  
}

void updateRR()
{
  int avg = 0;
  int count = 0;
  for(int i=0; i<numStamps-1;i++)
  {
    if(stamps[i]>0)
    {
      avg += stamps[i+1]-stamps[i];
      count++;
    }
  }
  avg/=(count);// in millisec

  float freq=avg/((float)1000);
  RR=(60)/freq; //convert to BPM
  
}

void loop() {
  unsigned long currentMillis = millis();
  float t = currentMillis/((float)1000);
   if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    //int sensorValue = analogRead(A0);
    
    float freq = 2*M_PI;
    float voltage = 3.2 +  0.2*sin (freq*t);
    
    appendWindow(voltage);
    calcGrad();
    detect();
    updateRR();
  }
   if (currentMillis - dispMillis >= dispInterval) {
    dispMillis = currentMillis;
    lcd.setCursor(0, 0);
    lcd.print(F("RR: "));
    lcd.print(RR,5);

    lcd.setCursor(0, 1);
    lcd.print(F("Grad:"));
    lcd.print(Grad,5);
    lcd.print(F("S:"));
    lcd.print(interval);

  }
}
