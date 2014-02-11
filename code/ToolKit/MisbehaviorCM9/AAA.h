#ifndef AAA_H
#define AAA_H

#include "Dynamixel.h"
extern Dynamixel Dxl;

#include "HardwareSerial.h"

//#define USE_SERIALUSB


#ifdef USE_SERIALUSB
  //!!! SerialUSB n'a pas de param Baudrate (57200)
  #define SERIAL SerialUSB
  #define BAUDS
#else
  //Xbee communication
  #define SERIAL Serial2
  #define BAUDS 115200
#endif

#define DBG SERIAL.print
#define DBGln SERIAL.println
#define DBGLN SERIAL.println

#endif

