
int numScriptGUI = 0;

class ScriptGUI implements ControlListener //implements CallbackListener
{
  Script script = null;
  
  int scriptIndex = 0;
  int idFile   = 1;
  Textfield textFile   = null;
  Textfield textEngine = null;
  Toggle    togglePlay = null;
  Button    buttonStep = null;
  
  ListBox listbox;
  
  int consoleMaxLines = 30;
  Textarea console;
    
  int nbLines  = 0;
  int currLine = 0;
  int nextLine = 0;
  
  ScriptGUI(Script scr)
  {
    script = scr;
    scriptIndex = numScriptGUI++;
  }
  
  /*
  ScriptGUI(int x,int y,int h,String tabName)
  {
    scriptIndex = numScriptGUI++;
    build(x,y,h,tabName);
  }
  */
  void build(int x,int y,int h,String tabName)
  {
    idFile = globalID++;
    textFile = cp5.addTextfield("Script "+scriptIndex)
                  .setId(idFile)
                  .setPosition(x,y)
                  .setSize(300,18)
                  .setAutoClear(false)
                  .moveTo(tabName)
                  .addListener(this);

   textFile.getCaptionLabel().setText("SCRIPT FILE ")
     .setColor(0xFF000000)
     .align(ControlP5.TOP_OUTSIDE,ControlP5.TOP_OUTSIDE);
     //.align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER);

    y+=20;

   textEngine = cp5.addTextfield("Servo "+scriptIndex)
                  .setId(idFile)
                  .setPosition(x+280,y)
                  .setSize(20,18)
                  .setAutoClear(false)
                  .setValue(" "+scriptIndex)
                  .moveTo(tabName)
                  .addListener(this);
   textEngine.getCaptionLabel().setText(" SERVO INDEX ")
             .setColor(0xFF000000)
             .align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);

    
   togglePlay = cp5.addToggle("SPLAY"+scriptIndex)
       .setId(globalID++)
       .setPosition(x,y)
       .setSize(50,30)
       .moveTo(tabName);
   togglePlay.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   togglePlay.getCaptionLabel().setText("PLAY");
   togglePlay.addListener(this);

   buttonStep = cp5.addButton("SSTEP"+scriptIndex)
       .setId(globalID++)
       .setPosition(x+100,y)
       .setSize(50,30)
       .moveTo(tabName);
   buttonStep.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER);
   buttonStep.getCaptionLabel().setText("STEP");
   buttonStep.addListener(this);
    
    y+=55;

   console = cp5.addTextarea("console "+scriptIndex)
     .setPosition(x+150,y-15)
     .setSize(150,h)
     .setLineHeight(20)
     .setColor(color(255))
     .setColorBackground(color(0))
     .setColorForeground(color(255))
     .setFont(courrierFont)
     .moveTo(tabName);
     
    listbox = cp5.addListBox("ScrList"+scriptIndex)
         .setId(globalID++)
         .setPosition(x,y)
         .setSize(145,h-15) //80 ????
         .toUpperCase(false)
         .setItemHeight(18)
         .setBarHeight(18)
         .setColorBackground(color(255, 128))
         .setColorActive(color(0))
         .setColorForeground(color(128,128,128))
         .actAsPulldownMenu(false)
         .setScrollbarWidth(10)
         .disableCollapse()
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
    nbLines  = 0;
    currLine = 0;
    nextLine = 0;
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
    try{ script.load(filename); }
    catch(Exception e){}
    setCurrLine(0,0);
    listbox.scrolled(0);
  }
  
  void update()
  {
    if(currLine != script.currLine )
    {
      int pl = currLine;
      setCurrLine(script.currLine,script.iLine);
    }    
  }
  
  void scriptStep()
  {
    int next = script.nextStep();
    println("next = "+next);
    setCurrLine(currLine,next);
  }
  
  void playStop()
  {
     if( togglePlay.getValue() > 0.5 )
     {
        togglePlay.getCaptionLabel().setText("STOP");
        script.run();
     }
     else
     {
        script.stop();
        togglePlay.getCaptionLabel().setText("PLAY");
     }
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
    //lbi.getCaptionLabel().setFont(courrierFont);
  }
  
  void setCurrLine(int current,int next)
  {
    int clr = 0xFFFF0000;
    if(current==next)
      clr = 0xFF404040;
    
    ListBoxItem lbc = listbox.getItem(currLine);
    if(lbc!=null)
    {
      lbc.setColorBackground(0xff808080);
      lbc.setColorForeground(0xFF707070);
    }
    nextLine = next;
    currLine = current;
    lbc = listbox.getItem(currLine);
    if(lbc!=null)
    {
      lbc.setColorBackground(clr);
      lbc.setColorForeground(clr);
    }
  }

  
  void controlEvent(ControlEvent evt)
  {
    if (evt.isGroup())
    {
      ControlGroup g = evt.group();
      if( g == listbox )
      {
        int line = (int)g.value();
        setCurrLine(currLine,line);
        script.start(line);
      }
    }
    else if(evt.isController())
    {
      Controller c = evt.getController();
      if( c== textFile ){ load(c.getStringValue()); }
      else if(c==togglePlay){ playStop(); }
      else if(c==buttonStep){ scriptStep(); }
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
