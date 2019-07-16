

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

const byte numTaps = 31;
//matlab fir1
float filterCoeffs[numTaps] = {0.00490978693901733,0.00552744069659965,0.00735239064715894,0.0103052953470635,0.0142574274541768,0.0190362972401042,0.0244331937254776,0.0302123134725768,0.0361210774221532,0.0419011840213643,0.0472999145473743,0.0520811954082435,0.0560359327901525,0.0589911668561715,0.0608176443926426,0.0614354780794468,0.0608176443926426,0.0589911668561715,0.0560359327901525,0.0520811954082435,0.0472999145473743,0.0419011840213643,0.0361210774221532,0.0302123134725768,0.0244331937254776,0.0190362972401042,0.0142574274541768,0.0103052953470635,0.00735239064715894,0.00552744069659965,0.00490978693901733};
byte filterReady = 0;
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
  if(filterReady == 0 && filterWindow[0]>0)
    filterReady = 1;
  
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
    float freq = 2*M_PI*0.2;
    float voltage = 3.2 +  0.2*sin (freq*t);

    fillFilt(voltage);
    if(filterReady == 1)
    {
      calcSMA();
      detect(voltage);
      updateRR();
    }
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
