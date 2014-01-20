import themidibus.*;
import processing.serial.*;
import controlP5.*;

PApplet  mainApp;
int keyModifier = 0; //1 shift 2ctrl 4alt 

PFont arialFont; // = createFont("Arial",20,true); // use true/false for smooth/no-smooth

CommArduino    arduino;
DxlControl     dxlGui;
ServoArray     servoArray;
ServoGUIarray  servoGUIarray;
Script[]       scriptArray;

ControlP5 cp5;
int globalID = 0;

String tabNameBasic = "default"; // the identifier name is different from the label for the default tab.
String tabNameAdvanced = "ADVANCED";
int currentTabId = 1; // 1:default tab / 2:ADVANCED tab

int nbMotors = 4; // default value. Might be overriden with value set in the config.xml file
int[] motorIds;
String[] animPaths;
int nbAnims = 0;
int nbAnimsMax = 18; 
String arduinoPort = "COM13";
int arduinoBaudRate = 57600;


void setup()
{
  mainApp = this;
  size(1150,800); //P3D OPENGL
  
  println("Path:"+sketchPath);
  
  cp5 = new ControlP5(this);
  globalID = 200;
  
  arialFont = createFont("Courier New",12,false); // use true/false for smooth/no-smooth

  cp5.addTab(tabNameAdvanced)
     .activateEvent(true)
     .setId(2);
     //.setColorBackground(color(255, 160, 100))
     //.setColorLabel(color(0,0,0))
     //.setColorActive(color(255,128,255));
  cp5.getTab("default")
     .setLabel("BASIC")
     .activateEvent(true)
     .setId(1);
     //.setColorBackground(color(0, 160, 100))
     //.setColorLabel(color(255))
     //.setColorActive(color(255,128,0));

  loadConfig("config_dib.xml");
  
  arduino = new CommArduino(arduinoPort,arduinoBaudRate);
  arduino.buildBasicGUI(20,50,tabNameBasic);
  arduino.buildGUI(150,20,tabNameAdvanced);

  servoArray = new ServoArray(motorIds);
       
  dxlGui = new DxlControl();
  dxlGui.buildGUI(100,20,tabNameAdvanced);
  
  servoGUIarray = new ServoGUIarray(motorIds);
  servoGUIarray.buildGUI(350,20,tabNameAdvanced);
  servoGUIarray.buildBasicGui(250,50,tabNameBasic);
    
  
  //scriptConsole.buildGui(700,150,450); //a suprimer
  //scriptEditor.buildGui(800,150,450); //a suprimer
  scriptArray        = new Script[4]; //... TODO : config
  scriptArray[0]    = new Script();
  scriptArray[0].buildGui(350,200,400,tabNameAdvanced);
  scriptArray[1]    = new Script();
  scriptArray[1].buildGui(650,200,400,tabNameAdvanced);
  scriptArray[0].load("/anims/AnimE1.txt");
  
  //scriptGuiArray[0] = new ScriptGUI(350,200,400,tabNameAdvanced);
  //scriptGuiArray[1] = new ScriptGUI(650,200,400,tabNameAdvanced);


/*
  listMidiDevices();
  openMidi("BCF2000", "BCF2000"); //TODO  config
  //openMidi("BCR2000", "BCR2000");  
*/


  //String[] fonts = PFont.list();
  //println(fonts);
}

void draw()
{
  if(currentTabId == 1) // tab BASIC
  {
    background(255);
  }
  else // tab ADVANCED
  {
    background(64);
  } 
  
  scriptArray[0].update();
  //scriptGuiArray[0].update();
  servoArray.update();
  servoGUIarray.update();
  arduino.update();  
  dxlGui.update();
  
  //servoArray.draw(500,20);
  //curve.test(500,100,1300,500);
}

void close()
{
  println("CLOSE");
}

void exit()
{
  arduino.close();
  println("EXIT");
  
  super.exit();  
}

void loadConfig(String xmlFilePath)
{
  
  println("Loading Config file...");
  XML xml = loadXML(xmlFilePath);
  if(xml==null)
    return;      //>>error message ?
  
  XML[] children = xml.getChildren("motor");
  
  arduinoPort = xml.getChild("arduino").getString("port");
  arduinoBaudRate = xml.getChild("arduino").getInt("bauds");
  println("-> Arduino port="+arduinoPort + " bauds=" + arduinoBaudRate);

  nbMotors = children.length;
  motorIds = new int[nbMotors];
  for (int i = 0; i < children.length; i++) {
    int id = children[i].getInt("id");
    motorIds[i] = id;
    println("-> adding motor with id " + id);
  }
  
  children = xml.getChildren("anim");
  nbAnims = children.length;
  //animPaths = new String[nbAnims];
  animPaths = new String[nbAnimsMax];
  for(int i=0; i<children.length; i++)
  {
    String animPath = children[i].getString("path");
    animPaths[i] = animPath;
    println("-> adding anim with path " + animPath);
  }
}

void controlEvent(ControlEvent evt)
{
  if(evt.isTab())
  {
    println("TAB "+evt.getTab().getName()+" IS SELECTED with id "+evt.getTab().getId());
    currentTabId = evt.getTab().getId();
  }
}

void garbage(ControlEvent evt)
{
  if(evt.isGroup())
  {
    println("MAIN GROUP");
    /*
     String gName = evt.getGroup().getName();
     int iselect = (int)evt.getGroup().getValue();
     if(gName.equals("SerialPort"))
     {
       
       println("SERIALPORT :"+iselect+" " );
     }
     else if(gName.equals("BAUDRATE"))
       arduino.baudFromGUI();
     //println("event from group : "+evt.getGroup().getValue()+" from "+evt.getGroup());
     println("event from group : "+evt.getGroup().getValue()+" from "+gName);
    */
  }
  else if(evt.isController())  
  {
    int evId = evt.getController().getId();
    String evAdrr = evt.getController().getAddress();
    String evName = evt.getController().getName();
    //println("controlEvent "+evName);
    /*
    if( evName.equals("ARDUINO") )
    {
      //arduino.toggleOnOff(); //bloquant ... 
      action = 1;
    }
    else if( evName.equals("SCAN") )
      arduino.list();
    else if( evName.equals("SEND") )
      arduino.serialSend();
    else if( evName.equals("CLEAR") )
      arduino.clearTerminal();
      */
  }
  else
    println("UNKNOWN EVENT");
}

void serialEvent(Serial serial)
{
  try{
    
  if( serial == arduino.serial )
  {
    arduino.serialRcv();
    //arduino.append("received "+serialEventCount+'\n');
  }
  }catch(Exception e){println("SERIAL EXCEPTION");}
  
  /*
  else
  {
    println("serial ?????????");
    while(serial.available()>0)
      serial.read();
  }
  */
}

void keyReleased()
{
  if(key==CODED)
  {
    switch(keyCode)
    {
      case SHIFT: keyModifier   &= ~1; break;
      case CONTROL: keyModifier &= ~2; break;
      case ALT: keyModifier     &= ~4; break;
    }
  }
}


void keyPressed()
{ 
  //print("KEY "+(int)key+" "+(int)keyCode);
  //if(key>32)print(" "+key);
  //if( (keyCode>32)&&(keyCode<256) )print(" "+(char)keyCode);
  //println(" ");
    
  if(key==CODED)
  {
    switch(keyCode)
    {
      case SHIFT: keyModifier   |= 1; break;
      case CONTROL: keyModifier |= 2; break;
      case ALT: keyModifier     |= 4; break;
    }
  }
  else if(keyModifier!=0) //GRRRR SHIFT CTRL ALT
  {
    if( (keyModifier & 1)!=0 )  
      keyCode = SHIFT;
    else if( (keyModifier & 2)!=0 )
    {
      key = (char)keyCode; //GRRRRRRRRRRRRR
      keyCode = CONTROL;
    }
    else if( (keyModifier & 4)!=0 )
    {
      key = (char)keyCode; //majuscule plutot que minuscule
      keyCode = ALT;
    }
    //EMERGENCY STOP : SHIFT or CTRL or ALT + ' 'or ENTER or BACKSPACE
    if( (key==32)||(key==10)||(key==13)||(key==8) ) // BACKSPACE --> STOP ALL
      arduino.serialSend("S\n");

  }
  /*
  if( editHandleKey(key,keyCode) )
    return;
  */  
  if( keyCode == CONTROL )
  {
    //if(key=='A')
    //  anim.fromListEdit(editAnim);
  }  
    
/*  
  if( (key=='s')||(key=='S') )
  {
    println(" kmod "+keyModifier );
  }
*/  
  
}

