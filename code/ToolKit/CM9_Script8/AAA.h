#ifndef AAA_H
#define AAA_H

#include "Dynamixel.h"
extern Dynamixel Dxl;

#include "HardwareSerial.h"

//!!! SerialUSB n'a pas de param Baudrate
#define SERIAL SerialUSB
#define BAUDS

//Xbee communication
//#define SERIAL Serial2
//#define BAUDS 57600

#define DBG SERIAL.print
#define DBGln SERIAL.println
#define DBGLN SERIAL.println

#endif

