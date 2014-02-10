
int motorColumnWidth;

class ServoGUIarray
{
  ServoGUI[] servoGUIs;

  ServoGUIarray(int[] motorIds, int[] jointwheelmode)
  {
    servoGUIs = new ServoGUI[motorIds.length];
    for(int i=0;i<motorIds.length;i++)
    {
      servoGUIs[i] = new ServoGUI(i,motorIds[i], jointwheelmode[i]);
    }    
  }
  
  
  void buildMotorGui(int x, int y, String tabName)
  {
    
    motorColumnWidth = 0;
    for(int i=0;i<servoGUIs.length;i++)
    {
      servoGUIs[i].buildMotorGUI(x,y-5,tabName);
      x+=30;
      motorColumnWidth += 30;
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
  Slider advSliderSpeed;
  Slider advSliderWheel;
  //Knob watch;
 

ServoGUI(int index,int dxlid, int joinwheel)
{
  servoIndex = index;
  motorId = dxlid;
  modeJoinWheel = joinwheel;
}

ServoDxl getServo()
{
  return servoArray.getByIndex(servoIndex);
}


void buildMotorGUI(int x, int y, String tabName)
{
    Slider slider = cp5.addSlider("SLIDERMOTORVAL"+servoIndex)
     .setPosition(x,y)
     .setSize(20,150)
     .setRange(-1023,1023)
     .setValue(0)
     .moveTo(tabName)
     .setColorForeground(0xFF792e3f)
     .setColorBackground(0xFFE3E3E3)
     .setColorActive(0xFFFF0000)
     //.showTickMarks(true);
     //.setNumberOfTickMarks(1024)
     ;
    slider.addListener(this);
    
    slider.getValueLabel().setColor(0xFFFF0000).setFont(createFont("Verdana",8)).align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);//.setPaddingX(2);
    //slider.getValueLabel().setColor(0xFF000000);//.align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    if(modeJoinWheel == 0)
    {
      slider.getCaptionLabel().setColor(0xFFFFFFFF).setFont(createFont("Verdana",14)).setText("J").align(ControlP5.CENTER, ControlP5.BOTTOM);//.setOffsetY(-20);
    }
    else
    {
      slider.getCaptionLabel().setColor(0xFFFFFFFF).setFont(createFont("Verdana",14)).setText("W").align(ControlP5.CENTER, ControlP5.BOTTOM);//.setOffsetY(-20);
    }  
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
   tfID.getCaptionLabel().align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER);
   //tfID.getCaptionLabel().setText("MOTOR "+imot+" ");
   tfID.setValue(""+motorId);
   tfID.addListener(this);

  toggleJoin = cp5.addToggle("JOIN"+index)
       .setId(globalID++)
       .setPosition(x,y+20)
       .setSize(40,22)
       .moveTo(tabName);
   toggleJoin.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   toggleJoin.getCaptionLabel().setText("JOIN");
   toggleJoin.addListener(this);

  toggleRelax = cp5.addToggle("RELAX"+index)
       .setId(globalID++)
       .setPosition(x+250,y)
       .setSize(50,50)
       .moveTo(tabName);
   toggleRelax.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   toggleRelax.getCaptionLabel().setText("RELAX");
   toggleRelax.addListener(this);

  //y+=30;
  /*
  watch = cp5.addKnob("watch"+index)
               .setId(globalID++)
               .setPosition(x+100,y)
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
  */
   knob = cp5.addKnob("Knob"+index)
               .setId(globalID++)
               .setPosition(x+120,y)
               .setRadius(30)
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
    
    advSliderSpeed = cp5.addSlider("ADVSPEED"+servoIndex)
     .setPosition(x,y+65)
     .setSize(300,15)
     .setRange(0,1024)
     .setValue(0)
     .moveTo(tabName)
     .addListener(this);
    advSliderSpeed.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setText("SPEED");
    
    advSliderWheel = cp5.addSlider("ADVWHEEL"+servoIndex)
     .setPosition(x,y+85)
     .setSize(300,15)
     .setRange(-1024,1024)
     .setValue(0)
     .moveTo(tabName)
     .addListener(this);
    advSliderWheel.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setText("WHEEL");
    

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
/*  
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
*/  
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
       //  servo.setKnobValue( value );
         servo.setGoal(value+512);
       //midiCtrlChange(servoIndex+1,64-(value>>3));
     }
  }
  else if(c==advSliderSpeed)
  {
    ServoDxl servo = servoArray.getByIndex(servoIndex);
    if(servo != null)
      servo.setSpeed((int)c.getValue());
  }
  else if(c==advSliderWheel)
  {
    ServoDxl servo = servoArray.getByIndex(servoIndex);
    if(servo != null)
      servo.setWheelSpeed((int)c.getValue());
  }
  
  else if(addr.startsWith("/JOIN")  )
  { 
     if( motorId>0 )
     {
       ServoDxl servo = servoArray.getByIndex(servoIndex);
       if(servo != null)
         servo.setWheelMode( toggleJoin.getValue() > 0.5 );
     }
     if( toggleJoin.getValue() > 0.5 )
     {
        c.getCaptionLabel().setText("WHEEL");
        modeJoinWheel = 1;
        //knob.setValue(0);
     }
     else
     {
        c.getCaptionLabel().setText("JOIN");
        modeJoinWheel = 0;
        //knob.setValue(0);
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
  else if(addr.startsWith("/SLIDERMOTORVAL"))
  {
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       if(servo.isWheelMode())
       {
         servo.setSpeed( (int)c.getValue());
       }
       else
       {
         servo.setGoal( (int)c.getValue());
       }
     }
  }

}



  
};
