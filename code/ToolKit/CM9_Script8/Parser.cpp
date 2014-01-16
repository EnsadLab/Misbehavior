#include "AAA.h"
#include "libpandora_types.h"
#include "Arduino-compatibles.h"
#include "Parser.h"

const char* eocmd = ">;/\l\r"; 

//strcmp ???
bool strEquals(const char* s0,const char* s1)
{
  while(*s0==*s1)
  {
    if(*s0==0)
      return true;
    s0++;
    s1++;
  }
  return false;
}
char* strFind(char* ps0,const char* what)
{
  int iw=0;
  while( *ps0!=0 )
  {
    while( (ps0[iw] == what[iw])&&(ps0[iw]!=0) )
      iw++;
    if(what[iw]==0)
      return ps0;
    iw=0;
    ps0++;    
  }
  return NULL;
}
inline bool strChr(const char* str,char c)
{
  while(*str!=0)
  {
    if(*str==c)return true;
    str++;
  }
  return false;
}
int strToInt(char** ppstr)
{
  char* pstr= *ppstr;
  //skip separator
  while( (*pstr==' ')||(*pstr=='=')||(*pstr==9)||(*pstr==',') )pstr++;
  int v = atoi(pstr); //TODO what if not num
  //skip num
  if(*pstr=='-')pstr++;
  while( (*pstr>='0')&&(*pstr<='9') )pstr++;
  *ppstr = pstr;
  return v;  
};
int strRndInt(char** ppstr)
{
  int v0=strToInt(ppstr);
  int v1=strToInt(ppstr);
  return (int)random(v0,v1);  
}




int ScriptStr::nbScripts = 0;
ScriptStr* ScriptStr::scriptList[32];
ScriptStr::ScriptStr(char* pn,char* pstr)
{ 
  name=pn;
  script=pstr; 
  if(nbScripts<32)
  {
    scriptList[nbScripts]=this;
    nbScripts++;
  }
}
ScriptStr* ScriptStr::getScript(int iscript)
{
  if((iscript>=0)&&(iscript<nbScripts))
    return scriptList[iscript];
  return NULL;
}

ScriptStr* ScriptStr::getScript(const char* n)
{
  for(int i=0;i<nbScripts;i++)
  {
    if(strEquals(n,scriptList[i]->name))
      return scriptList[i];
  }
  return NULL;
}

char* parseCmd(char* pstr);
char* parseToken(char* pstr);
char* parseInt(char* pstr);
char* parseRnd(char* pstr);
char* parseValue(char* pstr);
char* skipToNum(char* pstr);


Parser::Parser()
{
  start(NULL);
}

void Parser::start(char* pstr)
{
  pStart = pParsing = pstr;
}
void Parser::stop()
{
  pStart = pParsing = NULL;
}

int Parser::readValue()
{
  return readIntValue(&pParsing);
}

int Parser::readToken()
{
  if( (pParsing==NULL)||(*pParsing==0) )
    return TOK_ENDSCRIPT;
  
  token = 0;
  do
  {
    char c=*pParsing;
    if(c==0)
      return TOK_ENDSCRIPT;
    pParsing++;
    
    if( (c>='a')&&(c<='z') ) //upper case
      c += ('A'-'a');    
    switch(c)
    {
      case 'J':token=TOK_JOINT; break;
      case 'S':token=TOK_SPEED; break;
      case 'W':token=TOK_WHEEL; break;
      case 'D':token=TOK_DURATION;break;
      case 'C':token=TOK_COMPLIANCE;break;
      case 'T':token=TOK_TORQUE;break;
      case 'M':token=TOK_MARGE;break;
      case 'I':token=TOK_IN;break;
      case 'O':token=TOK_OUT;break;
      case 'P':token=TOK_PAUSE;break;
      case '[':
      case '=':token=TOK_VALUE;break;
      case '#':pParsing = storeString(pParsing);break;
      case '@':gotoLabel(pParsing,NULL);break;
      case '>':token=TOK_ENDCMD;break;
      //default:      
    }  
  }while(token==0);
  
  //skip word
  while( ((*pParsing>='A')&&(*pParsing<='Z'))||((*pParsing>='a')&&(*pParsing<='z')) )
    pParsing++;
    
  return token;
}

void Parser::readBezierIn()
{
  pParsing++; //'I'
  if(*pParsing=='n')pParsing++; 
  token = TOK_IN; //JOINT+DURATION = bezier ; WHEEL+DURATION = interpole ;duration seule = pause
  value = readIntValue(&pParsing);
  DBG("d ");DBGln(value);
}
void Parser::readBezierOut()
{
  pParsing++; //'O'
  if(*pParsing=='u')pParsing++; 
  if(*pParsing=='t')pParsing++; 
  token = TOK_OUT; //JOINT+DURATION = bezier ; WHEEL+DURATION = interpole ;duration seule = pause
  value = readIntValue(&pParsing);
  DBG("d ");DBGln(value);
}




char* skipCmd(char* pstr)
{
  //skip to
  while( (*pstr!=0)&&( !strChr(eocmd,*pstr) ) )
    pstr++;
  //skip 
  while( (*pstr!=0)&&( strChr(eocmd,*pstr) ) )
    pstr++;
  return pstr;
}


char* Parser::nextWord(char* pstr)
{
    while( (*pstr!=' ')&&(*pstr!=',')&&(*pstr!=0) )
      pstr++;  
    while( (*pstr==' ')||(*pstr!=',') )
      pstr++;  
}

char* Parser::nextCmd(char* pstr)
{
    //letter if valid next cmd
    if( ((*pstr>='A')&&(*pstr<='Z'))||((*pstr>='a')&&(*pstr<='z')) )
      return pstr;
      
    //end cmd : \0 \n \; \' '
    while( (*pstr!=0)&&(*pstr!=';')&&(*pstr!=10)&&(*pstr!=13)&&(*pstr!=' ') )
      pstr++;
      
    //skip trailing spaces & crlf tab
    while( (*pstr>0)&&(*pstr<=' ') )
      pstr++;
      
    while( *pstr==';' )
      pstr++;  
            
    return pstr;
}

bool Parser::readIntValue(int& dest)
{
    char* pstr = pParsing;
    //skip to num 
    while( (*pstr!=' ')&&(*pstr!='=')&&(*pstr!=',') )
    {
      if( (*pstr==0)||(*pstr=='>')||(*pstr=='<') )
        return false; //pParsing inchangé
      if( (*pstr>='0')&&(*pstr<='9') )
        break;
      if( (*pstr=='-')||(*pstr=='[') )
        break;
      pstr++;      
    }
    
    if(*pstr!='[')
      dest = strToInt(&pstr);
    else //random[]
    {
      pstr++;
      int v0=strToInt(&pstr);
      int v1=strToInt(&pstr);
      dest =(int)random(v0,v1);  
    }
    //skip
    while( (*pstr==' ')||(*pstr==9)||(*pstr==']') )
      pstr++;
    pParsing = pstr;
    return true;
}

char* Parser::storeString(char* pstr)
{
  char* pcpy = echoStr;
  for(int i=0;i<31;i++)
  {
    if( (*pstr==';')||(*pstr==0) )
      break;
    *pcpy = *pstr;
    pstr++;
    pcpy++;    
  }
  *pcpy = 0;
  DBG("STRING ");DBGln(echoStr);
  return pstr; //on reste sur le ';' ...> nextCmd  
}

void Parser::pop()
{
  if(stackIndex>=0)
  {  
    pStart   = stack[stackIndex].srcScript;
    pParsing = stack[stackIndex].srcCmd;
    stackIndex--;
  }  
  //skip jump command
  while( (*pParsing!=0)&&(*pParsing!='<') )
    pParsing++;    
}

void Parser::push(char* pcmd,char* dest,int count)
{
  if( (++stackIndex)<MAX_STACK )
  {  
     stack[stackIndex].set(pStart,pcmd,dest,count);
  }
  else
  {
    stackIndex--;
    DBGln("STACK OVERFLOW");
    //TODO ERROR ...???
  }  
}

// null=notFound , or next cmd
char* Parser::findLabel(const char* plabel,char* pfrom)
{
  //assume ptrs are not null
  char* pAfterLabel = NULL;
  do{
    while( (*pfrom!='<')&&(*pfrom!=0) )
      pfrom++;
      
    if(*pfrom==0)
      break;
      
    pfrom++;
    if( (*pfrom!=0)&&(*(++pfrom)=='#') )
    {
      pfrom++;  //skip '#'
      //strcmp(pfrom label)
      char* pl=(char*)plabel;
      while( (*pfrom==*pl)&&(*pl!=' ')&&(*pl!='>')&&(*pl!=0) ) // , ; / ) .... etc
      {
        pfrom++;
        pl++;
      }
      //check if pfrom is end label 
      if( (*pfrom=='>')||(*pfrom==' ')||(*pfrom==',')||(*pfrom==0) ) //found
      {
        //skip cmd
        while( (*pfrom!='<')&&(*pfrom!=0) )
          pfrom++;
        return pfrom;
      }
    }
  }while(*pfrom!=0);
  
  return NULL;
}

void Parser::gotoLabel(const char* plabel,char* pstr) //<@label> <@label count>
{
  if(pStart==NULL) return;
  if(pstr==NULL) pstr = pStart;
  
  if( (stackIndex>=0)&&(stack[stackIndex].srcCmd==pParsing) ) // loop
  {
    if( stack[stackIndex].count>0)
    {
      if( stack[stackIndex].count<999 )//infinite loop
        stack[stackIndex].count--;
      pStart   = stack[stackIndex].destScript;
      pParsing = stack[stackIndex].destCmd;
    }
    else
      pop();
    return;
  }
  
  char* pFound = findLabel(plabel,pstr);
  if(pFound == NULL)
  {
    DBG("LABEL ");DBG(plabel);DBGln(" NOT FOUND");
    while( (*pParsing!='<')&&(*pParsing!=0) )
      pParsing++;
    return;  
  }
  
  char* pcmd = pParsing;
  int count = 999;
  readIntValue(count);
  push(pcmd,pFound,count);  
  pParsing = pFound;
}





char* skipToNum(char* pstr)
{
  while( ( (*pstr<'0')||(*pstr>'9') )&&(*pstr!='-')&&(*pstr>0) )
    pstr++;
  return pstr;
}



char* parseValue(char* pstr)
{
  //skip spaces
  while(*pstr==' ')pstr++;
  if(*pstr==']')
    return parseRnd(++pstr);
  
  return parseInt(pstr);    
}


