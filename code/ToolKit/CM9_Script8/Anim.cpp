#include "AAA.h"

#include "libpandora_types.h"
#include "Arduino-compatibles.h"
#include "Dynamixel.h"
#include "usb_serial.h"
#include "Anim.h"
#include "DxlEngine.h"

#define TASK_JOINT 1
#define TASK_WHEEL 2
#define TASK_PAUSE 3

Anim::Anim()
{
  pEngine = NULL;
  setDxlId(0);
}

Anim::Anim(int id)
{
  pEngine = NULL;
  setDxlId(id);
}

void Anim::setDxlId(int id)
{
  iDxl = 0;
  frameTime = 0;
  pauseTime = 0;
  currentTask = 0;
  localTime  = 0;
  timeCoef   = 1.0f;  
  duration   = 0;
  speedValue = 0;
  startValue = 0;
  destValue  = 0;
  bezierIn   = 0.333;
  bezierOut  = 0.666;
  wantedGoal  = 0;
  goalMargin  = 4;
}

void Anim::stop()
{
  currentTask = 0; 
  frameTime = 0;
  pauseTime = 0;
}

// true = finished / false runningTask
bool Anim::update(unsigned long t)
{ 
  unsigned int dt= t-frameTime;  
  frameTime = t;

  if( (currentTask<=0)||(pEngine==NULL)  )
   return false; //stopped
 
  switch( currentTask )
  {
    case TASK_JOINT:
      //SERIAL.println("TASK_JOINT");currentTask=0;
      //SERIAL.print("D ");SERIAL.println(duration);
      //SERIAL.print("start ");SERIAL.println(startValue);
      //SERIAL.print("dest ");SERIAL.println(destValue);
      taskJoint(dt);
      //SERIAL.print("pos ");SERIAL.println(pEngine->fakePos);
      break;
    case TASK_WHEEL:SERIAL.println("TASK_WHEEL");currentTask=0;break;
    case TASK_PAUSE:taskPause(dt); break;
    default:
      currentTask=0;

    //case TASK_JOINT:taskJoint(dt);break;
    //case TASK_WHEEL:taskWheel(dt);break;    
  }
  return (currentTask<=0);
}

void Anim::sendReady()
{
  currentTask=0;
  duration  = 0;
  localTime = 0;
  SERIAL.print("ok ");SERIAL.print(pEngine->index);SERIAL.println(" 0"); //READY 
}

void Anim::execCmd(const char* strcmd,int value)
{
  int  cmd = 0;
  int  c = (int)strcmd[1];
  switch(c)
  {
    case 'g':cmd= TOKEN_JOINT; break;
    case 'j':cmd= TOKEN_JOINT_D; break;
    case 'w':cmd= TOKEN_WHEEL; break;
    case 'W':cmd= TOKEN_WHEEL_D; break;
    case 's':cmd= TOKEN_SPEED; break;
    case 'i':cmd= TOKEN_TGIN; break;
    case 'o':cmd= TOKEN_TGOUT; break;
    case 'm':cmd= TOKEN_MARGIN;break;
    case 'c':cmd= TOKEN_COMPLIANCE;break;
    case 't':cmd= TOKEN_TORQUE;break;
    case 'd':cmd= TOKEN_DURATION; break;
    case 'p':cmd= TOKEN_PAUSE; break;
  }
  if(cmd>0)
    execTokenDbg(cmd,value);
}

void Anim::execTokenDbg(int tok,int value)
{
  //SERIAL.print("DBG[");SERIAL.print(pEngine->dxlId);SERIAL.print("]");SERIAL.print(tok);SERIAL.print(" ");SERIAL.println(value); //READY  
  int cmd = tok & 0x3F; //0x80=EOL 0x40=RND
  switch(cmd)
  {
    case TOKEN_JOINT:
      pEngine->relax(false);
      wantedGoal=value;duration=0;
      pEngine->setGoal(value);
      //Dxl.writeWord(1,P_GOAL_POSITION_L,value);
      currentTask=TASK_JOINT;
      break;
    case TOKEN_JOINT_D:
      currentTask = 0;
      startValue=(float)pEngine->getPos();
      destValue =(float)value;
      wantedGoal = value;
      wantedTask=TASK_JOINT;
      break;
    case TOKEN_WHEEL:   pEngine->setWheelSpeed(value);break;
    case TOKEN_WHEEL_D:
      currentTask = 0;
      startValue = speedValue;
      destValue  =(float)value;
      wantedTask=TASK_JOINT;
      break;
    case TOKEN_SPEED:   pEngine->setGoalSpeed(value);break;
    case TOKEN_DURATION: //INTERPOLATION BEGINS
    {
       localTime = 0;
       duration  = (float)value; 
       currentTask = wantedTask;
       wantedTask  = 0;
    }
    break;
    case TOKEN_TGIN:
      bezierIn  = 0.01f*(float)value;
      SERIAL.print("bIn ");SERIAL.println(bezierIn);
      break;
    case TOKEN_TGOUT:
      bezierOut = 0.01f*(float)(100-value);
      SERIAL.print("bOut ");SERIAL.println(bezierOut);
      break;
    case TOKEN_MARGIN:
      goalMargin = value;
      break;
    case TOKEN_COMPLIANCE:
      pEngine->setCompliance(value,value);
      break;
    case TOKEN_TORQUE:
      pEngine->setTorque(value);
      SERIAL.print("torque ");SERIAL.println(value);
      break;      
    case TOKEN_PAUSE:
       localTime = 0; duration = (float)value;
       currentTask=TASK_PAUSE;
       break;
    default:
      SERIAL.print("...UNKNOWN");SERIAL.println(cmd);
  }
}

/*
void DxlEngine::execToken(int tok,int value)
{
  int cmd = tok & 0x3F; //0x80=EOL 0x40=RND
  switch(cmd)
  {
    case TOKEN_JOINT:   duration=0;setGoal(value,-1);currentTask=TASK_JOINT;break;
    case TOKEN_JOINT_D:
      startValue=(float)Dxl.readWord(dxlId,P_PRESENT_POSITION_L);
      destValue =(float)value;
      wantedTask=TASK_JOINT;
      break;
    case TOKEN_WHEEL:   setWheelSpeed(value);break;
    case TOKEN_WHEEL_D:
      currentTask = 0;
      startValue=(float)Dxl.readWord(dxlId,P_PRESENT_POSITION_L);
      destValue =(float)value;
      wantedTask=TASK_JOINT;
      break;
    case TOKEN_SPEED:   setGoalSpeed(value);break;
    case TOKEN_DURATION: //INTERPOLATION BEGINS
    {
       localTime = 0;
       duration  = (float)value; 
       currentTask = wantedTask;
       wantedTask  = 0;
    }
    break;
  }
}
*/

//true finished // false pausing
bool Anim::taskPause(unsigned long dt)
{
  float dlt = timeCoef*(float)dt;
  float t0  = localTime;
  localTime += dlt;
  if( localTime<duration )
    return false;
  
  SERIAL.print("localTime ");SERIAL.println(localTime);
  sendReady();
  return true;
}


//true if wait , false if done
bool Anim::taskJoint(unsigned int dt)
{
  if(duration<1)
  {
    //A VOIR: MOVING ???
    int pos = pEngine->getPos();
    //SERIAL.print("mv ");SERIAL.print(pEngine->dxlId);SERIAL.print(" ");
    //SERIAL.print(P_PRESENT_POSITION_L);SERIAL.print(" ");SERIAL.println(pos);
    //SERIAL.print("goal ");SERIAL.print(wantedGoal);SERIAL.print(" ");SERIAL.println(pEngine->getGoal());
    int dg  = wantedGoal-pos;
    if( (dg>goalMargin)||(dg<-goalMargin) )
      return false;
      
    sendReady();  
    return true;
  }
  // BEZIER
  //if(dt>100)
  //  dt=101;
  
  float dlt = timeCoef*(float)dt;
  float t0  = localTime;
  localTime += dlt;
  if( localTime>=duration )
  {
    pEngine->setGoal( wantedGoal,-1 );
    sendReady();  
    return false;
  }
  float bt = localTime/duration;
  float ot = 1.0f-bt;
  float fg = bt*( (bt*bt)+ (ot*bezierIn + bt*bezierOut)*ot*3 );
  int ig   = (int)( startValue + fg*(destValue-startValue) );
  pEngine->setGoal( ig );
  //SERIAL.print("dt ");SERIAL.println(dt);
  //SERIAL.print("MV ");SERIAL.print(pEngine->dxlId);SERIAL.print(" ");
  //SERIAL.print(P_GOAL_POSITION_L);SERIAL.print(" ");SERIAL.println( ig );
  return false; 
}

//true if interpoling , false if done
bool Anim::taskWheel(unsigned int dt)
{
  float dlt = timeCoef*(float)dt;
  float t0  = localTime;
  localTime += dlt;
  if( localTime>=duration )
  {
    speedValue = destValue;
    pEngine->setWheelSpeed( (int)destValue );
    sendReady();  
    return false;
  }
  float t1 = duration - t0;
  float kt = dlt/t0;
  speedValue+= (destValue - speedValue)*dlt/t0;
  pEngine->setWheelSpeed( (int)speedValue );
  return true;
}



/*
//false = finished / true = wating // TODO check speed? check Torque ?
bool Anim::waitGoal()
{
  int dg = wantedJoint-pEngine->getPos();
  if(dg>goalMargin)  return true;
  if(dg<-goalMargin) return true;
  currentTask = 0;
  return false;
}

void Anim::startWheelInterpole()
{
   localTime = 0;
   //TODO speedValue ????
}

//false = finished / true = running
bool Anim::interpoleWheel(unsigned long dt)
{
  float dlt = speedCoef*(float)dt;
  float t0  = localTime;
  localTime += dlt;
  if( localTime>=duration )
  {
    speedValue = (float)wantedWheel;
    pEngine->setWheelSpeed( wantedWheel );
    currentTask = 0;
    return false;
  }
  float t1 = duration - t0;
  float kt = dlt/t1;
  speedValue+= ((float)wantedWheel - speedValue)*kt;
  pEngine->setWheelSpeed( (int)speedValue );
  return true;
}

//void Anim::startBezier(float d,float g,float b0,float b1)
void Anim::startBezier()
{
  localTime = 0;
  startPos  = (float)pEngine->getGoal();
  //SERIAL.print("bez started ");
  //SERIAL.print( bezierA );
  //SERIAL.print(" ");
  //SERIAL.println(bezierB);
}

bool Anim::bezierGoal(unsigned long dt)
{
  float dlt = speedCoef*(float)dt;
  float t0  = localTime;
  localTime += dlt;
  if( localTime>=duration )
  {
    goalValue = keyGoal;
    pEngine->setGoal( wantedJoint,-1 );
    return false;
  }
  float bt = localTime/duration;
  float ot = 1.0-bt;
  float g = bt*( (bt*bt)+ (ot*bezierA + bt*bezierB)*ot*3 );
  goalValue = startPos + g*(keyGoal-startPos);
  pEngine->setGoal( (int)goalValue,-1 );
  //SERIAL.print("bez ");SERIAL.println( (keyGoal-startPos) );
  SERIAL.print("MV 2 30 ");SERIAL.println((int)goalValue+512);
  return true;  
}
*/



