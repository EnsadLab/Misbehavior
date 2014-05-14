/*******************************************************************************                                                   
*   Copyright 2013-2014 EnsadLab/Reflective interaction                        *
*   Copyright 2013-2014 Didier Bouchon, Cecile Bucher                          *
*                                                                              *
*   This file is part of MisB.                                                 *
*                                                                              *
*   MisB is free software: you can redistribute it and/or modify               *
*   it under the terms of the Lesser GNU General Public License as             *
*   published by the Free Software Foundation, either version 3 of the         *
*   License, or (at your option) any later version.                            *
*                                                                              *
*   MisB is distributed in the hope that it will be useful,                    *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of             *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
*   GNU Lesser General Public License for more details.                        *
*                                                                              *
*   You should have received a copy of the GNU Lesser General Public License   *
*   along with MisB.  If not, see <http://www.gnu.org/licenses/>.              *
*******************************************************************************/

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
  int[] dxlIds;   //tmp : a copy from initialization
  long frameTime;
  long recRate;

  ServoArray(int[] motorIds, int[] jointwheelmode)
  {
    servos = new ServoDxl[motorIds.length];
    dxlIds = new int[motorIds.length];
    for(int i=0;i<motorIds.length;i++)
    {
      dxlIds[i] = motorIds[i];
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
 
  int getNbServos()
  {
    return servos.length;
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
      {
        comCM9.serialSend("EI "+i+" "+servos[i].dxlId+"\n");
        delay(40); //take your time
      }      
    }        
  }

  void initAll()
  {
    sendDxlId();
    for(int i=0;i<servos.length;i++)
    {
      delay(10);    
      if(servos[i].dxlId>0)
      {
        if(servos[i].mode == 0)
        {
          servos[i].setWheelMode(false);
        }
        else
        {
          servos[i].setWheelMode(true);
        }
        servos[i].relax(false);
      }
    }        
  }

  void stopAll()
  {
    for(int i=0;i<servos.length;i++)
    {
      servos[i].stop();
    }    
  }

  void toggleDirection(int iservo)
  {
    if( (iservo>=0)&&(iservo<servos.length) )
      servos[iservo].wheelDirection *= -1;
  }
  
  void loadFromXml(XML parent) //TODO config_SERVOS.xml
  {
    XML[] xservos = parent.getChildren("servo");    
    for(int i=0;i<xservos.length;i++)
    {
      int num = xservos[i].getInt("index");
      if( (num>=0)&&(num<servos.length) )
      {
        int d = xservos[num].getInt("direction");
        if( d!=0 )
          servos[num].wheelDirection = d;
        println("dbg "+num+" WHEELDIR  "+d );
      }
    }
  }
  void saveToXml(XML parent) //TODO config_SERVOS.xml
  {
    for(int i=0;i<servos.length;i++)
    {
       XML x = parent.addChild("servo");
       x.setInt( "index",i);
       x.setInt( "direction",servos[i].wheelDirection );
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
    
  }
  
  
};



class ServoDxl
{
  static final int DXL_JOIN  = 0;
  static final int DXL_WHEEL = 1;
  
  int index     = 0;
  int dxlId     = 0;
  int status    = 0;
  int mode      = 0;       //0=JOIN 1=WHEEL
  int prevPos   = 0;
  int currPos   = 0;       //DXL36 current pos
  int currSpeed = 0;       //DXL38 current speed
  int goal   = 0;          //DXL30 goal
  int wantedSpeed = 0;
  int speed  = 0;          //DXL32: moving speed
  int torqueLimit = 1023;  //DXL34: relax
  int minGoal = 0;         //DXL 6
  int maxGoal = 1023;      //DXL 8
  int wheelDirection = 1;  //cf setSpeed, seWheelSpeed //used for reverse wheel direction (rumba)

  float origin = 0;
  float scale  = 0;
  
  boolean recording = false;
  boolean enableRecording = false;
  boolean playing = false;
  int oldGoal = 0;
  boolean loop = false;
  int currFrame = 0;
  
  String oldModus = "none";
  
  float[] recordValues;
  int[] animValues;
  int currRec = 0;
  ServoKey[] recValue;
  long recframeTime;
  long playframeTime;
  long recRate = 25;
  long playRate = 25;
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
    if(jointwheelmode == 0) setWheelMode(false);
    else setWheelMode(true);

 }

  void setDxlId(int id)
  {
    if(dxlId>0)
    {
      comCM9.serialSend("WR "+dxlId+" 36\n"); //remove watch pos
      delay(10);
      comCM9.serialSend("WR "+dxlId+" 38\n"); //remove watch speed
      delay(10);
    }
    dxlId = id;
    if(dxlId>0)
    {
      comCM9.serialSend("EI "+index+" "+dxlId+"\n");
      delay(10);    
      //comCM9.serialSend("WA "+dxlId+" 36\n"); //add watch pos
      delay(10);
      //println("-> add watch speed");
      //comCM9.serialSend("WA "+dxlId+" 38\n"); //add watch speed
      delay(10);
      comCM9.serialSend("MR "+dxlId+" 6\n"); //CW min
      delay(10);
      comCM9.serialSend("MR "+dxlId+" 8\n"); //CCW max, to know Joint/Wheel Mode
      delay(10);
      comCM9.serialSend("MR "+dxlId+" 34\n"); //torque, to know if relaxed
    }
    
  }

  void stop()
  {  
     stopPlaying(true);     
     setSpeed(0); //!!! joint = speed max !!! 
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
    recording = true;
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
      recordValues = append(recordValues,(float)goal*2.0/1024.0-1.0);
      //println("record goal: " + goal);
    }
  }
  
  float[] stopRecording()
  {
    recording = false;
    currFrame = 0;
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
    playRate = (int)((float)recRate/speed);
    println("-> animation playrate = " + playRate);
    playing = true;
    currFrame = 0;
    oldGoal = goal;
    animValues = new int[val.length];
    for(int i=0; i< val.length; i++)
    {
      double v = val[i]; 
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
        setSpeed(v);
      }
      else
      {
        if((v+512) != goal)
        {
          setGoal(v);
        }
      }
    }
    else if(frame == animValues.length)
    {
      if(loop)
      {
        println("LOOP: anim is finished on servo " + index);
        currFrame = 0;
        if(anim != null)
        {
          anim.loopIsFinished();
        }
      }
      else
      {
        println("anim is finished on servo " + index);
        if(anim != null)
        {
           anim.playingIsFinished();
        }
        stopPlaying(true);
      }
    }
    
  }
  
  void tellToAnimServoIsFinished()
  {
    if(anim != null)
    {
      anim.servoStoppedPlaying(index);
    }
  }
  
  void stopPlaying(boolean resetVelocity)
  {
    playing = false;
    currFrame = 0;
    anim = null;
    if(isWheelMode() && resetVelocity)
    {
      setSpeed(0);
    }
    scriptArray.scriptAt(index).setReady(); 
  }


  void setLoop(boolean b)
  {
    loop = b;
  }
  
  
  void update()
  {
    
    if(recording)
    {
      long t = millis();    
      if( (t-recframeTime)>=recRate ) 
      {
        recframeTime = t;
        recordFrame();
        currFrame++;
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
    
    //because midi
    if(speed!=wantedSpeed)
    {
      speed=wantedSpeed;
      comCM9.serialSend("EW "+index+" 32 "+speed+"\n");
    }
    
  }

  void sendToken(int tok,int value)
  {
    comCM9.serialSend("A "+dxlId+" "+tok+" "+value+"\n"); //Token immediat      
  }
  
  //from sensor or midi //String allows labels
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
  
  //from sensor or midi //String allows labels
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
  
  void setGoal(int val)
  {
    //relax(false);
    val += 512;
    goal = val;
    comCM9.serialSend("EW "+index+" 30 "+val+"\n");
    delay(1);
  }
  
  void setSpeed(int val)
  {
    if(index==1)
      println("dbg speed2 "+val);
    
    speed = val;
    wantedSpeed = val;
    comCM9.serialSend("EW "+index+" 32 "+val+"\n");
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
      comCM9.serialSend("EW "+index+" 32 0\n" ); //speed
      delay(10);      
      comCM9.serialSend("EW "+index+" 34 0\n" ); //torque    
    }
    else
    {
      //TODO mettre goal à current position
      comCM9.serialSend("EW "+index+" 32 0\n" ); //speed
      delay(10);      
      comCM9.serialSend("EW "+index+" 34 "+torqueLimit+"\n" );      
    }
  }
  void setWheelMode(boolean wheel)
  {
    //println("setWheelMode "+wheel);
    if(!wheel)
    {
      println("JOINT ");
      mode = DXL_JOIN;
      comCM9.serialSend("EW "+index+" 6 "+minGoal+"\n" );
      delay(10);
      comCM9.serialSend("EW "+index+" 8 "+maxGoal+"\n" );
      delay(10);
      //TODO set goal to current pos
    }
    else
    {
      println("WHEEL ");
      mode = DXL_WHEEL;
      comCM9.serialSend("EW "+index+" 32 0\n" ); //moving speed à 0;
      speed = 0;
      delay(10);
      comCM9.serialSend("EW "+index+" 6 0\n" );
      delay(10);
      comCM9.serialSend("EW "+index+" 8 0\n" );
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
    comCM9.serialSend("MR "+dxlId+" 36 ");
  }
  
  
}
