import javax.sound.midi.*;
import java.util.List;

public class MidiHandler
{
  int glou = 0;
  MidiDevice deviceIn = null;
  MidiRcv    receiver = null;

  MidiHandler()
  {
  }
  
  void printdevices()
  {
    MidiDevice device;
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    println("Nb MidiDeviceInfos "+infos.length);
    for(int i=0;i<infos.length;i++)
    {
        println( infos[i] );
        device = null;
        try{ device = MidiSystem.getMidiDevice(infos[i]); }
        catch(Exception e){println(" device exception");} //GRRRR
        
        if(device !=null)
        {
          //List<Transmitter> transmitters = device.getTransmitters();
          //println(" nb transmitters: "+ transmitters.size() ); // 0 !!! GRRRR ....
          //for(int j=0;j<transmitters.size();j++){}
          try{ Transmitter transmitter = device.getTransmitter(); println("   transmitter");}
          catch(Exception e){}
            
          try{Receiver receiver = device.getReceiver();println("   receiver");}
          catch(Exception e){}  
        }           
    }    
  }
  
  void close()
  {
    if(deviceIn!=null)
    {
      deviceIn.close();
      deviceIn = null;
    }
  }
  
  void openIn(String name)
  {
    close();
    println("====================");
    println("Opening input "+name);
    MidiDevice device;
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    for(int i=0;i<infos.length;i++)
    {
        if( name.equals(infos[i].getName() ) )
        {
          device = null;
          try
          {
            println( "get device ..." );
            device = MidiSystem.getMidiDevice(infos[i]);
            println( "get transmitter ..." );
            Transmitter transmitter = device.getTransmitter();
            receiver = new MidiRcv();
            println( " setReceiver ..." );
            transmitter.setReceiver(receiver);
            println( " openning ..." );
            device.open();
            deviceIn = device;
            println( "OPEN OK" );
            break;
            
          }
          catch(Exception e){println(" EXCEPTION");}
        }
    }
    if(deviceIn==null)
      println( name+" input NOT FOUND" );
    
  }

  class MidiRcv implements Receiver
  {
    
    public void send(MidiMessage msg,long tstamp) //send ???
    {
      int status = msg.getStatus();
      int len = msg.getLength();
      byte[] b = msg.getMessage();
      
      print("midimsg s="+status+" l="+len+" : ");
      for(int i=0;i<b.length;i++)
        print(" "+String.format("%02X",b[i] ));
      println("");
    }
    public void close()
    {
    }
    
  };


  
};

