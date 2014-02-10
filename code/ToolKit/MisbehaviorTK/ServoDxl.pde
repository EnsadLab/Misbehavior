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
  ServoDxl[] servos;
  long frameTime;
  long recRate;

  ServoArray(int[] motorIds, int[] jointwheelmode)
  {
    servos = new ServoDxl[motorIds.length];
    for(int i=0;i<motorIds.length;i++)
    {
      servos[i] = new ServoDxl(i,motorIds[i], jointwheelmode[i]);
      servos[i].index = i;
    }
    recRate = 20;
    frameTime = millis();    
  }
    
 ServoDxl[] getServos()
 {
   return servos;
 }

  ServoDxl getByIndex(int i)
  {
    if(i<servos.length)
      return servos[i];
    return null;
  }

  ServoDxl findById(int id)
  {
    for(int i=0;i<servos.length;i++)
    {
     if( servos[i].dxlId==id )
       return servos[i];
    }
    return null;
  }
  
  void sendDxlId()
  {
    for(int i=0;i<servos.length;i++) 
    {
      if(servos[i].dxlId>0)
        arduino.serialSend("EI "+i+" "+servos[i].dxlId+"\n");      
    }        
  }

  void initAll()
  {
    sendDxlId();
    delay(10);    
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i].dxlId>0)
      {
        servos[i].setWheelMode(true);
        servos[i].relax(false);
      }
    }        
  }

  
  void regValue(int id,int reg,int val)
  {
    for(int i=0;i<servos.length;i++) 
    {
      if(servos[i].dxlId==id )
        servos[i].regValue(reg,val);
    }        
  }

  void onSensor(SensorEvt cmd)
  {
    if( (cmd.servo>=0)&&(cmd.servo<servos.length) )
      servos[cmd.servo].onSensor(cmd);
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
    
    for(int i=0;i<servos.length;i++)
    { 
      servos[i].update(); 
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



class ServoDxl
{
  static final int DXL_JOIN  = 0;
  static final int DXL_WHEEL = 1;
  
  int index     = 0;
  int dxlId     = 0;
  int status    = 0;
  int mode      = 0; //0=JOIN 1=WHEEL
  int prevPos   = 0;
  int currPos   = 0;  //DXL36 current pos
  int currSpeed = 0;  //DXL38 current speed
  int goal   = 0;       //DXL30 goal
  int wantedSpeed = 0;
  int speed  = 0;      //DXL32: moving speed
  int torqueLimit = 1023; //DXL34: relax
  int minGoal = 0;     //DXL 6
  int maxGoal = 1023;  //DXL 8

  float origin = 0;
  float scale  = 0;
  
  boolean recording = false;
  boolean readyForRecording = false;
  boolean enableRecording = false;
  boolean playing = false;
  boolean loop = false;
  int currFrame = 0;
  
  String oldModus = "none";
  
  //JSONArray velocities;
  float[] recordValues;
  int[] animValues;
  int currRec = 0;
  ServoKey[] recValue;
  long recframeTime;
  long playframeTime;
  long recRate = 20;
  long playRate = 20;
  Anim anim = null;

  int scriptIndex = 0;  //future work: several scripts ???

  ServoDxl(int index,int id, int jointwheelmode)
  {
    this.index  = index;
    scriptIndex = index; //default
    recValue = new ServoKey[800];
    for(int i=0;i<800;i++)
      recValue[i]=new ServoKey();
      
    setDxlId(id);   
    
    // TODO: tell the servo to be on mode
    // TODO: INUTILE, car quand CM9 connexion est fait, tous les moteurs sont mis à wheel par défaut.... a changer
    if(jointwheelmode == 0)
    {
      setWheelMode(false);
    }
    else
    {
      setWheelMode(true);
    }
 }

  void setDxlId(int id)
  {
    if(dxlId>0)
    {
      arduino.serialSend("WR "+dxlId+" 36\n"); //remove watch pos
      delay(10);
      arduino.serialSend("WR "+dxlId+" 38\n"); //remove watch speed
      delay(10);
    }
    dxlId = id;
    if(dxlId>0)
    {
      arduino.serialSend("EI "+index+" "+dxlId+"\n");
      delay(10);    
//      arduino.serialSend("WA "+dxlId+" 36\n"); //add watch pos
      delay(10);
      //println("-> add watch speed");
      //arduino.serialSend("WA "+dxlId+" 38\n"); //add watch speed
      delay(10);
      arduino.serialSend("MR "+dxlId+" 6\n"); //CW min
      delay(10);
      arduino.serialSend("MR "+dxlId+" 8\n"); //CCW max, to know Joint/Wheel Mode
      delay(10);
      arduino.serialSend("MR "+dxlId+" 34\n"); //torque, to know if relaxed
    }
    
  }
  
  void enableRecording()
  {
    enableRecording = true;
  }
  
  void disableRecording()
  {
    enableRecording = false;
  }


  void startRecording()
  {
    recordValues = new float[0];
    readyForRecording = true;
    recording = true;
    //recording = false; // an intermediate state in case we wanna ignore first frames... to be done...
    currFrame = 0;
  }
  
  
  void recordFrame()
  {
    if(isWheelMode())
    {
      recordValues = append(recordValues,(float)speed/1024.0);
      //println("record speed: " + speed);
    }
    else
    {
      recordValues = append(recordValues,(float)goal/512.0);
      //println("record goal: " + goal);
    }
  }
  
  
  float[] stopRecording()
  {
    readyForRecording = false;
    recording = false;
    currFrame = 0;
    /*int s = 0;
    for(int i=0; i<200; i++)
    {
      recordValues = append(recordValues,s);
      s += 2;
    }*/
    return recordValues;
  }
  
  void startPlaying(double[] val, boolean l, float speed, Anim a)
  {
    if(anim != null)
    {
      anim.servoStoppedPlaying(index);
    }
    anim = a;
    loop = l;
    playRate = (int)((float)recRate*speed);
    println("-> animation playrate = " + playRate);
    playing = true;
    currFrame = 0;
    animValues = new int[val.length];
    for(int i=0; i< val.length; i++)
    {
      double v = val[i]; 
      //println("v = " + v);
      if(isWheelMode()) // convert to velocity
      {
        v = v*1024.0;
      }
      else // convert to goal
      {
        v = v*512.0;
      }
      animValues[i] = (int)v;
    }
    //relax(false); // TODO: didier, on en a besoin?
  }
  
  void playFrame(int frame)
  {
    
    if(frame <  animValues.length)
    {
      int v = animValues[frame];
      if(isWheelMode())
      {
        //println("speed: " + v);
        setSpeed(v);
      }
      else
      {
        //println("goal: " + v);
        setGoal(v);
      }
    }
    else if(frame == animValues.length)
    {
      if(loop)
      {
        currFrame = 0;
        if(anim != null)
        {
          anim.loopIsFinished();
        }
      }
      else
      {
        if(anim != null)
        {
          anim.playingIsFinished();
        }
        stopPlaying();
      }
    }
    
  }
  
  void stopPlaying()
  {
    playing = false;
    currFrame = 0;
    anim = null;
    if(isWheelMode())
    {
      setSpeed(0);
    }
    
    scriptArray.scriptAt(index).setReady(); //TODO safe ? a discuter ensemble !
  }


  void setLoop(boolean b)
  {
    loop = b;
  }
  
  
  void update()
  {
    
    if(readyForRecording)
    {
      if(recording)
      {
        long t = millis();    
        if( (t-recframeTime)>=recRate ) // ou controller depuis ServoDxl Array.... arf...
        {
          recframeTime = t;
          recordFrame();
          currFrame++;
        }
      }
    }
    if(playing)
    {
      long t = millis();    
      if( (t-playframeTime)>=playRate )
      {
          playframeTime = t;
          playFrame(currFrame);
          currFrame++;
      }
    }
    
    //becoz midi
    if(speed!=wantedSpeed)
    {
      speed=wantedSpeed;
      arduino.serialSend("EW "+index+" 32 "+speed+"\n");
    }
    
  }

  void sendToken(int tok,int value)
  {
    arduino.serialSend("A "+dxlId+" "+tok+" "+value+"\n"); //Token immediat      
  }
  
  //from sensor or midi //String alows labels
  void onSensor(SensorEvt cmd)
  {
    int v = (int)(cmd.coef * (cmd.value-cmd.center) );
    //println("TYPE "+cmd.type);
    switch( cmd.type )
    {
      case 0: // inside range
        if( (v>=cmd.min)&&(v<=cmd.max) )
          execStringCmd(cmd.cmd,v);
        break;
      case 1: //hysteresis down
        if( (cmd.state!=1)&&(v<cmd.min) )
        {
          cmd.state=1;
          //execStringCmd(cmd.cmd,v);
          println("STATE 1");        
        }
        else if( (cmd.state!=2)&&(v>cmd.max) )
        {
          cmd.state = 2;
          println("STATE 2");        
        }
        break;
      case 2: //hysteresis up
        if( (cmd.state!=1)&&(v<cmd.min) )
          cmd.state=1;
        else if( (cmd.state!=2)&&(v>cmd.max) )
        {
          cmd.state = 2;
          execStringCmd(cmd.cmd,v);        
        }
        break;
      case 3: //hysteresis change
        if( (cmd.state!=1)&&(v<cmd.min) )
        {
          cmd.state=1;
          execStringCmd(cmd.cmd,v);        
        }
        else if( (cmd.state!=2)&&(v>cmd.max) )
        {
          cmd.state = 2;
          execStringCmd(cmd.cmd,v);        
        }
        break;      
    }
  }
  
  //from sensor or midi //String alows labels
  void execStringCmd(String line,int value)
  {
      try{
        char c=line.charAt(0); 
        switch(c)
        {
          case '@': scriptArray.scriptAt(scriptIndex).start(line);break;
          case 'Q': case 'q': stop();break;
          case 'j': setGoal(value);    break;
          case 's': wantedSpeed=value; break;
          case 'w': wantedSpeed=value; break;
        }
      }   
      catch(Exception e){}
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
      case 38: currSpeed = value; println(currSpeed); break;      
      //...
    }
  }

  void recKey(long t)
  {
    if(dxlId<=0)
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
  
 /*
  int setKnobValue(int val)
  {
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
  */
  
  void setGoal(int val)
  {
    goal = val;
    arduino.serialSend("EW "+index+" 30 "+val+"\n");
    delay(1);
  }
  void setSpeed(int val)
  {
    //println("setSpeed "+val);
    speed = val;
    wantedSpeed = val;
    //println("setSpeed: " + val);
    arduino.serialSend("EW "+index+" 32 "+val+"\n");
    delay(1);
  }
  
  void setWheelSpeed(int val)
  {
      if(val>0) setSpeed( val );
      else setSpeed( 1024-(val) );
  }
  
  void relax(boolean doRelax)
  {
    if(doRelax)
    {
      arduino.serialSend("EW "+index+" 32 0\n" ); //speed
      delay(10);      
      arduino.serialSend("EW "+index+" 34 0\n" ); //torque    
    }
    else
    {
      //TODO mettre goal à current position
      arduino.serialSend("EW "+index+" 32 0\n" ); //speed
      delay(10);      
      arduino.serialSend("EW "+index+" 34 "+torqueLimit+"\n" );      
    }
  }
  void setWheelMode(boolean wheel)
  {
    //println("setWheelMode "+wheel);
    if(!wheel)
    {
      println("JOINT ");
      mode = DXL_JOIN;
      arduino.serialSend("EW "+index+" 6 "+minGoal+"\n" );
      delay(10);
      arduino.serialSend("EW "+index+" 8 "+maxGoal+"\n" );
      delay(10);
      //TODO set goal to current pos
    }
    else
    {
      println("WHEEL ");
      mode = DXL_WHEEL;
      arduino.serialSend("EW "+index+" 32 0\n" ); //moving speed à 0;
      speed = 0;
      delay(10);
      arduino.serialSend("EW "+index+" 6 0\n" );
      delay(10);
      arduino.serialSend("EW "+index+" 8 0\n" );
      delay(10);
    }
  }
  
   boolean isWheelMode()
  {
    if(mode == DXL_WHEEL)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  void askPos()
  {
    arduino.serialSend("MR "+dxlId+" 36 ");
  }
  
  
}
