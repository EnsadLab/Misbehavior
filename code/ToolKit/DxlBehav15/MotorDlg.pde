class MotorGroup
{
  MotorDlg[] motors;

  MotorGroup(int nbm)
  {
    motors = new MotorDlg[4];
    for(int i=0;i<nbm;i++)
    {
      motors[i] = new MotorDlg();
      motors[i].index = i;
    }    
  }

  void buildGUI(int x,int y)
  {
    for(int i=0;i<motors.length;i++)
    {
      motors[i].buildGUI(i, x,y);
      //y+=170;
      x+=200;
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

  void midiValue(int imot,int value)
  {
    try{motors[imot].midiValue( value ); }
    catch(Exception e){}
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
  int index = 0;
  int guiId = 0;
  int motorId = 0;
  int modeJoinWheel = 0;
  Textfield tfID;
  Toggle toggleRelax;
  Toggle toggleJoin;
  Knob knob;
  Knob watch;
  

void buildGUI(int index,int x,int y)
{
  int id0 = globalID;
    Textfield tfID =cp5.addTextfield("MOTOR"+index)
    .setId(globalID++)
    .setPosition(x,y)
    .setWidth(30)
    .setInputFilter(Textfield.INTEGER)
    .setAutoClear(false);
   tfID.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
   //tfID.getCaptionLabel().setText("MOTOR "+imot+" ");
   tfID.addListener(this);

  toggleJoin = cp5.addToggle("JOIN"+index)
       .setId(globalID++)
       .setPosition(x+35,y)
       .setWidth(30);
   toggleJoin.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   toggleJoin.getCaptionLabel().setText("JOIN");
   toggleJoin.addListener(this);


  toggleRelax = cp5.addToggle("RELAX"+index)
       .setId(globalID++)
       .setPosition(x+72,y)
       .setWidth(40);
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
               .setViewStyle(Knob.LINE );
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
               ;
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
  if(evt.isGroup()) //GRR reçoit tout ???
    return;
      
  Controller c = evt.getController();
  //int id = c.getId();
  String addr = c.getAddress();
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
       //println("KNOB "+motorId);
       int value = (int)c.getValue();
       DxlServo servo = servoArray.getServo(motorId);
       if(servo != null)
         servo.setKnobValue( value );
       midiCtrlChange(index+1,64-(value>>3));
       
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
}



  
};
