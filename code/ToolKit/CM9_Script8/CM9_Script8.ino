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
//TODO test attach/detach interrupts
int  pingSensorId = 0;
int  pingIndex    = 0;
byte pingPins[]   = {-1,-1,-1}; //{ 17,18,19 };
unsigned long pingEchoTimes[3];  //TODO: may share same long ?
unsigned long pingStartTimes[3]; //TODO: may share same long ?
int pingDistances[3];

//--------------------------------
//IR : Sharp GP2Y0A21YK0F
int  analogSensorId = 10;
int  analogIndex    = 0;
byte analogPins[]   = {-1,-1,-1}; //TODO more than one ... attach interrupts
//--------------------------------

unsigned long loopTime = 0;
unsigned long titime = 0;
HardwareTimer timer(1);
#define TIMER_RATE 40000 //1s 1000 000
//#define TIMER_RATE 50000 //1s 1000 000

char sendbuffer[128];
//
void setup()
{
  for(int i=0;i<3;i++) //Sigggnal
  {
    toggleLED();
    delay(500);
  }

  pinMode(BOARD_LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLDOWN);

  //init ping sensors //TODO test one interrupt
  if(pingPins[0] >= 0)attachInterrupt(pingPins[0],pingInterrupt0,CHANGE);
  if(pingPins[1] >= 0)attachInterrupt(pingPins[1],pingInterrupt1,CHANGE);
  if(pingPins[2] >= 0)attachInterrupt(pingPins[2],pingInterrupt2,CHANGE);

  //init sharp ir sensors
  for(int i=0;i<3;i++)
  {
    if( analogPins[i] >= 0 )
      pinMode(analogPins[i], INPUT_ANALOG);
  }

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
  //TODO Sensors here ???
  unsigned long t = millis();
  {
    for(int i=0;i<nbEngines;i++)
      engines[i].update(t);
  }  
}

int dogCount = 0;
int stepCount = 0;
void loop()
{
  unsigned long t = millis();
  unsigned long dt = t-loopTime;
  if(dt>=25)
  {
    loopTime = t;
    if(stepCount & 1)
      sendAnalogDistance();
    else
    {
      triggerPingDistance();
    }
    
    if(--dogCount<=0){dogCount = 25;digitalWrite(BOARD_LED_PIN, HIGH);SERIAL.println("x");}
    else if(dogCount==1)digitalWrite(BOARD_LED_PIN, LOW);
  }
  else
    cmdPoll(t);
 
  if( digitalRead(BUTTON_PIN) )
  {
    SERIAL.println("BUTTON"); //TODO use interrupt?
    for(int i=0;i<nbEngines;i++)
      engines[i].stop();
    delay(500); //
  }  
}

//TODO send value... not distance
void sendAnalogDistance()
{
  int pin = analogPins[ analogIndex ];
  if(pin>=0)
  {
    float value = (float)analogRead(pin);
    float distance = pow((value*3.3)/4096,-1.15)*27.86; //pow! wow! 
    SERIAL.print("P "); // "Pin" // S is for script !!!
    SERIAL.print(pingSensorId+analogIndex);
    SERIAL.print(" ");
    SERIAL.println(distance);
  }   
  if(++analogIndex>=3)
    analogIndex=0;
}

  
void triggerPingDistance()
{
  if( pingPins[pingIndex]>=0 ) //send previous ping
  {
    SERIAL.print("P "); // "=Pin" // S is for script !!!
    SERIAL.print(pingSensorId+pingIndex);
    SERIAL.print(" ");
    SERIAL.println(pingDistances[pingIndex]);
  }  
  if(++pingIndex>=3)
    pingIndex=0;
  byte pin = pingPins[pingIndex];
  if( pin>=0 )
  { 
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);  
    delayMicroseconds(5); 
    digitalWrite(pin, HIGH);
    delayMicroseconds(5);
    pinMode(pin, INPUT);
  }
}

void pingInterrupt0()
{
  pingEchoTimes[0]  = micros()-pingStartTimes[0];
  pingStartTimes[0] = micros();
  pingDistances[0]  = (int)(pingEchoTimes[0]/57);
}
void pingInterrupt1()
{
  pingEchoTimes[1]  = micros()-pingStartTimes[1];
  pingStartTimes[1] = micros();
  pingDistances[1]  = (int)(pingEchoTimes[1]/57);
}
void pingInterrupt2()
{
  pingEchoTimes[2]  = micros()-pingStartTimes[2];
  pingStartTimes[2] = micros();
  pingDistances[2]  = (int)(pingEchoTimes[2]/57);
}



 
