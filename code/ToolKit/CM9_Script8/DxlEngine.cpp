#include "libpandora_types.h"
#include "Arduino-compatibles.h"
#include "Dynamixel.h"
#include "dxl_constants.h"
#include "EEPROM.h"
#include "DxlEngine.h"
#include "AAA.h"

extern EEPROM CM9_EEPROM;

#define RELAXED 1
#define JOINT_MODE 2

int DxlEngineCount = 0;

DxlEngine::DxlEngine()
{
  index = DxlEngineCount++;
  anim.pEngine = this;
  dxlId = -1;
}

void DxlEngine::setId(int id)
{
  dxlId = id;    
  init();
  if(dxlId>0)
    CM9_EEPROM.write(index,(uint16)dxlId);
  
  anim.init(this);
  if(id>0)
    relax(true);
}

int DxlEngine::getIdFromFlash()
{
  return CM9_EEPROM.read(index);// read data from virtual address 0~9  
}

void DxlEngine::init()
{
  status = RELAXED;
  jointMode = true;
  lastSpeed = 0;
  minPos = 0;
  maxPos = 1023;
  torqueLimit = 1023;
  anim.init(this);    
  
  int id = CM9_EEPROM.read(index);
  if( (id>0)&&(id<255) )
    dxlId = id;
  if( dxlId<=0 )
    return;
  
  int rid = Dxl.readByte(dxlId,P_ID);
  if( rid != dxlId ) //rid = FF 
  {
     dxlId = -1;
     return;
  }
  relax(true);
  jointMode = (Dxl.readWord(dxlId,P_CCW_ANGLE_LIMIT_L)>0 );
  anim.init(this);    
}

void DxlEngine::stop()
{
  anim.stop();
  relax(true);  
  //checkMode();
}

void DxlEngine::donothing()
{
}

// true = finished / false runningTask
bool DxlEngine::update(unsigned int t)
{
  if(dxlId <= 0)
    return true; //finished  
  anim.pEngine = this;
  return anim.update(t);
}

void  DxlEngine::onCmd(const char* cmd,int i1,int i2,int i3 )//i1 = engine index
{
  if( cmd[1]=='I')
  {
    setId(i2);
    return;
  }
  
  if(dxlId<=0)
    return;
    
  if( cmd[1]=='W')
  {
    setDxlValue(i2,i3);
    return;
  }    
}

void DxlEngine::setDxlValue(int addr,int val)
{
  if(dxlId<=0)
    return;
  
  switch(addr)
  {
    case P_CW_ANGLE_LIMIT_L:
      if((val>=0)&&(val<1024))
        Dxl.writeWord(dxlId,P_CW_ANGLE_LIMIT_L,val);
      break;

    case P_CCW_ANGLE_LIMIT_L:  
      if(val>1023) val = 1023;
      if(val<=0) setWheelMode();  //!!! assume cw limit == 0 !!!
      else { maxPos=val ; setJointMode(); } 
      break;

    case P_CW_COMPLIANCE_SLOPE:
        Dxl.writeByte(dxlId,P_CW_COMPLIANCE_SLOPE,val);
        break;
    
    case P_CCW_COMPLIANCE_SLOPE:
        Dxl.writeByte(dxlId,P_CCW_COMPLIANCE_SLOPE,val);
        break;

    case P_GOAL_POSITION_L:
        setGoal(val);
        break;

    case P_GOAL_SPEED_L:
        setGoalSpeed(val);  //Wheel ... +-1024 ...
        break;
        
    case P_TORQUE_LIMIT_L :
        setTorque(val);
        break;
  }
}



void DxlEngine::setGoalSpeed(int s)
{
  if( (s>=0)&&(s!=lastSpeed) )
  {
    Dxl.writeWord(dxlId,32,s);
    lastSpeed=s;
  }
}

void DxlEngine::setWheelSpeed(int s)
{
   if(jointMode)
      setWheelMode();
    
  if(lastSpeed!=s)
  {
    lastSpeed =s;
    if(s>=0)
      Dxl.writeWord(dxlId,32,s);
    else
      Dxl.writeWord(dxlId,32,1024-s);
  }
  if( status & RELAXED )
    relax(false);    
}

void DxlEngine::setGoal(int g)
{
    Dxl.writeWord(dxlId,P_GOAL_POSITION_L,g);
}

void DxlEngine::setGoal(int g,int s)
{
    if(!jointMode)
      setJointMode();
  
    Dxl.writeWord(dxlId,P_GOAL_POSITION_L,g);
    if( (s>0)&&(s!=lastSpeed) )
    {
      Dxl.writeWord(dxlId,32,s);
      lastSpeed=s;
    }    
    if( status & RELAXED )
      relax(false);    
}

int DxlEngine::getGoal()
{
  return Dxl.readWord(dxlId,30);
}
int DxlEngine::getPos()
{
  return Dxl.readWord(dxlId,P_PRESENT_POSITION_L);
}
int DxlEngine::getSpeed()
{
  int s = Dxl.readWord(dxlId,32);
  if(s>=1024)
    s= 1024-s;
  return s;
}
int DxlEngine::getCurrSpeed()
{
  int s = Dxl.readWord(dxlId,30);
  if(s>=1024)
    s= 1024-s;
  return s;
}
void DxlEngine::relax(bool dorelax)
{
  if(dorelax)
  {
    Dxl.writeWord(dxlId,P_TORQUE_LIMIT_L,0);
    status |= RELAXED;
  }
  else
  {
    int p = Dxl.readWord(dxlId,P_PRESENT_POSITION_L);  //currPos
    Dxl.writeWord(dxlId,P_GOAL_POSITION_L,p);          //goal = currPos
    Dxl.writeWord(dxlId,P_GOAL_SPEED_L,0);             //speed 0 !!!!!! max ?    
    Dxl.writeWord(dxlId,P_TORQUE_LIMIT_L,torqueLimit);              //
    status &= ~RELAXED;
  }
}

void DxlEngine::setTorque(int tl)
{
  if(tl<=0)
    relax(true);
  else
  {
    torqueLimit = tl;
    relax(false);
  }  
}


void DxlEngine::setWheelMode()
{
    //devrai mettre speed à 0 ... 1 ???
    Dxl.writeWord(dxlId,P_CW_ANGLE_LIMIT_L,0);
    Dxl.writeWord(dxlId,P_CCW_ANGLE_LIMIT_L,0);
    jointMode = false;  
}
void DxlEngine::setJointMode()
{
    int p = Dxl.readWord(dxlId,P_PRESENT_POSITION_L);  //currPos
    Dxl.writeWord(dxlId,P_GOAL_POSITION_L,p);          //goal = currPos
    Dxl.writeWord(dxlId,P_GOAL_SPEED_L,0);             //speed 0 !!!!!! max ?    
    
    Dxl.writeWord(dxlId,P_CW_ANGLE_LIMIT_L ,minPos);
    Dxl.writeWord(dxlId,P_CCW_ANGLE_LIMIT_L,maxPos);  
    jointMode = true;  
}

void DxlEngine::setCompliance(int cw,int ccw)
{
  if(cw>7)cw=7;
  int cpl = 1<<cw;
  Dxl.writeByte(dxlId,P_CW_COMPLIANCE_SLOPE,cpl); //CW SLOPE
  if(ccw>0)
    cpl = 1<<ccw;
  Dxl.writeByte(dxlId,P_CCW_COMPLIANCE_SLOPE,cpl); //CCW SLOPE  
}



