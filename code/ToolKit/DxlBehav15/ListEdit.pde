
static ListEdit editActive = null;
static boolean editHandleKey(int k, int kc )
{
  if( editActive != null )
    return editActive.onKey(k,kc);
  return false;
}
static void editSave(String fname)
{
  if( editActive != null )
    editActive.save(fname);
}
static void editLoad(String fname)
{
  if( editActive != null )
    editActive.load(fname);
}



class ListEdit implements CallbackListener
{    
  int idFile   = 0;
  Textfield textFile = null;
  int idSlider = 0;
  Slider slider = null;
  Group myGroup = null;
  
  String title = "edit";
  String nameId = "E"; //GRRR: names are unique & only way to retrieve ctrler


  int idFirst = 0;
  int idLast  = 0;
  boolean focusChange = false;
  int idEdit = -1;
  int eventCount = 0;
  int nbLines = 0;
  int currLine = 0;
  Textfield currTF = null;
  
  Script script;
  String lines[];

  ListEdit(String name)
  {
    title = name;
  }
  
  void buildGui(String strId,int x,int y,int nbl)
  {
    lines = new String[nbl];
    
    idFile = globalID++;
    textFile = cp5.addTextfield("Script "+strId)
                  .setId(idFile)
                  .setPosition(x,y)
                  .setSize(150,18)
                  .setAutoClear(false);
    
    idSlider = globalID++;
    slider = cp5.addSlider("SLD"+strId)
                .setId(idSlider)
                .setPosition(x+155,y)
                .setSize(10,nbl*20)
                .setRange(0,nbl)
                .setNumberOfTickMarks(nbl);

    
    y+=50;
    nameId = strId;
    myGroup = cp5.addGroup(title)
                  .setId(globalID++)
                  //.toUpperCase(false)
                  .setPosition(x,y)
                  .setBarHeight(15)
                  .setWidth(150)
                  .setBackgroundHeight(100)
                  .setBackgroundColor(color(80,80,80,255));
           
    myGroup.getCaptionLabel().toUpperCase(false);      
    int gy = 0;
    
    idFirst = globalID;
    for(int i=0;i<nbl;i++)
    {
      cp5.addTextfield(nameId+i)
       .setGroup(myGroup)
       .setId(globalID++)
       .setPosition(0,gy)
       .setWidth(150)
       .setAutoClear(false)
       //.addListener(this);
       //.addCallback(this); //NIET ... GRRRR
       .setLabel("");
       gy+=19;
    }
    idLast  = globalID;
    nbLines = idLast-idFirst;
    
    cp5.addCallback(this);
    
  }
  
  void save(String fname)
  {
    PrintWriter file = createWriter(fname);
    for(int i=0;i<nbLines;i++)
    {
      Controller c = cp5.getController(nameId+i);
      if(c!=null)
        file.println( c.getStringValue() );
      
    }
    file.flush();
    file.close();
  }

  String getLine(int iLine)
  {
    if( (iLine<0) || (iLine>=nbLines) )
      return null;
    Controller c = cp5.getController(nameId+iLine);
    if(c==null)
      return null;
      
    return c.getStringValue();    
  }
  
  void load(String fname)
  {
    for(int i=0;i<nbLines;i++)
      ((Textfield)(cp5.getController(nameId+i))).setValue("");
    
    BufferedReader  file = createReader(fname);
    try{
      for(int i=0;i<nbLines;i++)
      {
        Textfield tf =(Textfield)(cp5.getController(nameId+i));
        tf.setValue( file.readLine() );
        tf.submit();
      }
      textFile.setValue(fname);
      scriptTokenize();
    }catch(Exception e){}
    try{ file.close(); }
    catch(Exception e){}
  }
    
  boolean onKey(int k,int kc)
  {
    if(!myGroup.isOpen()||(currTF==null) )
      return false;
  
    if(!currTF.isFocus() )
      return false;
     
    boolean handled = true;  
    if(key==CODED)
    {
      if(kc==UP) changeFocus(currLine-1);
      else if(kc==DOWN)changeFocus(currLine+1);
      else handled = false;
    }
    else if( kc==CONTROL )
    {
      if( k=='S') save("anims/Anim"+nameId+".txt");
      else if( k=='L' )load("anims/Anim"+nameId+".txt");
      else if( k=='X' )script.run(); //scriptTokenize();
      else if( k==' ' )scriptStep();      
      else handled = false;
    }
    else if( (k==RETURN)||(k==ENTER) )
      changeFocus(currLine+1);
      
    return handled;
  }
  
  void changeFocus(int line)
  {
    if( (line<0)||(line>=nbLines) )
      return;
    
    if( currTF != null )
    {
      currTF.submit();
      currTF.setFocus(false);
    }
    
    Controller c = cp5.getController(nameId+line);
    if(c!=null)
    {
      currTF = (Textfield)c;
      currTF.setFocus(true);
      currLine = line;
      String s = currTF.getText().trim();
      currTF.setText(s);
      currTF.submit();
      int len=s.length();
      if(len>2)
      {
        for(int i=0;i<len;i++){
          if(s.charAt(i)<32)print(" "+(int)s.charAt(i) );
        }
        //println("edit <"+s+">"+(int)s.charAt(len-1) );
      }
    }    
  }
  
  void scriptTokenize()
  {
    if( lines == null )
    {
      println("LINES NULL");
      return;
    }
    if( script == null )
    {
      println("SCRIPT NULL");
      return;
    }
    
    for(int i=0;i<nbLines;i++)
    {
      Controller c = cp5.getController(nameId+i);
      if(c!=null)
        lines[i]=c.getStringValue().trim();      
    }
    script.parse(lines);   
    println("currLine "+currLine);
    script.start(currLine);
  }
  
  void scriptStep()
  {    
    //println("currLine "+currLine);
    int next = script.nextStep();
    changeFocus(next);
  }
  
  
  void controlEvent(CallbackEvent evt)
  {
     Controller c = evt.getController();
     int id = c.getId();
     //if( (id==idExec)&&(evt.getAction()==ControlP5.ACTION_PRESSED) )    
     //  lineStep();

      int ac = evt.getAction();
      switch(ac)
      {
      case ControlP5.ACTION_PRESSED:
        editActive = this;
      case ControlP5.ACTION_ENTER:println("ACTION_ENTER");break;
      case ControlP5.ACTION_LEAVE:println("ACTION_LEAVE");break;
      case ControlP5.ACTION_RELEASEDOUTSIDE:println("ACTION_RELEASEDOUTSIDE");break;
      case ControlP5.ACTION_RELEASED:println("ACTION_RELEASED");break;
      case ControlP5.ACTION_BROADCAST:println("ACTION_BROADCAST");editActive = this;break;
      default:
        println("ACTION UNKNOWN");      
    };
      
      
      
      if(id==idFile)
      {
        if(ac==ControlP5.ACTION_BROADCAST)
          load(c.getStringValue());
        return;
      }
     
     
      if( (id<idFirst)||(id>=idLast) )
        return;

      Textfield tf = (Textfield)c;

      switch(ac)
      {
        case ControlP5.ACTION_PRESSED:
          currTF = tf;
          currLine = c.getId()-idFirst;
          editActive = this;
          break;
        case ControlP5.ACTION_RELEASED:
          currTF = tf;
          currLine = c.getId()-idFirst;
          editActive = this;
          scriptTokenize();
          script.start(currLine);
          break;
/*        
        println("ACTION_PRESSED");break;
      case ControlP5.ACTION_ENTER:println("ACTION_ENTER");break;
      case ControlP5.ACTION_LEAVE:println("ACTION_LEAVE");break;
      case ControlP5.ACTION_RELEASEDOUTSIDE:println("ACTION_RELEASEDOUTSIDE");break;
      case ControlP5.ACTION_RELEASED:println("ACTION_RELEASED");break;
      case ControlP5.ACTION_BROADCAST:println("ACTION_BROADCAST");break;
      default:
        println("ACTION UNKNOWN");
*/      
    };
/*    
    if(ac==ControlP5.ACTION_BROADCAST)
    {
      int nid = id+1;
      if( nid>=idLast)
        return;
      if(idEdit<0)
        idEdit = id;
      else
      {      
        idEdit = -1;
        Controller n = cp5.getController("A"+(nid-idFirst));
        if(n==null)
          println("next is null");
        else
        {
            ((Textfield)c).setFocus(false);
            ((Textfield)n).setFocus(true);
        }
      }
    }
    */
  }
 
};
