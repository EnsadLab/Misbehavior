#ifndef ANIM_H
#define ANIM_H

#include "libpandora_types.h"
#include "Parser.h"

#define TOKEN_JOINT    2
#define TOKEN_JOINT_D  3
#define TOKEN_WHEEL    4
#define TOKEN_WHEEL_D  5
#define TOKEN_SPEED    6
#define TOKEN_TGIN     7
#define TOKEN_TGOUT    8
#define TOKEN_MARGIN   9
#define TOKEN_COMPLIANCE 10
#define TOKEN_TORQUE     11

#define TOKEN_DURATION 12
#define TOKEN_PAUSE 13
#define TOKEN_TEST  31
//End Of Line
#define TOKEN_EOL 63

class DxlEngine;

class Anim
{
  public:
  //int iDxl;
  DxlEngine* pEngine;
  unsigned long frameTime;
  unsigned long pauseTime;
  unsigned long pauseDuration;
  int   currentTask;
  int   wantedTask;
  float localTime;
  float timeCoef;  
  float duration;
  float speedValue;
  float startValue;
  float destValue;
  float bezierIn;
  float bezierOut;
  int   wantedGoal;
  int   goalMargin;
    
  int   wSpeed;
  float prevPos;  
  char strBuffer[64];
    
  Anim();
  void init(DxlEngine* pEng);
  //bool startScript(int iscript,const char* plabel);
  //bool startScript(const char* pname,const char* plabel);
  //void start(unsigned long t,AnimKey* pAni);
  void stop();
  bool update(unsigned long t);
  void sendReady();
  void execCmd(const char* strcmd,int value);
  void execTokenDbg(int tok,int value);
  void execToken(int tok,int value);

  bool taskPause(unsigned long dt);
  bool taskJoint(unsigned int dt);  //wait goal or bezier
  bool taskWheel(unsigned int dt);  //lineaire
  void taskSpeedTest(unsigned long dt);

  
  
  
};

#endif
