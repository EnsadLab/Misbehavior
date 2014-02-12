static final int SENSOR_NB_ROWS   = 30;
static final int EVT_WIDTH = 220; 
static final int EVT_TAB_X0 = 50;
static final int EVT_TAB_Y0 = 50;
static final int EVT_BT_SIZE  = 16; 
static final int EVT_BT_SPC   = 4; 
static final int EVT_LINE_DY  = 20; 
static int SensorColonIndex = 0;

//===================================
class SensorRow
{
  int index;
  int state;
  int cmdLeft=0;

  boolean activated;
  int animIndex;
  boolean playing;
  Toggle toggleLeft;
  Toggle toggleRight;
  Toggle toggleLeftState;
  Toggle toggleRightState;
  Slider progress;
  //Textfield textAnim;
  Textlabel textAnim;
  
  SensorRow(int idx)
  {
    index = idx;
    animIndex = -1;
    activated = false;
    playing = false;
  }
  
  //FAKE
  int update()
  {
    if( (!activated)||(!playing)||(animIndex<0) )
      return 0;
    /*  
    fakePos+=fakeSpeed;
    if(fakePos>1024)
    {
      stop();
      return 2; //stopped
    }
    */  
    //progress.setValue((float)fakePos);
    if(!animGUI.isAnimPlaying(animIndex))
    {
      stop();
      return 2; //just stopped
    }
    
    progress.setValue( animGUI.getProgress(animIndex) );
    return 1;  //playing
  }
    
  void stop()
  {
     toggleRight.setColorActive(0xFF008a62);  
     toggleLeft.setColorActive(0xFF008a62);  
     toggleLeftState.setColorActive(0xFF008a62);  
     toggleRightState.setColorActive(0xFF008a62);  
     progress.setValue(0);
     playing = false;
  }
  
  void start(int side,int type)
  {
     println("dbgStart "+index+" side "+side+" ia "+animIndex);
     stop();
     if(side==0)
     {
       if(type==0)
         toggleLeft.setColorActive(0xFFFF0000);
       else
         toggleLeftState.setColorActive(0xFFFF0000);       
     }
     else
     {    
       if(type==0)
         toggleRight.setColorActive(0xFFFF0000);
       else
         toggleRightState.setColorActive(0xFFFF0000);       
     }
     progress.setValue(0);
     animGUI.startPlaying(animIndex);
     playing  = true;
  }
  
  //TEST...
  int clickLeft()
  {
    if(++cmdLeft==3)cmdLeft=0;
    switch(cmdLeft)
    {
      case 0: toggleLeft.getCaptionLabel().setText("0");break;
      case 1: toggleLeft.getCaptionLabel().setText("A");break;
      case 2: toggleLeft.getCaptionLabel().setText("B");break;
      case 3: toggleLeft.getCaptionLabel().setText("C");break;
    }
    println("dbg CLick "+cmdLeft);
    return cmdLeft;    
    
  }
    
  void buildGui(int x,int y,String tabname,int col,ControlListener cl)
  {
      toggleLeftState=cp5.addToggle("STATELOW"+col+"-"+index)
         .setId(index)
         .setPosition(x,y)
         .setSize(EVT_BT_SIZE,EVT_BT_SIZE)
         .setColorForeground(0xFFC2C2C2)
         .setColorBackground(0xFFD2D2D2)  
         .setColorActive(0xFF008a62)  
        .setLabelVisible(false)
         .moveTo(tabname)
         .addListener(cl);
       toggleLeftState.getCaptionLabel()
           .align(ControlP5.CENTER,ControlP5.CENTER)
           .setColor(255).setFont(verdanaFont).setText("X");
 
        x+=EVT_BT_SIZE+EVT_BT_SPC;
        toggleLeft=cp5.addToggle("EVDOWN"+col+"-"+index)
         .setId(index)
         .setPosition(x,y)
         .setSize(EVT_BT_SIZE,EVT_BT_SIZE)
         .setColorForeground(0xFFC2C2C2)
         .setColorBackground(0xFFD2D2D2)  
         .setColorActive(0xFF008a62)  
        .setLabelVisible(false)
         .moveTo(tabname)
         .addListener(cl);
       toggleLeft.getCaptionLabel()
           .align(ControlP5.CENTER,ControlP5.CENTER)
           .setColor(255).setFont(verdanaFont).setText("X");
        
        x+=EVT_BT_SIZE+EVT_BT_SPC;
        int w = EVT_WIDTH - ((EVT_BT_SIZE+EVT_BT_SPC)*4);
       progress = cp5.addSlider("EVPRG"+col+"-"+index)
         .setBroadcast(false)
         .setPosition(x,y)
         .setSize(w,EVT_BT_SIZE)
         .setRange(0,1)
         .setValue(0)
         .setLabelVisible(false)
         .setColorBackground(0xffCCCCCC)  
         .setColorForeground(0xffAAAAAA)  
         .setColorActive(0xffAAAAAA)
         .moveTo(tabname);
       progress.getCaptionLabel()
           .align(ControlP5.CENTER,ControlP5.CENTER)
           .setColor(255).setFont(verdanaFont)
           ;//.setText;
       
       //textAnim = cp5.addTextfield("ANIM"+col+"-"+index)
       textAnim = cp5.addTextlabel("ANIM"+col+"-"+index)
           .setPosition(x+20,y)
           .setSize(w-20,EVT_BT_SIZE)
           //.setAutoClear(false)
           .setColorBackground(0x20BBBBBB)  
           .setColorForeground(0x10888888)
           .setLabelVisible(false)
           .moveTo(tabname)
           .bringToFront()
           .setText("Anim Label")
           .setColor(0).setFont(verdanaFont);

       
        x+=w+EVT_BT_SPC;
       toggleRight=cp5.addToggle("EVUP"+col+"-"+index)
         .setId(index)
         .setPosition(x,y)
         .setSize(EVT_BT_SIZE,EVT_BT_SIZE)
         .setColorForeground(0xFFC2C2C2)
         .setColorBackground(0xFFD2D2D2)  
         .setColorActive(0xFF008a62)  
         //.setColorActive(0xFFFF0000)  
        .setLabelVisible(false)
         .moveTo(tabname)
         .addListener(cl);
       toggleRight.getCaptionLabel()
           .align(ControlP5.CENTER,ControlP5.CENTER)
           .setColor(255).setFont(verdanaFont).setText("U");

        x+=EVT_BT_SIZE+EVT_BT_SPC;
      toggleRightState=cp5.addToggle("STATEHIGH"+col+"-"+index)
         .setId(index)
         .setPosition(x,y)
         .setSize(EVT_BT_SIZE,EVT_BT_SIZE)
         .setColorForeground(0xFFC2C2C2)
         .setColorBackground(0xFFD2D2D2)  
         .setColorActive(0xFF008a62)  
       .setLabelVisible(false)
         .moveTo(tabname)
         .addListener(cl);
       toggleRightState.getCaptionLabel()
           .align(ControlP5.CENTER,ControlP5.CENTER)
           .setColor(255).setFont(verdanaFont).setText("H");    
  }
  
  void setAnim(String label,int ianim)
  {
    animIndex = ianim;
    textAnim.setText(label);
  }
  
  void setPosition(int x,int y)
  {
    toggleLeftState.setPosition(x,y);
    x+=EVT_BT_SIZE+EVT_BT_SPC;
    toggleLeft.setPosition(x,y);
    x+=EVT_BT_SIZE+EVT_BT_SPC;
    int w = EVT_WIDTH - ((EVT_BT_SIZE+EVT_BT_SPC)*4);
    progress.setPosition(x,y);
    textAnim.setPosition(x+20,y);
    textAnim.setLabelVisible(false);
    x+=w+EVT_BT_SPC;
    toggleRight.setPosition(x,y);
    x+=EVT_BT_SIZE+EVT_BT_SPC;
    toggleRightState.setPosition(x,y);
  }

  String getLabel()
  {
    return textAnim.get().getText();
  }
  
  void setVisible(boolean onOff)
  {
    activated = onOff;
    toggleLeft.setVisible(onOff);
    toggleRight.setVisible(onOff);
    toggleLeftState.setVisible(onOff);
    toggleRightState.setVisible(onOff);
    progress.setVisible(onOff);
    textAnim.setVisible(onOff);
  }

};

//==========================================
class SensorColon implements ControlListener
{
  int index;
  int positionX;
  int positionY;

  boolean activated;
  int state = 1;
  Toggle toggleActive;
  Toggle test;
  Slider sliderVal;
  Range  rangeThres;
  DropdownList dropList;
  
  int    threshold0 = 412;
  int    threshold1 = 512;
  IntList selectedLow    = new IntList();
  IntList animsLow       = new IntList();
  IntList selectedHigh   = new IntList();
  IntList animsHigh      = new IntList();
  SensorRow[] row = new SensorRow[SENSOR_NB_ROWS];
        
  SensorColon()
  {
    index = SensorColonIndex++;
    activated = false;
  }
  
  void update()
  {
    if(!activated)
      return;
    
    int playingCount = 0;
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      if( row[i].update()==1 )
        playingCount++;
    }
    if( playingCount == 0 )
     randomPlay(state);
  }

  void randomPlay(int side)
  {
    //println("dbg random play side "+side);
    IntList list = animsLow;
    if(side==1)
      list = animsHigh;
    
    if(list.size()>0)
    {
      int iA = list.get(0);
      row[iA].start(side,1);
      list.shuffle();
    }
  }

  
  void buildGUI(int x0,int y0,String tabname)
  {
    positionX = x0;
    positionY = y0;
    toggleActive = cp5.addToggle("EVONOFF"+index)
         .setId(index)
         .setPosition(x0,y0)
         .setSize(20,20)
         .setColorForeground(0xFFC2C2C2)
         .setColorBackground(0xFFD2D2D2)  
         //.setColorActive(0xFF008a62)  
         .setColorActive(0xFFFF0000)  
         .moveTo(tabname)
         .addListener(this);
       toggleActive.getCaptionLabel()
           .align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER)
           .setColor(0).setFont(verdanaFont).setText("  SENSOR "+index+"   ");

/*
    test = cp5.addToggle("EVANIM"+index)
         .setId(index)
         .setPosition(x0+100,y0)
         .setSize(20,20)
         .setColorForeground(0xFFC2C2C2)
         .setColorBackground(0xFFD2D2D2)  
         //.setColorActive(0xFF008a62)  
         .setColorActive(0xFFFF0000)  
         .moveTo(tabname)
         .addListener(this);
       test.getCaptionLabel()
           .align(ControlP5.RIGHT_OUTSIDE,ControlP5.CENTER)
           .setColor(0).setFont(verdanaFont).setText(" test "+index+"   ");
*/
    
    y0+=25;
     sliderVal = cp5.addSlider("EVTVAL"+index)
         .setBroadcast(false)
         .setPosition(x0,y0)
         .setSize(EVT_WIDTH,15)
         .setRange(0,1024)
         .setValue(512)
         .setColorForeground(0xFFB02000)
         .setColorBackground(0xFFC0B0A0)  
         .setColorForeground(0xFFB02000)
         .setColorActive(0xFFB02000)  
         .moveTo(tabname)
         .addListener(this)
         //.setBroadcast(true)
         ;
       sliderVal.getValueLabel().setFont(testFont).align(ControlP5.CENTER,ControlP5.CENTER);
 
       y0+=20;
       rangeThres = cp5.addRange("EVTR"+index) //NOT VERTICAL ; HIGH VALUE FONT ????
         .setBroadcast(false)
         .setPosition(x0,y0)
         .setSize(EVT_WIDTH,15)
         .setRange(0,1024)
         .setValue(512)
         .setHandleSize(4) //range
         .setRangeValues(threshold0,threshold1)
         .setColorBackground(0xFFC0B0A0)  
         .setColorForeground(0xFFB02000)
         .setColorActive(0xFFB02000)  
         .moveTo(tabname)
         .addListener(this)
         //.setBroadcast(true)
         ;
      
      y0+=20;
         
      dropList = cp5.addDropdownList("DROP"+index)
          .setPosition(x0,y0+15)
          .setSize(EVT_WIDTH,250)
          .moveTo(tabname)
          .setItemHeight(20)
          .addListener(this)
          .setBarHeight(12)
          .setColorForeground(color(128,197,176))
          .setColorBackground(color(204,232,224))
          .setColorActive(color(0,138,98))
          .setColorLabel(0xFF000000)
          .toUpperCase(false)
          ;
     //availableAnims.captionLabel().set("Load animation").setFont(createFont("Verdana",11)).align(ControlP5.LEFT,ControlP5.CENTER);
     //availableAnims.valueLabel().setFont(createFont("Verdana",13)).setColor(0xFFFF0000).align(ControlP5.CENTER,ControlP5.CENTER); // ne marche pas.........
     //updateDropDownAnimList();
     for(int i=0;i<20;i++)
     {
       ListBoxItem item = dropList.addItem("anim label "+i, i);
     }
     
       y0+=25;
       //String sDown = "EVDOWN"+index+"-";
       //String sPrg  = "EVPRG"+index+"-";
       //String sUp   = "EVUP"+index+"-";
       for(int ir = 0;ir<SENSOR_NB_ROWS;ir++)
       {
         row[ir] = new SensorRow(ir);
         row[ir].buildGui(x0,y0,tabname,index,this);
        y0+=EVT_LINE_DY;         
       }    
       dropList.bringToFront();
  }
  
  
  boolean appendAnim(String label,int iAnim)
  {
    //TODO one loop ?
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      if( label.equals( row[i].getLabel()) )
      {
         row[i].setAnim(label,iAnim);
         row[i].setPosition(positionX,positionY+90+(iAnim*EVT_LINE_DY));
         row[i].setVisible(true);
         return true;        
      }
    }   
 
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      if( row[i].animIndex<0 )
      {
         row[i].setAnim(label,iAnim);
         row[i].setPosition(positionX,positionY+90+(iAnim*EVT_LINE_DY));
         row[i].setVisible(true);
         return true;
      }
    }
    return false;
  }
  
  void checkLabels( StringList labels )
  {
    int nbl = labels.size();   
    if(nbl>SENSOR_NB_ROWS)
      nbl = SENSOR_NB_ROWS;

    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      row[i].setVisible(false);
    }
              
    for(int i=0;i<nbl;i++)
    {
      appendAnim(labels.get(i),i);
    }
  }
   
  void changeState(int st)
  {
    println("dbgSTATE "+state+">>>"+st);
    switch(st)
    {
      case 0:
      println("dbgSTATE nb "+selectedLow.size() );
      if(selectedLow.size()>0)
      {
        stop();
        int iA = selectedLow.get(0);
        if(activated)
          row[iA].start(0,0);
        selectedLow.shuffle();
        state = st;
      }
      break;
      case 1:
      if(selectedHigh.size()>0)
      {
        stop();
        int iA = selectedHigh.get(0);
        if(activated)
          row[iA].start(1,0);
        selectedHigh.shuffle();
        state = st;
      }
      break;     
    }
    state = st;    
  }

  
  void stop()
  {
      for(int i=0;i<SENSOR_NB_ROWS;i++)
        row[i].stop();     
  }
  
  void setVisible(boolean onOff)
  {
      for(int i=0;i<SENSOR_NB_ROWS;i++)
        row[i].setVisible(onOff);
  }  
    
  void toggleAnim(IntList list,int irow,boolean onOff)
  {
    int iA = list.index(irow);
    if(onOff)
    {
      if(iA<0)
        list.append(irow);
      println("dbg ON "+list.size());
    }      
    else
    {
      if(iA>=0)
        list.remove(iA);
      println("dbg OFF "+list.size());
    }
    list.shuffle();  
  }
    
  void controlEvent(ControlEvent evt)
  {
    if(evt.isGroup())
      return;
    if(!evt.isController())
      return;
    
    Controller c = evt.getController();
    if(c==sliderVal) //TODO desactiver
    {
      int v = (int)c.getValue();
      //println("dbg val "+v+" state "+state+" t0  "+threshold0);
      switch(state)
      {
        case 0:if(v>threshold1)changeState(1);break;
        case 1:if(v<threshold0)changeState(0);break;
      }
    }
    else if(c==rangeThres)
    {
      threshold0 = (int)c.getArrayValue(0);
      threshold1 = (int)c.getArrayValue(1);
    }
    else if(c==toggleActive)
    {
      activated = (c.getValue()>0.5);
    }
    /*
    else if( c==test )
    {      
      dropList.setPosition(400,50);
      dropList.bringToFront();
      dropList.open();
    }
    */
    else
    {   
      String addr = c.getAddress();
      int id = c.getId();
      println("SENSOR "+addr+" id:"+id);
      if(addr.startsWith("/EVDOWN"))
        toggleAnim(selectedLow,id,(c.getValue()>0.5));
      else if(addr.startsWith("/EVUP"))
        toggleAnim(selectedHigh,id,(c.getValue()>0.5));
      else if(addr.startsWith("/STATELOW"))
        toggleAnim(animsLow,id,(c.getValue()>0.5));
      else if(addr.startsWith("/STATEHIGH"))
        toggleAnim(animsHigh,id,(c.getValue()>0.5));
      
    }
  }    


  
}

//=========================================

class EventGUI implements ControlListener
{
    int rowPos = 100;
  
    boolean openned = false;
    StringList labels;
    SensorColon[] sensorColons; 
  
    Slider sliderSensor;
    Textfield[] textfields = new Textfield[6];
    Button buttons[] = new Button[6];
    Group selector;
    
  EventGUI()
  {
    sensorColons = new SensorColon[5];
    labels = new StringList();
  }


  void onOpen()
  {
    labels.clear();
    int iAnim = 0;
    String label = animGUI.getAnimLabel(0);
    while(label!=null)
    {
        if(!label.isEmpty())
          labels.append(label);
        iAnim++;
        label = animGUI.getAnimLabel(iAnim);
    }    
    for(int i=0;i<5;i++)
    {
      sensorColons[i].checkLabels( labels );
    }
    openned = true;    
  }
  
  void onClose()
  {
    openned = false;
  }
  
    
  void controlEvent(ControlEvent evt)
  {
    if(evt.isGroup())
      return;
    if(!evt.isController())
      return;
    Controller c = evt.getController();
  }    

  void update()
  {
    if(!openned)
      return;
      
    for(int i=0;i<5;i++)
      sensorColons[i].update();
  }
        
  void buildGUI(int x0,int y0,String tabname)
  {
    int x=x0;
    for(int i=0;i<5;i++)
    {
      sensorColons[i]=new SensorColon();
      sensorColons[i].buildGUI(x,y0,tabname);
      x+=EVT_WIDTH+30;
    }
    //sensorColons[3].setVisible(false); 

/*
    int y=rowPos;
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      Textlabel lbl = cp5.addTextlabel("EVTACT "+i)
        .setPosition(x0+300,y)
        .setSize(200,20)
        .setLineHeight(20)
        //.enableColorBackground()
        //.setColorBackground(0xFF000080)
        .setColorValue(0xFF000000)
        .setText("emotion")
        //.setFont(testFont)
        .bringToFront()
        .align(ControlP5.CENTER,ControlP5.CENTER,ControlP5.CENTER,ControlP5.CENTER)
        .moveTo(tabname);
        //lbl.getCaptionLabel().setText("");
        
        //lbl.getValueLabel().setWidth(500).setColorBackground(0xFF808080);
        
        y+=30;
    }
*/

  }

/*  
  void draw()
  {
    stroke(235);
    strokeWeight(10);
    int y=rowPos+20;
    for(int i=0;i<20;i++)
    {
      line(0,y,1280,y);
      y+=30;
    }
  }
 */

  




  
};




