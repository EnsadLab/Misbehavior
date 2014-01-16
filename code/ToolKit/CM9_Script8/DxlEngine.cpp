#include "libpandora_types.h"
#include "Arduino-compatibles.h"
#include "Dynamixel.h"
#include "dxl_constants.h"
#include "DxlEngine.h"
#include "AAA.h"

#define RELAXED 1
#define JOINT_MODE 2




int DxlEngineCount = 0;

DxlEngine::DxlEngine()
{
  index = DxlEngineCount++;
  anim.pEngine = this;
  setId(0);
}

DxlEngine::DxlEngine(int id)
{
  index = DxlEngineCount++;
  anim.pEngine = this;
  setId(id);  
}

void DxlEngine::setId(int id)
{
  dxlId = id;
  status = RELAXED;
  jointMode = true;
  torqueLimit = 1023;
  minPos = 0;
  maxPos = 1023;
  
  fakePos = -1;
  fakeGoal = -1;
  
  anim.iDxl = id;
  anim.pEngine = this;
  if(id>0)
    relax(true);
}

void DxlEngine::stop()
{
  anim.stop();
  relax(true);  
}

// true = finished / false runningTask
bool DxlEngine::update(unsigned int t)
{
  anim.pEngine = this;
  return anim.update(t); 
}

void DxlEngine::setGoalSpeed(int s)
{
  if( (s>=0)&&(s!=lastSpeed) )
  {
    Dxl.writeWord(dxlId,32,s);
    lastSpeed=s;
  }
  SERIAL.print("goalSpeed ");SERIAL.println(s);  
}

void DxlEngine::setWheelSpeed(int s)
{
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
    Dxl.writeWord(dxlId,34,0);
    status |= RELAXED;
  }
  else
  {
    int p = Dxl.readWord(dxlId,36); //currPos
    Dxl.writeWord(dxlId,30,p);      //goal
    
    Dxl.writeWord(dxlId,34,torqueLimit);
    status &= ~RELAXED;
  }
}

void DxlEngine::setTorque(int tl)
{
  if(tl==0)
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
    Dxl.writeWord(dxlId,6,0);
    Dxl.writeWord(dxlId,8,0);
    jointMode = false;  
}
void DxlEngine::setJointMode()
{
    //devrait mettre goal à pos
    //speed ?
    Dxl.writeWord(dxlId,6,minPos);
    Dxl.writeWord(dxlId,8,maxPos);  
    jointMode = true;  
}

void DxlEngine::setCompliance(int cw,int ccw)
{
  if(cw>7)cw=7;
  int cpl = 1<<cw;
  Dxl.writeByte(dxlId,28,cpl); //CW SLOPE
  if(ccw>0)
    cpl = 1<<ccw;
  Dxl.writeByte(dxlId,29,cpl); //CCW SLOPE  
}


