//String ???

#include "Anim.h"

boolean echo = false;

boolean polling = false;

int   bufferHead = 0;
int   bufferTail = 0;
char  bufferIn[256];
char  bufferOut[256];
char* pBuffersIn[4] = {bufferIn,bufferIn+0x40,bufferIn+0x80,bufferIn+0xC0};
int   readBuffer  = 0;
int   writeBuffer = 0;

int   parseStep = 0;
char  cmdId[32];
int   params[16];

boolean sending = false;
unsigned long serialTime = 0;

//pour Test
void serialInterrupt0(uint8 c)
{ 
  //Test for detection of forgotten bytes
  //unsigned long t=micros();
  //unsigned long dt=t-serialTime; // ~100 - .... 2000 ?
  //serialTime=t;
  //if(dt>200){  bufferIn[bufferTail]=c; bufferTail=(++bufferTail)&0xFF; }
  
  bufferIn[bufferHead]=c;
  bufferHead = (++bufferHead)&0xFF;
  //todo bufferTail overFlow
}


void serialInterruptUSB(uint8* pb,uint8 c)
{
  for(int i;i<c;i++)
  {
    serialInterrupt1(*pb);pb++;
  }
}




//pour Test : 4 line buffers
void serialInterrupt1(uint8 c)
{
  char* pb = pBuffersIn[writeBuffer];
  if( c>=32 )    
    pb[bufferHead++]=(char)c;
  else if(c==10)
    c=0;
    
  if( (c==0)||(bufferHead>=60) )
  {
    pb[bufferHead++]='#';
    pb[bufferHead]=0;      
    bufferHead=0;
    writeBuffer = (++writeBuffer)&3;
    *pBuffersIn[writeBuffer]=0; 
  }
}

void serialParse()
{
  if( readBuffer!=writeBuffer )
  {
    //SERIAL.println(pBuffersIn[readBuffer]);
    serialParseLine();
    readBuffer = (++readBuffer)&3; 
  }
}

//true: gotLine // false nomore
int serialParseLine()
{
  if( readBuffer==writeBuffer )
    return 0;

  parseStep = 0;
  char* pb = pBuffersIn[readBuffer];
  int  ichar = 0;
  char c = 0;
  
  //copy cmd String
  do{ c=*pb;cmdId[ichar]=c; pb++; ichar++; } //copy cmd string
  while(c>' ');
  cmdId[ichar]=0;             //!!! ' ' copied
  parseStep = 1; 
  if( c<' ' )
    return 1; //one field
 
  //parse ints
  ichar = 0;
  do
  { 
    c = pb[ichar];
    if(c=='#')
      c=0;
    if( c<=' ' ) //separator or end
    {
      pb[ichar]=0;
      char t=*pb;
      if( (t=='-')||((t>='0')&&(t<='9')) )
      {   //tant qu'a faire autant itoa soi-meme non? 
          params[parseStep] = atoi(pb);//only ints now
          parseStep++;
          pb+=ichar+1;
          ichar = -1;
      }
      else //error
      {
        parseStep = -(int)c;
        c=0; //= break
      }
    }
    ichar++;
  }while(c>=' ');
  
  //serialSend(" && ",params[1],params[2],params[3],bufferOut );
  if( cmdId[0]=='E')
  {
    //serialSend(" %dbg E ",parseStep-2,params[2],params[3],bufferOut);
    if( (params[1]>=0)&&(params[1]<NB_ENGINES) )
      engines[params[1]].onCmd(cmdId,&params[2],parseStep-2);    
  }
  else if( cmdId[0]=='S')
  {
    processScript();
  }
  else if( cmdId[0]=='M')
  {
    processMotor(); //in fact Dxl
  }

  return parseStep;  
}

char* getSerialCmd()
{
  return cmdId;
}
int getCmdParam(int i)
{
  return params[i];
}

char* sprint(char* sce,char* dest) //!!! no security at all
{
  do
  {
    *dest = *sce; dest++; sce++;
  }while(*sce!=0);
  return dest;
}

char* sprint(int num,char* dest)
{
  if(num==0){*dest='0';return ++dest;}
  itoa(num,dest,10);
  while(*dest!=0){dest++;}
  return dest;  
}

void serialSend(const char* str)
{
  while(sending){}
  //sending = true;
  SERIAL.print(str);
  sending = false;
}

void serialSend(char* cmd,int i0,char* buffer)
{
  char* dest = sprint(cmd,buffer);
  dest[0]=' ';dest++;
  dest = sprint(i0,dest);
  dest[1]=10;dest[0]=13;dest[2]=0;
  while(sending){}
  //sending = true;
  SERIAL.print(buffer);
  sending = false;
}

void serialSend(char* cmd,int i0,int i1,char* buffer)
{
  char* dest = sprint(cmd,buffer);
  dest[0]=' ';dest++;
  dest = sprint(i0,dest);
  dest[0]=' ';dest++;
  dest = sprint(i1,dest);
  dest[0]=13;dest[1]=10;dest[2]=0;
  while(sending){}
  //sending = true;
  SERIAL.print(buffer);
  sending = false;
}

void serialSend(char* cmd,int i0,int i1,int i2,char*buffer)
{
  char* dest = sprint(cmd,buffer);
  dest[0]=' ';dest++;
  dest = sprint(i0,dest);
  dest[0]=' ';dest++;
  dest = sprint(i1,dest);
  dest[0]=' ';dest++;
  dest = sprint(i2,dest);
  dest[0]=13;dest[1]=10;dest[2]=0;
  while(sending){}
  //sending = true;
  SERIAL.print(buffer);
  sending = false;
}

//watch:  nom a revoir dbg
#if 0
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
      serialSend("MV",imot,reg,v,bufferOut);
      /*
      SERIAL.print("MV ");
      SERIAL.print(imot);
      SERIAL.print(" ");
      SERIAL.print(reg);
      SERIAL.print(" ");
      SERIAL.println(v);
      */
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
  /*
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
      SERIAL.print("addWatch "); //echo?
      SERIAL.println(i);
      break;
    }
  }
  */
}
#endif

/*
void removeWatch(int imot,int reg)
{
  for(int i=0;i<16;i++)
  {
    if((imot==watches[i].imot)&&(reg==watches[i].reg))
      watches[i].imot = -1;
  }
}
*/

/*
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
*/

#if 0
void cmdPoll3(unsigned int t)
{
  bool crlf = false;
  char c = 255;
  while(SERIAL.available()>0)
  {
    c = SERIAL.read();
    if(c<32)
    {
      crlf = true;
      break;
    }  
    bufferInt[charCount]=SERIAL.read();
    if(++charCount>=120)
      break;
  }
  
  if(crlf)
  { 
    if( charCount == 0)
    {
     serialSend("zero",(int)c,bufferOut);
     
    }
    else
    { 
    bufferIn[charCount]=0;
    char* dest = sprint("&&",bufferOut);
    dest = sprint(bufferIn,bufferOut);
    dest[0]=10;dest[1]=0;
    SERIAL.print(bufferOut);
    }    
    charCount = 0;
  }  
}

//Test
int avCount = 0;
void cmdPoll(unsigned int t)
{
  while(SERIAL.available()>0)
  {
    int c = SERIAL.read();
    if( (c==10)||(c==13) )
    {
      bufferIn[bufferHead]=0;
      bufferHead = 0;
      serialSend(bufferIn,avCount,bufferOut);
    }
    else if(c>0)
    {
      bufferIn[bufferHead]=(char)c;
      if(++bufferHead>=120)
        bufferHead=0;
    }
    else
      avCount++;
  }
}
#endif

/*
boolean cmdPoll2(unsigned int t)
{
  bool cmdOk = false;
  while(SERIAL.available()>0)
  {
    polling = true;
    char c = SERIAL.read();
    if((c==10)||(c==13)||(c==';'))
    {
      processCmd();
      cmdOk = true;
      polling = false;
    }
    else if(c==' ')
      parse();
    else
    {
      bufferIn[bufferHead]=c;
      if(++bufferHead>=60)
      {
        bufferHead=0;
        parseStep = 0;
      }
    }
  }
  //if(cmdOk){ Serial2.print("Rcv ");Serial2.print(cmdId);Serial2.println(charCount); }
  //if(!polling)
  //  processWatches();
  return cmdOk;    
}
*/

/*
void parse()
{
  bufferIn[bufferHead]=0;
  if(parseStep>0)
    params[parseStep] = atoi(bufferIn);//que des ints now
  else
  {//pas de strcpy ???
    for(int i=0;i<=bufferHead;i++)
      cmdId[i]=bufferIn[i];
  }
  bufferHead = 0; 
  parseStep++;
}
*/

/*
void processCmd()
{
  parse(); //dernier chiffre
  if(  cmdId[0]=='E' )
  {
    if( (params[1]>=0)&&(params[1]<NB_ENGINES) )
      engines[params[1]].onCmd(cmdId,&params[2],parseStep-2);
  }
  else if(  cmdId[0]=='M' )
    processMotor();
  else if(  cmdId[0]=='S' )
    processScript();
  else if(  cmdId[0]=='Q' )
    stopMotors();
  else if(  cmdId[0]=='W' )
    cmdWatch();
  parseStep = 0;

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
  polling = false;
}
*/

void processScript()
{
  //SERIAL.print("__char ");SERIAL.println((int)cmdId[1]);
  if( (cmdId[1]!=' ')&&(cmdId[1]!=0) )
    engines[0].anim.execCmd(cmdId,params[1]);
  else if( (parseStep>3)&&(params[1]>=0)&&(params[1]<NB_ENGINES)&&(params[2]>=0) ) 
    engines[params[1]].anim.execTokenDbg(params[2],params[3]);
  else
   SERIAL.println(" invalid cmd");
}

void processMotor() //in fact Dxl
{
  switch((int)cmdId[1])
  {
    case 'W': //write
      dxlWrite(params[1],params[2],params[3]);
      break;
    case 'R': //read
      serialSend("MV",params[1],params[2],dxlRead(params[1],params[2]),bufferOut);
      break;

    case 'T': //token  engineIndex tok value
      SERIAL.println("TOKEN ");
      if( (parseStep>3)&&(params[1]>=0)&&(params[1]<NB_ENGINES)&&(params[2]>=0) ) 
        engines[params[1]].anim.execTokenDbg(params[2],params[3]);
      else
        SERIAL.println(" invalid");
    break;

    case 'Q':
      if(parseStep<2)
        stopMotors();
      else if( (params[1]>=0)&&(params[1]<NB_ENGINES) )
        engines[params[1]].stop();
    break;
            
    case 'I':
      if( (params[1]>=0)&&(params[1]<4) )
        engines[params[1]].setId(params[2]);
      //SERIAL.print("MI ");SERIAL.print(params[1]);SERIAL.print(" ");SERIAL.println(engines[params[1]].dxlId);
      break;

    case 'i':
      if( (params[1]>=0)&&(params[1]<4) )
      serialSend("Mi",params[1],engines[params[1]].getIdFromFlash(),engines[params[1]].dxlId,bufferOut);
      break;

    case '?': //find a motor id M? from // return M? from found
      if(parseStep==2)
        SERIAL.print("M? ");SERIAL.print(params[1]);SERIAL.print(" ");SERIAL.println(dxlFindEngine(params[1]));
      break;

      
  }
}

void stopMotors()
{
  for(int i=0;i<NB_ENGINES;i++)
    engines[i].stop();
}


