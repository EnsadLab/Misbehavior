//String ???

#include "Anim.h"

boolean polling = false;
boolean echo = true;
int currChar = 0;
char buffer[32];
int parseStep = 0;
char cmdId[32];
int params[16];
int charCount = 0;
int cmdCount = 0;

char* getSerialCmd()
{
  return cmdId;
}
int getCmdParam(int i)
{
  return params[i];
}

//watch:  nom a revoir dbg
class watch
{
  public:
  int imot;
  int reg;
  int val;
  watch(){imot=-1;}
  void send()
  {
    int v = dxlRead( imot,reg);
    if( v != val )
    { 
      val = v;
      SERIAL.print("MV ");
      SERIAL.print(imot);
      SERIAL.print(" ");
      SERIAL.print(reg);
      SERIAL.print(" ");
      SERIAL.println(v);
    }    
  }
};

watch watches[16];
int currWatch = 0;
unsigned int tWatch = 0;

void clearWatches()
{
  for(int i=0;i<16;i++)
    watches[i].imot = -1;
}
void addWatch(int imot,int reg)
{
  for(int i=0;i<16;i++)
    if((imot==watches[i].imot)&&(reg==watches[i].reg))
      return;

  for(int i=0;i<16;i++)
  {
    if(watches[i].imot <0 )
    {
      watches[i].reg = reg;
      watches[i].val = -1;
      watches[i].imot =imot;
      SERIAL.print("addWatch ");
      SERIAL.println(i);
      break;
    }
  }
}

void removeWatch(int imot,int reg)
{
  for(int i=0;i<16;i++)
  {
    if((imot==watches[i].imot)&&(reg==watches[i].reg))
      watches[i].imot = -1;
  }
}

void processWatches()
{
  unsigned long t = millis();
  if( (t-tWatch)<50 )
    return;    
  tWatch = t;

  for(int i=0;i<16;i++)
  {  
    if(++currWatch>=16)
      currWatch = 0;
    
    if( watches[currWatch].imot>0 )
    {
      watches[currWatch].send();
      break;
    }
  }
}

boolean cmdPoll(unsigned int t)
{
  bool cmdOk = false;
  while(SERIAL.available()>0)
  {
    charCount++;
    polling = true;
    char c = SERIAL.read();
    if((c==10)||(c==13)||(c==';'))
    {
      processCmd();
      cmdCount++;
      cmdOk = true;
      polling = false;
    }
    else if(c==' ')
      parse();
    else
    {
      buffer[currChar]=c;
      if(++currChar>=32)
        currChar=0;
    }
  }
  //if(cmdOk){ Serial2.print("Rcv ");Serial2.print(cmdId);Serial2.println(charCount); }
  if(!polling)
    processWatches();
  return cmdOk;    
}

void parse()
{
  buffer[currChar]=0;
  if(parseStep>0)
    params[parseStep] = atoi(buffer);//que des ints now
  else
  {//pas de strcpy ???
    for(int i=0;i<=currChar;i++)
      cmdId[i]=buffer[i];
  }
  currChar = 0;
  parseStep++;
}

void processCmd()
{
  parse(); //dernier chiffre

  if(echo)
  {
    SERIAL.print("echo:");
    SERIAL.print(cmdId);
    for(int i=1;i<parseStep;i++)
    {
      SERIAL.print(" ");
      SERIAL.print(params[i]);
    }
    SERIAL.println(" ");
  }
  
  if(  cmdId[0]=='M' )
    processMotor();
  else if(  cmdId[0]=='S' )
    processScript();
  else if(  cmdId[0]=='Q' )
    stopMotors();
  else if(  cmdId[0]=='W' )
    cmdWatch();
  parseStep = 0;
  polling = false;
}

void processScript()
{
  SERIAL.print("ANIM ");SERIAL.println(cmdId);
  if( cmdId[1]!=(char)0 )
    engines[0].anim.execCmd(cmdId,params[1]);
  else if( (parseStep>3)&&(params[1]>=0)&&(params[1]<nbEngines)&&(params[2]>=0) ) 
    engines[params[1]].anim.execTokenDbg(params[2],params[3]);
  else
   SERIAL.println(" invalid");
}

void processMotor()
{
  switch((int)cmdId[1])
  {
    case 'W':
      dxlWrite(params[1],params[2],params[3]);
      break;
    case 'R':
      SERIAL.print("MV ");
      SERIAL.print(params[1]);
      SERIAL.print(" ");
      SERIAL.print(params[2]);
      SERIAL.print(" ");
      SERIAL.println( dxlRead(params[1],params[2]) );
      break;

    case 'T': //token  engineIndex tok value
      SERIAL.println("TOKEN ");
      if( (parseStep>3)&&(params[1]>=0)&&(params[1]<nbEngines)&&(params[2]>=0) ) 
        engines[params[1]].anim.execTokenDbg(params[2],params[3]);
      else
        SERIAL.println(" invalid");
    break;

    case 'Q':
      if(parseStep<2)
        stopMotors();
      else if( (params[1]>=0)&&(params[1]<nbEngines) )
        engines[params[1]].stop();
    break;
            
    case 'I':
      if( (params[1]>=0)&&(params[1]<4) )
        engines[params[1]].setId(params[2]);
      SERIAL.print("MI ");SERIAL.print(params[1]);SERIAL.print(" ");SERIAL.println(engines[params[1]].dxlId);
      break;        
  }
}

/*
void processAnim()
{
  switch((int)cmdId[1])
  {
    case 'K': //!!! not safe !!!
    {
      AnimKey* pAnim = anims[params[1]];
      ik = params[2];
      pAnim[ik].time = params[2];
      pAnim[ik].cmd  = params[3];
      pAnim[ik].goal = params[4];
      pAnim[ik].speed = params[5];
      
    }
  }  
}
*/

void stopMotors()
{
  for(int i=0;i<nbEngines;i++)
    engines[i].stop();
}


void cmdWatch() //"WA" "WR" "WC"
{
  switch(cmdId[1])
  {
    case 'A':
      addWatch(params[1],params[2]);
      break;
    case 'R':
      removeWatch(params[1],params[2]);
      break;
    case 'C':
      clearWatches();
    break;
  }
}

