//#import import themidibus.*;

MidiBus midiBus; // The MidiBus
int midiChannel = 0;

float midiRefSpeed = 0;
float midiDiffVal = 0;
float midiDiffCoef = 0.5f;
float midiDiffOrigin = 0;

void listMidiDevices()
{
  MidiBus.list();
}

void openMidi(String in,String out)
{
  midiBus = new MidiBus(this, in , out );
}

void noteOn(int channel, int pitch, int vel)
{
  print("on: ");
  print(" C:"+channel);
  print(" N:"+pitch);
  println(" V:"+vel);
  servoGUIarray.midiValue(pitch-1,64);  
}

void noteOff(int channel, int pitch, int vel)
{
  print("off: ");print(" C:"+channel);print(" N:"+pitch);println(" V:"+vel);
  //servoArray.servos[pitch-1].relax(true);
  servoGUIarray.midiValue(pitch-1,64);  
}


void midiCtrlChange( int inum, int value )
{
  if(midiBus!=null)
  {
    //midiBus.sendControllerChange(midiChannel,inum,value);
  }
}

void controllerChange(int channel, int num, int value)
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

