/*******************************************************************************                                                   
*   Copyright 2013-2014 EnsadLab/Reflective interaction                        *
*   Copyright 2013-2014 Didier Boucher, Cecile Bucher                          *
*                                                                              *
*   This file is part of MisB.                                                 *
*                                                                              *
*   MisB is free software: you can redistribute it and/or modify               *
*   it under the terms of the Lesser GNU General Public License as             *
*   published by the Free Software Foundation, either version 3 of the         *
*   License, or (at your option) any later version.                            *
*                                                                              *
*   MisB is distributed in the hope that it will be useful,                    *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of             *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
*   GNU Lesser General Public License for more details.                        *
*                                                                              *
*   You should have received a copy of the GNU Lesser General Public License   *
*   along with MisB.  If not, see <http://www.gnu.org/licenses/>.              *
*******************************************************************************/

// In order to run the MisB gui, the libraries TheMidiBus and controlP5 needs to be installed.
// Under the menu Sketch, select "Import Library" and then "Add Library".
// In the pop-up window, filter the two above libraries and add them to your processing application.

import themidibus.*;
import processing.serial.*;
import controlP5.*;

String configFile = "config.xml";
String animConfigPath = "config_ANIM.xml";

PApplet  mainApp;
int keyModifier = 0; //1 shift 2ctrl 4alt 

PFont courrierFont; // = createFont("Arial",20,true); // use true/false for smooth/no-smooth
PFont verdanaFont; //
PFont testFont;

PFont verdanaFont_16 = createFont("Verdana",16,true);
PFont verdanaFont_14 = createFont("Verdana",14,true);
PFont verdanaFont_13 = createFont("Verdana",13,true);
PFont verdanaFont_12 = createFont("Verdana",12,true);
PFont verdanaFont_11 = createFont("Verdana",11,true);
PFont verdanaFont_10 = createFont("Verdana",10,true);

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

int nbMotors = 0; // this value will be overriden with the value set in the config.xml file
int[] motorIds;
int[] jointwheelmodes;
String[] animPaths;
int nbAnims = 0;
int nbAnimsMax = 27; // Fixed by the size of the window. TODO: add some scrolling

// these values will be overriden with the value set in the config.xml file
String arduinoPort = "COM13"; 
int arduinoBaudRate = 57600; 
String midiInDevice = null; 
String midiOutDevice = null;

// gui variables
int marginLeft = 40;
int marginTop = 50;




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
     .setId(3);
  
  cp5.addTab(tabNameAdvanced)
     .activateEvent(true)
     .setId(2)
     //.hide()
     ;
     
  cp5.getTab("default")
     .setLabel("ANIMATION")
     .activateEvent(true)
     .setMoveable(true)
     .setId(1)
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

  listMidiDevices();
  if( (midiInDevice!=null)&&(midiOutDevice!=null) ) //config
    openMidi(midiInDevice,midiOutDevice);
  
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
    eventGUI.update();
  } 
  
  scriptArray.update();
  servoArray.update();
  servoGUIarray.update();
  arduino.update();  
  dxlGui.update();
  animGUI.update();
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
  
}



