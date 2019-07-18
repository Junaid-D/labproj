#include <TimeLib.h>
#include <LiquidCrystal.h>
unsigned long previousMillis = 0;        // will store last time ADC queried
int ADCpin = A0;
byte flag = 0;

const byte numStamps = 5; //n
const byte averagePeriod = 10; //t

// constants won't change:
const int sampleRate = 120;
const float slowRate = 0.1;
const long interval = (1 / (float)sampleRate) * 1000;        // interval at which to blink (milliseconds)

byte b=0;
const float thresholdGrad = 0.1;
const float convVal = 5.0/1023.0;

const int windowSize = (sampleRate / slowRate) / 32;

const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;


int sampleWindow[windowSize] = {0};
float RR = 0;
float Grad = 0;
unsigned long stamps[numStamps];


const byte numTaps = 31;
//matlab fir1
float filterCoeffs[numTaps] = {0.00490978693901733, 0.00552744069659965, 0.00735239064715894, 0.0103052953470635, 0.0142574274541768, 0.0190362972401042, 0.0244331937254776, 0.0302123134725768, 0.0361210774221532, 0.0419011840213643, 0.0472999145473743, 0.0520811954082435, 0.0560359327901525, 0.0589911668561715, 0.0608176443926426, 0.0614354780794468, 0.0608176443926426, 0.0589911668561715, 0.0560359327901525, 0.0520811954082435, 0.0472999145473743, 0.0419011840213643, 0.0361210774221532, 0.0302123134725768, 0.0244331937254776, 0.0190362972401042, 0.0142574274541768, 0.0103052953470635, 0.00735239064715894, 0.00552744069659965, 0.00490978693901733};
byte filterReady = 0;
int filterWindow [numTaps] = {0};


const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  lcd.begin(16, 2);
}

void fillFilt(int val)
{
  if (filterReady == 0 && filterWindow[0] > 0)
    filterReady = 1;

  for (int i = 0; i < numTaps - 1; i++)
  {
    filterWindow[i] = filterWindow[i + 1];
  }
  filterWindow[numTaps - 1] = val;

}

int getFiltOut()
{
  float temp = 0;
  for (int i = 0; i < numTaps; i++)
  {
    temp += filterWindow[i] * filterCoeffs[i]*convVal;
  }
  //Serial.println(temp/convVal);
  return temp/convVal;

}


void appendWindow(int val)
{
  for (int i = 0; i < windowSize - 1; i++)
  {
    sampleWindow[i] = sampleWindow[i + 1];
  }
  sampleWindow[windowSize - 1] = val;

}


void calcGrad()
{
  float xx = 0;
  float xy = 0;
  float x = 0;
  float y = 0;

  for (int i = 0; i < windowSize; i++)
  {
    x += i;
    y += sampleWindow[i];
    xx += i * i;
    xy += sampleWindow[i] * i;
  }

  Grad = (windowSize * xy - x * y) / (windowSize * xx - x * x);
 // Serial.println(xy,5);

}

void detect()
{
  if (abs(Grad) < thresholdGrad)
  return;


  if (Grad < 0 && flag == 0)
  {
    flag = 1;
    for (int i = 0; i < numStamps - 1; i++)
    {
      stamps[i] = stamps[i + 1];
    }
    stamps[numStamps - 1] = millis();
  }

  if (Grad > 0 && flag == 1)
  {
    flag = 0;
  }

}

//only consider those added in the last t seconds !

void updateRR()
{
  unsigned long cur = millis();
  unsigned long avg = 0;
  unsigned int count = 0;
  for (int i = 0; i < numStamps - 1; i++)
  {
   // Serial.print(stamps[i]);
    //Serial.print(" ");

    if (stamps[i] > 0 )//&& (cur-stamps[i])<averagePeriod*1000 )
    {
      avg += stamps[i + 1] - stamps[i];
      count++;
    }
  }
  //Serial.println(avg);

  if(avg == 0)
  {
     RR = 0;
     return;  
  }
  
  avg /= (count); // in millisec

  float freq = avg / ((float)1000);
  RR = (60) / freq; //convert to BPM

}

void loop() {
  unsigned long currentMillis = millis();
  float t = currentMillis / ((float)1000);
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;



    //int sensorValue = analogRead(A0);

    float freq = 2*M_PI*0.5;
    float voltage = 3.2 +  0.1*sin (freq*t);// comment for not using adc
    int sensorValue = voltage*(1023.0/5);//
    
    //int sensorValue = analogRead(A0);
   // float voltage = sensorValue * convVal;
    //Serial.print(voltage,5);
    Serial.println(b++);
    Serial.println(b/2);

    fillFilt(sensorValue);
    if (filterReady == 1)
    {
      appendWindow(getFiltOut());
      calcGrad();
      detect();
      updateRR();
    }
  }
  if (currentMillis - dispMillis >= dispInterval) {
    dispMillis = currentMillis;
    lcd.setCursor(0, 0);
    lcd.print(F("RR: "));
    lcd.print(RR, 5);

    lcd.setCursor(0, 1);
    lcd.print(F("Grad:"));
    lcd.print(Grad, 3);
    lcd.print(F("S:"));
    lcd.print(interval);

  }
}
