//#import import themidibus.*;

static final int  MAX_MIDI_NUM  = 128;
MidiBus midiBus;
int midiChannel = 0;

float midiRefSpeed = 0;
float midiDiffVal = 0;
float midiDiffCoef = 0.5f;
float midiDiffOrigin = 0;
/*
class MidiCmd
{
  int     servo  = -1;
  int     type   = 0;
  float   value  = 0;
  float   center = 0;
  float   coef   = 1.0f;
  int     min = -1024;
  int     max =  1024;
  String  cmd = null;
  void    fromXML(XML xml)
  {
    servo  = xml.getInt("servo");
    value  = xml.getInt("value");
    center = xml.getInt("center");
    coef   = xml.getInt("coef");
    min    = xml.getInt("min");
    max    = xml.getInt("max");
    cmd    = xml.getString("cmd");
    println(toString());
  }
  String toString()
  {
    return "s:"+servo+" v:"+value+ " str:"+cmd;
  }
}
*/
SensorEvt[] midiNoteOnCmd;
SensorEvt[] midiNoteOffCmd;
SensorEvt[] midiCtrlChgCmd;

void listMidiDevices()
{
  MidiBus.list();
}

void openMidi(String in,String out)
{
  midiBus = new MidiBus(this, in , out );
}

void loadMidiConfig(String xmlFilePath)
{
  midiNoteOnCmd  = new SensorEvt[MAX_MIDI_NUM];for(int i=0;i<MAX_MIDI_NUM;i++)midiNoteOnCmd[i] =new SensorEvt();
  midiNoteOffCmd = new SensorEvt[MAX_MIDI_NUM];for(int i=0;i<MAX_MIDI_NUM;i++)midiNoteOffCmd[i]=new SensorEvt();
  midiCtrlChgCmd = new SensorEvt[MAX_MIDI_NUM];for(int i=0;i<MAX_MIDI_NUM;i++)midiCtrlChgCmd[i]=new SensorEvt();

  println("Loading Midi Config file...");
  XML xml = loadXML(xmlFilePath);
  if(xml==null)
    return;      //>>error message ?
  
  //try{midiInDevice  = xml.getChild("midi").getString("in");}catch(Exception e){}
  //try{midiOutDevice = xml.getChild("midi").getString("out");}catch(Exception e){}
  //println("MIDIin  "+midiInDevice);
  //println("MIDIout "+midiOutDevice);

  XML[] children = xml.getChildren("noteOn");
  for (int i = 0; i < children.length; i++)
  {
    int id = children[i].getInt("id");
    if( (id>=0)&&(id<MAX_MIDI_NUM) )
      midiNoteOnCmd[id].fromXML( children[i] );
  }
      
  children = xml.getChildren("noteOff");
  for (int i = 0; i < children.length; i++)
  {
    int id = children[i].getInt("id");
    if( (id>=0)&&(id<MAX_MIDI_NUM) )
      midiNoteOffCmd[id].fromXML( children[i] );
  }

  children = xml.getChildren("ctrl");
  for (int i = 0; i < children.length; i++)
  {
    int id = children[i].getInt("id");
    if( (id>=0)&&(id<MAX_MIDI_NUM) )
    {
      print("CC"+id+">");
      midiCtrlChgCmd[id].fromXML( children[i] );
    }
  }
}

void noteOn(int channel, int pitch, int vel)
{
  print("NoteON:  C:"+channel+" N:"+pitch+" V:"+vel);
  if( pitch<MAX_MIDI_NUM)
  {
    SensorEvt cmd = midiNoteOnCmd[pitch];
    println(cmd.toString()); 
    cmd.value = vel;    
    servoArray.onSensor(cmd);
  }
}

void noteOff(int channel, int pitch, int vel)
{
  print("NoteOFF: ");print(" C:"+channel);print(" N:"+pitch);println(" V:"+vel);
  if( pitch<MAX_MIDI_NUM)
  {
    SensorEvt cmd = midiNoteOffCmd[pitch];
    println(cmd.toString());    
    cmd.value = vel;    
    servoArray.onSensor(cmd);
  }
}

void controllerChange(int channel, int num, int value)
{
  if( num<MAX_MIDI_NUM)
  {
    SensorEvt cmd = midiCtrlChgCmd[num];
    cmd.value = value;    
    println("CC "+num+":"+cmd.toString()+" "+cmd.coef*(value-cmd.center));
    println(cmd.toString() ); 
    servoArray.onSensor(cmd);
  }
}

void midiCtrlChange( int inum, int value )
{
  if(midiBus!=null)
  {
    //midiBus.sendControllerChange(midiChannel,inum,value);
  }
}

void controllerChangeOld(int channel, int num, int value)
{  
  if(num==1)
    servoGUIarray.midiValue(num-1,value);
  else if(num==2)
    servoGUIarray.midiValue(num-1,127-value);
    delay(10);
  
  // Receive a controlChange
  
//  print("CC: ");print(" C:"+channel);print(" N:"+number);println(" V:"+value);
/*  if( number<=8)
  {
    motorGroup.midiValue(number-1,value);
    delay(10);
  }
*/
//  else
//    midiDifferentiel(number,value);
}

void midiDifferentiel(int num,int val)
{
  if(num==13) //speed
    midiRefSpeed = (float)(64-val);
  else if(num==12)
    midiDiffVal  = (float)(64-val);
//  else if(num==12)
//    midiDiffCoef = 64.0f-val;
//  else if(num==13)
//    midiDiffOrigin = 64.0f-val;

  int v1 = (int)(midiRefSpeed + (midiDiffVal*midiDiffCoef));
  int v2 = (int)(midiRefSpeed - (midiDiffVal*midiDiffCoef));

  if(v1>63)v1=63; else if(v1<-63)v1=-63;
  if(v2>63)v1=63; else if(v2<-63)v2=-63;
  
  //motorGroup.midiValue(0,v1);  
  servoArray.servos[0].setWheelSpeed( -(v1)<<4);
    delay(20);
  //motorGroup.midiValue(1,v2);    
  servoArray.servos[1].setWheelSpeed(  (v2)<<4);
    delay(20);

  println("v1 "+(v1<<4)+" v2 "+(v2<<4));
    
}

