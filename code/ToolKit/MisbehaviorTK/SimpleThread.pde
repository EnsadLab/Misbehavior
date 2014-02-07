
class ThreadTest extends Thread
{
  boolean running;
  int wait;
  String id;
  int count;
  
  ThreadTest()
  {
    running = false;
    //wait = w;
    //id = str;
    count = 0;
  }
  void Start()
  {
    running = true;
    count = 0;
    //println("ThreadTest start "+running);
    super.start();
  }
  void run()
  {
    running = true;
    println("ThreadTest run "+running);
    while(running && (count<100) )
    {
      count++;
      println("ThreadTest "+count);
      delay(3000);
      try{sleep(2000);}
      catch(Exception e){}      
    }
    println("ThreadTest done");    
  }
  /*
  void quit()
  {
    println("ThreadTest quit");    
    running = false;
    interrupt(); //force stop
  }
  */
  
}
