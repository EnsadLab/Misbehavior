int numScript = 0;


class Token
{
  //AREVOIR: 1 2 ou 3 caracteres style /jr /cr /# /< ...etc  OSC /E0/Sj i val
  static final int JOINT      =  2;
  static final int JOINT_D    =  3; //interpolated : JOINT+1 
  static final int WHEEL      =  4;
  static final int WHEEL_D    =  5; //interpolated : WHEEL+1
  static final int SPEED      =  6;
  static final int TGIN       =  7;
  static final int TGOUT      =  8;
  static final int MARGIN     =  9;
  static final int COMPLIANCE =  10;
  static final int TORQUE     =  11;
  static final int DURATION   =  12;
  static final int PAUSE      =  13;
  //static final int ENGINE   = 12;  
  //static final int ORIGINE
  //static final int TIMECOEF
  //static final int SCALE
  static final int TEST     =  31;
  static final int PARAM    =  32; //param tout court versus param #0 #1 #2 #3
  static final int SCRIPT   =  PARAM+4; //no value
  static final int LABEL    =  PARAM+5; //no value
  static final int END      =  PARAM+6; //no value
  static final int CALL     =  PARAM+7;
  static final int JUMP     =  PARAM+8;
  static final int COUNT    =  PARAM+9;
  static final int ANIM     =  PARAM+10;
  static final int EOL      =  63;
  static final int RND      =  64;

//AREVOIR = PARAM = 32+nParam; PARAM 8=script;PARAM 9=label ... etc (param 0-8)=undef
  //engine 0,reg,value
  //?j watch
  //origine
  //timeScale
  
  //send /motor /cmd /value

  Token(int c,int v,int l){cmd=c;value=v;line=l;};
  int type(){return cmd & (~RND); }
  void dbg(){} //println("TOK="+cmd+" v="+value+" L="+line);}
  int cmd;
  int value;
  int line;  
}

class ScriptArray
{
  Script    scriptList[];
  ScriptGUI scriptGUIs[];

  
  ScriptArray(int nb)
  {
    scriptList = new Script[nb];
    scriptGUIs = new ScriptGUI[2];
    
    for(int i=0;i<nb;i++)
      scriptList[i]= new Script(i);
  }
  void buildGUI(int x,int y,int h,String tabname)
  {
    scriptGUIs[0] = new ScriptGUI(scriptList[0]);
    scriptGUIs[0].build(x,y,h,tabname);
    if( scriptList[0] != null)
      scriptList[0].currentGUI = scriptGUIs[0];
    
    scriptGUIs[1] = new ScriptGUI(scriptList[1]);
    scriptGUIs[1].build(x+380,y,h,tabname);
    if( scriptList[1] != null)
      scriptList[1].currentGUI = scriptGUIs[1];
  }
  
  Script scriptAt(int i)
  {
    if((i>=0)&&(i<scriptList.length)) return scriptList[i];
    return null;
  }
  /*
  ScriptGUI guiAt(int i)
  {
    if(i<scriptList.length) return scriptList[i].gui;
    return null;
  } 
 */ 
  void update()
  {
    for(int i=0;i<scriptList.length;i++)
      scriptList[i].update();
  }
  void stopAll()
  {
    for(int i=0;i<scriptList.length;i++)
      scriptList[i].stop();
  }
  void rcvMsg(int iservo,int cmd)
  {
    for(int i=0;i<scriptList.length;i++)
    {
      if(scriptList[i].servoIndex == iservo )
      {
        scriptList[i].rcvMsg(iservo,cmd);
        //println("RCV "+iservo+" "+i);
      }
    }
  }

  
  /*
    ArrayList<String[]> scriptList = new ArrayList<String[]>(); 

    int nbSripts(){return scriptList.size();}
    boolean load(String filename)
    {
      String script[] = loadStrings(filename);
      if( (script==null)||(script.length<2) )
        return false;
        
      println("LOADED "+ filename); 
      scriptList.add(script);
      return true;
    }

    int loadAll(String dir)
    {
      File file = new File(dir);
      if(!file.isDirectory())
       return 0;
    
      String names[] = file.list();
      for(int i=0;i<names.length;i++)
      {
        if(names[i].endsWith(".txt"))
          load(names[i]);
      }
      return nbSripts();
    }
    
    String[] find(String name)
    {
      int nb = scriptList.size();
      for(int i=0;i<nb;i++)
      {
        String script[] = scriptList.get(i);
        if( (script!=null)&&(name.equals(script[0])) )
              return script;
      }
      return null;
    }
  */
}

class ScriptLabel
{
  ScriptLabel(String n,int tok,int l){name=n;iToken=tok;iLine=l;}
  String name;
  int iToken;
  int iLine;
}

class ScriptAnim
{
  ScriptAnim(String n,int tok,int l){name=n;iToken=tok;iLine=l;}
  String name;
  int iToken;
  int iLine;
}



class ScriptStack
{
  int lineSce;
  int lineDest;
  int count;
  void set(int sce,int dst,int c)
  {
    lineSce  = sce;
    lineDest = dst;
    count  = c;
  }
}

class Script
{
  ScriptGUI currentGUI = null;
  
  int index = 0;
  String fileName = null;
  static final int STACK_MAX = 128;
  int frameTime = 0;
  int pauseDuration = 1;
  int execMode    = 0;
  int servoIndex  = 0;
  int servoIndexB = -1;
  
  boolean waitReady = true;
  boolean verbose   = false;
  int currLine =  0;
  int iToken   = -1;
  ArrayList<Token> tokens = new ArrayList<Token>();
  int iStack=-1;
  ScriptStack stack[] = new ScriptStack[STACK_MAX];
  
  //parser  
  int currentSubScript;
  int iLine=0;
  int iChar=0;
  boolean eol = false; //EndOfLine
  String scriptLines[];
  ArrayList<ScriptLabel> labels = new ArrayList<ScriptLabel>();
  ArrayList<ScriptAnim>  anims  = new ArrayList<ScriptAnim>();
  
  Script(int idx)
  {
    index = idx;
    servoIndex = idx; 
    for(int i=0;i<STACK_MAX;i++)
      stack[i]=new ScriptStack();
  }
  
  void setGUI( ScriptGUI otherGUI )
  {
    currentGUI = otherGUI;
    if(fileName != null )
      reload(); //mmmm  -> stop !!!
  }

  void dbg(String txt)
  {
    //scriptConsole.append(txt);
    //scriptGuiArray[index].print(txt);
    if(currentGUI!=null)
      currentGUI.print(txt);
  }
  
  void send( int tok,int value )
  {
    //dbg("SEND:"+"S "+servoIndex+" "+tok+" "+value);
    if(servoIndex>=0)
    {
      arduino.serialSend("S "+servoIndex+" "+tok+" "+value+"\n");
    }
    dbg(cmdToString(tok)+" "+value);
  }
  void sendB( int tok,int value )
  {
    //dbg("SEND:"+"S "+servoIndex+" "+tok+" "+value);
    if(servoIndexB>=0)
    {
      arduino.serialSend("S "+servoIndexB+" "+tok+" "+value+"\n");
    }
    dbg(cmdToString(tok)+" "+value);
  }
  
  
  void start(int line)
  {
    //servoArray.sendDxlId();
    iLine = 0;
    iChar = 0;
    iToken = 0;
    iStack=-1;
    waitReady = false;    
    for(int i=0;i<tokens.size();i++)
    {
      if(tokens.get(i).line==line)
      {
        //println("got line "+i );
        currLine = line;
        iLine  = line;
        iToken = i;
        break;
      }
    }
    dbg("Restart "+iLine);
  }
  
  boolean start(String lbl)
  {
    int nbl = labels.size();
    String lbs[] = lbl.split("[@ \\.]");
    println("DBG start "+lbs.length);
    int ilabel = 0;
    ScriptLabel found = null;
    for(int i=0;i<lbs.length;i++)
    {
      if(lbs[i].length()>0)
      {
        //println("DBG find "+lbs.length);
        for(;ilabel<nbl;ilabel++)
        {
          if( lbs[i].equals(labels.get(ilabel).name) )
          {
            found = labels.get(ilabel);
            ilabel++;
            break;
          }
        }
      }
    }
    if(found != null)
    {
    println("DBG found "+found.iLine);
      currLine = iLine = found.iLine;
      iToken = found.iToken;
      run();
      return true;  
    }      
    return false;
  }
  
  void pause()
  {
    execMode = 0;
  }

  void stop()
  {
    execMode = 0;
    servoArray.getByIndex(index).stopPlaying();
    arduino.serialSend("Q "+servoIndex+"\n");    
  }

  void run()
  {
    //dbg("RUN");
    execMode = 0;
    if(iToken<0)
      iToken = 0;    
    execMode = 1;
    waitReady = false;
    pauseDuration = 0;
  }
  
  int nextStep()
  {
    if( (tokens==null)||(iToken<0)||(tokens.size()<=iToken)||(scriptLines==null) )
      return 0;
    
    execMode = 0;
    if(waitReady)
    {
      waitReady = false;
      pauseDuration = 0;
      currLine=tokens.get(iToken).line;
      return iLine;
    }
    stepToken(1);
    return tokens.get(iToken).line;    
  }

void rcvMsg(int imot,int cmd)
{
  //TODO  
  waitReady = false;
  dbg("READY");
}
  
void update()
{
  int t = millis();
  if( pauseDuration > 10)
  {
    if( (t-frameTime)<pauseDuration )
      return;
    pauseDuration = 0;
    waitReady=false;
    dbg("READY");
  }

  if( waitReady || (iToken<0) )
    return;
    
  frameTime = t;
  try{ currLine=tokens.get(iToken).line; }
  catch(Exception e){println("TOKEN OVERFLOW "+tokens.size() );}
  
  if( execMode>0 )//0 = step by step
  {
    stepToken(4);
    dbg("...");
  }
  if( currentGUI!=null )
    currentGUI.update();
}

void setReady()
{
  pauseDuration = 0;
  waitReady = false;
}

  String cmdToString(int tok)
  {
    String result;
    int c = tok & 0x1F;
    switch(c)
    {
      case 0:       result="";break;
      case Token.SCRIPT:  result="SCRIPT";break;
      case Token.LABEL:   result="LABEL";break;
      case Token.END:     result="END";break;
      case Token.CALL:    result="CALL";break;
      case Token.JUMP:    result="JUMP";break;
      case Token.PARAM:   result="x";break;
      case Token.COUNT:   result="COUNT";break;
      case Token.JOINT:   result="JOINT";break;
      case Token.JOINT_D:   result="JOINT_D";break;
      case Token.WHEEL:   result="WHEEL";break;
      case Token.WHEEL_D:   result="WHEEL_D";break;
      case Token.SPEED:   result="SPEED";break;
      case Token.TGIN:    result="TGIN";break;
      case Token.TGOUT:   result="TGOUT";break;
      case Token.MARGIN:  result="MARGIN";break;
      case Token.COMPLIANCE: result="COMPLIANCE";break;
      case Token.TORQUE:     result="TORQUE";break;
      case Token.DURATION:   result="DURATION";break;
      case Token.PAUSE:      result="PAUSE";break;
      case Token.EOL:        result="EOL";break;  
      default:result="ERROR";break;
    }
    if( (tok & Token.RND)!=0 )
      result+=" rnd:";
    
    return result;  
    
  }
  
void startAnim(int iAnim)
{
  //TODO  nbLoops , ... READY ???
  try
  { 
    //servoArray.getByIndex(servoIndex).startPlaying(anims.get(iAnim).name);
    animGUI.startPlaying(anims.get(iAnim).name);
    waitReady = true;
  }
  catch(Exception e)
  {
    dbg("ANIM ERROR "+iAnim);
  }  
}

//===========================EXEC
void stepToken(int countMax)
{
  Token currTok=tokens.get(iToken);
  int  tok = currTok.type();  
  int  line= -1;
  boolean gotCmd = false;
  int decount=countMax; //prevent infinite loop
  do
  {
    currLine = currTok.line;
    if(verbose && (line!=currLine) )
    {
      line=currLine;
      dbg("("+currTok.line+")"+scriptLines[line]);
    }
    int v;
    switch(tok)
    {
      case Token.SCRIPT:
      case Token.LABEL:
        dbg("----------");
        dbg("("+currTok.line+")"+scriptLines[currLine]);
        iToken++;
        break;
      case Token.JUMP:       execJump();decount=0; break;
      case Token.CALL:       execCall();decount=0; break;
      case Token.COUNT:      dbg("??? "+scriptLines[currTok.line]);iToken++;break;
      case Token.END:        execReturn(); decount=0;break;
      case Token.JOINT:      send(currTok.cmd,getValue());waitReady=true;gotCmd=true;break;
      case Token.JOINT_D:    send(currTok.cmd,getValue());decount+=4;gotCmd=true;break;
      case Token.WHEEL:      v = getValue();send(currTok.cmd,v);sendB(currTok.cmd,-v);gotCmd=true;break;
      case Token.WHEEL_D:    v = getValue();send(currTok.cmd,v);sendB(currTok.cmd,-v);decount+=4;gotCmd=true;break;
      case Token.DURATION:   v = getValue();send(currTok.cmd,v);sendB(currTok.cmd, v);waitReady=true;decount=0;gotCmd=true;break;
      case Token.SPEED:      send(currTok.cmd,getValue());break;
      //case Token.BEZIER:     dbg("??? "+script[currTok.line]);iToken++;break;
      case Token.MARGIN:     send(currTok.cmd,getValue()); break;
      case Token.COMPLIANCE: send(currTok.cmd,getValue()); break;
      case Token.TORQUE:     send(currTok.cmd,getValue()); break;
      case Token.TGIN:        send(currTok.cmd,getValue());break;
      case Token.TGOUT:       send(currTok.cmd,getValue());break;
      //case Token.ENGINE:     break;
      //case Token.REG:        break;
      case Token.ANIM:       startAnim(getValue());break;
      case Token.PAUSE:      pauseDuration=getValue();waitReady=true;decount=0;dbg("PAUSE "+pauseDuration);break;
      case Token.RND:        dbg("??? "+scriptLines[currTok.line]);iToken++;break;
      case Token.EOL:        send(currTok.cmd,getValue());decount=0; break;
      default:
        dbg("UNKNOWN TOKEN "+tok);iToken++;decount=0;
    }
    //next Token
    currTok=tokens.get(iToken);
    tok=currTok.type();
    if(waitReady)
      decount=0;
  }while(--decount>0);
  iLine = tokens.get(iToken).line;
}

int getValue()
{  
  int cmd = tokens.get(iToken).cmd;
  int val = tokens.get(iToken).value;
  iToken++;
  if( ((cmd & Token.RND)==0)||(tokens.get(iToken).cmd != Token.RND) )
    return val;
                
  int val2 = tokens.get(iToken).value;
  iToken++;
  return (int)random(val,val2);
}

boolean execLoop()
{
  if( (iStack<0)||(stack[iStack].lineSce!=iToken) )
    return false; //not on stack
  return execReturn();
}

boolean execReturn()
{
  if( iStack<0 )
    return false; //not on stack
    
  if( --(stack[iStack].count)>0 ) //doLoop
  {
    dbg("LOOP "+stack[iStack].count);
    iToken = stack[iStack].lineDest;
  }
  else // skip jump token ( count , rnd+count )
  { 
    dbg("END LOOP");
    iToken = stack[iStack].lineSce + 1;
    iStack--; //poped
    if( tokens.get(iToken).cmd ==  Token.COUNT )iToken++;
    if( tokens.get(iToken).cmd ==  Token.COUNT+Token.RND )iToken++;
    if( tokens.get(iToken).cmd ==  Token.RND )iToken++;
  }
  return true;
}

boolean execJump()
{
  //dbg("DBG-execJump");
  if(execLoop())
    return true; //dont push jump
  
  
  int sce   = iToken;
  int dest  = tokens.get(iToken).value;
  iToken++;
  int count = -1;
  if( tokens.get(iToken).type()==Token.COUNT )
    count = getValue();
  if(count>0) // jump: dont push
  {
    iStack++; //TODO STACK OVERFLOW
    stack[iStack].set(sce,dest,count);
  }
  dbg("LOOP "+count);
  iToken = dest;  
  return true;
}

boolean execCall()
{
  dbg("CALL ...");
  if(execLoop())
    return true; //dont push jump
  
  int sce   = iToken;
  int dest  = tokens.get(iToken).value;
  dbg("CALL sce "+sce+" dst "+dest);
  iToken++;
  int count = 1;
  if( tokens.get(iToken).type()==Token.COUNT )
    count = getValue();
  iStack++; //TODO STACK OVERFLOW
  stack[iStack].set(sce,dest,count);
  iToken = dest;  
  dbg(" stack "+iStack);
  return true;
}

boolean execJoint()
{
  dbg("JOINT "+getValue());
  return true;
}
boolean execWheel()
{
  dbg("WHEEL "+getValue());
  return true;
}
boolean execMargin()
{
  dbg("MARGIN "+getValue());
  return true;
}
boolean execCompliance()
{
  dbg("COMPLIANCE "+getValue());
  return true;
}
boolean execTorque()
{
  dbg("TORQUE "+getValue());
  return true;
}





//===========================PARSE
void reload()
{
  load(fileName);  
}

void load(String name)
{
  println("scr loading "+name);
  fileName = name;
  stop();
  iToken = -1;
  if(currentGUI!=null)
  {
    currentGUI.clearList();
    currentGUI.clearConsole();
    currentGUI.setName("\n");
  }
  
  if(name==null)
    return;
  
  try{ scriptLines = loadStrings(name); }
  catch(Exception e){ println("FILE ERROR");return;} //TODO ... clear tokens ???
  if(scriptLines==null)
  {
    dbg("FILE ERROR");
    return;
  }
    
  parse();
  
  if(currentGUI!=null)
  {
      currentGUI.setName(name);
      for(int i=0;i<scriptLines.length;i++)
        currentGUI.addLine(scriptLines[i]);
  }
}

void parse(String src[])
{
    scriptLines = src;
    parse();    
}

String getLine(int iline)
{
  if(iline<scriptLines.length)
    return scriptLines[iline];
  return null;
}


void parse()
{
  //scriptConsole.clear();
  try{ currentGUI.clearConsole(); }
  catch(Exception e){}
   
  iChar = 0;
  iStack=-1;
  tokens.clear();
  labels.clear();
  anims.clear();
  if(scriptLines==null)
    return;
  
  //build label list & 
  int nbl = scriptLines.length;
  char c;
  for(int i=0;i<nbl;i++)
  {
    try{
      c=scriptLines[i].charAt(0);
      if( (c=='#')||(c=='<') ) //script label or sub label
      {
        String lbl=scriptLines[i].substring(1).trim();
        ScriptLabel lab = new ScriptLabel(lbl,-1,i) ; //token still unkown
        labels.add( lab ); //token still unkown
        dbg("LABEL["+i+"] "+lbl);
      }
      if( c=='a' ) //anim
      {
        String lbl=scriptLines[i].substring(1).trim();
        anims.add( new ScriptAnim(lbl,-1,i) );
        dbg("ANIM["+i+"] "+lbl);
      }      
    }catch(Exception e){}      
  }
  
  currentSubScript = 0;
  for(iLine=0;iLine<nbl;iLine++)
  {
    iChar=0;
    parseLine();
  }
  //jump, second pass : change label num en iToken
  int nbt =  tokens.size();
  for(int i=0;i<nbt;i++)
  {
    int cmd = tokens.get(i).cmd;
    if( (cmd == Token.JUMP)||(cmd == Token.CALL) )
    {
      int ilab=tokens.get(i).value;
      int itok=labels.get(ilab).iToken;
      //dbg( "jump label["+ilab+"]>>"+itok );
      tokens.get(i).value = itok;      
    }
  }
  
  for(int i=0;i<nbt;i++)
  {
    tokens.get(i).dbg();
  }
  iLine  = 0;
  iChar = 0;
  iToken = 0;
  iStack=-1;
}

void parseLine()
{
  boolean done=false;
  int iInterpole = -1; 
  boolean hasDuration=false;
  boolean needEOL=false;
  iChar = 0;
  while(!done)
  {
      char c=0;
      int itok = tokens.size();
      try{ c=scriptLines[iLine].charAt(iChar); }
      catch(Exception e){done=true;}
      iChar++;
      if(!done)//
      {
        switch(c)
        {
          case ' ':
          case ',':
          case '/': break;
          case ';':done=true;break;
          case '<': parseLabel(Token.SCRIPT);done=true;break; //subScript
          case '>': tokens.add( new Token( Token.END,0,iLine) );done=true;break; //return;
          case '#': parseLabel(Token.LABEL);done=true;break;
          case '@': parseJump();done=true;break; //v1=labelNum v2=count
          case 'j': iInterpole=itok; parseValue(Token.JOINT,0);needEOL=true;break; //joint
          case 's': parseValue(Token.SPEED,0);break; //joint
          case 'w': iInterpole=itok;  parseValue(Token.WHEEL,0);needEOL=true;break; //wheel
          case 'd': hasDuration=true; parseValue(Token.DURATION,0);needEOL=true;break;
          case 'p': parseValue(Token.PAUSE,1000);break;
          case 'c': parseValue(Token.COMPLIANCE,5);break;
          case 'm': parseValue(Token.MARGIN,4);break;
          case 't': parseValue(Token.TORQUE,1203);break;
          case 'i': parseValue(Token.TGIN,40);break;
          case 'o': parseValue(Token.TGOUT,60);break;
          case 'a': parseAnim(Token.ANIM);done=true;break;
        }
    }
  }
  //AREVOIR
  if( hasDuration && (iInterpole>0) )
  {
    tokens.get(iInterpole).cmd+=1;   //(JOINT_D WHEEL_D)
  }
  
  //tokens.add( new Token( Token.EOL,0,iLine) );
  
    
}

int findLabel(int from,String name)
{
  int nbl = labels.size();
  for(int i=from;i<nbl;i++)
  {
    if( labels.get(i).name.equals(name) )
    {
      //dbg("FOUND "+name+" #"+i+" L"+labels.get(i).iLine);
      return i;
    }
  }
  dbg("LABEL NOT FOUND "+name);
  return -1;
}

int getLabelIndex(int line)
{
  int nbl = labels.size();
  for(int i=0;i<nbl;i++)
  {
    if(labels.get(i).iLine==iLine)
      return i;
  }
  return -1;
}

int parseInt(int defo) //default
  {    
    if(!skipSpaces())
      return defo;

    int inext=iChar;
    int result = defo;
    try{
      char c;
      do{ c=scriptLines[iLine].charAt(inext); inext++; }
      while( (c=='-')||( (c>='0')&&(c<='9') ) );
      inext--;
    }catch(Exception e){eol=true;}
    try{ result = Integer.decode(scriptLines[iLine].substring(iChar,inext)); }
    catch(Exception e){}
    //println("getint "+result);
    iChar = inext;
    return result;
  }


boolean parseValue(int tok,int defoo)
{
    //dbg("tokenize value...");
    if(!skipSpaces())
    {
      tokens.add( new Token( tok,defoo,iLine) );
      return true;
    }
    
    if( scriptLines[iLine].charAt(iChar) != '[' )
      tokens.add( new Token( tok,parseInt(defoo),iLine) ); //RND
    else
    {    
      //dbg("tokenize Random...");
      iChar++;
      int v1    = parseInt(defoo);
      int v2    = parseInt(v1);
      //dbg(" [ "+v1+" "+v2+" ]");
      if( v1==v2 )
        tokens.add( new Token( tok,v1,iLine) );
      else if(v1<v2)
      {
        //dbg(" [ "+v1+" "+v2+" ]");
        int it = tokens.size();
        tokens.add( new Token( tok+Token.RND,v1,iLine) );
        tokens.add( new Token( Token.RND,v2,iLine) );
        //dbg(" tok1 "+tokens.get(it).cmd+" tok2 "+tokens.get(it+1).cmd);
        
      }
      else
      {
        dbg(" [ "+v2+" "+v1+" ]");
        tokens.add( new Token( tok+Token.RND,v2,iLine) );
        tokens.add( new Token( Token.RND,v1,iLine) );
      }
    }
    // skip  
    try{
      char c;
      do{c=scriptLines[iLine].charAt(iChar);iChar++; }
      while( (c==' ')||(c==']')||(c==',') );
      iChar--;
    }catch(Exception e){eol=true;}
    
    return true;        
}

boolean parseLabel(int tok)
{
  int ilabel = getLabelIndex(iLine);
  if( ilabel>=0 )
  {
    labels.get(ilabel).iToken = tokens.size();
    tokens.add( new Token( tok,ilabel,iLine) );
    if(tok==Token.SCRIPT)
      currentSubScript = ilabel;    
    return true;
  }
  dbg("ERROR "+scriptLines[iLine] ); 
  return false;
}

boolean parseAnim(int tok)
{
  int nbl = anims.size();
  int ianim = -1;
  for(int i=0;i<nbl;i++)
  {
    if(anims.get(i).iLine==iLine)
    {
      ianim = i;
      break;
    }
  }
  if( ianim>=0 )
  {
    anims.get(ianim).iToken = tokens.size(); //inutile ?
    tokens.add( new Token( tok,ianim,iLine) );
    return true;
  }
  dbg("ERROR "+scriptLines[iLine] ); 
  return false;
}


boolean parseJump()
{
  //get destination label
  skipSpaces();
  int inext=iChar;
  int idot=-1;
  try
  {
    char c;
    do
    { c=scriptLines[iLine].charAt(inext);
      if(c=='.')idot=inext;
      inext++;
    }while( (c>' ')&&(c!=',') );
    inext--;
  }catch(Exception e){}
    
  int iFrom = currentSubScript; 
  if(idot>0)
  {
    iFrom = findLabel( 0,scriptLines[iLine].substring(iChar,idot) );
    iChar = idot+1;
  }
  int iLabel=-1;
  if( iFrom>=0 )
    iLabel = findLabel( iFrom,scriptLines[iLine].substring(iChar,inext) );
          
  iChar = inext;  
  if(iLabel>=0)
  {
    int jumpType = Token.JUMP;
    if( iFrom != currentSubScript )
      jumpType = Token.CALL;
    
    //dbg(" destLabel "+iLabel);
    tokens.add( new Token( jumpType,iLabel,iLine) ); //iLabel sera remplacé par iToken
    parseValue( Token.COUNT,-1 );
    return true;
  }  

  println("LABEL UNKNOWN "+scriptLines[iLine]);
  return false;      
}
  
 boolean skipSpaces()
  {
    eol = false;
    try{
      char c;
      do{ c=scriptLines[iLine].charAt(iChar); iChar++; }
      while( (c==' ')||(c=='=')||(c==',') );
      iChar--;
    }catch(Exception e){eol=true;}
    return !eol;
  }
  
  boolean isNum()
  {
    boolean isnum = false;
    try{
      char c = scriptLines[iLine].charAt(iChar);
      if( (c=='-')||( (c>='0')&&(c<='9') ) )
        isnum = true;
    }catch(Exception e){eol=true;}
    return isnum;    
  }
  
  
}//
