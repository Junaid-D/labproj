#include <QuickSortLib.h>
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

const byte sendCount = 30;
byte sendCtr = 0;


const float thresholdGrad = 0.2;


const int windowSize = (sampleRate / slowRate) / 32;

const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;


float sampleWindow[windowSize] = {0};
float RR = 0;
float Grad = 0;
unsigned long stamps[numStamps];
float grads[windowSize-1] = {0};


const byte numTaps = 31;
//matlab fir1
float filterCoeffs[numTaps] = {0.00490978693901733, 0.00552744069659965, 0.00735239064715894, 0.0103052953470635, 0.0142574274541768, 0.0190362972401042, 0.0244331937254776, 0.0302123134725768, 0.0361210774221532, 0.0419011840213643, 0.0472999145473743, 0.0520811954082435, 0.0560359327901525, 0.0589911668561715, 0.0608176443926426, 0.0614354780794468, 0.0608176443926426, 0.0589911668561715, 0.0560359327901525, 0.0520811954082435, 0.0472999145473743, 0.0419011840213643, 0.0361210774221532, 0.0302123134725768, 0.0244331937254776, 0.0190362972401042, 0.0142574274541768, 0.0103052953470635, 0.00735239064715894, 0.00552744069659965, 0.00490978693901733};
byte filterReady = 0;
float filterWindow [numTaps] = {0};

const int gradScaleFac = 1000;

  const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
  LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  lcd.begin(16, 2);
}

void fillFilt(float val)
{
  if (filterReady == 0 && filterWindow[0] > 0)
    filterReady = 1;

  for (int i = 0; i < numTaps - 1; i++)
  {
    filterWindow[i] = filterWindow[i + 1];
  }
  filterWindow[numTaps - 1] = val;

}

float getFiltOut()
{
  float temp = 0;
  for (int i = 0; i < numTaps; i++)
  {
    temp += filterWindow[i] * filterCoeffs[i];
  }
  return temp;
}


float appendWindow(float val)
{
  for (int i = 0; i < windowSize - 1; i++)
  {
    sampleWindow[i] = sampleWindow[i + 1];
  }
  sampleWindow[windowSize - 1] = val;

}

void bSort(float* arr,int size)
{
  for(int i=0; i <size-1; i++)
  {
    for(int j  = 0; j<(size-i-1); j++)
    {
      if(arr[j] > arr[j+1])
      {
        float temp = arr[j];
        arr[j] = arr[j+1];
        arr[j+1] = temp;
      }
      
    } 
  }
  
}

void calcGrad()
{
  for (int i = 0; i < windowSize-1; i++)
  {
    grads[i] = sampleWindow[i+1]-sampleWindow[i];
  //  Serial.println(grads[i]);
  }
  bSort(grads,windowSize-1);

  Grad = grads[(windowSize-1)/2];
  //Serial.println(Grad,5);

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
    //Serial.print(stamps[i]);
    //Serial.print(" ");
    //Serial.println(cur);

    if (stamps[i] > 0 )//&& (cur-stamps[i])<averagePeriod*1000 )
    {
      avg += stamps[i + 1] - stamps[i];
      count++;
    }
  }
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

    float freq = 2*M_PI*0.15;
    float sinPart = .1*sin (freq*t);
    //float voltage = 3.2 +  max(sinPart,0);// comment for not using adc

    int sensorValue = analogRead(A0);
    float voltage = sensorValue * (5.0 / 1023.0);

    fillFilt(voltage*gradScaleFac);
    if (filterReady == 1)
    {
      float x = getFiltOut();
      //Serial.println(Grad);

      appendWindow(x);
      calcGrad();
      detect();
      updateRR();
    
      sendCtr++;
    if(sendCtr==sendCount)
    {
       Serial.print(voltage,5);
       Serial.print(" ");     
       Serial.print(x/gradScaleFac,5);
       Serial.print(" ");     
       Serial.print(stamps[numStamps - 1]);
       Serial.print(" ");
       Serial.print(RR,5);
       Serial.print(" ");
       Serial.println(currentMillis);
       sendCtr = 0;
    }

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
