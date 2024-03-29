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

  ServoArray(int[] motorIds)
  {
    servos = new ServoDxl[motorIds.length];
    for(int i=0;i<motorIds.length;i++)
    {
      servos[i] = new ServoDxl(i,motorIds[i]);
      servos[i].index = i;
    }
    recRate = 20;
    frameTime = millis();    
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
        //servos[i].update(); // mouais... pas très logique d'appeler un update pas à chaque update... je changerai prob par la suite
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
  int currFrame = 0;
  
  String oldModus = "none";
  
  JSONArray velocities;
  int currRec = 0;
  ServoKey[] recValue;
  long recframeTime;
  long playframeTime;
  long recRate = 20;
  long playRate = 20;

  int scriptIndex = 0;  //future work: several scripts ???

  ServoDxl(int index,int id)
  {
    this.index  = index;
    scriptIndex = index; //default
    recValue = new ServoKey[800];
    for(int i=0;i<800;i++)
      recValue[i]=new ServoKey();
      
    setDxlId(id);   
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

  void startRecording(boolean isGlobal)
  {
    
    println("start record enable: " + enableRecording + " " + index);
    if((isGlobal && enableRecording) || !isGlobal)
    {
      setWheelMode(true);
      relax(false);
  
      readyForRecording = true;
      recording = true;
      //recording = false;
      currFrame = 0;
      velocities = new JSONArray();
    }
    
    /* to generate animations....
    int v = 250;
    boolean down = false;
    for(int i=0; i<5000; i++)
    {
      JSONObject vel = new JSONObject();
      vel.setInt("frame", i);
      vel.setInt("vel", v);
      velocities.setJSONObject(i,vel);
      if(down)
      {
        v -= 5;
        if(v < 250)
        {
          v = 250;
          down = false;
        }
      }
      else
      {
        v += 5;
        if(v > 350)
        {
          down = true;
        }
      }
     
    }
    saveJSONArray(velocities, "anims/anim.json");
    */
   
  }

  void recordFrame(int frame)
  {
     JSONObject vel = new JSONObject();
     vel.setInt("frame", frame);
     if(isWheelMode())
     {
       vel.setString("modus","wheel");
       vel.setInt("vel", speed);
     }
     else
     {
       vel.setString("modus","joint");
       vel.setInt("vel", goal);
     }
     
     
     //vel.setInt("vel", recValue[currRec].speed);
     velocities.setJSONObject(frame,vel);
  }
  
  
  JSONArray stopGlobalRecording()
  {
     readyForRecording = false;
     recording = false;
     currFrame = 0;
     return velocities;
  }
  
  String stopRecording()
  {
    readyForRecording = false;
    recording = false;
    currFrame = 0;
    int d = day();    // Values from 1 - 31
    int m = month();
    int s = second();  // Values from 0 - 59
    int min = minute();  // Values from 0 - 59
    int h = hour();    // Values from 0 - 23
    String path = "anims/anim_" + d + "-"+ m + "_" + h + "-" + min + ".json";
    println("Saving animation into " + path);
    saveJSONArray(velocities, path);
    return path;
  }

// taking in account just velocity animation for now...
  void startPlaying(String jsonFilenmame)
  {
    playing = true;
    currFrame = 0;
    long t1 = millis();
    velocities = loadJSONArray(jsonFilenmame);
    long t2 = millis()-t1;
    println("finished loading in " + t2 + " milliseconds");
    //if(!isWheelMode())
    //{
    //  setWheelMode(true);
    //}
    relax(false);
  }
  
  void startPlaying(JSONArray vel, float speed)
  {
    playRate = (int)((float)recRate*speed);
    println("-> animation playrate = " + playRate);
    playing = true;
    currFrame = 0;
    velocities = vel;
    //if(!isWheelMode())
    //{
      // setWheelMode(true); // is done now in play frame
    //}
    relax(false);
  }
  
  void playFrame(int frame)
  {
    if(frame <  velocities.size())
    {
      JSONObject vel = velocities.getJSONObject(frame); 
      String modus = vel.getString("modus","wheel");
      //println("modus: " + modus + " " + oldModus);
      if(modus.equals("wheel") && !oldModus.equals(modus))
      {
        setWheelMode(true);
      }
      else if(modus.equals("joint") && !oldModus.equals("joint"))
      {
        setWheelMode(false);
      }
      int v = vel.getInt("vel");
      
      if(modus.equals("wheel"))
      {
        //println("vel: " + v);
        //println("f: " + frame);
        setSpeed(v);
      }
      else
      {
        //println("goal: " + v + " " + goal);
        if(v != goal)
        {
          //println("goal: " + v);
          setGoal(v);
        }
      }
      oldModus = modus;
    }
    else if(frame == velocities.size())
    {
      stopPlaying();
    }
    
  }

  void stopPlaying()
  {
    playing = false;
    currFrame = 0;
    oldModus = "none";
    setWheelMode(true);
    setSpeed(0);
    scriptArray.scriptAt(index).setReady(); //TODO safe ?
  }

  void update()
  {
    if(readyForRecording)
    {
      //if(speed != 0) recording = true;
      //println("GOAL : " + float(recValue[currRec].goal));//recValue[currRec].goal);
      //println("POS : " + float(recValue[currRec].pos));
      //println("SPEED : " + currSpeed); 
      //println("SPEED : " + float(recValue[currRec].speed));
      if(recording)
      {
        long t = millis();    
        if( (t-recframeTime)>=recRate ) // ou controller depuis ServoDxl Array.... arf...
        {
          recframeTime = t;
          recordFrame(currFrame);
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
    println("TYPE "+cmd.type);
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
    speed = val;
    wantedSpeed = val;
    println("speed " + val);
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
