import themidibus.*;
import processing.serial.*;
import controlP5.*;

//String configFile = "config.xml";
String configFile = "config_cbu.xml";
//String configFile = "config_dib.xml";


PApplet  mainApp;
int keyModifier = 0; //1 shift 2ctrl 4alt 

PFont courrierFont; // = createFont("Arial",20,true); // use true/false for smooth/no-smooth
PFont verdanaFont; //
PFont testFont;

CommArduino     arduino;
DxlControl      dxlGui;
ServoArray      servoArray;
ServoGUIarray   servoGUIarray;
ScriptArray     scriptArray;
SensorGUIarray  sensorGUI;
AnimGUI        animGUI;

EventGUI eventGUI;

ControlP5 cp5;
int globalID = 0;

String tabNameBasic = "default"; // the identifier name is different from the label for the default tab.
String tabNameAdvanced = "ADVANCED";
String tabNameEvent    = "EVENTS";
int currentTabId = 1; // 1:default tab / 2:ADVANCED tab

int nbMotors = 4; // default value. Might be overriden with value set in the config.xml file
int[] motorIds;
int[] jointwheelmodes;
String[] animPaths;
int nbAnims = 0;
int nbAnimsMax = 27;

String arduinoPort = "COM13";
int arduinoBaudRate = 57600;

String midiInDevice = null; 
String midiOutDevice = null;

int marginLeft = 40;
int marginTop = 50;

String animConfigPath = "config_ANIM.xml";


void setup()
{
  
  mainApp = this;
  size(1280,720); //P3D OPENGL
  
  frame.setTitle("Misbehaviors toolkit");
  
  println("Path:"+sketchPath);
  
  cp5 = new ControlP5(this);
  globalID = 200;
  
  courrierFont = createFont("Courier New",12,false); // use true/false for smooth/no-smooth
  verdanaFont  = createFont("Verdana",12,true);
  testFont = createFont("Consolas Bold",18,true);
  
  //cp5.setControlFont(testFont);

  cp5.addTab(tabNameEvent)
     .activateEvent(true)
     //.setColorLabel(color(255))
     //.setColorActive(color(200,200,200))
     .setId(3);
  
  cp5.addTab(tabNameAdvanced)
     .activateEvent(true)
     .setId(2)
     //.hide()
     ;
     //.setColorBackground(color(255, 160, 100))
     //.setColorLabel(color(0,0,0))
     //.setColorActive(color(255,128,255));
  cp5.getTab("default")
     .setLabel("ANIMATION")
     .activateEvent(true)
     .setMoveable(true)
     .setId(1)
     //.setColorBackground(color(0, 160, 100))
     //.setColorLabel(color(255))
     //.setColorActive(color(0,138,98));
     ;

  loadConfig(sketchPath+"/"+configFile);
  loadAnim(animConfigPath);
  
  int wFirstColumn = 160;
  int space = 20;
  
  arduino = new CommArduino(arduinoPort,arduinoBaudRate);
  arduino.buildBasicGUI(marginLeft,marginTop,tabNameBasic,wFirstColumn,50);
  arduino.buildGUI(marginLeft,marginTop,tabNameAdvanced);

  servoArray = new ServoArray(motorIds,jointwheelmodes);
       
  dxlGui = new DxlControl();
  dxlGui.buildGUI(1050,70,tabNameAdvanced);
    
  servoGUIarray = new ServoGUIarray(motorIds,jointwheelmodes);

  servoGUIarray.buildGUI(260,40,tabNameAdvanced);
  servoGUIarray.buildMotorGui(marginLeft+wFirstColumn+space,marginTop,tabNameBasic);
 
  animGUI = new AnimGUI();
  animGUI.buildGUI(marginLeft, 220, tabNameBasic,wFirstColumn+space);

  eventGUI = new EventGUI();
  eventGUI.buildGUI(30,30,tabNameEvent);
  eventGUI.load(sketchPath+"/events.xml");
    
  scriptArray = new ScriptArray(motorIds.length );
  scriptArray.buildGUI(260,70,456,tabNameAdvanced);  //TODO ... more than 2 scripts
  scriptArray.scriptAt(0).load("scripts/Script00.txt"); //<<< TODO config.xml
  scriptArray.scriptAt(1).load("scripts/Script00.txt"); //<<< TODO config.xml

/*  
  sensorArray = new SensorArray();
  sensorArray.loadConfig("config_MIDI.xml");
  sensorGUI = new SensorGUIarray();
  //sensorGUI.buildGUI(280,5,tabNameEvent);
*/

  //listMidiDevices();
  if( (midiInDevice!=null)&&(midiOutDevice!=null) ) //config
    openMidi(midiInDevice,midiOutDevice);

  //String[] fonts = PFont.list();
  //println(fonts);
  
  //threadTest = new ThreadTest(); //,"le thread");
  //threadTest.start();
  
}

void draw()
{
  if(currentTabId == 1) // tab BASIC
  {
    background(255);
  }
  else // tab ADVANCED
  {
    background(240);
    //eventGUI.draw();
    eventGUI.update();
  } 
  
  scriptArray.update();
  //scriptGuiArray[0].update();
  servoArray.update();
  servoGUIarray.update();
  arduino.update();  
  dxlGui.update();
  animGUI.update();
  
  //servoArray.draw(500,20);
  //curve.test(500,100,1300,500);
}

void exit()
{
  arduino.close();
  eventGUI.save(sketchPath+"/events.xml");
  println("EXIT");  
  super.exit();  
}

void loadConfig(String xmlFilePath)
{
  println("Loading Config file...");
  XML xml = loadXML(xmlFilePath);
  if(xml==null)
  {
    println("[ERROR]: config file " + xmlFilePath + " could not be loaded");
    return;    
  }
  
  XML[] children = xml.getChildren("motor");
  
  arduinoPort = xml.getChild("arduino").getString("port");
  arduinoBaudRate = xml.getChild("arduino").getInt("bauds");
  println("-> Arduino port="+arduinoPort + " bauds=" + arduinoBaudRate);

  nbMotors = children.length;
  motorIds = new int[nbMotors];
  jointwheelmodes = new int[nbMotors];
  for (int i = 0; i < children.length; i++) {
    int id = children[i].getInt("id");
    motorIds[i] = id;
    String jointwheelmode = children[i].getString("mode");
    if(jointwheelmode.equals("joint"))
    {
      jointwheelmodes[i] = 0;
    }
    else
    {
      jointwheelmodes[i] = 1;
    }
    
    println("-> adding motor with id " + id + " in mode " + jointwheelmode);
  }
  
  try{midiInDevice  = xml.getChild("midi").getString("in");}catch(Exception e){}
  try{midiOutDevice = xml.getChild("midi").getString("out");}catch(Exception e){}
  println("MIDIin  "+midiInDevice);
  println("MIDIout "+midiOutDevice);  
}

void loadAnim(String xmlFilePath)
{
  println("Loading ANIM Config file...");
  XML xml = loadXML(xmlFilePath);
  if(xml==null)
  {
    println("[ERROR]: config ANIM file " + xmlFilePath + " could not be loaded");
    return;    
  }
  XML[] children = xml.getChildren("anim");
  nbAnims = children.length;
  animPaths = new String[nbAnims];
  //animPaths = new String[nbAnimsMax];
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
    if(currentTabId == 3) //TODO 3 ???
      eventGUI.onOpen();
    else
      eventGUI.onClose();
    
      
  }
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

void toggleAdvancedTab()
{
    if(cp5.getTab(tabNameAdvanced).isVisible())
    {
      cp5.getTab(tabNameAdvanced).hide();
    }
    else
    {
      cp5.getTab(tabNameAdvanced).show();
    }
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
/*
    if(keyCode == SHIFT) // TODO: @Didier: on peut changer is jamais... j'y voyais pas très clair ds cette methode
    {
      if(cp5.getTab(tabNameAdvanced).isVisible())
      {
        cp5.getTab(tabNameAdvanced).hide();
      }
      else
      {
        cp5.getTab(tabNameAdvanced).show();
      }
    }
*/

  }
  else if(keyModifier!=0) //GRRRR SHIFT CTRL ALT
  {
    if( (keyModifier & 1)!=0 )  
      keyCode = SHIFT;
    else if( (keyModifier & 2)!=0 )
    {
      println("dbg CONTROL key"+(int)key+" "+(int)keyCode );
      
      key = (char)keyCode; //GRRRRRRRRRRRRR
      keyCode = CONTROL;
      
      if(key==9) //TAB
        toggleAdvancedTab();

        
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



