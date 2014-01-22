#include "AAA.h" //GLOBAL definitions ... !!!SerialUSB/XBEE!!!
#include "libpandora_types.h"
#include "Dynamixel.h"

#define BUTTON_PIN 25 //NOT 23 !!! !!!

//--------------------------------
#include "DxlEngine.h"
Dynamixel Dxl(1); //Dynamixel on Serial1(USART1)
const int nbEngines = 4;
DxlEngine engines[nbEngines];
//--------------------------------

//--------------------------------
//PING : PARALLAX utrasound distance sensor
byte pingPin = -1;  //17; //TODO more than one ... attach interrupts
unsigned long pingEchoTime  = 0;
unsigned long pingStartTime = 0;
byte          pingDistance  = 0;
//CF  void triggerPingDistance(int pin)
// && pingInterrupt()
//--------------------------------

//--------------------------------
//IR : Sharp GP2Y0A21YK0F
byte sharpIRPin = -1; //TODO more than one ... attach interrupts
//CF float getSharpDistance(byte pin)
//--------------------------------


unsigned long loopTime = 0;
unsigned long titime = 0;
HardwareTimer timer(1);
#define TIMER_RATE 40000 //1s 1000 000
//#define TIMER_RATE 50000 //1s 1000 000

//
void setup()
{
  pinMode(BOARD_LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLDOWN);

  for(int i=0;i<3;i++) //Sigggnal
  {
    toggleLED();
    delay(500);
  }

  //init ping sensor
  if(pingPin > 0)
    attachInterrupt(pingPin,pingInterrupt,CHANGE);

  //init sharp sensor
  if( sharpIRPin > 0 )
    pinMode(sharpIRPin, INPUT_ANALOG);
  

  //Dxl Engines    
  clearWatches();  
  Dxl.begin(1);
  engines[0].setId(1);
  engines[1].setId(2);
  engines[2].setId(3);
  engines[3].setId(4);

  delay(500);
  SERIAL.begin(BAUDS);
  delay(500);
  //Serial2.begin(57600);

  for(int i=0;i<7;i++) //Siggggnal
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
  //if( (t-titime)>5000 ){titime = t;SERIAL.print(";t\n");}
  //else
  {
    for(int i=0;i<nbEngines;i++)
      engines[i].update(t);
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
  
void triggerPingDistance(int pin){
  pinMode(pin, OUTPUT);
  digitalWrite(pin, LOW);  
  delayMicroseconds(5); 
  digitalWrite(pin, HIGH);
  delayMicroseconds(5);
  pinMode(pin, INPUT);
}
void pingInterrupt()
{
  pingEchoTime  = micros()-pingStartTime;
  pingStartTime = micros();
  pingDistance  = pingEchoTime/57;
}

float getSharpDistance(byte pin)
{
  float analogValue = analogRead(pin);
  float distance = pow((analogValue/4096)*3.3,-1.15)*27.86;
  return distance;
}

 
