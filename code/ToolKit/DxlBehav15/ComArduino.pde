


class CommIno implements ControlListener //CallbackListener
{
  int listIndex = 0;
  String port = "COM13";
  //int baudrate = 9600; //57600;
  int baudrate = 57600;
  boolean openned = false;
  int action = 0;
  Serial serial;
  //GUI
  Toggle titleButton;
  Toggle scanButton;  
  DropdownList listBauds;
  DropdownList listBox;
  Button clearButton;
  Textarea  textArea;
  Textfield sendField;
  int iBuffer = 0;
  byte[] buffer = new byte[256];
    
       
  void buildGUI(int x,int y)
  {
    
   titleButton = cp5.addToggle("ARDUINO")
      .setPosition(x,y)
      .setColorActive(0xFFCC0000)
      .setSize(150,18);   
   titleButton.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
      
    y+=20;

    

   scanButton = cp5.addToggle("SCAN")
     .setPosition(x,y)
     .setWidth(30);
   scanButton.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);

    listBox = cp5.addDropdownList("SerialPort")
      .setPosition(x+48,y+20) //??? origine en bas !!!
      .setWidth(50)
      .setBarHeight(19)
      .setOpen(false);    
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
      .addItems( bauds );
   listBauds.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   listBauds.getCaptionLabel().setText("57600");  
 
   y+=20;
   textArea = cp5.addTextarea("TextArea")
     .setPosition(x,y)
     .setSize(150,600)
     .setLineHeight(14)
     .setColor(color(255))
     .setColorBackground(color(0))
     .setColorForeground(color(255));
     
     listBauds.bringToFront();
     listBox.bringToFront();

     y+=602;
     sendField = cp5.addTextfield("SEND")
           .setPosition(x,y)
           .setWidth(118)
           .setAutoClear(true);
    
     //y+=20;
     cp5.addButton("CLEAR")
       .setWidth(30)
       .setPosition(x+120,y);
       
    cp5.addListener(this);
  }
  
  void update()
  {
    switch(action)
    {
      case 0: break;
      case 1: toggleOnOff(); action=0; break;
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
    else
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
    JSONObject jo = new JSONObject();
    jo.setInt("bauds",baudrate);
    jo.setString("port",port);    
    saveJSONObject(jo,"SerialConfig.txt");
  }

  void loadConfig() //TODO
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
  
  void toggleOnOff()
  {
    //println("toggle");
    if(titleButton.getState())
    {
      open();
      titleButton.getCaptionLabel().setText("ARDUINO on");
    }
    else
    {
      close();
      titleButton.getCaptionLabel().setText("ARDUINO off");
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
      serial.clear();
      serial.stop();
      serial.clear();
      serial = null;
    }
  }
  
  void serialRcv()
  {
    if( !openned || (serial == null))
      return;
    
    String rcv = serial.readString();
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
        servoArray.regValue(imot,ireg,val);
        motorGroup.setValue(imot,ireg,val);
        dxlGui.setValue(imot,ireg,val);
        }catch(Exception e){println("TOK EXCEPTION");}
      }
    }
    else if(toks[0].equals("MA"))
    {      
        try{ 
        int imot = Integer.parseInt(toks[1]); //GRRR
        int icmd = Integer.parseInt(toks[2]); //GRRR
        script.rcvMsg(imot,icmd);
        }catch(Exception e){}
    }
  }

 boolean serialSend(String toSend)
 {
   if(openned && (serial!=null) )
   {
     textArea.append( ">>>"+toSend );
     serial.write(toSend);
   }
   return openned;   
 }
 
  
}
