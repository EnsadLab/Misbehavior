
import processing.serial.*;
import controlP5.*;
import themidibus.*;

PApplet  mainApp;

CommIno  arduino;
ServoArray servoArray;

int serialEventCount = 0;

DXLmotor dxlGui;
MotorGroup motorGroup;

ControlP5 cp5;
int globalID = 0;  //GRRRR
int myColor = color(0,0,0);

String tabNameBasic = "default"; // the identifier name is different from the label for the default tab.
String tabNameAdvanced = "ADVANCED";
int currentTabId = 1; // 1:default tab / 2:ADVANCED tab

int nbMotors = 4; // default value. Might be overriden with value set in the config.xml file
int[] motorIds;
String[] animPaths;
int nbAnims = 0;
int nbAnimsMax = 18; 
String arduinoPort;
int arduinoBaudRate;

//int sliderValue = 100;
//int sliderTicks1 = 100;
//int sliderTicks2 = 30;
//Slider abc;

void setup()
{
  mainApp = this;
  size(1150,800); //P3D OPENGL
  frame.setTitle("Toolkit");
  
  cp5 = new ControlP5(this);
  globalID = 200;
  
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
  
  arduino = new CommIno(arduinoPort,arduinoBaudRate);
  arduino.buildGUI(150,20,tabNameAdvanced);
  arduino.buildBasicGUI(20,50,tabNameBasic);

  servoArray = new ServoArray(motorIds);
  
  // Fo now, we display it just in the advanced tab
  dxlGui = new DXLmotor();
  dxlGui.buildGUI(100,20,tabNameAdvanced);
  
  motorGroup = new MotorGroup(motorIds);
  motorGroup.buildGUI(350,20,tabNameAdvanced);
  motorGroup.buildBasicGui(250,50,tabNameBasic);
  
  //anim = new Anim();
  //animGui = new AnimGui();
  //animGui.buildGUI(500,50,550);
}

void loadConfig(String xmlFilePath)
{
  
  println("Loading Config file...");
  XML xml = loadXML(xmlFilePath);
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

void draw()
{  
  if(currentTabId == 1) // tab BASIC
  {
    background(255);
  }
  else // tab ADVANCED
  {
    background(128);
  } 
  //anim.update();
  servoArray.update();
  motorGroup.update();
  arduino.update();  
  dxlGui.update();
  
  // in order TO REMOVE THE GRAPH FROM THE BASIC TAB. Although useful if speed value needed...blablablabla...
  if(currentTabId != 1)
  {
    servoArray.draw(500,20);
  }
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


void controlEvent(ControlEvent evt)
{
  
  if(evt.isGroup())
  {
    println("MAIN GROUP");
  }
  else if(evt.isTab())
  {
    println("TAB "+evt.getTab().getName()+" IS SELECTED with id "+evt.getTab().getId());
    currentTabId = evt.getTab().getId();
  }
  else if(evt.isController())  
  {
    int evId = evt.getController().getId();
    String evAdrr = evt.getController().getAddress();
    String evName = evt.getController().getName();
    //println("controlEvent "+evName);
  }
  else
    println("UNKNOWN EVENT");
    
}

void serialEvent(Serial serial)
{
  if( serial == arduino.serial )
  {
    arduino.serialRcv();
    //arduino.append("received "+serialEventCount+'\n');
  }
  /*
  else
  {
    while(serial.available()>0)
      serial.read();
  }
  */
  serialEventCount++;
}
