class ServoKey
{
  ServoKey(){set(0,0,0,0);}
  void set(long t,int g,int p,int s){time=t;goal=g;pos=p;speed=s;} 
  long time;
  int goal;
  int pos;
  int speed;  
};


class ServoArray
{
  DxlServo[] servos;
  long frameTime;
  long recRate;

  ServoArray(int nbs)
  {
    servos = new DxlServo[4];
    for(int i=0;i<nbs;i++)
    {
      servos[i] = new DxlServo();
      servos[i].index = i;
    }
    recRate = 20;
    frameTime = millis();    
  }

  DxlServo getServo(int imot)
  {
    for(int i=0;i<servos.length;i++)
    {
     if( servos[i].servoId==imot )
       return servos[i];
    }
    return null;
  }
  
  void sendDxlId()
  {
    for(int i=0;i<servos.length;i++) 
    {
      if(servos[i].servoId>0)
        arduino.serialSend("MI "+i+" "+servos[i].servoId+"\n");      
    }        
  }
  

  void regValue(int idxl,int reg,int val)
  {
    //println("servoreg "+idxl+" "+reg+" "+val);
    for(int i=0;i<servos.length;i++) 
    {
      if(servos[i].servoId==idxl )
        servos[i].regValue(reg,val);
    }        
  }
  
  void midiValue(int iServo,int value)
  {
    try{servos[iServo].setGoal( value<<2 ); }
    catch(Exception e){}
  }
  
  void update()
  {
    long t = millis();    
    if( (t-frameTime)>=recRate )
    {
      frameTime = t;
      for(int i=0;i<servos.length;i++)
      { 
        servos[i].recKey(t);
      }
    }
  }

  void draw(int x,int y)
  {
      //for(int i=0;i<servos.length;i++)
      /*
      for(int i=0;i<1;i++)
      { 
        servos[i].draw(x,y);
        y+=170;
      }
      */
  }
  
};



class DxlServo
{
  static final int DXL_JOIN  = 0;
  static final int DXL_WHEEL = 1;
  
  int index     = 0;
  int servoId   = 0;
  int speedCoef  = 1; //coef todo: float
  
  int status    = 0;
  int mode      = 0; //0=JOIN 1=WHEEL
  int prevPos   = 0;
  int currPos   = 0;  //DXL36 current pos
  int prevSpeed = 0;  
  int currSpeed = 0;  //DXL38 current speed
  int goal   = 0;       //DXL30 goal
  int speed  = 0;      //DXL32: moving speed
  int torqueLimit = 1023; //DXL34: relax
  int minGoal = 0;     //DXL 6
  int maxGoal = 1023;  //DXL 8

  int currRec = 0;
  ServoKey[] recValue;


  DxlServo()
  {
    recValue = new ServoKey[800];
    for(int i=0;i<800;i++)
      recValue[i]=new ServoKey();
  }

  void setId(int id)
  {
    if(servoId>0)
    {
      arduino.serialSend("WR "+servoId+" 36\n"); //remove watch pos
      delay(10);
      arduino.serialSend("WR "+servoId+" 38\n"); //remove watch speed
      delay(10);
    }
    servoId = id;
    if(servoId>0)
    {
      arduino.serialSend("MI "+index+" "+servoId+"\n");      
      arduino.serialSend("WA "+servoId+" 36\n"); //add watch pos
      delay(10);
      arduino.serialSend("WA "+servoId+" 38\n"); //add watch speed
      delay(10);
      arduino.serialSend("MR "+servoId+" 6\n"); //CW min
      delay(10);
      arduino.serialSend("MR "+servoId+" 8\n"); //CCW max
      delay(10);
      arduino.serialSend("MR "+servoId+" 34\n"); //torque      
    }
    
  }

  void update()
  {
  }

  void sendToken(int tok,int value)
  {
    arduino.serialSend("A "+servoId+" "+tok+" "+value+"\n"); //Token immediat      
  }
    
  void regValue(int reg,int value)
  {
    switch(reg)
    {
      //case  6: minGoal = value; break;
      //case  8: maxGoal = value; break;
      case 30: goal=value; break;
      //case 34: torqueLimit = value; break; //relax
      case 36: currPos = value; break;
      case 38: currSpeed = value;break;      
      //...
    }
  }

  void recKey(long t)
  {
    if(servoId<=0)
      return;
    int spd = currSpeed>>1;
    if(currSpeed>=1024) spd = (1024-currSpeed)>>1;
    recValue[currRec].set(t,goal,currPos,spd+512);
    if(++currRec>=800)
      currRec=0;
  }
  
  void draw(int x,int y)
  {
    stroke(0);
    int irec = currRec;
    float vg = recValue[currRec].goal;
    float vp = recValue[currRec].pos;
    float vs = recValue[currRec].speed;
    for(int i=0;i<800;i++)
    {
      if(++irec>=800)
        irec=0;
      stroke(255,0,0);          
      line(x,y+vs*0.15f,x+1,y+recValue[irec].speed*0.15f);
      stroke(255,255,0);
      line(x,y+vp*0.15f,x+1,y+recValue[irec].pos*0.15f);
      stroke(0,200,200);
      line(x,y+vg*0.15f,x+1,y+recValue[irec].goal*0.15f);
      vg = recValue[irec].goal;
      vp = recValue[irec].pos;
      vs = recValue[irec].speed;
      x++;
    }
  }
  
  int setKnobValue(int val)
  {
    //println("DXL MODE "+mode);
    if( mode == DXL_JOIN )
    {
      setGoal(val+512);
      return goal;
    }
    else
    {
      if(val>0) setSpeed(    val<<1 );
      else setSpeed( 1024-(val<<1) );
      return speed;
    }    
  }
  
  
  void setGoal(int val)
  {
    goal = val;
    arduino.serialSend("MW "+servoId+" 30 "+val+"\n");
  }
  void setSpeed(int val)
  {
    speed = val*speedCoef;
    arduino.serialSend("MW "+servoId+" 32 "+val+"\n");
  }
  
  void setWheelSpeed(int val)
  {
      if(val>0) setSpeed(    val );
      else setSpeed( 1024-(val) );
  }
  
  void relax(boolean doRelax)
  {
    if(doRelax)
    {
      arduino.serialSend("MW "+servoId+" 32 0\n" ); //speed
      delay(50);      
      arduino.serialSend("MW "+servoId+" 34 0\n" ); //torque    
    }
    else
    {
      //TODO mettre goal à current position
      arduino.serialSend("MW "+servoId+" 32 0\n" ); //speed
      delay(50);      
      arduino.serialSend("MW "+servoId+" 34 "+torqueLimit+"\n" );      
    }
  }
  void setWheelMode(boolean wheel)
  {
    println("setWheelMode "+wheel);
    if(!wheel)
    {
      println("JOINT ");
      mode = DXL_JOIN;
      arduino.serialSend("MW "+servoId+" 6 "+minGoal+"\n" );
      delay(100);
      arduino.serialSend("MW "+servoId+" 8 "+maxGoal+"\n" );
      delay(100);
      //TODO set goal to current pos
    }
    else
    {
      println("WHEEL ");
      mode = DXL_WHEEL;
      arduino.serialSend("MW "+servoId+" 32 0\n" ); //moving speed à 0;
      speed = 0;
      delay(100);
      arduino.serialSend("MW "+servoId+" 6 0\n" );
      delay(100);
      arduino.serialSend("MW "+servoId+" 8 0\n" );
      delay(100);
    }
  }
  
  
  void askPos()
  {
    arduino.serialSend("MR "+servoId+" 36 ");
  }
  
  
}
