
//TODO READY ok ...

class CommArduino implements ControlListener //CallbackListener
{
  int listIndex = 0;
  String port = "COM13";
  int baudrate = 57600;
  boolean openned = false;
  int action = 0;
  int rcvCount = 0;
  Serial serial;
  OpenSerial openSerial;
  
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
    
  CommArduino(String port, int baudrate)
  {
    this.port = port;
    this.baudrate = baudrate;
    serial = null;
    openSerial = null;
    openned = false;
    action = 0;
    rcvCount = 0;
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
       
       
  void buildGUI(int x,int y,String tabName)
  {
    
   titleButton = cp5.addToggle("ARDUINO")
      .setPosition(x,y)
      .setColorActive(0xFFCC0000)
      .setSize(180,40)
      .moveTo(tabName);   
   titleButton.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER)
     .setFont(verdanaFont)
     .setText("CONNECT TO ARDUINO");

   //watchdog reception CM9
   togleDog = cp5.addToggle("Dog")
       .setPosition(x+6,y+6)
       .setSize(6,6)
       .setColorActive(0xFF00FF00)
       .moveTo(tabName);
   togleDog.getCaptionLabel().setText("");
   
    y+=45;
    listBox = cp5.addDropdownList("SerialPort")
      .setPosition(x,y+20) //??? origine en bas !!!
      .setWidth(180)
      .setBarHeight(19)
      .setOpen(false)
      .moveTo(tabName);    
    for(int i=0;i<10;i++) 
      listBox.addItem("COMM"+i,i);     
    listBox.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setText(port);

    y+=20;
   scanButton = cp5.addToggle("SCAN")
     .setPosition(x,y)
     .setWidth(30)
     .moveTo(tabName);
   scanButton.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);

   String[] bauds ={"9600","14400","19200","28800","38400","57600","115200"};
   listBauds = cp5.addDropdownList("BAUDRATE")
      .setPosition(x+50,y+20)
      .setWidth(130)
      .setBarHeight(19)
      .setOpen(false)
      .addItems( bauds )
      .moveTo(tabName);

   listBauds.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   listBauds.getCaptionLabel().setText("57600");  
 
   y+=30;
   textArea = cp5.addTextarea("TextArea")
     .setPosition(x,y)
     .setSize(180,600)
     .setLineHeight(14)
     .setColor(color(255))
     .setColorBackground(color(128))
     .setColorForeground(color(255))
     .moveTo(tabName);
     
     listBauds.bringToFront();
     listBox.bringToFront();

     y+=602;
     sendField = cp5.addTextfield("SEND")
           .setPosition(x,y)
           .setWidth(148)
           .setAutoClear(true)
           .moveTo(tabName);
    
     //y+=20;
     cp5.addButton("CLEAR")
       .setWidth(30)
       .setPosition(x+150,y)
       .moveTo(tabName);
       
    cp5.addListener(this);
  }
  
  void update()
  {
    switch(action)
    {
      case 0: break;      
      case 1: action=2;break;
      case 2: action=0; break;
      case 3: //serial openned
         openSerial = null; //cannot restart;(& I prefer not keeping it running)
         servoArray.sendDxlId();
         titleButton.getCaptionLabel().setText("ARDUINO on");
         titleButtonBasic.getCaptionLabel().setText("ARDUINO on");
         textArea.append("Openned "+port+" "+baudrate+"\n");
         action = 0;
         break;
     case 4: //serial closed
         if(openSerial!=null)
           openSerial.interrupt();
        openned = false; 
        openSerial = null;        
        titleButtonBasic.getCaptionLabel().setText("ARDUINO off");
        titleButton.getCaptionLabel().setText("ARDUINO off");
        togleDog.setState(false);
        togleDogBasic.setState(false);
        action = 0;
      break;
     default:
      action = 0;
    }
  }
  
  void controlEvent(ControlEvent evt)
  {
    //println("ARDUI EVT");
    if(evt.isGroup()) //dropdown list
    {
      ControlGroup g = evt.group();
      //String gName = evt.getGroup().getName();
      //println("ARDUI GROUP :"+gName);
      if( g == listBox )
      {
        int line = (int)g.value();
        port = listBox.getItem(line).getName();
        textArea.append("select "+port+"\n"+"bauds "+baudrate+"/n");
        baudrate = 57600;
      }
      else if(g == listBauds)
      {
        int line = (int)g.value();
        try{ baudrate = Integer.decode(listBauds.getItem(line).getName()); }catch(Exception e){}
        textArea.append("select "+port+"\n"+"   bauds "+baudrate+"/n");
      }
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
        println("TOGGLE1 "+titleButton.getState()+" "+action);
        if(action==0)
        {
          if(titleButton.getState())
            open();
          else
            close();
        }
        /*
        titleButton.getCaptionLabel().setText("WAIT");        
        //arduino.toggleOnOff(); //bloquant ... 
        //action = 1; //will toggle next loop;
        toggleOnOff(titleButton);
        */        
      }
      else if(evName.equals("ARDUINObasic") )
      {
        println("TOGGLE2 "+titleButtonBasic.getState()+" "+action);
        if(action==0)
        {
          if(titleButtonBasic.getState())
            open();
          else
            close();
        }
        /*
        
        titleButtonBasic.getCaptionLabel().setText("WAIT");
        toggleOnOff(titleButtonBasic); 
        //action = 2;
        */
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

  //cbu: done in DxlBehav09  
  //void saveConfig(){...} //TODO
  //void loadConfig(){...} //TODO
  
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
    textArea.append("port:"+port);
    open();
  }
/*  
  void baudFromGUI()
  {
    String b = listBauds.getCaptionLabel().getText();
    textArea.append("Baudrate : "+b+"\n");
    
  }
*/  
  /*
  void toggleOnOff(Toggle button) //modif cbu
  {
    if(button.getState())
    {
      //this.titleButton.setState(true); // We need to ensure that both buttons have the same state, although just one of them had been clicked
      //this.titleButtonBasic.setState(true);
      open();
      //this.titleButton.getCaptionLabel().setText("ARDUINO on");
      //this.titleButtonBasic.getCaptionLabel().setText("ARDUINO on");
    }
    else
    {
      //this.titleButton.setState(false);
      //this.titleButtonBasic.setState(false);
      close();
      //this.titleButton.getCaptionLabel().setText("ARDUINO off");
      //this.titleButtonBasic.getCaptionLabel().setText("ARDUINO off");
    }
  }
  */
  
  void open()
  {
    println("SERIAL OPEN "+action);
    action = 1;
    if(openned)  
      close();
      
    if( !titleButton.getState() )
      titleButton.setState(true); // We need to ensure that both buttons have the same state, although just one of them had been clicked
    if( !titleButtonBasic.getState() )
       titleButtonBasic.setState(true);       
    titleButtonBasic.getCaptionLabel().setText("Wait"); //s'affiche apreés coup
    titleButton.getCaptionLabel().setText("Wait"); //s'affiche apreés coup
       
    textArea.append("openning "+port+" "+baudrate+"\n");
    openSerial = new OpenSerial(); //thread
    openSerial.start();
  }
  
  void close()
  {    
    println("SERIAL CLOSE");
         
    openned = false;
    action  = 1; 
    textArea.append("closing "+port+"\n");
    if(serial!=null)
    {
      //serial.clear();
      serial.stop();
      //serial.clear();
      //serial = null;
      rcvCount = 0;
    }
    if( titleButton.getState() )
      titleButton.setState(false); // We need to ensure that both buttons have the same state, although just one of them had been clicked
    if( titleButtonBasic.getState() )
      titleButtonBasic.setState(false);        
    action = 4;
  }
  
  void serialRcv()
  {
    if( !openned || (serial == null))
      return;

    String rcv = null;
    try{ rcv = serial.readString(); }
    catch(Exception e){return;}
    rcvCount++;

    //println("rcv" + rcv);
    if(rcv.charAt(0)=='x')
    {
      if(togleDog.getState()){togleDog.setState(false);togleDogBasic.setState(false); }
      else {togleDog.setState(true);togleDogBasic.setState(true);}
      return;
    }
          
    String[] toks = rcv.replaceAll("[\\n\\r]","").split(" "); //GRRRR sinon parseInt exception
    if(toks.length==3)
    {
      if(toks[0].equals("P")) //sensor (Pin)
      { 
        try{ 
          int   sensor = Integer.parseInt(toks[1]);
          float value  = Float.parseFloat(toks[2]);
          sensorArray.rcvValue(sensor,value);
        }catch(Exception e){}
      }
      else if(toks[0].equals("ok")) //TODO TODO
      {   
        textArea.append("READY"+rcv,200);
        try{ 
        int imot = Integer.parseInt(toks[1]); //GRRR
        int icmd = Integer.parseInt(toks[2]); //GRRR
        scriptArray.rcvMsg(imot,icmd);
        textArea.append("READY! "+imot+" "+icmd);
        }catch(Exception e){}
      }
      else
      {
        textArea.append("---"+rcv,200);
        textArea.scroll(1.0);
      }
    }
    else if(toks.length>=4)
    {
      textArea.append("---"+rcv,200);
      textArea.scroll(1.0);
      if(toks[0].equals("MV"))
      { 
        try
        { 
          int imot = Integer.parseInt(toks[1]); //GRRR
          int ireg = Integer.parseInt(toks[2]); //GRRR
          int val  = Integer.parseInt(toks[3]); //GRRRRRRRRRR
          if(val>=0)
          {
            servoArray.regValue(imot,ireg,val);
            servoGUIarray.setDxlValue(imot,ireg,val);
            dxlGui.setValue(imot,ireg,val);
          }
        }catch(Exception e){println("TOK EXCEPTION");}
      }
    }
    else if(toks[0].equals("ok")) //TODO TODO
    {   
        //println("DBG ready");  
        try{ 
        int imot = Integer.parseInt(toks[1]); //GRRR
        int icmd = Integer.parseInt(toks[2]); //GRRR
        scriptArray.rcvMsg(imot,icmd);
        }catch(Exception e){}
    }
    else
    {
      textArea.append("---"+rcv,200);
      textArea.scroll(1.0);
    }
  }

 boolean serialSend(String toSend)
 {
   //print("send("+rcvCount+")"+toSend);
   try
   {
     if(openned && (rcvCount>0) && (serial!=null) ) //Serial is good if received at least once
     {
       if(toSend.charAt(0)!='E')
         textArea.append( ">>>"+toSend );
       serial.write(toSend); //no exception ????
     }
   }
   catch(Exception e){}
   return openned;   
 }

class OpenSerial extends Thread
{
  boolean running;
  OpenSerial(){}
  void start(){super.start();}
  void run()
  {
    running = true;
    openned = false;
    Serial tmp = null;
    textArea.append("WAIT\n");
    try
    { 
      tmp = new Serial(mainApp,port,baudrate); //GRRR Windows : no exception, no null even if cannot open 
      serial = tmp;
      serial.bufferUntil(10);
      openned = true;
      action  = 3; //openned
    }
    catch(Exception e){action = 4;}//closed
    textArea.append(" DONE "+baudrate+"/n");
    running = false;
    //interrupt(); //force stop
  }
  void quit()
  {
    running = false;
    interrupt(); //force stop
  }
}
   
}


