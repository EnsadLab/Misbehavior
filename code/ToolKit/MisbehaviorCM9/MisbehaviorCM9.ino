#include "AAA.h" //GLOBAL definitions ... !!!SerialUSB/XBEE!!!
#include "libpandora_types.h"
#include "Dynamixel.h"
#include "EEPROM.h"

const int NB_ENGINES = 6; // global scope !

#define BUTTON_PIN 25 //NOT 23 !!! !!!

//--------------------------------
EEPROM CM9_EEPROM;
//--------------------------------
#include "DxlEngine.h"
Dynamixel Dxl(1); //Dynamixel on Serial1(USART1)
DxlEngine engines[NB_ENGINES];
//--------------------------------

//--------------------------------
//PING : PARALLAX utrasound distance sensor
//TODO test attach/detach interrupts
int  pingSensorId = 0;
int  pingIndex    = 0;
int  pingPins[]   = {13,15}; //{22,23)
unsigned long pingEchoTimes[2];  //TODO: may share same long ?
unsigned long pingStartTimes[2]; //TODO: may share same long ?
int pingDistances[2];

//--------------------------------
//IR : Sharp GP2Y0A21YK0F
int  analogSensorId = 0; //!!!!!!!!
int  analogIndex    = 2; // !!! nb pings = 2 !!!
int  analogPins[]   = {7,8,9}; //{7,8,9}; //
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
  CM9_EEPROM.begin();
  //SERIAL.end();
  SERIAL.begin(BAUDS);
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
//  if(pingPins[2] >= 0)attachInterrupt(pingPins[2],pingInterrupt2,CHANGE);

  //init sharp ir sensors
  for(int i=0;i<3;i++)
  {
    if( analogPins[i] >= 0 )
      pinMode(analogPins[i], INPUT_ANALOG);
  }

  //Dxl Engines    
  Dxl.begin(1);
  delay(1000);
  for(int i=0;i<NB_ENGINES;i++)
  {
    engines[i].init();
    delay(50);
  }
  
  delay(500);
  //wait wait wait wait, please
  for(int i=0;i<100;i++) //Siggggnal
  {
    toggleLED();
    delay(50);
  }
  
  #ifdef USE_SERIALUSB
    SERIAL.attachInterrupt(serialInterruptUSB);  
  #else
    SERIAL.flush();
    SERIAL.attachInterrupt(serialInterrupt1);
  #endif

  SERIAL.println("Start");
/*  
  timer.pause(); // Pause the timer while configuration
  timer.setPeriod(TIMER_RATE); // in microseconds
  timer.setMode(TIMER_CH1, TIMER_OUTPUT_COMPARE); // Set up an interrupt on channel 1
  timer.setCompare(TIMER_CH1, 1);  // Interrupt 1 count after each update
  timer.attachInterrupt(TIMER_CH1, timerHandler); 
  timer.refresh();   // Refresh the timer's count  , prescale, and overflow
  titime = millis();
  timer.resume(); // Start the timer counting 
*/  
  loopTime = millis();
}

int stepCount = 0;
int dogCount  = 0;
void timerHandler(void)
{
  /*
  unsigned long t = millis();
  {
    for(int i=0;i<NB_ENGINES;i++)
      engines[i].update(t);
  }
  */
  //if(--dogCount<=0){dogCount = 25;digitalWrite(BOARD_LED_PIN, HIGH);serialSend("x\n");}
  //else if(dogCount==1)digitalWrite(BOARD_LED_PIN, LOW);
}

void loop()
{
  unsigned long t = millis();
  unsigned long dt = t-loopTime;
  if(dt>=25)
  {    
    loopTime = t;
    for(int i=0;i<NB_ENGINES;i++)
      engines[i].update(t);
    
    stepCount = (++stepCount)&7;
    if( stepCount==0 )
        sendAnalogDistance();
    else if( stepCount==1 )
       triggerPingDistance();

    if(--dogCount<=0){dogCount = 25;digitalWrite(BOARD_LED_PIN, HIGH);SERIAL.println("x");}
    else if(dogCount==1)digitalWrite(BOARD_LED_PIN, LOW);
  }
  delay(1);
  serialParse();
  
  if( digitalRead(BUTTON_PIN) )
  {
    //SERIAL.println("BUTTON"); //TODO use interrupt?
    serialSend("BUTTON");
    for(int i=0;i<NB_ENGINES;i++)
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
    int value = analogRead(pin);
    if(value<=350)
    //float distance = pow((value*3.3)/4096,-1.15)*27.86; //pow! wow!
      serialSend("P",analogSensorId+analogIndex,value,sendbuffer);
  }   
  if(++analogIndex>=3)
    analogIndex=0;
}

  
void triggerPingDistance()
{
  if( pingPins[pingIndex]>=0 ) //send previous ping
    serialSend("P",pingSensorId+pingIndex,pingDistances[pingIndex],sendbuffer);
    
  if(++pingIndex>=2)
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



 
