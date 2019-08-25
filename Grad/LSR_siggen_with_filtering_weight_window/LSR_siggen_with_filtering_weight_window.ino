#include <TimeLib.h>
#include <LiquidCrystal.h>
unsigned long previousMillis = 0;        // will store last time ADC queried
int ADCpin = A0;
byte flag = 0;

const byte numStamps = 5; //n

float windowWeights[numStamps-1] = {0.05,0.1,0.4,0.45};
const byte averagePeriod = 10; //t
const byte windowRRInterval = 15; //t


// constants won't change:
const int sampleRate = 120;
const float slowRate = 0.1;
const long interval = (1 / (float)sampleRate) * 1000;        // interval at which to blink (milliseconds)

const byte sendCount = 10;
byte sendCtr = 0;

char detChar = '*';
unsigned long lastStamp = 0;

const float thresholdGrad = 2.0;

const int windowSize = (sampleRate / slowRate) / 32;

const byte dispInterval = 1000;           // interval at which to blink (milliseconds)
unsigned long dispMillis = 0;
char gradBuf[12];


float sampleWindow[windowSize] = {0};
float RR = 0;
float Grad = 0;
unsigned long stamps[numStamps];


const byte numTaps = 31;
//matlab fir1
float filterCoeffs[numTaps] = {0.00490978693901733, 0.00552744069659965, 0.00735239064715894, 0.0103052953470635, 0.0142574274541768, 0.0190362972401042, 0.0244331937254776, 0.0302123134725768, 0.0361210774221532, 0.0419011840213643, 0.0472999145473743, 0.0520811954082435, 0.0560359327901525, 0.0589911668561715, 0.0608176443926426, 0.0614354780794468, 0.0608176443926426, 0.0589911668561715, 0.0560359327901525, 0.0520811954082435, 0.0472999145473743, 0.0419011840213643, 0.0361210774221532, 0.0302123134725768, 0.0244331937254776, 0.0190362972401042, 0.0142574274541768, 0.0103052953470635, 0.00735239064715894, 0.00552744069659965, 0.00490978693901733};
byte filterReady = 0;
float filterWindow [numTaps] = {0};

const int gradScaleFac = 10000;

  const int rs = 10, en = 9, d4 = 5, d5 = 6, d6 = 7, d7 = 8;
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
  float sum = 0;
  for (int i = 0; i < numStamps - 1; i++)
  {
    
    if (stamps[i] > 0 && (cur-stamps[i])<windowRRInterval*1000 )
    {
      sum += windowWeights[i];
      avg += (stamps[i + 1] - stamps[i])*windowWeights[i];
    }
  }
  if(avg == 0)
  {
     RR = 0;
     return;  
  }
  

  float freq = avg / (((float)1000) * sum );
  RR = (60) / freq; //convert to BPM

}

void loop() {
  unsigned long currentMillis = millis();
  float t = currentMillis / ((float)1000);
  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;



    //int sensorValue = analogRead(A0);

    float freq = 2*M_PI*0.25;

    
    
    float sinPart = .2*sin (freq*t);
    float voltage = 3.2 +  max(sinPart,0);// comment for not using adc

    //int sensorValue = analogRead(A0);
    //float voltage = sensorValue * (5.0 / 1023.0);

    fillFilt(voltage*gradScaleFac);
    if (filterReady == 1)
    {
      float x = getFiltOut();
      appendWindow(x);
      calcGrad();
      detect();
      if(stamps[numStamps - 1]!=lastStamp)
      {
        lastStamp = stamps[numStamps - 1];
        if(detChar == '*')
          detChar = '.';
        else
          detChar = '*';
      }
      updateRR();
    
      sendCtr++;
  if(sendCtr==sendCount)
  {
     Serial.print(voltage);
     Serial.print(" ");     
     Serial.print(x/gradScaleFac);
     Serial.print(" ");     
     Serial.print(stamps[numStamps - 1]);
     Serial.print(" ");
     Serial.print(RR);
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
    if( (currentMillis - stamps[numStamps-1]) < averagePeriod*1000)
    {
      lcd.print(F("G:"));
      char* gradStr = dtostrf(Grad,4,4,gradBuf);
      lcd.print(gradStr);
    }
    else
    {
      lcd.print(F("                "));
      lcd.setCursor(0, 1);
      lcd.print(F("No Breath"));
    }
    lcd.setCursor(12, 1);
    lcd.print(detChar);

  }
}
