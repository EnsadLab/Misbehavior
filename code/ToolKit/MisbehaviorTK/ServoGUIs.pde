
int motorColumnWidth;

class ServoGUIarray implements ControlListener
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
      servoGUIs[i].buildMotorGUI(x,y,tabName);
      x+=30;
      motorColumnWidth += 30;
    }
    motorColumnWidth -= 10;
    
  }

  // constructs the advanced tab gui
  void buildGUI(int x,int y, String tabName)
  {
    int nbServos = servoArray.getNbServos();
    
    int ix=300;
    for(int i=0;i<nbServos;i++)
    {
      Textfield tfID =cp5.addTextfield("DXLID"+i)
      .setId(i)
      .setPosition(ix,20)
      .setWidth(30)
      .setInputFilter(Textfield.INTEGER)
      .setAutoClear(false)
      .setValue( ""+servoArray.getByIndex(i).dxlId )
      .moveTo(tabName);
     tfID.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER)
         .setText(" MOTOR  "+i+"  ").setColor(0xFF000000)
         ;//.setValue("?");
     tfID.addListener(this);
     ix+=120;
    }
        
    /* //DIB CLEAN ... ....  
    for(int i=0;i<servoGUIs.length;i++)
    {
      servoGUIs[i].buildGUI(i, x,y,tabName);
      //y+=170;
      x+=350;
    }
    */
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
  
  void midiValue( int imotor, float val )
  {
    try
    {
      servoGUIs[imotor].midiValue( val ); 
    }
    catch(Exception e){}
  }
  
  void update()
  {
    for(int i=0;i<servoGUIs.length;i++)
    { 
      servoGUIs[i].update();
    }
  }
  
  void controlEvent(ControlEvent evt)
  {
    if(!evt.isController())
      return;
      
   
    Controller c = evt.getController();
    //int id = c.getId();
    String addr = c.getAddress();
    if(addr.startsWith("/SPEED"))
    {
      println("speed selected");
    }
    else if(addr.startsWith("/DXLID"))
    {
      int num = c.getId();
      int dxlid   = Integer.parseInt(c.getStringValue());
      println("dbg DXLID"+c.getId()+" : "+dxlid);
      {
        ServoDxl servo = servoArray.getByIndex(num);
        if(servo!=null)
          servo.setDxlId(dxlid);
      }
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
  //Slider advSliderGoal;
  //Slider advSliderSpeed;
  //Slider advSliderWheel;
  Button stopVelocityButton;
  Slider sliderWheelGoal;
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
  
    
   stopVelocityButton = cp5.addButton("STOPBUTTON"+servoIndex)
                .setPosition(x,y-30)
                .setSize(20,20)
                .moveTo(tabName)
                .setImages(loadImage("stopVelButtonOff.jpg"),loadImage("stopVelButtonOver.jpg"),loadImage("stopVelButtonOn.jpg"))
                .addListener(this)
                ;
  
    sliderWheelGoal = cp5.addSlider("SLIDERMOTORVAL"+servoIndex)
     .setPosition(x,y)
     .setSize(20,150)
     .setValue(0)
     .moveTo(tabName)
     .setColorForeground(0xFF792e3f)
     .setColorBackground(0xFFE3E3E3)
     .setColorActive(0xFFFF0000)
     //.showTickMarks(true);
     //.setNumberOfTickMarks(1024)
     ;
    if(modeJoinWheel == 0) // JOINT
    {
      sliderWheelGoal.setRange(-512,512);
    }
    else // WHEEL
    {
      sliderWheelGoal.setRange(-1023,1023);
    }
    sliderWheelGoal.addListener(this);
    
    sliderWheelGoal.getValueLabel().setColor(0xFFFF0000).setFont(createFont("Verdana",8)).align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);//.setPaddingX(2);
    //slider.getValueLabel().setColor(0xFF000000);//.align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
    if(modeJoinWheel == 0)
    {
      sliderWheelGoal.getCaptionLabel().setColor(0xFFFFFFFF).setFont(createFont("Verdana",14)).setText("J").align(ControlP5.CENTER, ControlP5.BOTTOM);//.setOffsetY(-20);
    }
    else
    {
      sliderWheelGoal.getCaptionLabel().setColor(0xFFFFFFFF).setFont(createFont("Verdana",14)).setText("W").align(ControlP5.CENTER, ControlP5.BOTTOM);//.setOffsetY(-20);
    }  
}


void buildGUI(int index,int x,int y,String tabName)
{
  //CLEAN ... ... ...
  /*
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
//  y+=70;
  */  

}

void update()
{
}

void midiValue(float value)
{
  //scriptConsole.append("midi "+value);
  if(modeJoinWheel == 0)
  {
    sliderWheelGoal.setValue(value*512.0);
  }
  else
  {
    sliderWheelGoal.setValue(value*1024.0);
  }
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
  /*
  else if(c==advSliderSpeed)
  {
    println("dbg slider speed");
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
  */
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
  else if(addr.startsWith("/STOPBUTTON"))
  {
    if(sliderWheelGoal != null)
    {
      sliderWheelGoal.setValue(0); 
    }
  }
  else if(addr.startsWith("/SLIDERMOTORVAL"))
  {
     ServoDxl servo = servoArray.getByIndex(servoIndex);
     if(servo != null)
     {
       if(servo.isWheelMode())
       {
         if(servo.playing) // stop the animation if there is one running TODO: do it also when controlling from MIDI         
         {
           servo.tellToAnimServoIsFinished();
           servo.stopPlaying(false);
         }
         servo.setSpeed( (int)c.getValue()*servo.wheelDirection );
       }
       else
       {
         if(servo.playing) // stop the animation if there is one running TODO: do it also when controlling from MIDI    
         {
           servo.tellToAnimServoIsFinished();
           servo.stopPlaying(false);
         }
         servo.setGoal( (int)c.getValue());
       }
     }
  }
}




  
};
