
int numScriptGUI = 0;

class ScriptGUI implements ControlListener //implements CallbackListener
{
  int scriptIndex = 0;
  int idFile   = 1;
  Textfield textFile   = null;
  Textfield textEngine = null;
  Toggle    togglePlay = null;
  Toggle    toggleStep = null;
  
  ListBox listbox;
  
  int consoleMaxLines = 30;
  Textarea console;
    
  int nbLines = 0;
  int currLine = 0;
  
  ScriptGUI(int x,int y,int h,String tabName)
  {
    scriptIndex = numScriptGUI++;
    build(x,y,h,tabName);
  }
  
  void build(int x,int y,int h,String tabName)
  {
    idFile = globalID++;
    textFile = cp5.addTextfield("Script "+scriptIndex)
                  .setId(idFile)
                  .setPosition(x+30,y)
                  .setSize(200,18)
                  .setAutoClear(false)
                  .moveTo(tabName);
   textFile.getCaptionLabel().setText("FILE ");
   //textFile.getCaptionLabel().align(ControlP5.TOP_OUTSIDE,ControlP5.TOP_OUTSIDE);
   textFile.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
   textFile.addListener(this);

    y+=20;
    
   togglePlay = cp5.addToggle("SPLAY"+scriptIndex)
       .setId(globalID++)
       .setPosition(x+100,y)
       .setWidth(30)
       .moveTo(tabName);
   togglePlay.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   togglePlay.getCaptionLabel().setText("PLAY");
   togglePlay.addListener(this);

    

   textEngine = cp5.addTextfield("Servo "+scriptIndex)
                  .setId(idFile)
                  .setPosition(x+30,y)
                  .setSize(50,18)
                  .setAutoClear(false)
                  .moveTo(tabName);
   textEngine.getCaptionLabel().setText("Servo ");
   textEngine.getCaptionLabel().align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);
   textEngine.addListener(this);

    y+=40;

   console = cp5.addTextarea("console "+scriptIndex)
     .setPosition(x+103,y-15)
     .setSize(150,h)
     .setLineHeight(20)
     .setColor(color(255))
     .setColorBackground(color(0))
     .setColorForeground(color(255))
     .setFont(arialFont)
     .moveTo(tabName);
     
    listbox = cp5.addListBox("ScrList"+scriptIndex)
         .setId(globalID++)
         .setPosition(x,y)
         .setSize(100,h-15) //80 ????
         .toUpperCase(false)
         .setItemHeight(15)
         .setBarHeight(15)
         .setColorBackground(color(255, 128))
         .setColorActive(color(0))
         .setColorForeground(color(128,128,128))
         .actAsPulldownMenu(false)
         .moveTo(tabName);

  listbox.captionLabel().toUpperCase(false);
  listbox.captionLabel().set("A Listbox");
  listbox.captionLabel().setColor(0xff000000);
  listbox.captionLabel().style().marginTop = 3;
  listbox.valueLabel().style().marginTop = 3;
  
  listbox.addListener(this);
  
//   cp5.addCallback(this);    
  }
  
  void clearList()
  {
    nbLines = 0;
    currLine = 0;
    listbox.clear();
  }
  void clearConsole()
  {
    console.clear();
  }
  void print(String txt)
  {
    console.append(txt,consoleMaxLines);
    console.scroll(1.0);
  }  
  void load(String filename)
  {
    clearList();
    clearConsole();
    print("loading "+filename);
    try{ scriptArray[scriptIndex].load(filename); }
    catch(Exception e){}
  }
   
  void setName(String name)
  {
    textFile.setValue(name);
  }
    
  void addLine(String line)
  {
    ListBoxItem lbi = listbox.addItem(line,nbLines++);
    lbi.setId(globalID++);
    lbi.toUpperCase(false);
    lbi.setColorBackground(0xff808080);
    lbi.setColorForeground(0xFF707070);
    lbi.setColorActive(0xFF00FF00);
  }
  
  void setCurrLLine(int iline)
  {
    ListBoxItem lbi = listbox.getItem(currLine);
    if(lbi!=null)
    {
      lbi.setColorBackground(0xff808080);
      lbi.setColorForeground(0xFF707070);
    }
    currLine = iline;
    lbi = listbox.getItem(currLine);
    if(lbi!=null)
    {
      lbi.setColorBackground(0xff505050);
      lbi.setColorForeground(0xFF404040);
    }
    
  }

  void playStop()
  {
     if( togglePlay.getValue() > 0.5 )
     {
        togglePlay.getCaptionLabel().setText("STOP");
     }
     else
     {
        togglePlay.getCaptionLabel().setText("PLAY");
     }
  }
  
  void controlEvent(ControlEvent evt)
  {
    if (evt.isGroup())
    {
      ControlGroup g = evt.group();
      if( g == listbox )
      {
        int iline = (int)g.value();
        setCurrLLine(iline);
        println("test "+iline);
      }
    }
    else if(evt.isController())
    {
      Controller c = evt.getController();
      if( c== textFile ){ load(c.getStringValue()); }
      else if(c==togglePlay){ playStop(); }
    }
  }
  
  /*
  void controlEvent(CallbackEvent evt)
  {
     Controller c = evt.getController();
     int id = c.getId();
     //if( (id==idExec)&&(evt.getAction()==ControlP5.ACTION_PRESSED) )    
     //  lineStep();

      int ac = evt.getAction();
      switch(ac)
      {
      case ControlP5.ACTION_PRESSED:println("ACTION_ENTER");break;
      case ControlP5.ACTION_ENTER:println("ACTION_ENTER");break;
      case ControlP5.ACTION_LEAVE:println("ACTION_LEAVE");break;
      case ControlP5.ACTION_RELEASEDOUTSIDE:println("ACTION_RELEASEDOUTSIDE");break;
      case ControlP5.ACTION_RELEASED:println("ACTION_RELEASED");break;
      case ControlP5.ACTION_BROADCAST:println("ACTION_BROADCAST");break;
      default:
        println("?ACTION UNKNOWN?");      
    }
  }
  */
  
}
