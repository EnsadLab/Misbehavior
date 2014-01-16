class MotorGroup
{
  MotorDlg[] motors;

  MotorGroup(int[] motorIds)
  {
    motors = new MotorDlg[motorIds.length];
    for(int i=0;i<motorIds.length;i++)
      motors[i] = new MotorDlg(motorIds[i]);    
  }
  
  void buildBasicGui(int x,int y, String tabName)
  {
    for(int i=0;i<motors.length;i++)
    {
      motors[i].buildBasicGUI(i,x,y-5,tabName);
      y+=380;
    }
  }

  void buildGUI(int x,int y, String tabName)
  {
    for(int i=0;i<motors.length;i++)
    {
      motors[i].buildGUI(i, x,y,tabName);
      y+=170;
    }
  }
  
  void buildNewPlayAnimButton(String path)
  {
    for(int i=0;i<motors.length;i++)
    {
      motors[i].buildNewPlayAnimButton(i,path,tabNameBasic);
    }
  }

  void setValue(int imot,int reg,int val)
  {
    for(int i=0;i<motors.length;i++) 
    {
      if(motors[i].motorId==imot)
        motors[i].setValue(reg,val);
    }        
  }
  
  void update()
  {
    for(int i=0;i<motors.length;i++)
    { 
      motors[i].update();
    }
  }
  
};

class MotorDlg implements ControlListener
{
  int guiId = 0;
  int motorId = 0;
  int modeJoinWheel = 0;
  Textfield tfID;
  Toggle toggleRelax;
  Toggle toggleJoin;
  Knob knob;
  Knob watch;
  Toggle recButtonPlayPause;
  //Button recButtonStop;
  
  Button[] animPlayButtons; // Pas envie d'utiliser un toogle... expliquerai de vive voix pourquoi... 
  Button[] animStopButtons;
  int xCurrAnimGui;
  int yCurrAnimGui;
  int yAnimGui;
  
  MotorDlg(int id)
  {
    motorId = id;
  }
  
  
void startRecording()
{
  if( motorId>0 )
   {
     DxlServo servo = servoArray.getServo(motorId);
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
     DxlServo servo = servoArray.getServo(motorId);
     if(servo != null)
     {
       String newPath = servo.stopRecording();
       nbAnims++; // done here and not in buildNewPlayAnimButton... we want it to increment just once...
       motorGroup.buildNewPlayAnimButton(newPath);
     }
   }
}


void startPlaying(String filename)
{
  if( motorId>0 )
  {
     DxlServo servo = servoArray.getServo(motorId);
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
     DxlServo servo = servoArray.getServo(motorId);
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

void buildBasicGUI(int index,int x,int y, String tabName)
{
  Textlabel label = cp5.addTextlabel("MOTORBASIC"+index) // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
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
  label = cp5.addTextlabel("position"+index)
          .setText("Position:")
          .setPosition(x,y)
          .setColorValue(0xFF000000)
          .setFont(createFont("Verdana",14))
          .moveTo(tabName);
          ;  
          
   Knob knobPosition = cp5.addKnob("POSITIONKNOB"+index)
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
    label = cp5.addTextlabel("velocity"+index)
          .setText("Velocity:")
          .setPosition(x-5,y+240)
          .setColorValue(0xFF000000)
          .setFont(createFont("Verdana",14))
          .moveTo(tabName);
          ;
          
   Slider slider = cp5.addSlider("SLIDERVEL"+index)
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
    label = cp5.addTextlabel("RECORDING"+index) // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Recording: ")
              .setPosition(x,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
              
     recButtonPlayPause = cp5.addToggle("RECPLAY"+index)
        .setPosition(x+150,y-5)
        .setColorActive(0xFFCC0000)
        .setSize(50,25)
        .moveTo(tabName)
        .setCaptionLabel("REC");
     recButtonPlayPause.getCaptionLabel().setFont(createFont("Verdana",12)).align(ControlP5.CENTER,ControlP5.CENTER);
     recButtonPlayPause.addListener(this);
     
     y += 50;
     label = cp5.addTextlabel("ANIMATIONS"+index) // we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
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
     //for(int i=0; i<animPaths.length; i++) // car ne correspond pas a la liste actuelle... ok je vais faire un vecteur... fais a la vite...
     for(int i=0; i<nbAnims; i++)
     {
     
      if(i == 6 || i == 12)
      {
        x += 350;
        y = yAnimGui;
      } 
     
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
       
       label = cp5.addTextlabel("ANIMATION"+index+"_"+i) 
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

void buildGUI(int index,int x,int y, String tabName)
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
               ;
    knob.getCaptionLabel().align(ControlP5.CENTER,ControlP5.BOTTOM);
    knob.getCaptionLabel().setText("position");
 
    knob.addListener(this);
}

void update()
{
}

void setValue(int reg,int value)
{
  if( modeJoinWheel == 0) //JOIN
  {
    if(reg==30)knob.setValue(value-512);
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
  if(evt.isGroup()) //GRR reçoit tout ???
    return;
  else if(evt.isController())  // cbu: added this check otherwise we get a nullpointerexception
  {   
    
    Controller c = evt.getController();
    //int id = c.getId();
    String addr = c.getAddress();
    println("ADDR: " + addr);
    if(addr.startsWith("/MOTOR"))  //ID
    {
      //find previous servo (or free one)... and change ID
      DxlServo servo = servoArray.getServo(motorId);
      if(servo!=null)
      {
        motorId = Integer.parseInt(c.getStringValue());
        servo.setId(motorId);
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
         DxlServo servo = servoArray.getServo(motorId);
         if(servo != null)
           servo.setKnobValue( (int)c.getValue() );
       }
    }
    else if(addr.startsWith("/JOIN")  )
    { 
       if( motorId>0 )
       {
         DxlServo servo = servoArray.getServo(motorId);
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
         DxlServo servo = servoArray.getServo(motorId);
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
         DxlServo servo = servoArray.getServo(motorId);
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
         DxlServo servo = servoArray.getServo(motorId);
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
}



  
};
