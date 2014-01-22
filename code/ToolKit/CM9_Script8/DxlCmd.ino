byte dxlAdrr[50]=
{
  2,0, //0 R  ModelNumber
  1,  //2 R  FirmWare
  1,  //3 RW ID
  1,  //4 RW Baudrate
  1,  //5 RW Return delay time
  2,0, //6 RW CW  angle limit
  2,0, //8 RW CCW
  0,   //10 ?
  1,   //11 RW temp
  1,   //12
  1,   //13
  2,0, //14 Max Torque
  1,   //16
  1,   //17
  1,   //18
  0,0,0,0,0,   //19,20,21,22,23 ?
  1,   //24
  1,   //25
  1,   //26
  1,   //27
  1,   //28
  1,   //29
  2,0, //30 Goal Position
  2,0, //32 Moving Speed
  2,0, //34 Torque Limit
  2,0, //36 Present Position
  2,0, //38 Present Speed
  2,0, //40 Present Load
  1,   //42 Present Voltage
  1,   //43 Present temp
  1,   //44 Registered
  0,   //45 ??
  1,   //46 Moving
  1,   //47 Lock EEPROM
  2,0  //48 Punch 
};



void dxlWrite(int imot,int ireg,int value)
{
  if(ireg<=4)
    return;
  if( dxlAdrr[ireg]==1 )
    Dxl.writeByte(imot,ireg,value);
  else if(dxlAdrr[ireg]==2)
    Dxl.writeWord(imot,ireg,value);
}

int dxlRead(int imot,int ireg)
{
  int r=-1;
  if( dxlAdrr[ireg]==1 )
  {
    r= Dxl.readByte(imot,ireg);
    if(r==255)
      r = -1;
  } 
  else if(dxlAdrr[ireg]==2)
  {
    r= Dxl.readWord(imot,ireg);
    if(r==0xFFFF)
      r=-1;
  }
  return r;
}

int dxlFindEngine(int from)
{
  for(int i=from;i<254;i++)
  {
    int id=Dxl.readByte(i,P_ID);
    if( id==i)
      return i;
    delay(20);
  }
  return -1;
}

void dxlSetGoal(int imot,int goal)
{
    Dxl.writeWord(imot,30,goal);
}
void dxlSetSpeed(int imot,int speed)
{
    if(speed<0)
      Dxl.writeWord(imot,32,1024-speed);
    else
      Dxl.writeWord(imot,32,speed);      
}

int dxlGetDeltaGoal(int imot)
{
  return Dxl.readWord(imot,30)- Dxl.readWord(imot,36);
}

