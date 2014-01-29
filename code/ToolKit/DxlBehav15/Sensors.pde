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
    x+=150;
    }
  }
  
  void showValue(int isensor,float value)
  {
    if( (isensor>=0)&&(isensor<6) )
      textfields[isensor].setText( String.format("%f",value));
  }  
}

class SensorArray
{
  SensorEvt[] sensorEvts;
  SensorArray()
  {
     sensorEvts = new SensorEvt[64];
     for(int i=0;i<64;i++)
       sensorEvts[i] = new SensorEvt();
  }

  void loadXmlConfig(String xmlFilePath)
  {
    println("Loading Sensor Config file...");
    XML xml = loadXML(xmlFilePath);
    if(xml==null)
      return;      //>>error message ?

     for(int i=0;i<64;i++)
       sensorEvts[i].servo = -1;
  
    XML[] children = xml.getChildren("sensor");
    for (int i = 0; i < children.length; i++)
    {
      int id = children[i].getInt("id");
      if( (id>=0)&&(id<64) )
        sensorEvts[id].fromXML( children[i] );
    }
  }
  
  void rcvValue(int index,float value)
  {
    if( (index>=0)&&(index<64) )
    {
      if(sensorEvts[index].servo>=0 )
      {
        sensorEvts[index].value = value;    
        servoArray.onCmd(sensorEvts[index]);
      }
      sensorGUI.showValue( index,value );      
    }
  }  
  
  
}

