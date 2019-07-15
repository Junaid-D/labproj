
// constants won't change. Used here to set a pin number:
const int ledPin =  LED_BUILTIN;// the number of the LED pin

// Variables will change:
int ledState = LOW;             // ledState used to set the LED

// Generally, you should use "unsigned long" for variables that hold time
// The value will quickly become too large for an int to store
unsigned long previousMillis = 0;        // will store last time LED was updated

// constants won't change:
#define sampleRate 120;
const long interval = 1/sampleRate;           // interval at which to blink (milliseconds)
byte b=0;
void setup() {
  Serial.begin(9600);
}

void loop() {
  
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    Serial.println(b++);
  }
}
