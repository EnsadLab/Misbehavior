/*******************************************************************************                                                   
*   Copyright 2013-2014 EnsadLab/Reflective interaction                        *
*   Copyright 2013-2014 Didier Bouchon, Cecile Bucher                          *
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


/* In order to run the MisB gui, the libraries TheMidiBus and controlP5 need to be installed.
 * Under the menu Sketch, select "Import Library" and then "Add Library".
 * In the pop-up window, filter the two above libraries and add them to your processing application.
 */

import themidibus.*;
import processing.serial.*;
import controlP5.*;

String configFile = "config.xml"; // please insert you own configuration in the config.xml file
String animConfigPath = "config_ANIM.xml"; // this file is updated automatically and list all animations that you select through the gui

PApplet  mainApp;
ControlP5 cp5;
int globalID = 0;
int keyModifier = 0; //1 shift 2ctrl 4alt 

// fonts used throughout the application
PFont courrierFont = createFont("Courier New",12,false); // use true/false for smooth/no-smooth
PFont consolasFont = createFont("Consolas Bold",18,true);
PFont verdanaFont_16 = createFont("Verdana",16,true);
PFont verdanaFont_14 = createFont("Verdana",14,true);
PFont verdanaFont_13 = createFont("Verdana",13,true);
PFont verdanaFont_12 = createFont("Verdana",12,true);
PFont verdanaFont_11 = createFont("Verdana",11,true);
PFont verdanaFont_10 = createFont("Verdana",10,true);

// main objects
ComCM9          comCM9;
DxlControl      dxlGui;
ServoArray      servoArray;
ServoGUIarray   servoGUIarray;
ScriptArray     scriptArray;
SensorGUIarray  sensorGUI;
AnimTab         animTab;
EventTab        eventTab;

// GUI tabs
String tabNameAnim = "default"; // the identifier name is different from the label for the default tab.
String tabNameEvent    = "EVENTS";
String tabNameAdvanced = "ADVANCED";
String tabNameAbout = "ABOUT";
int tabIdEvent   = 3;
int currentTabId = 1; // 1:default tab / 2:ADVANCED tab /3:EVENT tab

// these values will be overriden with the value set in the config.xml file
String cm9_port = "COM13"; 
int cm9_baudrate = 57600; 
String midiInDevice = null; 
String midiOutDevice = null;
int nbMotors = 0;

int[] motorIds;
int[] jointwheelmodes;
String[] animPaths;
int nbAnims = 0;
int nbAnimsMax = 27; // Fixed by the size of the window. TODO: add some scrolling

// margin variables
int marginLeft = 40;
int marginTop = 50;

String credits;


void setup()
{
  
  // general setting
  mainApp = this;
  size(1280,720);
  frame.setTitle("MisB");
  cp5 = new ControlP5(this);
  globalID = 200;
  
  // create our three tabs. Per default, just the tab ANIMATION and the tab EVENT are displayed
  cp5.getTab("default")
     .setLabel("ANIMATION")
     .activateEvent(true)
     .setMoveable(true)
     .setId(1)
     ;
  cp5.addTab(tabNameEvent)
     .activateEvent(true)
     .setId(tabIdEvent);
  cp5.addTab(tabNameAbout)
     .activateEvent(true)
     .setId(4);
  cp5.addTab(tabNameAdvanced)
     .activateEvent(true)
     .setId(2)
     .hide()
     ;

  // load our configurations and the animations
  loadConfig(sketchPath+"/"+configFile);
  loadAnim(sketchPath+"/"+animConfigPath);
  
  int wFirstColumn = 160;
  int space = 20;
  
  comCM9 = new ComCM9(cm9_port,cm9_baudrate);
  comCM9.buildBasicGUI(marginLeft,marginTop,tabNameAnim,wFirstColumn,50);
  comCM9.buildGUI(marginLeft,marginTop,tabNameAdvanced);

  servoArray = new ServoArray(motorIds,jointwheelmodes);
       
  dxlGui = new DxlControl();
  dxlGui.buildGUI(1050,70,tabNameAdvanced);
    
  servoGUIarray = new ServoGUIarray(motorIds,jointwheelmodes);

  servoGUIarray.buildGUI(260,40,tabNameAdvanced);
  servoGUIarray.buildMotorGui(marginLeft+wFirstColumn+space,marginTop,tabNameAnim);
 
  animTab = new AnimTab();
  animTab.buildGUI(marginLeft, 220, tabNameAnim,wFirstColumn+space);

  eventTab = new EventTab();
  eventTab.buildGUI(30,30,tabNameEvent);
  eventTab.load(sketchPath+"/events.xml");
    
  scriptArray = new ScriptArray(motorIds.length );
  scriptArray.buildGUI(260,70,456,tabNameAdvanced);

  /* Removing Script experiment 
  if(motorIds.length >= 2)
  {
    scriptArray.scriptAt(0).load("scripts/Script00.txt"); 
    scriptArray.scriptAt(1).load("scripts/Script00.txt"); 
  }
  */
  listMidiDevices();
  if( (midiInDevice!=null)&&(midiOutDevice!=null) ) //defined in the config.xml file
    openMidi(midiInDevice,midiOutDevice);
    
  credits = "MisB KIT est développé par l’équipe Reflective Interaction, sous la direction de Samuel Bianchini, par Didier Bouchon, Cécile Bucher, Martin Gautron, Benoît Verjat et Alexandre Saunier, dans le cadre du projet The Behaviour of Things, coordonné par Emanuele Quinz pour le compte du Labex Arts-H2H.";
  credits += "L’ensemble des développements du MisB KIT, hardware comme software, sont sous Licence LGPL, à l’exception des modules propriétaires Bioloid que nous utilisons, principalement les moteurs Dynamixels et des pièces de jeu de construction K’Nex employés ici comme éléments de structure.";
  credits += "Ce toolkit a été initié avec l’équipe Sociable Media (dirigée par Rémy Bourganel) avec en particulier Émeline Brulé et Max Mollon, pour le Workshop “The Misbehavior of Animated Objects”, TEI 2014, avec le soutien du Labex Arts-H2H et de la Fondation Bettencourt Schueller dans le cadre de la Chaire Innovation et Savoir faire et avec la participation de Jean-Baptiste Labrune et Nicolas Nova.";
  credits += "Nous remercions la société Génération Robots pour leurs conseils avisés, ainsi que Marie Descourtieux, Hiroshi Ishii, Emmanuel Mahé et Élodie Tincq.";
  
}

void draw()
{
  if(currentTabId == 1 || currentTabId == 4) // tab BASIC or ABOUT
  {
    background(255);
  }
  else // tab EVENT or ADVANCED
  {
    background(240);
    eventTab.update();
  } 
  
  if(currentTabId == 4)
  {
    fill(50);
    textFont(verdanaFont_12);
    text(credits, marginLeft, marginTop, 600, 600);  // Text wraps within text box
  }
  //scriptArray.update(); //removing Script experiment
  servoArray.update();
  servoGUIarray.update();
  comCM9.update();  
  dxlGui.update();
  animTab.update();
}

void exit()
{
  comCM9.close();
  eventTab.save(sketchPath+"/events.xml");
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
  
  // CM9 configuration
  try{cm9_port = xml.getChild("cm9").getString("port");}catch(Exception e){}
  try{cm9_baudrate = xml.getChild("cm9").getInt("bauds");}catch(Exception e){}
  println("-> cm9 port="+cm9_port + " bauds=" + cm9_baudrate);

  // Motors configuration
  XML[] children;
  try{
    children = xml.getChildren("motor");
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
  }
  catch(Exception e){}
  
  // MIDI configuration
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
  
  XML[] children;
  try{
    children = xml.getChildren("anim");
    nbAnims = children.length;
    animPaths = new String[nbAnims];
    for(int i=0; i<children.length; i++)
    {
      String animPath = children[i].getString("path");
      animPaths[i] = animPath;
      println("-> adding anim with path " + animPath);
    }
  }
  catch(Exception e){}
  
}

void controlEvent(ControlEvent evt)
{
  if(evt.isTab())
  {
    //println("TAB " + evt.getTab().getName() + " IS SELECTED with id " + evt.getTab().getId());
    currentTabId = evt.getTab().getId();
    if(currentTabId == tabIdEvent) 
      eventTab.onOpen();
    else
      eventTab.onClose();
  }
}

void serialEvent(Serial serial)
{
  try{      
    if( serial == comCM9.serial )
    {
      comCM9.serialRcv();
    }
  }catch(Exception e){println("SERIAL EXCEPTION");}  
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
      case SHIFT:   keyModifier &= ~1; break;
      case CONTROL: keyModifier &= ~2; break;
      case ALT:     keyModifier &= ~4; break;
    }
  }
}

void keyPressed()
{ 
  if(key==CODED)
  {
    switch(keyCode)
    {
      case SHIFT:   keyModifier |= 1; break;
      case CONTROL: keyModifier |= 2; break;
      case ALT:     keyModifier |= 4; break;
    }
  }
  else if(keyModifier!=0) //GRRRR SHIFT CTRL ALT
  {
    if( (keyModifier & 1)!=0 )      //SHIFT  
      keyCode = SHIFT;
    else if( (keyModifier & 2)!=0 ) //CTRL
    {
      //println("dbg CONTROL key"+(int)key+" "+(int)keyCode );
      key = (char)keyCode; //
      keyCode = CONTROL;
      if(key==9) //TAB
        toggleAdvancedTab();
    }
    else if( (keyModifier & 4)!=0 ) //ALT
    {
      key = (char)keyCode; //majuscule plutot que minuscule
      keyCode = ALT;
    }
    
    //EMERGENCY STOP : SHIFT or CTRL or ALT + ' 'or ENTER or BACKSPACE
    if( (key==32)||(key==10)||(key==13)||(key==8) ) // BACKSPACE --> STOP ALL
      comCM9.serialSend("S\n");

  }
  
}





