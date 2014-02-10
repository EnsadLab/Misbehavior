

int animLabelColumnWidth;
int space = 30;
int toggleSize = 20;
int spaceBetweenToggle = 10;
int spaceBetweenColumns = 230;
int spaceBetweenLines = 15;
PImage playImage;



class AnimGUI implements ControlListener
{
 
  Anim[] anims;// = new Anim[nbAnimsMax];
  Toggle recButtonPlayPause;
  Toggle[] motorToggles;
  Textfield recordLabelTextField;
  WavEncoder wavEncoder = new WavEncoder(); 

  AnimGUI()
  {
  
  }
  
  
  
  void buildGUI(int x, int y, String tabName, int animLabelColumnW)
  {
    
     playImage = loadImage("playButton.jpg");
    
     //motorColumnWidth = 300;
     animLabelColumnWidth = animLabelColumnW;
    
     cp5.addToggle("FAKETOGGLE")
        .setPosition(x,y)
        .setColorBackground(0xFF008A62)
        .setSize(animLabelColumnWidth-toggleSize,30)
        .lock()
        .moveTo(tabName);
        
     Textlabel label = cp5.addTextlabel("ANIMATIONS_gui")// we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Animations")
              .setPosition(x+30,y+5)
              .setColorValueLabel(0xFFFFFFFF)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
    
     cp5.addToggle("FAKETOGGLEMOTORS")
        .setPosition(x+animLabelColumnWidth,y)
        .setColorBackground(0xFF792e3f)
        .setSize(motorColumnWidth,30)
        .lock()
        .moveTo(tabName);
              
     label = cp5.addTextlabel("MOTORS_gui")// we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("Motors")
              .setPosition(x+animLabelColumnWidth+motorColumnWidth/2-30,y+5)
              .setColorValue(0xFFFFFFFF)
              .setFont(createFont("Verdana",14))
              .moveTo(tabName);
              ;
       
     y += 50;
     
     buildRecordGui(x,y,tabName);
     
     y += 50;
     
     int yTemp = y;
     anims = new Anim[nbAnimsMax];   

     for(int i=0; i<anims.length; i++)
     {
       if(i == 11)
       {
         y = marginTop-10;
         x += animLabelColumnWidth + motorColumnWidth + spaceBetweenColumns;
       }
       anims[i] = new Anim();
       anims[i].buildGui(x,y,tabName,i);
       y += toggleSize  + spaceBetweenLines;
     }
     
     for(int i=anims.length-1; i >= 0; i--)
     {
       anims[i].buildDropDownSpeed(tabName,i);
     }
     
     for(int i=0; i<animPaths.length; i++)
     {
         //anims
         if(i < anims.length)
         {
           anims[i].setAnim(animPaths[i]);
         }
     }
  }
  
  void buildRecordGui(int x, int y, String tabName)
  {
    
    recordLabelTextField = cp5.addTextfield("RECORDTEXTFIELD")
                  .setPosition(x,y)
                  .setSize(animLabelColumnWidth-toggleSize,toggleSize)
                  .setColorForeground(color(255,0,0))
                  .setColor(color(2255,0,0))
                  .setColorBackground(0xFFFFFFFF)
                  .setColorActive(color(255,0,0))
                  .setAutoClear(false)
                  .moveTo(tabName)
                  .addListener(this)
                  .setColorValueLabel(0xFF000000)
                  ;
     recordLabelTextField.getValueLabel().setFont(createFont("Verdana",13)).align(ControlP5.LEFT,ControlP5.CENTER);
     
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
         //.setColorForeground(color(255,129,129))
         //.setColorBackground(0xFFFFCCCC)
         .setColorForeground(color(255,0,0))
         .setColorBackground(0xFFFF0000)
         .setColorActive(color(255,0,0))
        .setSize(2*toggleSize,toggleSize)
        .moveTo(tabName)
        .setCaptionLabel("REC");
     recButtonPlayPause.getCaptionLabel().setFont(createFont("Verdana",12)).align(ControlP5.CENTER,ControlP5.CENTER);
     recButtonPlayPause.addListener(this);
     
  }
  
  void startPlaying(String label)
  //void startPlaying(String label, boolean loop, float speed)
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
    //selectInput("Select a file to process:", "fileSelected");
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
    if(recordLabel.equals(""))
    {
      int d = day();    // Values from 1 - 31
      int m = month();
      int s = second();  // Values from 0 - 59
      int min = minute();  // Values from 0 - 59
      int h = hour();    // Values from 0 - 23
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
    
    // save wav
    recordWavPath += ".wav";
    wavEncoder.writeWav(recordWavPath,recordValues[0].length,recordValues); // we know we have at least one chanel since nbActivatedMotors > 0
    
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
  
  void update()
  {
    for(int i=0; i<anims.length; i++)
    {
      anims[i].update();
    }
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
    if(!evt.isController())
    return;
  
    Controller c = evt.getController();
    if(c == recButtonPlayPause)
    {
      if(recButtonPlayPause.getState())
      {
        println("-> start recording");
        recButtonPlayPause.setCaptionLabel("STOP");
        startRecording();
      }
      else
      {
        println("-> stop recording");
        recButtonPlayPause.setCaptionLabel("REC");
        stopRecording(recordLabelTextField.getText());
      }
    }
    
    //int id = c.getId();
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
  DropdownList animSpeed;
  float[] speeds = { 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0 }; // ou a generer...
  float animSpeedSelected = 1.0;
  String label;
  String wavPath;
  PVector posDDSpeed;
  boolean free = true;
  boolean loop = false;
  long playframeTime;
  long recRate = 20; // ATTENTION: cette valeur est aussi inscrite dans ServoDxl...
  long playRate = 20;
  int nbFrames = 0;
  int currFrame = 0;
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
   deleteButton.getCaptionLabel().setFont(createFont("Verdana",16)).setColor(0xFF000000).align(ControlP5.CENTER,ControlP5.CENTER);
  
   animLabel = cp5.addTextlabel("ANIMLABEL_" + index)// we keep index as identifier. This way we are completely sure no label has the same identifier. In case user adds twice same motorid in xml.
              .setText("")
              .setPosition(x+toggleSize+spaceBetweenToggle,y)
              .setColorValue(0xFF000000)
              .setFont(createFont("Verdana",14))
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
     //.addListener(this)
     ;
     playMotorToggles[i].getCaptionLabel().hide();
     xTemp += toggleSize + spaceBetweenToggle;
   }
   
   //x += toggleSize;
   x = x + toggleSize - spaceBetweenToggle;
   
   
   PImage playImage2  = loadImage("playButton.jpg");
   
   animPlayButton = cp5.addButton("PLAYTOGGLE_"+index)
   .setPosition(x,y)
   .setSwitch(true)
   .setSize(toggleSize,toggleSize)
   .setImages(loadImage("playButton.jpg"),loadImage("playButton.jpg"),loadImage("stopButton.jpg"))//playImage2)//,playImage2,playImage2)
   //.updateSize()
   .setColorForeground(color(128,197,176))
   .setColorBackground(color(204,232,224))
   .setColorActive(color(0,138,98))
   .hide()
   //.lock(true)
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
   //.setImage(playImage2)//,playImage2,playImage2)
   .moveTo(tabName)
   .addListener(this)
   ;
   loopButton.getCaptionLabel().setFont(createFont("Verdana",12)).setColor(0xFFFFFFFF).align(ControlP5.CENTER,ControlP5.CENTER);
   
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
   //.addListener(this) // for the future: access directly frames in the animation
   .setValue(0)
   ;
   
   progressbar.getValueLabel().hide();
   progressbar.getCaptionLabel().hide();
   //progressbar.setValue(0.5);
   
   x += 3*toggleSize + spaceBetweenToggle;
   posDDSpeed = new PVector(x,y);
   
}

void buildDropDownSpeed(String tabName, int index)
{
 
   animSpeed = cp5.addDropdownList("SPEEDANIM" + index)
          .setPosition(posDDSpeed.x, posDDSpeed.y+toggleSize)
          .setSize(2*toggleSize,150)
          .moveTo(tabName)
          .setItemHeight(toggleSize)
          .addListener(this)
          .setBarHeight(toggleSize)
          .setColorForeground(color(204,232,224))
          .setColorBackground(0xFFE3E3E3)
          .setColorActive(color(0,138,98))
          .setColorLabel(0xFF000000)
          .hide();
          ;
   animSpeed.captionLabel().setColor(0xFF000000).align(ControlP5.CENTER,ControlP5.CENTER);
   animSpeed.valueLabel().setColor(0xFF000000).align(ControlP5.CENTER,ControlP5.CENTER);
         // animSpeed.captionLabel().style().marginLeft = 5;
         // animSpeed.valueLabel().style().marginTop = 5;
   for(int i=0; i<speeds.length; i++)
   {
      animSpeed.addItem(""+speeds[i], i);
   }
   animSpeed.setIndex(8);
   
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
  animSpeed.show();
}

void startPlaying()
{
  if(!wavPath.equals(""))
  {
    double[][] values = wavEncoder.readWav(wavPath); 

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
    playRate = (int)((float)recRate*animSpeedSelected);
    
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
            servos[i].stopPlaying(); 
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
  animPlayButton.setOff();
  for(int i=0; i<playMotorToggles.length; i++)
  {
    playMotorToggles[i].hide();
  }
  progressbar.setValue(0.0);
  currFrame = 0;
}

void loopIsFinished()
{
  progressbar.setValue(0.0);
  currFrame = 0;
}

void setLoop(boolean b)
{
  loop = b;
  ServoDxl[] servos = servoArray.getServos();
  for(int i=0;i<servos.length;i++)
  {
    if(servos[i] != null)
    {
      if(servos[i].playing)
      {
        servos[i].setLoop(b);
      }
    }
  }
}

/*
void selectForPlaying(boolean select, int index)
{
  ServoDxl servo = servoArray.getByIndex(index);
  if(servo != null)
  {
      servo.enablePlaying = select;
      //println("SELECT for playing " + index + " " + select);
  }
}
*/


void deleteAnim()
{
  wavPath = "";
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
  progressbar.setValue(0.0);
  animPlayButton.setOff();
  loopButton.setState(false);
  animSpeed.setIndex(8);
  
  // lock and hide buttons
  deleteButton.setLock(true);
  deleteButton.hide();
  animPlayButton.setLock(true);
  animPlayButton.hide();
  loopButton.setLock(true);
  loopButton.hide();
  progressbar.hide();
  animSpeed.hide();
  
  free = true;

  
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
          progressbar.setValue(((float)currFrame)/((float) nbFrames));
          currFrame++;
      }
   }
  
}

void controlEvent(ControlEvent evt)
{
 
    if(evt.isGroup()) //dropdown list
    {
      ControlGroup g = evt.group();
      if( g == animSpeed )
      {
        int line = (int)g.value();
        if(line >= 0 && line < speeds.length)
        {
          animSpeedSelected = speeds[line];
          println("-> selected new animation speed: " + animSpeed);
        }
      }
    }
    if(!evt.isController())
      return;
      
    Controller c = evt.getController();
    String addr = c.getAddress();
    if(c == deleteButton)
    {
      println("-> delete animation " + label);
      deleteAnim();
    }
    else if(c == animPlayButton)
    {
      if(animPlayButton.isOn())
      {
        println("-> play animation");
        startPlaying();
      }
      else
      {
        println("-> stop animation");
        stopPlaying();
      }
    }
    else if(c == loopButton)
    {
      if(loopButton.getState())
      {
        println("-> loop is activated");
        setLoop(true);
      }
      else
      {
        println("-> loop is desactivated");
        setLoop(false);
      }
    }
    else if(addr.startsWith("/MOTORTOGGLE_"))
    {
      // we don't need to do anything
      /*for(int i=0; i<motorToggles.length; i++)
      {
        if(c == motorToggles[i])
        {
          selectForPlaying(motorToggles[i].getState(),i);
        }
      }*/
    }

}



  
};
