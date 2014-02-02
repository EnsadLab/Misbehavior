class ServoGUIarray implements ControlListener
{
  ServoGUI[] servoGUIs;
  
  Toggle recButtonPlayPause;
  Button[] globalAnimPlayButtons; // Pas envie d'utiliser un toogle... expliquerai de vive voix pourquoi... 
  Button[] globalAnimStopButtons;
  JSONArray allVelocities;
  int xCurrAnimGui;
  int yCurrAnimGui;

  ServoGUIarray(int[] motorIds)
  {
    servoGUIs = new ServoGUI[motorIds.length];
    for(int i=0;i<motorIds.length;i++)
    {
      servoGUIs[i] = new ServoGUI(i,motorIds[i]);
    }    
  }

  // constructs the left part of the basic tab gui, global controllers
  void buildGlobalGui(int x, int y, String tabName)
  {
     Textlabel label = cp5.addTextlabel("RECORDING_global") // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Recording for all selected motors:\n------------------------------------------ ")
              .setPosition(x-5,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
              
     y += 40;
     recButtonPlayPause = cp5.addToggle("RECPLAY_global")
        .setPosition(x,y)
        .setColorActive(0xFFCC0000)
        .setSize(70,35)
        .moveTo(tabName)
        .setCaptionLabel("REC");
     recButtonPlayPause.getCaptionLabel().setFont(createFont("Verdana",14)).align(ControlP5.CENTER,ControlP5.CENTER);
     recButtonPlayPause.addListener(this);
     
     y += 60;
     label = cp5.addTextlabel("ANIMATIONS_global") // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Animations for all selected motors:\n------------------------------------------  ")
              .setPosition(x-5,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
              
     y += 40;
     
     globalAnimPlayButtons = new Button[nbGlobalAnimsMax];
     globalAnimStopButtons = new Button[nbGlobalAnimsMax];
     xCurrAnimGui = x;
     yCurrAnimGui = y;
     //for(int i=0; i<globalAnimPaths.length; i++) // car ne correspond pas a la liste actuelle... TODO: utiliser append a la place
     for(int i=0; i<nbGlobalAnims; i++)
     {  
       buildGlobalPlayAnimButtons(i,globalAnimPaths[i] + ":",tabName); 
     }
     
  }
  
  void buildGlobalPlayAnimButtons(int index, String textLabel, String tabName)
  {
     Textlabel label = cp5.addTextlabel("ANIMATION_global_"+index) 
              .setText(textLabel)
              .setPosition(xCurrAnimGui-5 ,yCurrAnimGui)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",13))
              .moveTo(tabName);
              ;
       yCurrAnimGui += 20;
       Button animButtonPlay = cp5.addButton("ANIMPLAY_global_"+index)
          .setPosition(xCurrAnimGui,yCurrAnimGui)
          .setColorActive(0xFFCC0000)
          .setSize(40,20)
          .moveTo(tabName)
          .setCaptionLabel("PLAY");
       animButtonPlay.getCaptionLabel().setFont(createFont("Verdana",11)).align(ControlP5.CENTER,ControlP5.CENTER);
       animButtonPlay.addListener(this);
       globalAnimPlayButtons[index] = animButtonPlay;
       //append(globalAnimPlayButtons,animButtonPlay);
       
       Button animButtonStop = cp5.addButton("ANIMSTOP_global_"+index)
          .setPosition(xCurrAnimGui+45,yCurrAnimGui)
          .setColorActive(0xFFCC0000)
          .setSize(40,20)
          .moveTo(tabName)
          .setCaptionLabel("STOP");
       animButtonStop.getCaptionLabel().setFont(createFont("Verdana",11)).align(ControlP5.CENTER,ControlP5.CENTER);
       animButtonStop.addListener(this);
       globalAnimStopButtons[index] = animButtonStop;
       //append(globalAnimStopButtons,animButtonStop);
       
       yCurrAnimGui += 25;

  }

  // constructs the right part of the basic tab gui, single controllers
  void buildBasicGui(int x,int y, String tabName)
  {
    for(int i=0;i<servoGUIs.length;i++)
    {
      servoGUIs[i].buildBasicGUI(x,y-5,tabName);
      y+=380;
    }
  }

  // constructs the advanced tab gui
  void buildGUI(int x,int y, String tabName)
  {
    for(int i=0;i<servoGUIs.length;i++)
    {
      servoGUIs[i].buildGUI(i, x,y,tabName);
      //y+=170;
      x+=350;
    }
  }
  
  void buildNewPlayAnimButton(String path)
  {
    for(int i=0;i<servoGUIs.length;i++)
    {
      servoGUIs[i].buildNewPlayAnimButton(i,path,tabNameBasic);
    }
  }


  void setDxlValue(int imot,int reg,int val)
  {
    if(val<0)
      return;
    
    for(int i=0;i<servoGUIs.length;i++) 
    {
      if(servoGUIs[i].motorId==imot)
        servoGUIs[i].setValue(reg,val);
    }        
  }

  void midiValue(int imot,int value)
  {
    try{servoGUIs[imot].midiValue( value ); }
    catch(Exception e){}
  }
  
  void update()
  {
    for(int i=0;i<servoGUIs.length;i++)
    { 
      servoGUIs[i].update();
    }
  }
  
  void startGlobalRecording()
  {
    for(int i=0;i<servoGUIs.length;i++)
    {
      // TODO: test if this motor is selected for recording
      ServoDxl servo = servoGUIs[i].getServo();
      if(servo != null)
      {
        servo.startRecording();
      }
    }
  }

  void stopGlobalRecording()
  {
    
    allVelocities = new JSONArray();
    for(int i=0;i<servoGUIs.length;i++) 
    {
      // TODO: test if this motor is selected for recording
      ServoDxl servo = servoGUIs[i].getServo();
      if(servo != null)
      {
        JSONArray velocities = servo.stopGlobalRecording();
        // for generating animations...
        /*JSONArray velocities = new JSONArray();
        int v = 0;
        for(int j=0; j<300; j++)
        {
          JSONObject vel = new JSONObject();
          vel.setInt("frame", j);
          if(i == 0)
            vel.setInt("vel", v);
          else
            vel.setInt("vel", 500-v);
           
          velocities.setJSONObject(j,vel);
          v += 2;
        }*/
        JSONObject anim = new JSONObject();
        anim.setInt("servoIndex", servoGUIs[i].servoIndex);
        anim.setJSONArray("frames",velocities);
        allVelocities.setJSONObject(i,anim);
      } 
    }
    int d = day();    // Values from 1 - 31
    int m = month();
    int s = second();  // Values from 0 - 59
    int min = minute();  // Values from 0 - 59
    int h = hour();    // Values from 0 - 23
    String path = "anims/globanim_" + d + "-"+ m + "_" + h + "-" + min + ".json";
    println("Saving animation into " + path);
    saveJSONArray(allVelocities, path);
    nbGlobalAnims++;
    if(nbGlobalAnims < nbGlobalAnimsMax)
    {
      globalAnimPaths[nbGlobalAnims-1] = path;
      buildGlobalPlayAnimButtons(nbGlobalAnims-1,path + ":",tabNameBasic); 
    }
  }

void startGlobalPlaying(String jsonFilenmame)
{
  allVelocities = loadJSONArray(jsonFilenmame);
  for(int i=0; i<allVelocities.size(); i++)
  {
     JSONObject anim = allVelocities.getJSONObject(i);
     int servoIndex = anim.getInt("servoIndex");
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       println("-> Starting animation on servoIndex " + servoIndex);
       servo.startPlaying(anim.getJSONArray("frames"));
     }  
  }
}


void stopGlobalPlaying()
{
  for(int i=0;i<servoGUIs.length;i++) // 
  {
    ServoDxl servo = servoGUIs[i].getServo();
    if(servo != null && servo.playing)
    {
      servo.stopPlaying();
    }
  }
}

  
  void controlEvent(ControlEvent evt)
  {
    if(!evt.isController())
      return;
      
    Controller c = evt.getController();
    //int id = c.getId();
    String addr = c.getAddress();
    if(addr.startsWith("/RECPLAY_global")) 
    {
      println("button RECORD GLOBAL PLAY" );
      if(recButtonPlayPause.getState())
      {
        println("start global recording");
        recButtonPlayPause.setCaptionLabel("STOP");
        startGlobalRecording();
      }
      else
      {
        println("stop recording");
        recButtonPlayPause.setCaptionLabel("REC");
        stopGlobalRecording(); 
      }
    }
    else if(addr.startsWith("/ANIMPLAY_global"))
    {
      for(int i=0; i<globalAnimPlayButtons.length; i++)
      {
        if(c == globalAnimPlayButtons[i])
        {
          startGlobalPlaying(globalAnimPaths[i]);
        }
      }
    }
    else if(addr.startsWith("/ANIMSTOP_global"))
    {
       stopGlobalPlaying();
    }
  }
  
};

class ServoGUI implements ControlListener
{
  int servoIndex = 0;
  int guiId = 0;
  int motorId = 0;
  int modeJoinWheel = 0;
  Textfield tfID;
  Toggle toggleRelax;
  Toggle toggleJoin;
  Knob knob;
  Knob watch;
  
  Toggle recButtonPlayPause;
  Button[] animPlayButtons; // Pas envie d'utiliser un toogle... expliquerai de vive voix pourquoi... 
  Button[] animStopButtons;
  int xCurrAnimGui;
  int yCurrAnimGui;
  int yAnimGui;

ServoGUI(int index,int dxlid)
{
  servoIndex = index;
  motorId = dxlid;
}

ServoDxl getServo()
{
  return servoArray.getByIndex(servoIndex);
}

void startRecording()
{
  if( motorId>0 ) // cbu: ce test est du coup inutile, non?
   {
     //ServoDxl servo = servoArray.getById(motorId);
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       servo.startRecording();
     }
   }
}

void stopRecording()
{
   if( motorId>0 )
   {
     //ServoDxl servo = servoArray.getById(motorId);
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       String newPath = servo.stopRecording();
       nbAnims++; // done here and not in buildNewPlayAnimButton... we want it to increment just once...
       servoGUIarray.buildNewPlayAnimButton(newPath);
     }
   }
}

void startPlaying(String filename)
{
  if( motorId>0 )
  {
     //ServoDxl servo = servoArray.getById(motorId);
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       println("-> Starting animation " + filename);
       servo.startPlaying(filename);
     }
   }
}


void stopPlaying()
{
  if( motorId>0 )
  {
     //ServoDxl servo = servoArray.getById(motorId);
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       println("-> Stop animation ");
       servo.stopPlaying();
     }
   }
}


void buildNewPlayAnimButton(int index, String animPath, String tabName)
{

     int i = nbAnims-1;
     animPaths[i] = animPath; // reservé au prealable nbAnimMax (18) valeurs
     
      if(i == 6 || i == 12)
      {
        xCurrAnimGui += 350;
        yCurrAnimGui = yAnimGui;
      } 
      
      int x = xCurrAnimGui;
      int y = yCurrAnimGui;
     
      Button animButtonPlay = cp5.addButton("ANIMPLAY"+index+"_"+i)
          .setPosition(x,y)
          .setColorActive(0xFFCC0000)
          .setSize(30,15)
          .moveTo(tabName)
          .setCaptionLabel("PLAY");
       animButtonPlay.getCaptionLabel().setFont(createFont("Verdana",10)).align(ControlP5.CENTER,ControlP5.CENTER);
       animButtonPlay.addListener(this);
       animPlayButtons[i] = animButtonPlay;
       
       Button animButtonStop = cp5.addButton("ANIMSTOP"+index+"_"+i)
          .setPosition(x+35,y)
          .setColorActive(0xFFCC0000)
          .setSize(30,15)
          .moveTo(tabName)
          .setCaptionLabel("STOP");
       animButtonStop.getCaptionLabel().setFont(createFont("Verdana",10)).align(ControlP5.CENTER,ControlP5.CENTER);
       animButtonStop.addListener(this);
       animStopButtons[i] = animButtonStop;
       Textlabel label = cp5.addTextlabel("ANIMATION"+index+"_"+i) 
              .setText(animPaths[i])
              .setPosition(x + 70,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",12))
              .moveTo(tabName);
              ;
       
       y += 25;
       
       xCurrAnimGui = x;
       yCurrAnimGui = y;
     
}

void buildBasicGUI(int x,int y, String tabName)
{
  Textlabel label = cp5.addTextlabel("MOTORBASIC"+servoIndex) // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("MOTOR id "+motorId +"\n---------------------------------------------------------------------------------------------------------------------------------------------")
              .setPosition(x,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
    
    
     
     /*recButtonStop = cp5.addButton("RECSTOP"+index)
        .setPosition(posRecButton+55,y-5)
        .setColorActive(0xFFCC0000)
        .setSize(50,25)
        .moveTo(tabName)
        .setCaptionLabel("STOP");
     recButtonStop.getCaptionLabel().setFont(createFont("Verdana",12)).align(ControlP5.CENTER,ControlP5.CENTER);
     recButtonStop.addListener(this);
     */
     
  
              
  y += 50;
  label = cp5.addTextlabel("position"+servoIndex)
          .setText("Position:")
          .setPosition(x,y)
          .setColorValue(0xFF000000)
          .setFont(createFont("Verdana",14))
          .moveTo(tabName);
          ;  
          
   Knob knobPosition = cp5.addKnob("POSITIONKNOB"+servoIndex)
             .setId(globalID++)
             .setPosition(x,y+60)
             .setRadius(80)
             .setRange(-512,512)
             .setValue(0)
             //.hideTickMarks()
             .setNumberOfTickMarks(4)
             .setTickMarkLength(5)
             .snapToTickMarks(false)
             //.setColorForeground(color(150))
             //.setColorBackground(color(220, 220, 220))
             //.setColorActive(color(100,100,100))
             .setDragDirection(Knob.VERTICAL)
             //.setConstrained(false)
             .setShowAngleRange(false) //?
             //.setViewStyle(Knob.ELLIPSE )
             .setViewStyle(Knob.ARC )
             .moveTo(tabName);
             ;
    knobPosition.getCaptionLabel().align(ControlP5.CENTER,ControlP5.BOTTOM);
    knobPosition.getCaptionLabel().setText("");
   
    knobPosition.addListener(this);
  
    //x += 230;        
    label = cp5.addTextlabel("velocity"+servoIndex)
          .setText("Velocity:")
          .setPosition(x-5,y+240)
          .setColorValue(0xFF000000)
          .setFont(createFont("Verdana",14))
          .moveTo(tabName);
          ;
          
   Slider slider = cp5.addSlider("SLIDERVEL"+servoIndex)
     .setPosition(x,y+30+240)
     .setSize(850,25)
     .setRange(-512,512)
     .setValue(0)
     .moveTo(tabName)
     //.showTickMarks(true);
     //.setNumberOfTickMarks(1024)
     ;
    slider.addListener(this);
    
    //slider.getValueLabel().setColor(0xFF000000);//.align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    //slider.getCaptionLabel().setColorValue(0xFFFF0000).align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  
    x += 280;
    label = cp5.addTextlabel("RECORDING"+servoIndex) // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Recording: ")
              .setPosition(x,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
              
     recButtonPlayPause = cp5.addToggle("RECPLAY"+servoIndex)
        .setPosition(x+150,y-5)
        .setColorActive(0xFFCC0000)
        .setSize(50,25)
        .moveTo(tabName)
        .setCaptionLabel("REC");
     recButtonPlayPause.getCaptionLabel().setFont(createFont("Verdana",12)).align(ControlP5.CENTER,ControlP5.CENTER);
     recButtonPlayPause.addListener(this);
     
     y += 50;
     label = cp5.addTextlabel("ANIMATIONS"+servoIndex) // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Animations: ")
              .setPosition(x,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
     
     
     animPlayButtons = new Button[nbAnimsMax];
     animStopButtons = new Button[nbAnimsMax];
     
     y += 40;
     yAnimGui = y;
     x += 5;
     //for(int i=0; i<animPaths.length; i++) // car ne correspond pas a la liste actuelle... TODO: utiliser append a la place
     for(int i=0; i<nbAnims; i++)
     {
     
      if(i == 6 || i == 12)
      {
        x += 350;
        y = yAnimGui;
      } 
     
       Button animButtonPlay = cp5.addButton("ANIMPLAY"+servoIndex+"_"+i)
          .setPosition(x,y)
          .setColorActive(0xFFCC0000)
          .setSize(30,15)
          .moveTo(tabName)
          .setCaptionLabel("PLAY");
       animButtonPlay.getCaptionLabel().setFont(createFont("Verdana",10)).align(ControlP5.CENTER,ControlP5.CENTER);
       animButtonPlay.addListener(this);
       animPlayButtons[i] = animButtonPlay;
       
       Button animButtonStop = cp5.addButton("ANIMSTOP"+servoIndex+"_"+i)
          .setPosition(x+35,y)
          .setColorActive(0xFFCC0000)
          .setSize(30,15)
          .moveTo(tabName)
          .setCaptionLabel("STOP");
       animButtonStop.getCaptionLabel().setFont(createFont("Verdana",10)).align(ControlP5.CENTER,ControlP5.CENTER);
       animButtonStop.addListener(this);
       animStopButtons[i] = animButtonStop;
       
       label = cp5.addTextlabel("ANIMATION"+servoIndex+"_"+i) 
              .setText(animPaths[i])
              .setPosition(x + 70,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",12))
              .moveTo(tabName);
              ;
       
       y += 25;
     }
     xCurrAnimGui = x;
     yCurrAnimGui = y;
}


void buildGUI(int index,int x,int y,String tabName)
{
  int id0 = globalID;
    Textfield tfID =cp5.addTextfield("MOTOR"+index)
    .setId(globalID++)
    .setPosition(x,y)
    .setWidth(30)
    .setInputFilter(Textfield.INTEGER)
    .setAutoClear(false)
    .moveTo(tabName);
   tfID.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
   //tfID.getCaptionLabel().setText("MOTOR "+imot+" ");
   tfID.setValue(""+motorId);
   tfID.addListener(this);

  toggleJoin = cp5.addToggle("JOIN"+index)
       .setId(globalID++)
       .setPosition(x+35,y)
       .setWidth(30)
       .moveTo(tabName);
   toggleJoin.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   toggleJoin.getCaptionLabel().setText("JOIN");
   toggleJoin.addListener(this);


  toggleRelax = cp5.addToggle("RELAX"+index)
       .setId(globalID++)
       .setPosition(x+72,y)
       .setWidth(40)
       .moveTo(tabName);
   toggleRelax.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   toggleRelax.getCaptionLabel().setText("RELAX");
   toggleRelax.addListener(this);


  y+=30;
  watch = cp5.addKnob("watch"+index)
               .setId(globalID++)
               .setPosition(x,y)
               .setRange(511,-512)
               .setRadius(44)
               .setTickMarkWeight(5)
               .hideTickMarks()
               .setShowAngleRange(false)
               .setColorActive(color(255,255,0))
               .setColorForeground(color(255,255,0))
               .setViewStyle(Knob.LINE )
               .moveTo(tabName);
    //knob.getCaptionLabel().align(ControlP5.CENTER,ControlP5.BOTTOM);
    //knob.getCaptionLabel().setText("position");
    watch.getCaptionLabel().hide();
  
   knob = cp5.addKnob("Knob"+index)
               .setId(globalID++)
               .setPosition(x+4,y+4)
               .setRadius(40)
               .setRange(511,-512)
               .setValue(512)
               //.hideTickMarks()
               .setNumberOfTickMarks(4)
               .setTickMarkLength(5)
               .snapToTickMarks(false)
               //.setColorForeground(color(255))
               //.setColorBackground(color(0, 160, 100))
               //.setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
               //.setConstrained(false)
               .setShowAngleRange(false) //?
               .setViewStyle(Knob.ARC )
               .moveTo(tabName);
               
    knob.getCaptionLabel().align(ControlP5.CENTER,ControlP5.BOTTOM);
    knob.getCaptionLabel().setText("position");
 
    knob.addListener(this);
}

void update()
{
}

void midiValue(int value)
{
  //scriptConsole.append("midi "+value);
  knob.setValue( -(value-64)<<3);
}

//AREVOIR
void setValue(int reg,int value)
{
  if(reg==8) //CCW limit
  {
    //assume re6 == 0
    if(value==0)modeJoinWheel=1;
    else modeJoinWheel = 0;
    toggleJoin.setState(modeJoinWheel==1);
  }
  else if(reg==34)//torque limit
  {
    if(value==0)toggleRelax.setState(true);
    else toggleRelax.setState(false);
  }
  
  if( modeJoinWheel == 0) //JOINT
  {
    //if(reg==30)knob.setValue(value-512); //provoque event knob >> envoit
    if(reg==36)watch.setValue(value-512);
  }
  else //AREVOIR
  {
    if(reg==38)
    {
      if(value<1024)
        watch.setValue( value>>1 );
      else
        watch.setValue( -((value-1024)>>1) );
    }    
  }
  
}

void controlEvent(ControlEvent evt)
{
  if(!evt.isController())
    return;
      
  Controller c = evt.getController();
  //int id = c.getId();
  String addr = c.getAddress();
  if(addr.startsWith("/MOTOR"))  //ID
  {
    //ServoDxl servo = servoArray.getById(motorId);
    ServoDxl servo = servoArray.getByIndex(servoIndex);
    if(servo!=null)
    {
      motorId = Integer.parseInt(c.getStringValue());
      servo.setDxlId(motorId);
    }
    else
    {
      motorId=0;
      c.setStringValue("0");
    } 
  }
  else if(addr.startsWith("/Knob") )
  { 
     if( motorId>0 )
     {
       //println("KNOB "+motorId);
       int value = (int)c.getValue();
       //ServoDxl servo = servoArray.getById(motorId);
       ServoDxl servo = servoArray.getByIndex(servoIndex);
       if(servo != null)
         servo.setKnobValue( value );
       midiCtrlChange(servoIndex+1,64-(value>>3));
       
     }
  }
  else if(addr.startsWith("/JOIN")  )
  { 
     if( motorId>0 )
     {
       //ServoDxl servo = servoArray.getById(motorId);
      ServoDxl servo = servoArray.getByIndex(servoIndex);
       if(servo != null)
         servo.setWheelMode( toggleJoin.getValue() > 0.5 );
     }
     if( toggleJoin.getValue() > 0.5 )
     {
        c.getCaptionLabel().setText("WHEEL");
        modeJoinWheel = 1;
        knob.setValue(0);
     }
     else
     {
        c.getCaptionLabel().setText("JOIN");
        modeJoinWheel = 0;
        knob.setValue(0);
     }
  }  
  else if(addr.startsWith("/RELAX") )
  { 
     if( motorId>0 )
     {
       //ServoDxl servo = servoArray.getById(motorId);
       ServoDxl servo = servoArray.getByIndex(servoIndex);
       if(servo != null)
         servo.relax( c.getValue() > 0.5 );
     }
  }
    else if(addr.startsWith("/RECPLAY"))
    {
      println("button RECORD PLAY on motor with id " + motorId );
      if(recButtonPlayPause.getState())
      {
        println("start recording");
        recButtonPlayPause.setCaptionLabel("STOP");
        startRecording();
      }
      else
      {
        println("stop recording");
        recButtonPlayPause.setCaptionLabel("REC");
        stopRecording(); // for now, later should call pauseRecording() perhaps...
      }
    }
    /*else if(addr.startsWith("/RECSTOP"))
    {
      println("button RECORD STOP on motor with id " + motorId );
      recButtonPlayPause.setCaptionLabel("REC");
      recButtonPlayPause.setState(false);
      stopRecording();
    }*/
    else if(addr.startsWith("/SLIDERVEL"))
    {
       if( motorId>0 )
       {
         //DxlServo servo = servoArray.getServo(motorId);
         ServoDxl servo = servoArray.getByIndex(servoIndex);
         if(servo != null)
         {
           if(!servo.isWheelMode())
           {
             servo.setWheelMode(true);
           }
           servo.setKnobValue( (int)c.getValue() );
         }
       }
    }
    else if(addr.startsWith("/POSITIONKNOB"))
    {
       if( motorId>0 )
       {
         //DxlServo servo = servoArray.getServo(motorId);
         ServoDxl servo = servoArray.getByIndex(servoIndex);
         if(servo != null)
         {
           if(servo.isWheelMode())
           {
             servo.setWheelMode(false);
           }
           servo.setKnobValue( (int)c.getValue() );
         }
       }
    }
    else if(addr.startsWith("/ANIMPLAY"))
    {
      for(int i=0; i<animPlayButtons.length; i++)
      {
        if(c == animPlayButtons[i])
        {
          startPlaying(animPaths[i]);
        }
       //startPlaying("anims/anim.json"); 
      }
    }
    else if(addr.startsWith("/ANIMSTOP"))
    {
       stopPlaying();
    }

}



  
};
