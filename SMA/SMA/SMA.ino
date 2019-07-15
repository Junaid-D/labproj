#include <TimeLib.h>
#include <LiquidCrystal.h>
unsigned long previousMillis = 0;        // will store last time ADC queried
int ADCpin = A0;
byte flag =0;

const byte numStamps = 5; //n
const byte averagePeriod = 5; //t

// constants won't change:
const int sampleRate = 120;
const int slowestPulse = 3;
const long interval = (1/(float)sampleRate) *1000;           // interval at which to blink (milliseconds)
const int windowSize=sampleRate*slowestPulse;

const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;        


float sampleWindow[windowSize]={0};
float RR=0;
float SMA=0;
time_t stamps[numStamps];

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  lcd.begin(16, 2);
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
  if(val>SMA && flag==0)
  {
    flag=1;
    for (int i=0;i<numStamps-1;i++)
    {
      stamps[i]=stamps[i+1];
    }
    stamps[numStamps-1] = now();
  }
  
  if(val<SMA && flag==1)
  {
    flag=0;
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
  // put your main code here, to run repeatedly:

}
