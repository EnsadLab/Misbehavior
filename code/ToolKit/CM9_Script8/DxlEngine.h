#ifndef DXLCLASS_H
#define DXLCLASS_H

#include "DxlEngine.h"
#include "Anim.h"
//#include "Parser.h"


class DxlEngine
{
  public:
  int index;
  int dxlId;
  int status;
  bool jointMode;
  int lastSpeed;
  int minPos,maxPos;
  int torqueLimit;
  
  int fakeGoal;
  int fakePos;

  //anim
  unsigned int frameTime;
  unsigned int pauseTime;
  int   currentTask;
  float localTime;
  float timeCoef;  
  float duration;
  float speedValue;
  float startValue;
  float destValue;
  float bezierIn;
  float bezierOut;

  int wantedTask;
  int goalMargin;
  int wantedJoint;  
  int wantedSpeed;
  int wantedWheel;
  int wantedDuration;
   
  Anim anim;
  
 DxlEngine();
   DxlEngine(int id);
  void setId(int id);
  void stop();
  void startScript(const char* name,const char* label=NULL);
  bool update(unsigned int t);
  void execTokenDbg(int tok,int value);
  void execToken(int tok,int value);
  bool waitGoal();
  bool taskJoint(unsigned int dt);  //wait goal or bezier
  bool taskWheel(unsigned int dt);  //lineaire

  void parse(char* pScript = NULL);
  void execCmd(int* pIntCmd);
  void setGoalSpeed(int s);
  void setGoal(int g);
  void setGoal(int g,int s);
  void setWheelSpeed(int s);
  int getGoal();
  int getPos();
  int getSpeed();
  int getCurrSpeed();
  void relax(bool dorelax);
  void setTorque(int tl);
  void setWheelMode();
  void setJointMode();
  
  void setCompliance(int cw,int ccw = -1);
  

  
};




#endif
