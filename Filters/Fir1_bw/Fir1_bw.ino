

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



const long interval = (1/(float)sampleRate) *1000;           // interval at which to blink (milliseconds)



const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;        



float RR=0;
float SMA=0;

const byte numTaps = 11;

float filterCoeffs[numTaps] = {0.0145971624312867,0.0306283292318002,
0.0725992192286402, 0.124479725293171,
0.166452876184707,0.182485375260789,
0.166452876184707,0.124479725293171,
0.0725992192286402, 0.0306283292318002,
0.0145971624312867};

float filterWindow [numTaps] = {0};

int stamps[numStamps];

const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  lcd.begin(16, 2);
}

void fillFilt(float val)
{
    for (int i=0;i<numTaps-1;i++)
    {
      filterWindow[i]=filterWindow[i+1];
    }
    filterWindow[numTaps-1] = val;
  
}




void calcSMA()
{
  float temp=0;
  for (int i=0;i<numTaps;i++)
  {
    temp+=filterWindow[i]*filterCoeffs[i];
  }
  SMA=temp;
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
  Serial.println(1/freq);
  RR=(60)/freq; //convert to BPM
  
}

void loop() {
  unsigned long currentMillis = millis();
  float t = currentMillis/((float)1000);
   if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    //int sensorValue = analogRead(A0);
    float freq = 2*M_PI*0.1;
    float voltage = 3.2 +  0.2*sin (freq*t);

    fillFilt(voltage);
    calcSMA();
    detect(voltage);
    updateRR();
  }
  
 
  
   if (currentMillis - dispMillis >= dispInterval) {
    dispMillis = currentMillis;
    lcd.setCursor(0, 0);
    lcd.print(F("RR: "));
    lcd.print(RR,5);

    lcd.setCursor(0, 1);
    lcd.print(F("DC: "));
    lcd.print(SMA,5);
    lcd.print(F("S:"));
    lcd.print(interval);

  }
}
