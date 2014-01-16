#ifndef PARSER_H
#define PARSER_H

#define MAX_STACK 16

#define TOK_ENDSCRIPT 0
#define TOK_JOINT  1
#define TOK_SPEED  2 //3= JOINT+SPEED
#define TOK_WHEEL  4
#define TOK_DURATION 8 //(JOINT+DURATION) //WHEEL+DURATION
#define TOK_COMPLIANCE 6
#define TOK_TORQUE 7   //RELAX if value = 0
#define TOK_MARGE 8
#define TOK_IN 9
#define TOK_OUT 10

//#define TOK_BEZIER 9 //(JOINT+DURATION+IN+OUT)
#define TOK_PAUSE 11   //v=duration
#define TOK_LOOP 12    //v=count
#define TOK_LABEL 13   //v=idLabel
#define TOK_VALUE  64  //value without token
#define TOK_ENDCMD 128 //may mark last value

class ScriptStr
{
  public:
   ScriptStr(char* pn,char* sc);
   char* name;
   char* script;
  static int nbScripts;
  static ScriptStr* scriptList[32];
  static ScriptStr* getScript(int iscript);
  static ScriptStr* getScript(const char* name);  
};
/*
class ScriptTok
{
  public:
   ScriptTok(char* pn,int* script);
   char* name;
   int*  script;
  static int nbScripts;
  static ScriptTok* scriptList[32];
  static ScriptTok* find(const char* name);  
  static int* find(const char* name,int label);  
};
*/

class ScriptStack
{
  public:
  ScriptStack(){set(NULL,NULL,NULL,0);}
  void set(char* ps,char* pc,char* pd,int c){srcScript=ps;srcCmd=pc;destCmd=pd;destScript=ps;count=c;}
  char* srcScript;
  char* srcCmd;
  char* destScript;
  char* destCmd;
  int   count;
};
/*
//loop: pushCurrent & count
//sub:  push Start & current & count
...
find a jump:
//if stack.current == addr > loop > pop & skip
//else push & jump
*/


class Parser
{
  public:
  char* pStart;
  char* pParsing;
  int token;
  int value;
  int echo; //static pour tous les scripts?
  //int tmpValues[8];
    
  Parser();
  //return token, NULL to continue
  void start(char* pstr);
  void stop();
  int readToken();
  int readValue();
  void gotoLabel(const char* plabel,char* pfrom);
  int readIntValue(char** pstr);
  void readBezierIn();
  void readBezierOut();

  int stackIndex;
  ScriptStack stack[MAX_STACK];

  
private:
  bool  readIntValue(int& dest);
  char* findLabel(const char* plabel,char* pfrom);
  void  push(char* pstr,char* dest,int count);
  void  pop();
  char* execNext();
  char* readInt(char* pstr);
  char* readIntValues(char* pstr,int nbv=1);
  char* readRndInt(char* pstr);
  char* nextCmd(char* pstr);
  char* nextWord(char* pstr);
  char* storeString(char* pstr);
  char  echoStr[32];
};



#endif

