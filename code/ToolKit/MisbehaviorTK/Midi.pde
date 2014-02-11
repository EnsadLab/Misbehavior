//#import import themidibus.*;

static final int  MAX_MIDI_NUM  = 128;
MidiBus midiBus;
int midiChannel = 0;

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
  print("NoteON:  C:"+channel+" N:"+pitch+" V:"+vel);
}

void noteOff(int channel, int pitch, int vel)
{
  print("NoteOFF: ");print(" C:"+channel);print(" N:"+pitch);println(" V:"+vel);
}

void controllerChange(int channel, int num, int value)
{
    println("CC "+num+":"+value);
    if( num<8) //ça tombe bien : num = Servo index
    {
      float fval = 0;
      if( value < 64 )
        fval = (float)(value-64)/64.0;
      else if(value > 64 )
        fval = (float)(value-64)/63.0;

      println("dbg midi "+num+","+fval);
      //... appeler la fonction correspondate ... wheelGoal
    }
    //TODO
    //potars?
    //Bouton:
    // stop
    // mode Wheel/joint
    // reverse
    //
}

/*
void midiCtrlChange( int inum, int value )
{
  if(midiBus!=null)
  {
    //midiBus.sendControllerChange(midiChannel,inum,value);
  }
}
*/

