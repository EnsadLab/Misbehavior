


class CommIno implements ControlListener //CallbackListener
{
  int listIndex = 0;
  String port = "COM37";
  int baudrate = 57600;
  boolean openned = false;
  int action = 0;
  Serial serial;
  //GUI
  Toggle titleButtonBasic;
  Toggle titleButton;
  Toggle togleDogBasic;
  Toggle togleDog;
  Toggle scanButton;  
  DropdownList listBauds;
  DropdownList listBox;
  Button clearButton;
  Textarea  textArea;
  Textfield sendField;
  int iBuffer = 0;
  byte[] buffer = new byte[256];
    
  CommIno(String port, int baudrate)
  {
    this.port = port;
    this.baudrate = baudrate;
  }
    
  // basic GUI: port and bauds must be set in the config.xml file
  void buildBasicGUI(int x,int y, String tabName)
  {
    
     Textlabel label = cp5.addTextlabel("arduinoInfos")
                  .setText("Current port: "+port + "\nCurrent baudrate: "+baudrate)
                  .setPosition(x-4,y+50)
                  .setColorValue(0xFF000000)
                  .setFont(createFont("Verdana",10))
                  .moveTo(tabName);
                  ;
      titleButtonBasic = cp5.addToggle("ARDUINObasic")
        .setPosition(x,y)
        .setColorActive(0xFFCC0000)
        .setSize(180,40)
        .moveTo(tabName)
        .setCaptionLabel("CONNECT TO ARDUINO");
     titleButtonBasic.getCaptionLabel().setFont(createFont("Verdana",13)).align(ControlP5.CENTER,ControlP5.CENTER);
     
     togleDogBasic = cp5.addToggle("DOGbasic")
         .setPosition(x+6,y+6)
         .setSize(6,6)
         .setColorActive(0xFF00FF00)
         .moveTo(tabName);
     togleDogBasic.getCaptionLabel().setText("");

  }
    
  // advanced GUI: gives the possibility to the user to select port and bauds and displays as well console infos
  void buildGUI(int x,int y, String tabName)
  {
    
   titleButton = cp5.addToggle("ARDUINO")
      .setPosition(x,y)
      .setColorActive(0xFFCC0000)
      .setSize(130,18)
      .moveTo(tabName);
   titleButton.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);

   togleDog = cp5.addToggle("Dog")
       .setPosition(x+6,y+6)
       .setSize(6,6)
       .setColorActive(0xFF00FF00)
       .moveTo(tabName);
   togleDog.getCaptionLabel().setText("");

   
   y+=20;

   scanButton = cp5.addToggle("SCAN")
     .setPosition(x,y)
     .setWidth(30)
     .moveTo(tabName);
   scanButton.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);

    listBox = cp5.addDropdownList("SerialPort")
      .setPosition(x+48,y+20) //??? origine en bas !!!
      .setWidth(50)
      .setBarHeight(19)
      .setOpen(false)
      .moveTo(tabName);   
    for(int i=0;i<10;i++) 
      listBox.addItem("COMM"+i,i);     
    listBox.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
    listBox.getCaptionLabel().setText(port);
 
   String[] bauds ={"9600","14400","19200","28800","38400","57600","115200"};
   listBauds = cp5.addDropdownList("BAUDRATE")
      .setPosition(x+100,y+20)
      .setWidth(50)
      .setBarHeight(19)
      .setOpen(false)
      .addItems( bauds )
      .moveTo(tabName);
   listBauds.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   listBauds.getCaptionLabel().setText("57600");  
 
   y+=20;
   textArea = cp5.addTextarea("TextArea")
     .setPosition(x,y)
     .setSize(150,600)
     .setLineHeight(14)
     .setColor(color(255))
     .setColorBackground(color(0))
     .setColorForeground(color(255))
     .moveTo(tabName);
     
     listBauds.bringToFront();
     listBox.bringToFront();

     y+=602;
     sendField = cp5.addTextfield("SEND")
           .setPosition(x,y)
           .setWidth(118)
           .setAutoClear(true)
           .moveTo(tabName);
    
     //y+=20;
     cp5.addButton("CLEAR")
       .setWidth(30)
       .setPosition(x+120,y)
       .moveTo(tabName);
    
    cp5.addListener(this);
  }
  
  void update()
  {
    switch(action)
    {
      case 0: break;
      case 1: toggleOnOff(titleButton); action=0; break;
      case 2: toggleOnOff(titleButtonBasic); action=0; break;
    }
    
  }
  
  void controlEvent(ControlEvent evt)
  {
    //println("ARDUI EVT");
    if(evt.isGroup()) //dropdown list
    {
      println("ARDUI GROUP");
      
       String gName = evt.getGroup().getName();
       int iselect = (int)evt.getGroup().getValue();
       if(gName.equals("SerialPort"))
         println("SERIALPORT :"+iselect ); //useless
       else if(gName.equals("BAUDRATE"))
         arduino.baudFromGUI();           //fait dans open
       //println("event from group : "+evt.getGroup().getValue()+" from "+evt.getGroup());
       //println("event from group : "+evt.getGroup().getValue()+" from "+gName);
    }
    else if(evt.isController())  // cbu: added this check otherwise we might get a nullpointerexception
    {
      Controller c = evt.getController();
      //println("arduiEvent ");
      int evId = evt.getController().getId();
      String evAdrr = evt.getController().getAddress();
      String evName = evt.getController().getName();
      //println("arduiEvent "+evName);
      if( evName.equals("ARDUINO") )
      {
        titleButton.getCaptionLabel().setText("WAIT");        
        //arduino.toggleOnOff(); //bloquant ... 
        action = 1; //will toggle next loop;
      }
      else if(evName.equals("ARDUINObasic") )
      {
        titleButtonBasic.getCaptionLabel().setText("WAIT"); 
        action = 2;
      }
      else if( evName.equals("SCAN") )
        list();
      else if( evName.equals("SEND") )
        serialSend(sendField.getText()+"\n");
      else if( evName.equals("CLEAR") )
        clearTerminal();      
    }
    //println("done");
  }
  
  void append(String txt)
  {
    textArea.append(txt);
    textArea.scroll(1.0);
  }

  void clearTerminal()
  {
    textArea.clear();
  }
  
  void saveConfig()
  {
  /*  JSONObject jo = new JSONObject();
    jo.setInt("bauds",baudrate);
    jo.setString("port",port);    
    saveJSONObject(jo,"SerialConfig.txt");
    */
  }

  void loadConfig() //TODO -> cbu: done in DxlBehav09
  {
  }
  
  void list()
  {
      if(scanButton.getState()==false)
        return;
        
      //button.getCaptionLabel().setText("Wait"); //s'affiche apreés coup
      println("Wait");
      listBox.clear();
      String[] ports = Serial.list();
      if(ports.length>0)
      {
        port = ports[0];
        listBox.addItems(ports);
        listBox.getCaptionLabel().setText(port);    
      }
     
      scanButton.setState(false);
      textArea.append("** Ports found "+ports.length+"\n");
  }
  
  void selectPort(int iselect)
  {
    port = listBox.item(iselect).getName();
    open();
    saveConfig();
  }
  
  void baudFromGUI()
  {
    String b = listBauds.getCaptionLabel().getText();
    textArea.append("Baudrate : "+b+"\n");
    
  }
  
  void toggleOnOff(Toggle titleButton)
  {
    //println("toggle");
    if(titleButton.getState())
    {
      this.titleButton.setState(true); // We need to ensure that both buttons have the same state, although just one of them had been clicked
      this.titleButtonBasic.setState(true);
      open();
      this.titleButton.getCaptionLabel().setText("ARDUINO on");
      this.titleButtonBasic.getCaptionLabel().setText("ARDUINO on");
    }
    else
    {
      this.titleButton.setState(false);
      this.titleButtonBasic.setState(false);
      close();
      this.titleButton.getCaptionLabel().setText("ARDUINO off");
      this.titleButtonBasic.getCaptionLabel().setText("ARDUINO off");
    }
  }
    
  void open()
  {
    println("openning "+port+" ");
    close();
    textArea.append("openning "+port+" "+baudrate+"\n");
    serial = new Serial(mainApp,port,baudrate);
    if(serial==null)
      println("serial NULL") ;
    serial.bufferUntil(10);
    println("openned "+port); 
    textArea.append("Openned "+port+" "+baudrate+"\n");
    openned = true;
  }
  
  void close()
  {
    openned = false;
    textArea.append("closing "+port+"\n");
    if(serial!=null)
    {
      openned = false;
      //serial.clear();
      serial.stop();
      //serial.clear();
      //serial = null;
    }
    // TODO: stop recording
  }
  
  void serialRcv()
  {
    if( !openned || (serial == null))
      return;
    
    String rcv = serial.readString();
    if(rcv.charAt(0)=='x')
    {
      if(togleDog.getState()){togleDog.setState(false);togleDogBasic.setState(false); }
      else {togleDog.setState(true);togleDogBasic.setState(true);}
      return;
    }
    
    textArea.append("---"+rcv);
    textArea.scroll(1.0);
    
    String[] toks = rcv.replaceAll("[\\n\\r]","").split(" "); //GRRRR sinon parseInt exception
    if(toks.length>=4)
    {
      if(toks[0].equals("MV"))
      { 
        try{ 
        int imot = Integer.parseInt(toks[1]); //GRRR
        int ireg = Integer.parseInt(toks[2]); //GRRR
        int val  = Integer.parseInt(toks[3]); //GRRRRRRRRRR
        println("COMING HERE.....");
        servoArray.regValue(imot,ireg,val);
        motorGroup.setValue(imot,ireg,val);
        dxlGui.setValue(imot,ireg,val);
        }catch(Exception e){println("TOK EXCEPTION");}
      }
    }
  }

 boolean serialSend(String toSend)
 {
   println("serial Send " + toSend);
   if(openned && (serial!=null) )
   {
     textArea.append( ">>>"+toSend );
     serial.write(toSend);
   }
   return openned;   
 }
 
  
}
