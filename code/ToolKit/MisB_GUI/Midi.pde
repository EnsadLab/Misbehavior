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

static final int  MAX_MIDI_NUM  = 128;
MidiBus midiBus;
int midiChannel = 0;
float midiValueCoef[] = new float[8]; //used for reverse value

void listMidiDevices()
{
  MidiBus.list();
}

void openMidi(String in,String out)
{
  midiBus = new MidiBus(this, in , out );
  for(int i=0;i<8;i++)
    midiValueCoef[i]=1;
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

      //println("dbg midi "+num+","+fval);
      servoGUIarray.midiValue(num,fval*midiValueCoef[num]);
    }
    
    else if( (num>=16)&&(num<24) ) //knobs
    {
      float fval = (float)value/127.0;
      eventTab.onMidiValue(num-16,fval);
    }
    
    else if( (num>=32)&&(num<40) ) //Bouton [S]
    {
      //println("midi S");
      servoGUIarray.midiValue(num-32,0); //  Stop/Center (both press(127) & release(0) )
    }
    
    else if( (num>=48)&&(num<56) ) //Bouton [M]
    {
      //println("midi M");
    }
    
    else if( (num>=64)&&(num<72) ) //Bouton [R]
    {
      if( value>64 ) //only press
      {
        //println("midi R");
        //midiValueCoef[num-64]*=-1.0f; //should send value? or stop ?
        servoArray.toggleDirection(num-64);
      }
    }    
    else if( num==42 ) //Main Stop
    {
      if( value>64 ) //only press
      {
        for(int i=0;i<8;i++)
          servoGUIarray.midiValue(i,0);
      }
    }
}


