

class DxlValue
{
  int index = 0;
  int iMotor = 0; //>adrr
  int registre = 0; //
  int value = 0;
  int valueMin = 0;
  int valueMax = 0;
  String label;
  Textfield textField;

  DxlValue(int reg,String name,int min,int max)
  {
    registre = reg;
    label = name;
    valueMin = min;
    valueMax = max;
  }
 
  Textfield addControl(int idx,int x,int y,int h,Group group)
  {
    //cp5.addSlider(label).setPosition(x,y).setRange(0,1000);
    index = idx;
    
    Textfield tf =    
     cp5.addTextfield("M"+iMotor+"/"+registre)
         .setId(globalID++)
         .setText("0") 
         .setPosition(x,y)
         .setSize(30,h)
         .setColorBackground(color(128))
         .setColorForeground(color(128))
         .setGroup(group);
         //.moveTo(tabName);
         
     tf.setInputFilter(Textfield.INTEGER);
     tf.setAutoClear(false);
         
     Label lbl = tf.getCaptionLabel();
     lbl.align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
     lbl.setFont(courrierFont);
     lbl.setText(label+" "+registre+":");
     lbl.setColor(0xFF000000);     
     textField = tf;
     return tf;
  }  
}; //DXLvalue


//==========================================================
class DxlControl implements ControlListener //CallbackListener
{
  int startID = 0;
  int endID = 0;
  int currentMotor = 17;
  DxlValue[] dxlValues;
  int action = 0;
  int currIndex = 0;
  //int[] dxlRegs = new int[10];
  

 DxlControl()
 {

  dxlValues = new DxlValue[]
  {
    //DXLvalue(int reg,String name,int min,int max)
    new DxlValue( 0," Model",0,1024),
    new DxlValue( 2," Firmware",0,1024),
    new DxlValue( 3," ID",0,1024), //RW 254=broadcast
    new DxlValue( 4," Baudrate",0,1024), //RW               1
    new DxlValue( 5," Return Delay",0,1024),//      250
    new DxlValue( 6," CW  Min",0,1024),//        0
    new DxlValue( 8," CCW Max",0,1024),//        0x3FF
    new DxlValue(11," Temp Max",0,1024),       // RW high limittemperature 70
    new DxlValue(12," Volt Min",0,1024),       // RW lowest limit voltage   60
    new DxlValue(13," Volt Max",0,1024),       // RW highest limit voltage  140
    new DxlValue(14," Torque Max",0,1024),     // RW Max Torque             0x3F36F
    new DxlValue(16," Status",0,1024),         // RW Status return Level    2
    new DxlValue(17," Alarm Led",0,1024),      // RW Arlarm Led             36
    new DxlValue(18," Alarm Shutdown",0,1024), // RW Alarm Shutdown         36
    //RAM
    new DxlValue(24," Torque Enable",0,1024),   //b RW Torque enable            0
    new DxlValue(25," Led On/Off",0,1024), // b RW LED on/off               0
    new DxlValue(26," CW  marging",0,1024), // b RW CW compliance margin     4
    new DxlValue(27," CWW marging",0,1024), // b RW CCW compliance margin    4
    new DxlValue(28," CW  slope",0,1024), //  b RW CW  compliance slope     64
    new DxlValue(29," CCW slope",0,1024), //  b RW CCW compliance slope     64
    new DxlValue(30," Goal Position",0,1024), // w RW Goal position *******************
    new DxlValue(32," Moving Speed",0,1024), // w RW Moving speed             -
    new DxlValue(34," Torque Limit",0,1024), // w RW Torque limit             ADD14 ADD15 ???
    new DxlValue(36," Current Position",0,1024), //  w R  present position ****************
    new DxlValue(38," Current Speed",0,1024), // w R  present speed
    new DxlValue(40," Present Load",0,1024), // w R  present load 
    new DxlValue(42," Present Voltage",0,1024), // b R  present volage
    new DxlValue(43," Present Temp",0,1024), // b R  present temperature
    new DxlValue(44," Registerd",0,1024), // b R  registered (instruction)  0
    new DxlValue(46," Moving",0,1024), // b R  Moving                    0
    new DxlValue(47," Lock",0,1024), //  b RW Lock locking EEPROM       0
    new DxlValue(48," Punch",0,1024) //  w RW Punch                   0x0020
  };
 }
    
  void setValue(int imotor,int reg,int value)
  {
    if(imotor!=currentMotor)
      return;
    
    int nbv = dxlValues.length;
    for(int i=0;i<nbv;i++)
    {
      if(dxlValues[i].registre == reg )
      {
        dxlValues[i].value = value;
        dxlValues[i].textField.setText( String.format("%d",value));      
      }
    }    
  }

 
 void update( )
 {
   switch(action)
   {
     case 1: // read all values
       //dxlValues[currIndex].sendRead(currentMotor);
       arduino.serialSend("MR "+currentMotor+" "+dxlValues[currIndex].registre+'\n');
       if(++currIndex>=dxlValues.length )
       {
         action=0;
         currIndex=0;
       }
       break;
   }
 }


  void buildGUI(int x0,int y0, String tabName)
  {
   
    Group group = cp5.addGroup("DXL controls")
                .setPosition(x0,y0-30)
                .setWidth(180)
                .setBackgroundHeight(600)
                .setBackgroundColor(color(200,200))
                .moveTo(tabName)
                .bringToFront();
                ;
    
    startID = globalID;
    Textfield tf =cp5.addTextfield(" DXL ID ")
      .setId(globalID++)
      .setPosition(140,10)
      .setWidth(30)
      .setInputFilter(Textfield.INTEGER)
      .setAutoClear(false)
      .setGroup(group)
      .addListener(this);
      //.moveTo(tabName);
     tf.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER).setColor(0xFF000000);
       //lbl.toUpperCase(false);
       //lbl.setText(label);
  
    int y = 30; //y0; //25;
    int h = 18;
    int nbv = dxlValues.length;
    for(int i=0;i<nbv;i++)
    {
      //dxlValues[i].addControl(i,x0,y,h,group);
      dxlValues[i].addControl(i,140,y,h,group).addListener(this);
      y+=h+2;    
    }
    
    endID = globalID;
    
    //cp5.addListener(this);
    //my_cp5.addCallback(this);    
  }

  void controlEvent(ControlEvent evt)
  {
    if(evt.isGroup())
      return;
    if(!evt.isController())
    return;

    println("got event");

    Controller c = evt.getController();
    int id = c.getId();
    if( (id<startID)||(id>=endID) )
      return;
      
    int cid = id-startID; 
    
    String addr = c.getAddress();
    String str  = c.getStringValue();
    int val = Integer.parseInt(str);  
    println("DXL["+cid+"]"+addr+" "+str);
    if(cid==0)
    {
      currentMotor = val;
      currIndex = 0;
      action = 1;  //v update
    }
    else if(cid<=dxlValues.length)
    {
      arduino.serialSend(" ========\n");
      dxlValues[cid-1].value = val;
      int reg = dxlValues[cid-1].registre;
      //arduino.serialSend("MW "+currentMotor+" "+reg+" "+str+'\n');
    }
  }
}

