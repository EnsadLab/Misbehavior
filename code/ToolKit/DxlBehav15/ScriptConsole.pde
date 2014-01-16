
class ScriptConsole
{
  int maxLines = 30;
  Textarea  textArea;
  void buildGui(int x,int y,int h)
  {
       textArea = cp5.addTextarea("Txt"+globalID)
     .setPosition(x,y)
     .setSize(200,h)
     .setLineHeight(20)
     .setColor(color(255))
     .setColorBackground(color(0))
     .setColorForeground(color(255))
     .setFont(arialFont);
     
    //for (int i=0;i<100;i++)
    //  textArea.append("item "+i,maxLines);
     

  }
  void append(String txt)
  {
    textArea.append(txt,maxLines);
    textArea.scroll(1.0);
  }
  void clear()
  {
    textArea.clear();
  }

 
  
  
}
