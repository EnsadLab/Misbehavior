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

int animLabelColumnWidth;
int space = 30;
int toggleSize = 20;
int spaceBetweenToggle = 10;
int secondColumnX = 650;
int spaceBetweenLines = 15;
PImage playImage;

class AnimGUI implements ControlListener
{
  
  Anim[] anims;
  Toggle recButtonPlayPause;
  Toggle[] motorToggles;
  Textfield recordLabelTextField;
  Button scanAnimFolder;
  DropdownList availableAnims;
  Toggle fakeDDBackground;
  boolean oldDDopenStatus = false;
  WavEncoder wavEncoder = new WavEncoder(); 
  int nbAvailableAnims = 0;
  Toggle fakeToggleSecond;
  Toggle fakeToggleMotorSecond;
  Textlabel labelAnimSecond;
  Textlabel labelMotorSecond;

  AnimGUI()
  {
    
  }


  String getAnimLabel(int i)
  {
    if( (i>=0)&&(i<anims.length) )
      return anims[i].label;
    return null;
  }
  
  IntDict getAnimLabels()
  {
    IntDict dict = new IntDict();
    for(int i=0;i<anims.length;i++)
    {
      if( (anims[i].label!=null)&&(!anims[i].label.isEmpty()) )
      {
        dict.set(anims[i].label,i);        
      }      
    }
    return dict;    
  }
  
  
  boolean isAnimPlaying(int iAnim)
  {
    if( (iAnim>=0)&&(iAnim<anims.length) )
      return anims[iAnim].animPlayButton.isOn(); 

    return false;
  }


  float getProgress(int iAnim)
  {
    if( (iAnim>=0)&&(iAnim<anims.length) )
      return anims[iAnim].progress;
    return 0;
  }

    
  void buildGUI(int x, int y, String tabName, int animLabelColumnW)
  {
    
     playImage = loadImage("images/playButton.jpg");

     animLabelColumnWidth = animLabelColumnW;
    
     Toggle fakeToggle = cp5.addToggle("FAKETOGGLE")
        .setPosition(x,y)
        .setColorBackground(0xFF008A62)
        .setSize(animLabelColumnWidth-toggleSize,30)
        .lock()
        .moveTo(tabName);
        
     Textlabel label = cp5.addTextlabel("ANIMATIONS_gui")
              .setText("Animations")
              .setPosition(x+30,y+5)
              .setColorValueLabel(0xFFFFFFFF)
              .setFont(verdanaFont_14)
              .moveTo(tabName);
    
     cp5.addToggle("FAKETOGGLEMOTORS")
        .setPosition(x+animLabelColumnWidth,y)
        .setColorBackground(0xFF792e3f)
        .setSize(motorColumnWidth,30)
        .lock()
        .moveTo(tabName);
        
              
     label = cp5.addTextlabel("MOTORS_gui")
              .setText("Motors")
              .setPosition(x+animLabelColumnWidth+motorColumnWidth/2-30,y+5)
              .setColorValue(0xFFFFFFFF)
              .setFont(verdanaFont_14)
              .moveTo(tabName);
              ;
     fakeToggleSecond = cp5.addToggle("FAKETOGGLE2").setPosition(secondColumnX,marginTop).setColorBackground(0xFF008A62).setSize(animLabelColumnWidth-toggleSize,30).lock().moveTo(tabName).hide();
     labelAnimSecond = cp5.addTextlabel("ANIMATIONS_gui2").setText("Animations").setPosition(secondColumnX+30,marginTop+5).setColorValueLabel(0xFFFFFFFF).setFont(verdanaFont_14).moveTo(tabName).hide();
     fakeToggleMotorSecond = cp5.addToggle("FAKETOGGLEMOTORS2").setPosition(secondColumnX+animLabelColumnWidth,marginTop).setColorBackground(0xFF792e3f).setSize(motorColumnWidth,30).lock().moveTo(tabName).hide();
     labelMotorSecond = cp5.addTextlabel("MOTORS_gui2").setText("Motors").setPosition(secondColumnX+animLabelColumnWidth+motorColumnWidth/2-30,marginTop+5).setColorValue(0xFFFFFFFF).setFont(verdanaFont_14).moveTo(tabName).hide();
   
     int xLabels = x + animLabelColumnWidth + motorColumnWidth + 16;
     int yLabels = y + 110;
     // create labels play,loop et etc...
     label = cp5.addTextlabel("labelPlay").setPosition(xLabels,yLabels).setText("Play").setColor(color(0,138,98)).moveTo(tabName).setFont(verdanaFont_10); xLabels += toggleSize + spaceBetweenToggle;
     label = cp5.addTextlabel("labelLoop").setPosition(xLabels,yLabels).setText("Loop").setColor(color(0,138,98)).moveTo(tabName).setFont(verdanaFont_10); xLabels += 2*toggleSize + spaceBetweenToggle;
     label = cp5.addTextlabel("labelProgress").setPosition(xLabels,yLabels).setText("Progress").setColor(color(0,138,98)).moveTo(tabName).setFont(verdanaFont_10); xLabels += 3*toggleSize + spaceBetweenToggle;
     label = cp5.addTextlabel("labelSpeed").setPosition(xLabels,yLabels).setText("Speed").setColor(color(0,138,98)).moveTo(tabName).setFont(verdanaFont_10);
     y += 50;
     
     buildRecordGui(x,y,tabName);
     y += 40;
     
     int yScanAnimTemp = y;
     int xScanAnimTemp = x; 
     y += 40;
     
     int yTemp = y;
     anims = new Anim[nbAnimsMax];   
     for(int i=0; i<anims.length; i++)
     {
       if(i == 10)
       {
         y = marginTop+57;
         x = secondColumnX;
       }
       anims[i] = new Anim();
       anims[i].buildGui(x,y,tabName,i);
       y += toggleSize  + spaceBetweenLines;
     }
          
     for(int i=0; i<animPaths.length; i++)
     {
         //anims
         if(i < anims.length)
         {
           anims[i].setAnim(animPaths[i]);
         }
     }
     
     if(animPaths.length >= 11)
     {
        fakeToggleSecond.show();
        fakeToggleMotorSecond.show();
        labelAnimSecond.show();
        labelMotorSecond.show();
     }
     
     fakeDDBackground = cp5.addToggle("FAKEBACKGROUND")
                   .setPosition(xScanAnimTemp, yScanAnimTemp)
                   .setSize(animLabelColumnWidth-toggleSize,170)
                   .setLock(true)
                   .moveTo(tabName)
                   .hide()
                   .setColorBackground(0xFFFFFFFF)
                   .setCaptionLabel("")
                   ;
     
     availableAnims = cp5.addDropdownList("AVAILABLEANIMS")
          .setPosition(xScanAnimTemp, yScanAnimTemp+toggleSize)
          .setSize(animLabelColumnWidth-toggleSize,250)
          .moveTo(tabName)
          .setItemHeight(toggleSize)
          .addListener(this)
          .setBarHeight(toggleSize)
          .setColorForeground(color(128,197,176))
          .setColorBackground(color(204,232,224))
          .setColorActive(color(0,138,98))
          .setColorLabel(0xFF000000)
          .toUpperCase(false)
          ;
     availableAnims.captionLabel().set("Load animation").setFont(verdanaFont_11).align(ControlP5.LEFT,ControlP5.CENTER);
     availableAnims.valueLabel().setFont(verdanaFont_13).setColor(0xFFFF0000).align(ControlP5.CENTER,ControlP5.CENTER); // ne marche pas.........
     updateDropDownAnimList();
     
  }
  
  void buildRecordGui(int x, int y, String tabName)
  {
    
    recordLabelTextField = cp5.addTextfield("RECORDTEXTFIELD")
                  .setPosition(x,y)
                  .setSize(animLabelColumnWidth-toggleSize,toggleSize)
                  .setColorForeground(color(255,0,0))
                  .setColor(color(255,0,0))
                  .setColorBackground(0xFFE0D0D0)
                  .setColorActive(color(255,0,0))
                  .setAutoClear(false)
                  .moveTo(tabName)
                  .addListener(this)
                  .setColorValueLabel(0xFF000000)
                  ;
     recordLabelTextField.getValueLabel().setFont(verdanaFont_13).align(ControlP5.LEFT,ControlP5.CENTER);
     
     motorToggles = new Toggle[nbMotors];
     x += animLabelColumnWidth;
     for(int i=0; i<motorToggles.length ; i++)
     {
       motorToggles[i] = cp5.addToggle("MOTORTOGGLERECORD_"+i)
       .setPosition(x,y)
       .setSize(toggleSize,toggleSize)
       .setValue(true)
       .setColorForeground(color(255,129,129))
       .setColorBackground(0xFFFFCCCC)
       .setColorActive(color(255,0,0))
       .setState(false)
       .moveTo(tabName)
       .addListener(this)
       ;
       x+= toggleSize + spaceBetweenToggle;
     }
     
     x -= spaceBetweenToggle;
     
     recButtonPlayPause = cp5.addToggle("RECPLAY_gui")
         .setPosition(x+toggleSize,y)
         .setColorForeground(color(255,0,0))
         .setColorBackground(0xFFFF0000)
         .setColorActive(color(255,0,0))
        .setSize(2*toggleSize,toggleSize)
        .moveTo(tabName)
        .setCaptionLabel("REC");
     recButtonPlayPause.getCaptionLabel().setFont(verdanaFont_12).align(ControlP5.CENTER,ControlP5.CENTER);
     recButtonPlayPause.addListener(this);
     
  }
  
  
  void updateDropDownAnimList()
  {
     availableAnims.clear();
     nbAvailableAnims = 0;
    
     File dossier = new File(sketchPath + "/anims");
     String[] fichiers = dossier.list();
     //println(fichiers);
     int index = 0;
     for(int i=0; i<fichiers.length; i++)
     {
       String f = fichiers[i];
       String ext = f.substring(f.length()-4,f.length());
       if(ext.equals(".wav") && !isAlreadyImported("anims/"+f))
       {
         ListBoxItem item = availableAnims.addItem(""+fichiers[i], index);
         index++;
         nbAvailableAnims++;
       }
       
     }
     availableAnims.captionLabel().set("Load animation");
    
  }
  
  
  boolean isAlreadyImported(String wavPath)
  {
    int index = 0;
    boolean found = false;
    while(index < anims.length)
    {
      if(anims[index].wavPath.equals(wavPath))
      {
        found = true;
        break;
      }
      index++;
    }
    return found;
  }
  
  
  void importNewAnimation(int line)
  {
    String newWavPath = availableAnims.getItem(line).getName();
    println("Import new animation: " + newWavPath);
    int index = 0;
    while(index < anims.length)
    {
      if(anims[index].isFree())
      {
        anims[index].setAnim("anims/"+newWavPath);
        break;
      }
      index++;
    }
    availableAnims.captionLabel().set("Load animation");
    updateAnimXml();
  }
  

  void startPlaying(int iAnim)
  {
    if( (iAnim>=0)&&(iAnim<anims.length) )
      anims[iAnim].animPlayButton.setOn();
  }


  void stopPlaying(int iAnim)
  {
    if( (iAnim>=0)&&(iAnim<anims.length) )
    {
      anims[iAnim].animPlayButton.setOff();
      anims[iAnim].stopPlaying();
    }
  }

  
  void startPlaying(String label)
  {
    for(int i=0; i<anims.length; i++)
    {
      if(anims[i].label.equals(label))
      {
        anims[i].startPlaying();
        break;
      }
    }
  }
  
  
  void startRecording()
  {
    
    for(int i=0; i<motorToggles.length ; i++)
    {
      motorToggles[i].setLock(true);
    }

    ServoDxl[] servos = servoArray.getServos();
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i] != null && servos[i].enableRecording)
      {
        servos[i].startRecording();
      }
    }
    
  }
  
  void stopRecording(String recordLabel)
  {
    //println("dbg STOP RECORDING 1");
    if(recordLabel.equals(""))
    {
      int d = day();   
      int m = month();
      int s = second();  
      int min = minute(); 
      int h = hour();    
      recordLabel = "D" + d + "-" + m + "-H" + h + "-" + min + "-" + s; // generate label according to date and time
    }
    String recordWavPath = "anims/" + recordLabel;
    
    // check which motor was enabled for recording and get recorded values
    ServoDxl[] servos = servoArray.getServos();
    int nbActivatedMotors = 0;
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i] != null)
      {
        if(servos[i].enableRecording)
        {
          recordWavPath += "_m" + i;
          nbActivatedMotors++;
        }
      }
    }
    
    for(int i=0; i<motorToggles.length ; i++)
    {
      motorToggles[i].setLock(false);
    }
    
    if(nbActivatedMotors == 0) return;
    
    float[][] recordValues = new float[nbActivatedMotors][0];
    int index = 0;
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i] != null)
      {
        if(servos[i].enableRecording)
        {
          recordValues[index] = servos[i].stopRecording();
          index++;
        }
      }
    }
    
    // save wav file
    recordWavPath += ".wav";
    if(wavEncoder == null) return;
    wavEncoder.writeWav(sketchPath+"/"+recordWavPath,recordValues[0].length,recordValues); // we know we have at least one chanel since nbActivatedMotors > 0
    
    // activate anim
    index = 0;
    while(index < anims.length)
    {
      if(anims[index].isFree())
      {
        anims[index].setAnim(recordWavPath);
        break;
      }
      index++;
    }
    
    // update anim config xml file
    updateAnimXml();
   
  }
  
  
  void selectForRecording(boolean select, int index)
  {
    ServoDxl servo = servoArray.getByIndex(index);
    if(servo != null)
    {
        servo.enableRecording = select;
        //println("SELECT for recording " + index + " " + select);
    }
  }
  
  void updateAnimXml()
  {
    XML xml = loadXML(animConfigPath); // we reload it in case file had been manually changed in between
    if(xml==null)
    {
      println("[ERROR]: config ANIM file " + animConfigPath + " could not be loaded");
      return;    
    }
    // addChild will append the new child at the end, but we want to have same ordering as in the gui so delete and recreate
    XML[] children = xml.getChildren("anim");
    for(int i=0; i<children.length; i++)
    {
      xml.removeChild(children[i]);
    }
    
    int count = 0;
    for(int i=0; i<anims.length; i++)
    {
      if(!(anims[i].wavPath.equals("")))
      {
        XML animChild = xml.addChild("anim");
        animChild.setString("path",anims[i].wavPath);
        count++;
      }
    }
    saveXML(xml,animConfigPath);
    
    if(count >= 11)
    {
        fakeToggleSecond.show();
        fakeToggleMotorSecond.show();
        labelAnimSecond.show();
        labelMotorSecond.show();
    }
    
  }
  
  void update()
  {
    for(int i=0; i<anims.length; i++)
    {
      anims[i].update();
    }
    if(oldDDopenStatus != availableAnims.isOpen())
    {
      if(availableAnims.isOpen())
      {
        updateDropDownAnimList(); // did not find a callback in cp5...
        fakeDDBackground.setHeight(nbAvailableAnims*toggleSize + toggleSize);
        fakeDDBackground.show(); 
      }
      else
      {
        fakeDDBackground.hide();
      }
    }
    oldDDopenStatus = availableAnims.isOpen();
  }
  
  
  void fileSelected(File selection) 
  {
    if (selection == null) 
    {
      println("Window was closed or the user hit cancel.");
    } 
    else 
    {
      println("User selected " + selection.getAbsolutePath());
    }
  }
  
  
  void controlEvent(ControlEvent evt)
  {
    if(evt.isGroup()) //dropdown list
    {
      ControlGroup g = evt.group();
      if( g == availableAnims )
      {
        int line = (int)g.value();
        importNewAnimation(line);
      }
    }
    
    if(!evt.isController())
    return;
  
    Controller c = evt.getController();
    if(c == recButtonPlayPause)
    {
      if(recButtonPlayPause.getState())
      {
        //println("-> start recording");
        recButtonPlayPause.setCaptionLabel("STOP");
        startRecording();
      }
      else
      {
        //println("-> stop recording");
        recButtonPlayPause.setCaptionLabel("REC");
        stopRecording(recordLabelTextField.getText());
      }
    }
    else if(c == scanAnimFolder)
    {
      updateDropDownAnimList();
    }
    
    String addr = c.getAddress();
    if(addr.startsWith("/MOTORTOGGLERECORD_"))
    {
      for(int i=0; i<motorToggles.length; i++)
      {
        if(c == motorToggles[i])
        {
          selectForRecording(motorToggles[i].getState(),i);
        }
      }
    }
    
  }
  
};



class Anim implements ControlListener
{
 
  Button deleteButton;
  Textlabel animLabel;
  Toggle[] motorToggles;
  Toggle[] playMotorToggles;
  Button animPlayButton;
  Toggle loopButton;
  Slider progressbar;
  Button speedIncrease;
  Button speedDecrease;
  Toggle fakeToggle;
  Textlabel speedLabel;
  float animSpeedSelected = 1.0;
  String label = "";
  String wavPath = "";
  PVector posDDSpeed;
  boolean free = true;
  boolean loop = false;
  long playframeTime;
  long recRate = 25; // sample rate for wavfile -> 1000/25=40, written directly in wavencoder class
  long playRate = 25;
  int nbFrames = 0;
  int currFrame = 0;
  float progress = 0.0;  
  WavEncoder wavEncoder = new WavEncoder(); 
  
  
  Anim()
  {
  
  }
  
  
  void buildGui(int x, int y, String tabName, int index)
  {
    
    
     deleteButton = cp5.addButton("DELTEBUTTON_"+index)
                  .setCaptionLabel("X")
                  .setPosition(x,y)
                  .setSize(toggleSize,toggleSize)
                  .setColorForeground(0xFFE3E3E3)
                  .setColorBackground(0xFFFFFFFF)
                  .setColorActive(0xFFE3E3E3)
                  .moveTo(tabName)
                  .hide()
                  .setLock(true)
                  .addListener(this)
                  ;  
     deleteButton.getCaptionLabel().setFont(verdanaFont_16).setColor(0xFF000000).align(ControlP5.CENTER,ControlP5.CENTER);
    
     animLabel = cp5.addTextlabel("ANIMLABEL_" + index)
                .setText("")
                .setPosition(x+toggleSize+spaceBetweenToggle,y)
                .setColorValue(0xFF000000)
                .setFont(verdanaFont_14)
                .moveTo(tabName);
     
     motorToggles = new Toggle[nbMotors];
     x += animLabelColumnWidth;
     int xTemp = x;
     for(int i=0; i<motorToggles.length ; i++)
     {
       motorToggles[i] = cp5.addToggle("MOTORTOGGLE_"+index+"_"+i)
       .setPosition(x,y)
       .setSize(toggleSize,toggleSize)
       .setValue(true)
       .setColorForeground(color(128,197,176))
       .setColorBackground(0xFFE3E3E3)
       .setColorActive(color(0,138,98))
       .setState(false)
       .moveTo(tabName)
       .setLock(true)
       .hide()
       .addListener(this)
       ;
       x+= toggleSize + spaceBetweenToggle;
     }
     
     playMotorToggles = new Toggle[nbMotors];
     for(int i=0; i<motorToggles.length ; i++)
     {
       playMotorToggles[i] = cp5.addToggle("MOTORPLAYTOGGLE_"+index+"_"+i)
       .setPosition(xTemp+2,y+2)
       .setSize(5,5)
       .setValue(true)
       .setColorForeground(0x00000000)
       .setColorBackground(0x00000000)
       .setColorActive(0xFF00FF00)
       .setState(false)
       .moveTo(tabName)
       .setLock(true)
       .hide()
       ;
       playMotorToggles[i].getCaptionLabel().hide();
       xTemp += toggleSize + spaceBetweenToggle;
     }
     
     x = x + toggleSize - spaceBetweenToggle;   
     
     animPlayButton = cp5.addButton("PLAYTOGGLE_"+index)
     .setPosition(x,y)
     .setSwitch(true)
     .setSize(toggleSize,toggleSize)
     .setImages(loadImage("images/playButton.jpg"),loadImage("images/playButton.jpg"),loadImage("images/stopButton.jpg"))
     .setColorForeground(color(128,197,176))
     .setColorBackground(color(204,232,224))
     .setColorActive(color(0,138,98))
     .hide()
     .moveTo(tabName)
     .addListener(this)
     ;
     
     x += toggleSize+spaceBetweenToggle;
     
     loopButton = cp5.addToggle("LOOPTOGGLE_"+index+"_")
     .setCaptionLabel("LOOP")
     .setPosition(x,y)
     .setSize(2*toggleSize,toggleSize)
     .setColorForeground(color(128,197,176))
     .setColorBackground(color(204,232,224))
     .setColorActive(color(0,138,98))
     .hide()
     .moveTo(tabName)
     .addListener(this)
     ;
     loopButton.getCaptionLabel().setFont(verdanaFont_12).setColor(0xFFFFFFFF).align(ControlP5.CENTER,ControlP5.CENTER);
     
     x += 2*toggleSize + spaceBetweenToggle;
     
     progressbar = cp5.addSlider("SLIDERPROGRESS"+index)
     .setPosition(x,y)
     .setSize(3*toggleSize,toggleSize)
     .setRange(0.0,1.0)
     .setColorForeground(color(0,138,98))
     .setColorBackground(0xFFE3E3E3)
     .setColorActive(color(0,138,98))
     .setLock(true)
     .hide()
     .moveTo(tabName)
     .setValue(0)
     ;
     
     progressbar.getValueLabel().hide();
     progressbar.getCaptionLabel().hide();
     
     x += 3*toggleSize + spaceBetweenToggle;
     posDDSpeed = new PVector(x,y);
     
     fakeToggle = cp5.addToggle("FAKESPEEDTOGGLE"+index)
                     .setPosition(x,y)
                     .setSize(2*toggleSize,toggleSize)
                     .setColorBackground(color(204,232,224))
                     .setLock(true)
                     .hide()
                     .moveTo(tabName)
                     ;
     
     speedLabel = cp5.addTextlabel("SPEEDLABEL"+index)
                .setText("1.0")
                .setPosition(x+5,y)
                .setColorValueLabel(0xFF000000)
                .setFont(verdanaFont_12)
                .hide()
                .moveTo(tabName);
     
     x += 2*toggleSize ;
     
     speedIncrease = cp5.addButton("SPEEDINCREASE_"+index)
                  .setCaptionLabel("+")
                  .setPosition(x,y)
                  .setSize(toggleSize,toggleSize/2)
                  .setColorForeground(color(128,197,176))
                  .setColorBackground(color(204,232,224))
                  .setColorActive(color(0,138,98))
                  .moveTo(tabName)
                  .hide()
                  .setLock(true)
                  .addListener(this)
                  ;  
     speedIncrease.getCaptionLabel().setFont(verdanaFont_10).setColor(0xFF000000).align(ControlP5.CENTER,ControlP5.CENTER);
     
     speedDecrease = cp5.addButton("SPEEDDECREASE_"+index)
                  .setCaptionLabel("-")
                  .setPosition(x,y+toggleSize/2)
                  .setSize(toggleSize,toggleSize/2)
                  .setColorForeground(color(128,197,176))
                  .setColorBackground(color(204,232,224))
                  .setColorActive(color(0,138,98))
                  .moveTo(tabName)
                  .hide()
                  .setLock(true)
                  .addListener(this)
                  ;  
     speedDecrease.getCaptionLabel().setFont(verdanaFont_14).setColor(0xFF000000).setPadding(7,15);
     
  }


  void setAnim(String path)
  {
    free = false;
    wavPath = path;
    int startLabelIndex = path.indexOf("/") + 1;
    int endLabelIndex = path.indexOf("_");
    if(endLabelIndex == -1) return; // this means no motor has been selected... we ignore it
    if(startLabelIndex <= path.length() && startLabelIndex != -1 && endLabelIndex <= path.length() && endLabelIndex != -1)
    {
      label = path.substring(startLabelIndex,endLabelIndex);
    }
    else
    {
      label = path;
    }
    animLabel.setText(label);
    
    for(int i=0; i<motorToggles.length ; i++)
    {
       motorToggles[i].show();
    }
    
    String pathEnd = path.substring(endLabelIndex,path.length()-4);
    int delimIndex = pathEnd.indexOf("_");
    while(delimIndex != -1)
    {
      delimIndex++;
      if((delimIndex+2) > pathEnd.length()) return;
      int newMotorIndex = int(pathEnd.substring(delimIndex+1,delimIndex+2));
      if(newMotorIndex >= 0 && newMotorIndex < motorToggles.length)
      {
        //println("NEW MOTOR : " + newMotorIndex);
         motorToggles[newMotorIndex].setLock(false);
         motorToggles[newMotorIndex].setColorBackground(color(128,197,176));
         motorToggles[newMotorIndex].setState(true);
      }
      
      pathEnd = pathEnd.substring(delimIndex,pathEnd.length());
      delimIndex = pathEnd.indexOf("_");
    }
    
    
    // unlock and unhide buttons
    deleteButton.setLock(false);
    deleteButton.show();
    animPlayButton.setLock(false);
    animPlayButton.show();
    loopButton.setLock(false);
    loopButton.show();
    progressbar.show();
    speedIncrease.setLock(false);
    speedIncrease.show();
    speedDecrease.setLock(false);
    speedDecrease.show();
    speedLabel.show();
    fakeToggle.show();
    
  }
  
  void startPlaying()
  {
    if(!wavPath.equals(""))
    {
      double[][] values = wavEncoder.readWav(sketchPath+"/"+wavPath); 
  
      int nbChannels = values.length;
      if(nbChannels > 0)
      {
        nbFrames = values[0].length;
      }
      ServoDxl[] servos = servoArray.getServos();
      int nbActivatedMotors = 0;
      boolean servoPlayingFound = false;
      for(int i=0;i<servos.length;i++)
      {
        if(servos[i] != null)
        {
          if(i < motorToggles.length)
          {
            if(!motorToggles[i].isLock()) // this motor was assigned to play the anim
            {
              if(motorToggles[i].getState()) // this motor was NOT desactivated to play the anim
              {
                if(nbActivatedMotors < nbChannels)
                {
                  servos[i].startPlaying(values[nbActivatedMotors], loop, animSpeedSelected,this);
                  playMotorToggles[i].show();
                  playMotorToggles[i].setState(true);
                  servoPlayingFound = true;
                }
              }
              nbActivatedMotors++;
            }    
          }
        }
      }
      
      if(!servoPlayingFound)
      {
        animPlayButton.setOff();
      }
      playRate = (int)((float)recRate/animSpeedSelected);
      
    }
  }
  
  
  void stopPlaying()
  {
    ServoDxl[] servos = servoArray.getServos();
    int nbActivatedMotors = 0;
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i] != null)
      {
        if(i < motorToggles.length)
        {
          if(!motorToggles[i].isLock()) // this motor was assigned to play the anim
          {
            if(motorToggles[i].getState()) // this motor was NOT desactivated to play the anim
            {
              if(i < playMotorToggles.length && playMotorToggles[i].isVisible()) // and this motor is playing THIS animation
              {
                println("servo " + i + " will stop");
                servos[i].stopPlaying(true);
              } 
            }
            nbActivatedMotors++;
          }    
        }
      }
    }
    for(int i=0; i<playMotorToggles.length; i++)
    {
      playMotorToggles[i].hide();
    }
    progressbar.setValue(0.0);
    currFrame = 0;
  }
  
  
  void servoStoppedPlaying(int index)
  {
    println("servoStoppedPlaying " + index);
    if(index >= 0 && index < playMotorToggles.length)
    {
      playMotorToggles[index].hide();
    }
    // check if there is still another servo playing this anim, otherwise we need to change playanim state
    boolean servoPlayingFound = false;
    for(int i=0; i< playMotorToggles.length; i++)
    {
      if(playMotorToggles[i].isVisible())
      {
        servoPlayingFound = true;
      }
    }
    if(!servoPlayingFound)
    {
      animPlayButton.setOff();
    }
  }
  
  void playingIsFinished()
  {
    animPlayButton.setOff(); // this will then automatically call stopPlaying()
  }

  void loopIsFinished()
  {
    progress = 0;
    progressbar.setValue(0.0);
    currFrame = 0;
  }
  
  void setLoop(boolean b)
  {
    loop = b;
    if(!animPlayButton.isOn()) return; // do not need to update value when anim has not started
    ServoDxl[] servos = servoArray.getServos();
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i] != null)
      {
        if(!motorToggles[i].isLock()) // this motor was assigned to play the anim
        {
          if(motorToggles[i].getState()) // this motor was NOT desactivated to play the anim
          {
            if(i < playMotorToggles.length && playMotorToggles[i].isVisible()) // and this motor is playing THIS animation
            {
              servos[i].setLoop(b);
            } 
          }
        }
      }
    }
  }


  void setSpeedToServos(float speed)
  {
    playRate = (int)((float)recRate/animSpeedSelected);
    if(!animPlayButton.isOn()) return; // do not need to update value when anim has not started
    ServoDxl[] servos = servoArray.getServos();
    for(int i=0;i<servos.length;i++)
    {
      if(servos[i] != null)
      {
        if(!motorToggles[i].isLock()) // this motor was assigned to play the anim
        {
          if(motorToggles[i].getState()) // this motor was NOT desactivated to play the anim
          {
            if(i < playMotorToggles.length && playMotorToggles[i].isVisible()) // and this motor is playing THIS animation
            {
              servos[i].playRate = playRate;
            } 
          }
        }
      }
    }
  }

  
  // only used when animation is already playing
  void selectForPlaying(boolean select, int index)
  {
    if(!animPlayButton.isOn()) return;
    if(select)
    {
      // for now we ignore this
      // if the animation is already running and the toggle is activated, nothing happens.
      return;
    }
    
    // toggle has been desactivated. Stop the animation for this servo
    ServoDxl servo = servoArray.getByIndex(index);
    if(servo != null)
    {
      if(index < playMotorToggles.length && playMotorToggles[index].isVisible())
      {
        playMotorToggles[index].hide();
        servo.stopPlaying(true);
      }
      //println("SELECT for playing " + index + " " + select);
    }
    
    // check if there is still another servo playing this anim, otherwise we need to change playanim state
    boolean servoPlayingFound = false;
    for(int i=0; i< playMotorToggles.length; i++)
    {
      if(playMotorToggles[i].isVisible())
      {
        servoPlayingFound = true;
      }
    }
    if(!servoPlayingFound)
    {
      animPlayButton.setOff();
    }
  }



  void deleteAnim()
  {
    
    label = "";
    animLabel.setText(label);
    for(int i=0; i<motorToggles.length ; i++)
    {
       motorToggles[i].setLock(true);
       motorToggles[i].setColorBackground(0xFFE3E3E3);
       motorToggles[i].setState(false);
       playMotorToggles[i].setState(false);
       playMotorToggles[i].hide();
    }
    
    // reset
    animSpeedSelected = 1.0;
    currFrame = 0;
    nbFrames = 0;
    progress = 0; //DIB
    progressbar.setValue(0.0);
    animPlayButton.setOff();
    loopButton.setState(false);
    speedLabel.setText("1.0");
    
    // lock and hide buttons
    deleteButton.setLock(true);
    deleteButton.hide();
    animPlayButton.setLock(true);
    animPlayButton.hide();
    loopButton.setLock(true);
    loopButton.hide();
    progressbar.hide();
    speedIncrease.setLock(true);
    speedIncrease.hide();
    speedDecrease.setLock(true);
    speedDecrease.hide();
    speedLabel.hide();
    fakeToggle.hide();
    
    free = true;
    
     // update anim config xml file
     XML xml = loadXML(animConfigPath); // we reload it in case file had been manually changed in between
     if(xml==null)
     {
        println("[ERROR]: config ANIM file " + animConfigPath + " could not be loaded");
        wavPath = "";
        return;    
     }
     
     XML[] children = xml.getChildren("anim");
     for(int i=0; i<children.length; i++)
     {
        String animPath = children[i].getString("path");
        if(animPath.equals(wavPath))
        {
          xml.removeChild(children[i]);
          println("-> removing anim with path " + animPath);
        }
     }
     
     saveXML(xml,animConfigPath);
     wavPath = "";
    
  }

  boolean isFree()
  {
    return free;
  }
  
  void update()
  {
    // just used for the progress bar
     if(animPlayButton.isOn())
     {
        long t = millis();    
        
        if( (t-playframeTime)>=playRate )
        {
            playframeTime = t;
            progress = (float)currFrame/(float) nbFrames; 
            progressbar.setValue(progress);
            currFrame++;
        }
     }
    
  }
  
  void controlEvent(ControlEvent evt)
  {
      if(!evt.isController())
        return;
        
      Controller c = evt.getController();
      String addr = c.getAddress();
      if(c == deleteButton)
      {
        //println("-> delete animation " + label);
        deleteAnim();
      }
      else if(c == animPlayButton)
      {
        if(animPlayButton.isOn())
        {
          //println("-> play animation");
          startPlaying();
        }
        else
        {
          //println("-> stop animation");
          stopPlaying();
        }
      }
      else if(c == loopButton)
      {
        if(loopButton.getState())
        {
          //println("-> loop is activated");
          setLoop(true);
        }
        else
        {
          //println("-> loop is desactivated");
          setLoop(false);
        }
      }
      else if(c == speedIncrease)
      {
        animSpeedSelected += 0.1;
        if(animSpeedSelected > 1.5)
        {
          animSpeedSelected = 1.5;
        }
        String text = String.format("%.1f", animSpeedSelected);
        speedLabel.setText(text);
        setSpeedToServos(animSpeedSelected);
      }
      else if(c == speedDecrease)
      {
        animSpeedSelected -= 0.1;
        if(animSpeedSelected < 0.2)
        {
          animSpeedSelected = 0.2;
        }
        String text = String.format("%.1f", animSpeedSelected);
        speedLabel.setText(text);
      }
      else if(addr.startsWith("/MOTORTOGGLE_"))
      {
        // we don't need to do anything
        for(int i=0; i<motorToggles.length; i++)
        {
          if(c == motorToggles[i])
          {
            selectForPlaying(motorToggles[i].getState(),i);
          }
        }
      }
  
  }



  
};
