#include "AAA.h"
#include "libpandora_types.h"
#include "DxlEngine.h"

#include "Dynamixel.h"
Dynamixel Dxl(1); //Dynamixel on Serial1(USART1)

const int nbEngines = 4;
DxlEngine engines[nbEngines];

#define BUTTON_PIN 25 //NOT 23 !!! !!!

//const char* PROGMEM test = "Globally declared in Flash mem";
//#define PGMSTR(x) (__FlashStringHelper*)(x)
//const char HEADER[] PROGMEM  = { "-- -- ---- -- -- -- ---------  ------  ------"};

int sensorPin   = 0;
int sensorValue = 0; // Variable to store the value coming from the sensor

//int ledCount = 5;
unsigned long loopTime = 0;
//unsigned long blinkTime = 0;
unsigned long titime = 0;
HardwareTimer timer(1);
#define TIMER_RATE 40000 //1s 1000 000
//#define TIMER_RATE 50000 //1s 1000 000

void setup() {
//SERIAL.println(F("Inline Flash mem"));
  pinMode(BOARD_LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLDOWN);
//  pinMode(sensorPin, INPUT_ANALOG);
    
//  clearWatches();

  for(int i=0;i<3;i++)
  {
    toggleLED();
    delay(1000);
  }
  
  Dxl.begin(1);

  engines[0].setId(1);
  engines[1].setId(2);
  engines[2].setId(3);
  engines[3].setId(4);

  delay(500);
  SERIAL.begin(BAUDS);
  delay(500);
  //Serial2.begin(57600);

  for(int i=0;i<7;i++)
  {
    toggleLED();
    delay(100);
  }
  SERIAL.println("Start");
  
  
  timer.pause(); // Pause the timer while configuration
  timer.setPeriod(TIMER_RATE); // in microseconds
  timer.setMode(TIMER_CH1, TIMER_OUTPUT_COMPARE); // Set up an interrupt on channel 1
  timer.setCompare(TIMER_CH1, 1);  // Interrupt 1 count after each update
  timer.attachInterrupt(TIMER_CH1, timerHandler); 
  timer.refresh();   // Refresh the timer's count  , prescale, and overflow
  titime = millis();
  timer.resume(); // Start the timer counting
    
  loopTime = millis();
}


void timerHandler(void)
{
  unsigned long t = millis();
  if( (t-titime)>5000 )
  {
    titime = t;
    SERIAL.print(";t\n");
  }
  else
  {
    //for(int i=0;i<nbEngines;i++)
      engines[0].update(t);
  } 
}


int dogCount = 0;
void loop()
{
  unsigned long t = millis();
  unsigned long dt = t-loopTime;
  if(dt>=25)
  {
    loopTime = t;
    if(--dogCount<=0){dogCount = 25;digitalWrite(BOARD_LED_PIN, HIGH);SERIAL.println("x");}
    else if(dogCount==1)digitalWrite(BOARD_LED_PIN, LOW);
    //else if(dogCount==10)Serial2.println("bee");
//    cmdPoll(t);
  
    //for(int i=0;i<nbEngines;i++)
    //  engines[i].update(t);
  
  }
  else
    cmdPoll(t);
 
  if( digitalRead(BUTTON_PIN) )
  {
    SERIAL.println("BUTTON");
    for(int i=0;i<nbEngines;i++)
      engines[i].stop();
    delay(500);
  }
  
}
  
 
