#include <arduinoFFT.h>
#include <LiquidCrystal.h>

unsigned long previousMillis = 0;        // will store last time ADC queried
unsigned long dispMillis = 0;
unsigned long FFTMillis = 1000;           // interval at which to blink (milliseconds)

const byte dispInterval = 1000;           // 
const byte FFTInterval = 1000;           // 1 sec fft update


byte windowFull = 0;


arduinoFFT FFT = arduinoFFT();
const int samples = 128;

// constants won't change:
const int sampleRate = 30;
const long interval = (1 / (float)sampleRate) * 1000;   

double sampleWindow[samples] = {0};
double sampleWindowImag[samples] = {0};


const byte numTaps = 31;
//matlab fir1
float filterCoeffs[numTaps] ={0.00334378511113945,0.00401069657967264,0.00564996062717318,0.00834049265023272,0.0120903584515579,0.0168318540716870,0.0224221117012879,0.0286493552149565,0.0352444859672700,0.0418972540837399,0.0482758975420757,0.0540488419253156,0.0589068723260151,0.0625841313099214,0.0648763688743967,0.0656550671271163,0.0648763688743967,0.0625841313099214,0.0589068723260151,0.0540488419253156,0.0482758975420757,0.0418972540837399,0.0352444859672700,0.0286493552149565,0.0224221117012879,0.0168318540716870,0.0120903584515579,0.00834049265023272,0.00564996062717318,0.00401069657967264,0.00334378511113945};
byte filterReady = 0;
float filterWindow [numTaps] = {0};

const byte resampFactor = 6;
byte ctr = 0;

//LCD
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
 // put your setup code here, to run once:
  Serial.begin(115200);
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


float getFiltOut()
{
  float temp=0;
  for (int i=0;i<numTaps;i++)
  {
    temp+=filterWindow[i]*filterCoeffs[i];
  }
  return temp;
}


void appendWindow(float val)
{
  if (windowFull == 0 && sampleWindow[0] > 0)
    windowFull = 1;
  for (int i = 0; i < samples - 1; i++)
  {
    sampleWindowImag[i] = 0;
    sampleWindow[i] = sampleWindow[i + 1];
  }
  sampleWindow[samples - 1] = val;
  sampleWindowImag[samples - 1] = 0;
}


void loop() {
  // put your main code here, to run repeatedly:
  unsigned long currentMillis = millis();
  float t = currentMillis / ((float)1000);

  if (currentMillis - previousMillis >= interval) {
    ctr++;
    previousMillis = currentMillis;
    

    float freq = 2*M_PI;
    float voltage = 3.2 +  0.2*sin (freq*t);// comment for not using adc

    int sensorValue = analogRead(A0);
    //float voltage = sensorValue * (5.0 / 1023.0);
    fillFilt(voltage);
  }

    if(filterReady == 1 && ctr== resampFactor)
    {
      appendWindow(getFiltOut());
      ctr = 0;
    }


  if (currentMillis - dispMillis >= dispInterval) {
    dispMillis = currentMillis;
  }

  if(windowFull == 1 && (currentMillis - FFTMillis) >= FFTInterval)
  {
     /*FFT*/
      FFT.Windowing(sampleWindow, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);
      FFT.Compute(sampleWindow, sampleWindowImag, samples, FFT_FORWARD);
      FFT.ComplexToMagnitude(sampleWindow, sampleWindowImag, samples);
     // double peak = FFT.MajorPeak(sampleWindow, samples, sampleRate);
   
      /*PRINT RESULTS*/
      //Serial.println(peak);     //Print out what frequency is the most dominant.
   
      for(int i=0; i<(samples/2); i++)
      {
          /*View all these three lines in serial terminal to see which frequencies has which amplitudes*/
           
          Serial.print((i * 1.0 * (sampleRate/resampFactor)) / samples, 1);
          Serial.print(" ");
          Serial.println(sampleWindow[i], 1);    //View only this line in serial plotter to visualize the bins
      }
      while(1){}
      
  }
    

}
