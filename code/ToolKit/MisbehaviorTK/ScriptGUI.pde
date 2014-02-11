
int numScriptGUI = 0;

class ScriptGUI implements ControlListener //implements CallbackListener
{
  Script script = null;
  int scriptIndex = 0;
  int idFile   = 1;
  long clickTime = 0; //pour double click
    
  RadioButton radioScript;
  Textfield textFile;
  Slider advSliderGoal;
  Slider advSliderSpeed;
  Slider advSliderWheel;

  Textfield textServoA  = null;
  Textfield textServoB  = null;
  Button    buttonPlay = null;
  Button    buttonStop = null;
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
      
  void build(int x,int y,int h,String tabName)
  {
    idFile = globalID++;
    radioScript = cp5.addRadioButton("SCRIPTSEL"+scriptIndex)
           .setPosition(x,y)
           .setSize(20,15)
           .setColorBackground(0xFFC0C0C0)
           .setColorForeground(0xFF505080)
           .setColorActive(0xFF404080)
           .setColorLabel(color(0))
           .setItemsPerRow(6)
           .setSpacingColumn(36)
           .addItem("SRADIO0"+scriptIndex,0)
           .addItem("SRADIO1"+scriptIndex,1)
           .addItem("SRADIO2"+scriptIndex,2)
           .addItem("SRADIO3"+scriptIndex,3)
           .addItem("SRADIO4"+scriptIndex,4)
           .addItem("SRADIO5"+scriptIndex,5)
           .addListener(this) //GRRRRR no event ???
           .moveTo(tabName)
           ;
     
     for(int i=0;i<6;i++)
     {
       Toggle t = radioScript.getItem(i);
       t.addListener(this);       
       Label lb = t.captionLabel();
       lb.setText("M "+i);
       //lb.setColorBackground(0xFFC0C0C0);
       lb.style().moveMargin(-7,0,0,-3);
       lb.style().movePadding(7,0,0,3);
       //lb.style().backgroundWidth = 45;
       //lb.style().backgroundHeight = 13;       
     }
    
    
    
     /*   
    CheckBox chkBox =
            cp5.addCheckBox("SCHECK"+scriptIndex)
            .moveTo(tabName)
            .setPosition(x,y)
            .setColorBackground(0xFF00FF00)
            .setColorForeground(0xFFFFFF00)
            .setColorActive(0xFFFF0000)
            .setColorLabel(0xFF00FF00)
            .setSize(20, 10)
            .setItemsPerRow(6)
            .setSpacingColumn(40)
            .setSpacingRow(10)
            .addItem("C0"+scriptIndex, 0)
            .addItem("C1"+scriptIndex, 1)
            .addItem("C2"+scriptIndex, 2)
            .addItem("C3"+scriptIndex, 3)
            .addItem("C4"+scriptIndex, 4)
            .addItem("C5"+scriptIndex, 5)
            ;
    for(int i=0;i<6;i++)
    {
      chkBox.getItem(i).getCaptionLabel()
         .setText("X").setColor(0xFF000000)
        .align(ControlP5.CENTER,ControlP5.CENTER);
    }
    */
    
    y+=30;
    textFile = cp5.addTextfield("Script "+scriptIndex)
                  .setId(idFile)
                  .setPosition(x,y)
                  .setSize(300,20)
                  .setAutoClear(false)
                  .moveTo(tabName)
                  .addListener(this);

   textFile.getCaptionLabel().setText("SCRIPT FILE ")
     .setColor(0xFF000000)
     .align(ControlP5.TOP_OUTSIDE,ControlP5.TOP_OUTSIDE);
     //.align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER);

   y+=30;
   
  advSliderGoal = cp5.addSlider("ADVGOAL"+scriptIndex)
   .setPosition(x,y)
   .setSize(300,20)
   .setRange(0,1024)
   .setValue(512)
   .moveTo(tabName)
   .addListener(this);
  advSliderGoal.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setText("GOAL");
  
  y+=25;
  advSliderSpeed = cp5.addSlider("ADVSPEED"+scriptIndex)
   .setPosition(x,y)
   .setSize(300,20)
   .setRange(0,1024)
   .setValue(0)
   .moveTo(tabName)
   .addListener(this);
  advSliderSpeed.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setText("SPEED");
  
  y+=25;
  advSliderWheel = cp5.addSlider("ADVWHEEL"+scriptIndex)
   .setPosition(x,y)
   .setSize(300,20)
   .setRange(-1024,1024)
   .setValue(0)
   .moveTo(tabName)
   .addListener(this);
  advSliderWheel.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setText("WHEEL");

  y+=30; 

   buttonStep = cp5.addButton("SSTEP"+scriptIndex)
       .setId(globalID++)
       .setPosition(x,y)
       .setSize(60,30)
       .moveTo(tabName)
       .addListener(this);
   buttonStep.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER)
        .setText("STEP");

   buttonPlay = cp5.addButton("SPLAY"+scriptIndex)
       .setId(globalID++)
       .setPosition(x+80,y)
       .setSize(60,30)
       .moveTo(tabName)
       .addListener(this);
   buttonPlay.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER)
       .setText("PLAY");

  buttonStop = cp5.addButton("SSTOP"+scriptIndex)
       .setId(globalID++)
       .setPosition(x+150,y)
       .setSize(60,30)
       .moveTo(tabName)
       .addListener(this);
   buttonStop.getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER)
       .setText("STOP");

   textServoA = cp5.addTextfield("Servo1"+scriptIndex)
                  .setId(idFile)
                  .setPosition(x+280,y)
                  .setSize(20,18)
                  .setAutoClear(false)
                  .setValue(" "+scriptIndex)
                  .setInputFilter(Textfield.INTEGER)
                  .moveTo(tabName)
                  .addListener(this);
   textServoA.getCaptionLabel().setText(" SERVO A ")
             .setColor(0xFF000000)
             .align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);

   textServoB = cp5.addTextfield("Servo2"+scriptIndex)
                  .setId(idFile)
                  .setPosition(x+280,y+20)
                  .setSize(20,18)
                  .setAutoClear(false)
                  .setValue("-1")
                  .setInputFilter(Textfield.INTEGER)
                  .moveTo(tabName)
                  .addListener(this);
   textServoB.getCaptionLabel().setText(" SERVO B ")
             .setColor(0xFF000000)
             .align(ControlP5.LEFT_OUTSIDE,ControlP5.CENTER);

    
    y+=60;

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
         .setItemHeight(20)
         .setBarHeight(18)
         .setColorBackground(color(255))
         .setColorActive(color(0))
         .setColorForeground(color(255,255,255)) //bar
         .actAsPulldownMenu(false)
         .setScrollbarWidth(10)
         .disableCollapse()
         //.setfont(testFont) // dont exist for listBox !!!!
         .moveTo(tabName);

  listbox.captionLabel().toUpperCase(false);
  listbox.captionLabel().set("Script");
  listbox.captionLabel().setColor(0xff000000);
  listbox.captionLabel().style().marginTop = 3;
  listbox.valueLabel().style().marginTop = 3;
  listbox.valueLabel().setFont(testFont); //......rien

  listbox.addListener(this);
  
//   cp5.addCallback(this);    
  }
  
  void changeScript(int other)
  {
    stop(); //... ??? TODO dont stop ???
    clearList();
    clearConsole();
    Script scr = scriptArray.scriptAt(other);
    script = scr;
    if( scr != null )
      scr.setGUI(this);
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
    //println("curr "+currLine+"next = "+next);
    setCurrLine(currLine,next);
  }
  /*
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
  */
  
   
  void setName(String name)
  {
    textFile.setValue(name);
  }
    
  void addLine(String line)
  {
    ListBoxItem lbi = listbox.addItem(line,nbLines++);
    lbi.setId(globalID++);
    lbi.setColorLabel(color(0));
    lbi.toUpperCase(false);
    lbi.setColorBackground(0xffC0C0C0);
    lbi.setColorForeground(0xFF707070);
    lbi.setColorActive(0xFF00FF00);
    //lbi.setFont(courrierFont);
  }
  
  void setCurrLine(int current,int next)
  {
    int clr = 0xFFFF0000;
    if(current==next)
      clr = 0xFF404040;
    
    ListBoxItem lbc;
    try
    {
      lbc = listbox.getItem(currLine); //Exception
      lbc.setColorBackground(0xff808080);
      lbc.setColorForeground(0xFF707070);
    }catch(Exception e){}

    nextLine = next;
    currLine = current;
    try
    {
      lbc = listbox.getItem(currLine);
      lbc.setColorBackground(clr);
      lbc.setColorForeground(clr);
    }
    catch(Exception e){}
  }

  void controlEvent(ControlEvent evt)
  {
    println("evt:"+evt.getName());
      if( evt.isFrom(radioScript) )
         println("RADIO");

    if (evt.isGroup())
    { 
       println("is group");
      
      ControlGroup g = evt.group();
      if( g == listbox )
      {
        long t = millis();
        long dt = t-clickTime;
        clickTime = t;
        
        int line = (int)g.value();
        setCurrLine(currLine,line);
        script.start(line);
        //println("click "+dt);
        if(dt<250) //double click (should check same line?)
          script.run();
      }
    }
    else if( evt.isController() )
    {
      Controller c = evt.getController();
      if( c== textFile ){ load(c.getStringValue()); }
      else if( c== textServoB ){ script.servoIndexB = Integer.parseInt(c.getStringValue().trim()); }
      else if(c==buttonPlay){ script.run();  }
      else if(c==buttonStop){ script.stop(); }
      else if(c==buttonStep){ scriptStep();  }
      else if(c==advSliderGoal)
      {
          ServoDxl servo = servoArray.getByIndex(script.servoIndex);
          if(servo != null)
            servo.setGoal((int)c.getValue());
      }
      else if(c==advSliderSpeed)
      {
          ServoDxl servo = servoArray.getByIndex(script.servoIndex);
          if(servo != null)
            servo.setSpeed((int)c.getValue());
      }
      else if(c==advSliderWheel)
      {
          ServoDxl servo = servoArray.getByIndex(script.servoIndex);
          if(servo != null)
            servo.setWheelSpeed((int)c.getValue());
      }
      else if( c.getAddress().startsWith("/SRADIO") )
      {
        println("dbg radio "+radioScript.getValue() ); //ok
        changeScript( (int)radioScript.getValue() );
        
      }
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
