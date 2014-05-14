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

// TODO

static final int SENSOR_NB_COLS   = 5;
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
  int checkFlags;
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
    checkFlags = 0;
    animIndex = -1;
    activated = false;
    playing = false;
  }
  
  int update()
  {
    if( (!activated)||(!playing)||(animIndex<0) )
      return 0;

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
     animGUI.stopPlaying(animIndex);
     toggleRight.setColorActive(0xFF008a62);  
     toggleLeft.setColorActive(0xFF008a62);  
     toggleLeftState.setColorActive(0xFF008a62);  
     toggleRightState.setColorActive(0xFF008a62);  
     progress.setValue(0);
     playing = false;
  }
  
  void start(int side,int type)
  {
     //println("dbgStart "+index+" side "+side+" ia "+animIndex);
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
           .setColor(255).setFont(verdanaFont_12).setText("X");
 
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
           .setColor(255).setFont(verdanaFont_12).setText("X");
        
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
           .setColor(255).setFont(verdanaFont_12)
           ;//.setText;
       
       textAnim = cp5.addTextlabel("ANIM"+col+"-"+index) //TODO progess label
           .setPosition(x+20,y-10)
           .setSize(w-20,EVT_BT_SIZE)
           //.setAutoClear(false)
           .setColorBackground(0x20BBBBBB)  
           .setColorForeground(0x10888888)
           .setLabelVisible(false)
           .moveTo(tabname)
           .bringToFront()
           .setText("Anim Label")
           .setColor(0).setFont(verdanaFont_12);

       
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
           .setColor(255).setFont(verdanaFont_12).setText("U");

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
           .setColor(255).setFont(verdanaFont_12).setText("H");    
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
    textAnim.setPosition(x+20,y-1);
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
  
  int getToggles()
  {
    checkFlags = 0;
    if(toggleRightState.getValue()>0.5)checkFlags |= 1;    
    if(toggleRight.getValue()>0.5)checkFlags      |= 2;
    if(toggleLeft.getValue()>0.5)checkFlags       |= 4;
    if(toggleLeftState.getValue()>0.5)checkFlags  |= 8;
    return checkFlags;
  }
  void setToggles(int flags)
  {
    if((flags & 1)==0)toggleRightState.setValue(0);else toggleRightState.setValue(1);
    if((flags & 1)==0)toggleRight.setValue(0);else toggleRight.setValue(1);
    if((flags & 1)==0)toggleLeft.setValue(0);else toggleLeft.setValue(1);
    if((flags & 1)==0)toggleLeftState.setValue(0);else toggleLeftState.setValue(1);
    checkFlags = flags;
  }
  

};

//==========================================
class SensorColon implements ControlListener
{
  int index;
  boolean activated;
  int positionX;
  int positionY;
  int inputType = 1; //manual
  int inputNum  = 0;
  int    min = 0;
  int    max = 1000;  
  int    threshold0 = 100;
  int    threshold1 = 110;

  int state = 1;
  Toggle toggleActive;
  Toggle test;
  Slider sliderVal;
  Range  rangeThres;
  DropdownList dropList;
  Textlabel textSensor=null;

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

  void toXML(XML xml)
  {
    XML xmlMe = xml.addChild("event");
    xmlMe.setInt("index",index);
    xmlMe.setInt("input",inputType);
    xmlMe.setInt("inputNum",inputNum);
    xmlMe.setInt("min",min);
    xmlMe.setInt("max",max);
    xmlMe.setInt("thresLow",threshold0);
    xmlMe.setInt("thresHigh",threshold1);
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      if( (row[i].activated) && (row[i].animIndex>=0) )
      {
        XML xmlAnim = xmlMe.addChild("anim");
        xmlAnim.setString("label",row[i].getLabel());
        xmlAnim.setInt("whenLow" ,(int)row[i].toggleLeftState.getValue() );
        xmlAnim.setInt("onLow"   ,(int)row[i].toggleLeft.getValue() );
        xmlAnim.setInt("onHigh"  ,(int)row[i].toggleRight.getValue() );
        xmlAnim.setInt("whenHigh",(int)row[i].toggleRightState.getValue() );
      }      
    }
  }

  void fromXML(XML child)
  {
    println("dbg FROM XML");
    activated = false;
    inputType = child.getInt("input");
    inputNum = child.getInt("inputNum");
    min = child.getInt("min");
    max = child.getInt("max");
    threshold0 = child.getInt("thresLow");
    threshold1 = child.getInt("thresHigh");
    setMinMax(min,max);
    //rangeThres.setRangeValues(threshold0,threshold1);
    //println("dbg1 threshold0 "+threshold0);
    //println("dbg1 threshold1 "+threshold1);    

    dropList.setIndex(inputType);

    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      row[i].setVisible(false);
      row[i].animIndex = -1;
    }
    
    XML xmlRow[] = child.getChildren("anim");
    int nb = xmlRow.length;
    if(nb>SENSOR_NB_ROWS)
      nb = SENSOR_NB_ROWS;    
    for(int i=0;i<nb;i++)
    {
      int irow = appendAnim( xmlRow[i].getString("label"),i);
      if(irow>=0)
      {
        row[irow].toggleLeftState.setValue((float)xmlRow[i].getInt("whenLow") );
        row[irow].toggleLeft.setValue((float)xmlRow[i].getInt("onLow") );
        row[irow].toggleRight.setValue((float)xmlRow[i].getInt("onHigh") );
        row[irow].toggleRightState.setValue((float)xmlRow[i].getInt("whenHigh") );
      }
    }
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
    println("dbg Random SIDE "+side);
    println("dbg Random LOW  "+animsLow.size());
    println("dbg Random HIGH "+animsHigh.size());
    IntList list = animsLow;
    if(side==1)
      list = animsHigh;
    
    if(list.size()>0)
    {
      int iA = list.get(0);
      row[iA].start(side,1);
      println("dbg Random iAnim "+iA);
      list.shuffle();
    }
  }

  void setMinMax(int mn,int mx)
  {
    min = mn;
    max = mx;
    sliderVal.setRange( (float)min,(float)max );
    sliderVal.getValueLabel().align(ControlP5.CENTER,ControlP5.CENTER); //GRRRR
    int t0 = threshold0; //GRRRR
    int t1 = threshold1; //GRRRR
    rangeThres.setRange( (float)min,(float)max );
    rangeThres.setRangeValues((float)t0,(float)t1);
  }
  
  void buildGUI(int x0,int y0,String tabname)
  {
      //for debug
      /*
       textSensor = cp5.addTextlabel("EVTSENS"+index)
       .setPosition(x0+150,y0)
       .setSize(100,25)
       //.setAutoClear(false)
       .setColorBackground(0x20BBBBBB)  
       .setColorForeground(0x10888888)
       .setLabelVisible(false)
       .moveTo(tabname)
       .bringToFront()
       .setText("00000")
       .setColor(0).setFont(verdanaFont);
      */
    
    
    
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
         .setLabelVisible(false)
         .addListener(this);

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
       sliderVal.getValueLabel().setFont(consolasFont).align(ControlP5.CENTER,ControlP5.CENTER);
 
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
         .setColorForeground(0xFF800000)
         .setColorActive(0xFFF02000)  
         .moveTo(tabname)
         .addListener(this)
         //.setBroadcast(true)
         ;
      
      y0+=20;
         
      dropList = cp5.addDropdownList("DROP"+index)
          .setPosition(positionX+20,positionY+20)
          .setSize(100,250)
          .moveTo(tabname)
          .setItemHeight(20)
          .addListener(this)
          .setBarHeight(20)
          .setColorForeground(color(128,197,176))
          .setColorBackground(color(230))
          .setColorActive(color(0,138,98))
          .setColorLabel(0xFF000000)
          .toUpperCase(false)
          ;
     dropList.captionLabel().setText("SENSOR").setFont(verdanaFont_12).align(ControlP5.CENTER,ControlP5.CENTER);
     dropList.addItem("SENSOR",0);
     dropList.addItem("MANUAL",1);
     dropList.addItem("KNOB",2);
     dropList.addItem("RANDOM",3);
     
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
  
  void onSensor(float val)
  {
    if(inputType != 0) //0 = SENSOR
      return;
    
    if( textSensor != null )
      textSensor.setText(""+val);
    sliderVal.setValue(val);
  }
  
  void onMidi(float val)
  {
    if(inputType != 2) //0 = MIDI
      return;

    sliderVal.setValue( val*(float)(max-min)+(float)min );
  }
  
  int appendAnim(String label,int iAnim)
  {
    //TODO one loop ?
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      if( label.equals( row[i].getLabel()) )
      {
         row[i].setAnim(label,iAnim);
         row[i].setPosition(positionX,positionY+90+(iAnim*EVT_LINE_DY));
         row[i].setVisible(true);
         return i; //exists keeps toggles        
      }
    }   
 
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      if( row[i].animIndex<0 )
      {
         row[i].setAnim(label,iAnim);
         row[i].setPosition(positionX,positionY+90+(iAnim*EVT_LINE_DY));
         row[i].setVisible(true);
         return i;
      }
    }
    return -1;
  }
  
  void checkLabels( IntDict animDict )
  {
    int nbl = animDict.size();   
    if(nbl>SENSOR_NB_ROWS)
      nbl = SENSOR_NB_ROWS;

    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      row[i].setVisible(false);
    }

    //bourrin, à voir itération  
    int    ias[] = animDict.valueArray();
    String lbs[] = animDict.keyArray();
    for(int i=0;i<nbl;i++)
    {
      appendAnim( lbs[i] , ias[i] );
    }

    selectedLow.clear();
    selectedHigh.clear();
    animsLow.clear();
    animsHigh.clear();
    for(int i=0;i<SENSOR_NB_ROWS;i++)
    {
      int checked = row[i].getToggles();
      toggleAnim(animsHigh,i,   ((checked&1)!=0));
      toggleAnim(selectedHigh,i,((checked&2)!=0));
      toggleAnim(selectedLow,i, ((checked&4)!=0));
      toggleAnim(animsLow,i,    ((checked&8)!=0));
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
      //println("dbg ON "+list.size());
    }      
    else
    {
      row[irow].stop();
      if(iA>=0)
        list.remove(iA);
      //println("dbg OFF "+list.size());
    }
    list.shuffle();  
  }
    
  void controlEvent(ControlEvent evt)
  {
    if(evt.isGroup())
    {
      ControlGroup g = evt.group();
      if( g == dropList )
      {
        inputType = (int)g.value();
        println("dbg INPUTTYPE "+inputType);
      }
      return;
    }
    if(!evt.isController())
      return;
    
    Controller c = evt.getController();
    if(c==sliderVal) //TODO desactiver
    {
      int v = (int)c.getValue();
      //println("dbg val "+v+" state "+state+" t0  "+threshold0);
      switch(state)
      {
        //changeState take 'activated' into count
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
      if(!activated)
        stop();
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
    //StringList labels;
    IntDict animIndexLabels = null;
    SensorColon[] sensorColons; 
  
    Slider sliderSensor;
    //Textfield[] textfields = new Textfield[6];
    //Button buttons[] = new Button[6];
    //Group selector;
    
    
    
  EventGUI()
  {
    sensorColons = new SensorColon[SENSOR_NB_COLS];
    //labels = new StringList();
  }

  void onOpen()
  {
    animIndexLabels = animGUI.getAnimLabels();
    for(int i=0;i<SENSOR_NB_COLS;i++)
    {
      sensorColons[i].checkLabels( animIndexLabels );
    }
    openned = true;    
  }
  
  void onClose()
  {
    openned = false;
    save("events.xml");
  }
  
  void onSensorValue(int id,float val)
  {
    if( (id>=0)&&(id<SENSOR_NB_COLS) )
      sensorColons[id].onSensor(val);
  }
  
  void onMidiValue(int id,float val)
  {
    if( (id>=0)&&(id<SENSOR_NB_COLS) )
      sensorColons[id].onMidi(val);    
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
      
    for(int i=0;i<SENSOR_NB_COLS;i++)
      sensorColons[i].update();
  }
        
  void buildGUI(int x0,int y0,String tabname)
  {
    int x=x0;
    for(int i=0;i<SENSOR_NB_COLS;i++)
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

  void save(String filename)
  {
    XML eventsXml = new XML("EVENTS");
    for(int i=0;i<SENSOR_NB_COLS;i++)
    {
      sensorColons[i].toXML(eventsXml);
    }
    // save direction CW CCW
    
    servoArray.saveToXml(eventsXml);    
    
    saveXML(eventsXml,filename);
    
  }
  
  void load(String filename)
  {
    try
    {
      XML eventsXml = loadXML(filename); //dont catch
      if( eventsXml == null )
        return;
      XML[] children = eventsXml.getChildren("event");
      int nbc = children.length;
      if(nbc>SENSOR_NB_COLS)
        nbc = SENSOR_NB_COLS;
      for(int i=0;i<nbc;i++)
        sensorColons[i].fromXML(children[i]);

      onOpen(); //checks anims from animGUI
      
      servoArray.loadFromXml(eventsXml);    
      
    }
    catch(Exception e){println(e);} 
    
  }  




  
};




