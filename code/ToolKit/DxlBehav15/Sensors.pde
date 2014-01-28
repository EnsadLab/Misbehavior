
class SensorEvt
{
  int     servo  = -1;
  int     type   = 0;
  float   value  = 0;
  float   center = 0;
  float   coef   = 1.0f;
  int     min    = -1024;
  int     max    =  1024;
  String  cmd = null;
  void    fromXML(XML xml)
  {
    servo  = xml.getInt("servo");
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

