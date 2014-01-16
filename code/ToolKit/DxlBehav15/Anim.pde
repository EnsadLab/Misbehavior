
class AnimKey
{
  int keyNum;
  int nbParams;
  int time;
  int cmd;
  int params[] = new int[4];
  
  int parse(String line)
  {
    time = -1;
    nbParams = 0;
    cmd = 0;
    
    String[] toks = line.replaceAll("[\\n\\r]","").split(",");
    int itok = 0;
    try{time=Integer.parseInt(toks[itok]);itok++;}
    catch(Exception e){time=0;}
    cmd = 0;
    if(toks[itok].equals("GOAL"))cmd |= 1;
    if(toks[itok].equals("SPEED"))cmd |= 2;
    if(toks[itok].equals("WHEEL"))cmd |= 4;
    if(toks[itok].equals("JOINT"))cmd |= 8;
    if(toks[itok].equals("RELAX"))cmd |= 16;
    if(toks[itok].equals("COMPL"))cmd |= 32;
    if(toks[itok].equals("TORQUE"))cmd |= 64;
    if(toks[itok].equals("MARGE"))cmd |= 128;
    if(toks[itok].equals("BEZIER"))cmd |= 256;
    if(toks[itok].equals("LOOP"))cmd = -2;
    if(toks[itok].equals("END"))cmd  = -1;
    itok++;
    int nbp = 0;
    try{
      params[0]=Integer.parseInt(toks[itok]);itok++;nbp++;
      params[1]=Integer.parseInt(toks[itok]);itok++;nbp++;
      params[2]=Integer.parseInt(toks[itok]);itok++;nbp++;
      params[3]=Integer.parseInt(toks[itok]);itok++;nbp++;
    }
    catch(Exception e){}
    
    //println("AKEY: "+time+" c:"+cmd+"["+nbp+"]"+params[0]+","+params[1] );
    
    return nbp;  
  }
};

class Anim
{
  int currKey = 0;
  ArrayList<AnimKey> keyList = new ArrayList<AnimKey>(); 
 
  void fromListEdit(ListEdit edit)
  {
    keyList.clear();
    String lk;
    int line = 0;
    do{
    lk = edit.getLine(line);
    if( (lk!=null)&&(!lk.isEmpty()) )
    {
      AnimKey ak = new AnimKey();
      ak.parse(lk);
    }
    line++;
    }while(lk!=null);   
  }
 
   
  
  
};
