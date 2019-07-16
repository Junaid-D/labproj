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
const int sampleRate = 120;
const long interval = (1 / (float)sampleRate) * 1000;   

double sampleWindow[samples] = {0};
double sampleWindowImag[samples] = {0};


//LCD
const int rs = 12, en = 11, d4 = 5, d5 = 4, d6 = 3, d7 = 2;
LiquidCrystal lcd(rs, en, d4, d5, d6, d7);

void setup() {
 // put your setup code here, to run once:
  Serial.begin(115200);
  lcd.begin(16, 2);
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
    previousMillis = currentMillis;
    

    float freq = 2*M_PI*0.2;
    float voltage = 3.2 +  0.2*sin (freq*t);// comment for not using adc

    int sensorValue = analogRead(A0);
    //float voltage = sensorValue * (5.0 / 1023.0);
    appendWindow(voltage);

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
           
          //Serial.print((i * 1.0 * sampleRate) / samples, 1);
          //Serial.print(" ");
          Serial.println(sampleWindow[i], 1);    //View only this line in serial plotter to visualize the bins
      }
      while(1){}
      
  }
    

}
