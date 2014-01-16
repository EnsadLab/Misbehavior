import themidibus.*;
import processing.serial.*;
import controlP5.*;

PApplet  mainApp;
int keyModifier = 0; //1 shift 2ctrl 4alt 

PFont arialFont; // = createFont("Arial",20,true); // use true/false for smooth/no-smooth
//ControlFont font; // = new ControlFont(pfont,241);


CommIno  arduino;
ServoArray servoArray;

int serialEventCount = 0;

DXLmotor dxlGui;
MotorGroup motorGroup;

ControlP5 cp5;
int globalID = 0;  //GRRRR
int myColor = color(0,0,0);

//int sliderValue = 100;
//int sliderTicks1 = 100;
//int sliderTicks2 = 30;
//Slider abc;

//Curve curve = new Curve();
ListEdit editAnim = new ListEdit("Anim0");
//ListEdit edit2    = new ListEdit("Anim1");
Anim anim = new Anim();
ScriptArray scriptlist = new ScriptArray(); 

Script script = new Script();

ScriptConsole scriptConsole = new ScriptConsole();

void setup()
{
  mainApp = this;
  size(1100,700); //P3D OPENGL
  
  println("Path:"+sketchPath);
  
  
  cp5 = new ControlP5(this);
  globalID = 200;
  
  //arialFont = createFont("Monospaced.plain",14,false); // use true/false for smooth/no-smooth
  //arialFont = createFont("Lucida Console",14,false); // use true/false for smooth/no-smooth
  arialFont = createFont("Courier New",12,false); // use true/false for smooth/no-smooth
  
  arduino = new CommIno();
  arduino.buildGUI(150,20);

  servoArray = new ServoArray(4);
      
  dxlGui = new DXLmotor();
  dxlGui.buildGUI(100,20);
  
  motorGroup = new MotorGroup(4);
  motorGroup.buildGUI(350,20);
  
  //anim = new Anim();
  //animGui = new AnimGui();
  //animGui.buildGUI(500,50,550);
  //curve.buildGUI(500,100);
  
  editAnim.buildGui("E1",500,150,25);
  //edit2.buildGui("E2",700,150,25);  
    
  //scriptlist.loadAll(sketchPath+"/anims");
  
  scriptConsole.buildGui(700,150,450);

  listMidiDevices();
  openMidi("BCF2000", "BCF2000");  
//  openMidi("BCR2000", "BCR2000");  

  editAnim.script = script;
  //editAnim.load(sketchPath+"/anims/AnimE1.txt");
  editAnim.load("/anims/AnimE1.txt");
  //String[] fonts = PFont.list();
  //println(fonts);
}

void draw()
{  
  background(64);
  //anim.update();
  script.update();
  servoArray.update();
  motorGroup.update();
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


void controlEvent(ControlEvent evt)
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
  if( serial == arduino.serial )
  {
    arduino.serialRcv();
    //arduino.append("received "+serialEventCount+'\n');
  }
  /*
  else
  {
    println("serial ?????????");
    while(serial.available()>0)
      serial.read();
  }
  */
  serialEventCount++;
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
  
  if( editHandleKey(key,keyCode) )
    return;
    
  if( keyCode == CONTROL )
  {
    if(key=='A')
      anim.fromListEdit(editAnim);
  }  
    
/*  
  if( (key=='s')||(key=='S') )
  {
    println(" kmod "+keyModifier );
  }
*/  
  
}

