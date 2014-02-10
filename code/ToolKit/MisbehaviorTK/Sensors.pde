class SensorEvt
{
  int     servo  = -1;
  int     type   = 0;
  float   value  = 0;
  float   center = 0;
  float   coef   = 1.0f;
  int     min    = -1024;
  int     max    =  1024;
  int     state  = -1;
  String  cmd = null;
  void    fromXML(XML xml)
  {
    servo  = xml.getInt("servo");
    type   = xml.getInt("type");
    value  = xml.getFloat("value");
    center = xml.getFloat("center");
    coef   = xml.getFloat("coef");
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

class SensorGUIarray
{
  Textfield[] textfields = new Textfield[6];
    
  void buildGUI(int x,int y,String tabName)
  {
/* ============================    
    for(int i=0;i<6;i++)
    {
     textfields[i] = cp5.addTextfield("SENSOR"+i) 
              .setText("0000.00")
              .setPosition(x ,y)
              .setWidth(90)
              .setColorBackground(color(128))

              //.setColorValue(0xFF000000)
              .setFont(createFont("Verdana",13))
              .moveTo(tabName);
              ;
    textfields[i].getCaptionLabel().setText("Sensor_"+i+"  ")
             .setColor(0xFF000000)
             .align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
             
             
      //Range slider = cp5.addRange("EVT"+i) //NOT VERTICAL
      Slider slider = cp5.addSlider("EVT"+i) //NOT VERTICAL
       .setBroadcast(false)
       .setPosition(x,y+40)
       .setSize(200,20)
       //.setHandleSize(20) //range
       //.setRangeValues(50,100)
       .setRange(0,1024)  
       .setValue(512)
       .setColorForeground(0xFF00FF00)
       .setColorBackground(0xFFFFFF00)  

       .moveTo(tabName)
       //.setBroadcast(true)
       ;
         
             
    y+=50;
    }
    
    
    
===================== */     
  }
  
  void showValue(int isensor,float value)
  {
    if( (isensor>=0)&&(isensor<6) )
      textfields[isensor].setText( String.format("%f",value));
  }  
}

class SensorArray
{
  int nbSensors = 16;  
  SensorEvt[] sensorEvts;
  SensorArray()
  {
     sensorEvts = new SensorEvt[nbSensors];
     for(int i=0;i<nbSensors;i++)
       sensorEvts[i] = new SensorEvt();
  }

  void loadConfig(String xmlFilePath)
  {
    println("Loading Sensor Config file...");
    XML xml = loadXML(xmlFilePath);
    if(xml==null)
      return;      //>>error message ?

    for(int i=0;i<16;i++)
      sensorEvts[i].servo = -1;

    XML dist = xml.getChild("DISTANCE");
    if( dist!=null)
    {
      XML x[] = dist.getChildren("sensor");
      int nb = x.length;
      println("  nb sensors "+ nb);
    
      for (int i = 0; i < nb; i++)
      {
        int id = x[i].getInt("id");
        if( (id>=0)&&(id<nbSensors) )
          sensorEvts[id].fromXML( x[i] );
      }
    }    
  }
  
  void rcvValue(int index,float value)
  {
    if( (index>=0)&&(index<64) )
    {
      if(sensorEvts[index].servo>=0 )
      {
        sensorEvts[index].value = value;    
        servoArray.onSensor(sensorEvts[index]);
      }
      sensorGUI.showValue( index,value );      
    }
  }  
  
  
}

