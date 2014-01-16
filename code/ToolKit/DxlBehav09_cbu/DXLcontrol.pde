

class DXLvalue
{
  int index = 0;
  int iMotor = 0; //>adrr
  int registre = 0; //
  int value = 0;
  int valueMin = 0;
  int valueMax = 0;
  String label;
  Textfield textField;

  DXLvalue(int reg,String name,int min,int max)
  {
    registre = reg;
    label = name;
    valueMin = min;
    valueMax = max;
  }

  /*
  void sendRead(int imot)
  {
    println("Dxl read "+imot+" "+registre);
  }
  */
 
  Textfield addControl(int idx,int x,int y,int h)
  {
    //cp5.addSlider(label).setPosition(x,y).setRange(0,1000);
    index = idx;
    
    Textfield tf =    
     cp5.addTextfield("M"+iMotor+"/"+registre)
         .setId(globalID++)
         .setText("0") 
         .setPosition(x,y)
         .setSize(30,h);
         
     tf.setInputFilter(Textfield.INTEGER);
     tf.setAutoClear(false);
         
     Label lbl = tf.getCaptionLabel();
     lbl.align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
     //lbl.toUpperCase(false);
     lbl.setText(label+":"+registre);
     
     textField = tf;
     return tf;
  }  
  
  void addDxlValueToTab(String tabName)
  {
      textField.moveTo(tabName);
  }
  
}; //DXLvalue


//==========================================================
class DXLmotor implements ControlListener //CallbackListener
{
  int startID = 0;
  int endID = 0;
  int currentMotor = 17;
  DXLvalue[] dxlValues;
  int action = 0;
  int currIndex = 0;
  //int[] dxlRegs = new int[10];
  

 DXLmotor()
 {

  dxlValues = new DXLvalue[]
  {
    //DXLvalue(int reg,String name,int min,int max)
    new DXLvalue( 0," Model",0,1024),
    new DXLvalue( 2," Firmware",0,1024),
    new DXLvalue( 3," ID",0,1024), //RW 254=broadcast
    new DXLvalue( 4," Baudrate",0,1024), //RW               1
    new DXLvalue( 5," Return Delay",0,1024),//      250
    new DXLvalue( 6," CW  Min",0,1024),//        0
    new DXLvalue( 8," CCW Max",0,1024),//        0x3FF
    new DXLvalue(11," Temp Max",0,1024),       // RW high limittemperature 70
    new DXLvalue(12," Volt Min",0,1024),       // RW lowest limit voltage   60
    new DXLvalue(13," Volt Max",0,1024),       // RW highest limit voltage  140
    new DXLvalue(14," Torque Max",0,1024),     // RW Max Torque             0x3F36F
    new DXLvalue(16," Status",0,1024),         // RW Status return Level    2
    new DXLvalue(17," Alarm Led",0,1024),      // RW Arlarm Led             36
    new DXLvalue(18," Alarm Shutdown",0,1024), // RW Alarm Shutdown         36
    //RAM
    new DXLvalue(24," Torque Enable",0,1024),   //b RW Torque enable            0
    new DXLvalue(25," Led On/Off",0,1024), // b RW LED on/off               0
    new DXLvalue(26," CW  marging",0,1024), // b RW CW compliance margin     4
    new DXLvalue(27," CWW marging",0,1024), // b RW CCW compliance margin    4
    new DXLvalue(28," CW  slope",0,1024), //  b RW CW  compliance slope     64
    new DXLvalue(29," CCW slope",0,1024), //  b RW CCW compliance slope     64
    new DXLvalue(30," Goal Position",0,1024), // w RW Goal position *******************
    new DXLvalue(32," Moving Speed",0,1024), // w RW Moving speed             -
    new DXLvalue(34," Torque Limit",0,1024), // w RW Torque limit             ADD14 ADD15 ???
    new DXLvalue(36," Current Position",0,1024), //  w R  present position ****************
    new DXLvalue(38," Current Speed",0,1024), // w R  present speed
    new DXLvalue(40," Present Load",0,1024), // w R  present load 
    new DXLvalue(42," Present Voltage",0,1024), // b R  present volage
    new DXLvalue(43," Present Temp",0,1024), // b R  present temperature
    new DXLvalue(44," Registerd",0,1024), // b R  registered (instruction)  0
    new DXLvalue(46," Moving",0,1024), // b R  Moving                    0
    new DXLvalue(47," Lock",0,1024), //  b RW Lock locking EEPROM       0
    new DXLvalue(48," Punch",0,1024) //  w RW Punch                   0x0020
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


 
 /*
 // DIDIER? est-ce que c'est moi qui l'ai mis en commentaire par hasard? ou ça vient de toi?
 void controlEvent(CallbackEvent evt)
 {
   Controller ctrl = evt.getController();
   int act = evt.getAction();
   //if(act==ControlP5.ACTION_ENTER)
   //println(" motorAction:["+act+"] "+ctrl.getAddress()+" "+ctrl.getValue() );
   if(act == ControlP5.ACTION_BROADCAST )
   {

      println(" motor:"+ctrl.getAddress()+" "+ctrl.getStringValue() );
     //println("action: "+act+" "+ControlP5.ACTION_BROADCAST );
     //ctrl.setValueLabel("zob");
   }
 }
*/
 
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
     startID = globalID;
     Textfield tf =cp5.addTextfield("DXL ID ")
      .setId(globalID++)
      .setPosition(x0,y0)
      .setWidth(30)
      .setInputFilter(Textfield.INTEGER)
      .setAutoClear(false)
      .moveTo(tabName);
     tf.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
     
       //lbl.toUpperCase(false);
       //lbl.setText(label);
  
    int y = y0+25;
    int h = 18;
    int nbv = dxlValues.length;
    for(int i=0;i<nbv;i++)
    {
      dxlValues[i].addControl(i,x0,y,h);
      dxlValues[i].addDxlValueToTab(tabName);
      y+=h+2;    
    }
    
    endID = globalID;
    
    cp5.addListener(this);
    //my_cp5.addCallback(this);    
  }

  void controlEvent(ControlEvent evt)
  {
    if(evt.isGroup())
    {
      //println("DXL GROUP");
      return;
    }
    else if(evt.isController())  // cbu: added this check otherwise we might get a nullpointerexception
    {
    
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
        dxlValues[cid-1].value = val;
        int reg = dxlValues[cid-1].registre;
        arduino.serialSend("MW "+currentMotor+" "+reg+" "+str+'\n');
      }
    }
  }
}

