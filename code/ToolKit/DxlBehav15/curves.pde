
class Curve implements ControlListener
{
  float x0,y0,kx,ky;
  float param1 = 0;
  float param2 = 1;
  Slider slider;

void buildGUI(int x,int y)
{
  slider = cp5.addSlider("p1")
    .setPosition(x,y)
    .setWidth(500)
    .setRange(0,1)
    .addListener(this);
  
  cp5.addSlider("p2")
    .setPosition(x,y+30)
    .setRange(1,0)
    .addListener(this);  
};

void controlEvent(ControlEvent evt)
{
  if(evt.isGroup()) //GRR reçoit tout ???
    return;
      
  Controller c = evt.getController();
  String addr = c.getAddress();
  println("slider "+addr);
  if(addr.startsWith("/p1"))
    param1 = slider.getValue();
  else if(addr.startsWith("/p2"))
    param2 = c.getValue();
  println("slider "+param1);
    
}  
  
  
void test(float x,float y,float x1,float y1)
{
    x0 = x;
    y0 = y;
    kx = x1-x0;
    ky = y1-y0;

    stroke(255,255,0,255);
    cuBezier2(1.0,1.0);
/*    
    for(float m1=0;m1<1;m1+=0.1)
      //hermite(0,m1);
      cuBezier2(0.0,m1);

    stroke(0,255,0,255);
    for(float m0=0;m0<1;m0+=0.1)
      //hermite(m0,0);
      cuBezier2(param1,param2);
*/

}

void cuBezier2(float p1,float p2)
{
   float x = x0;
   float y = y0;
  
  for(float t=0;t<=1.0;t+= 0.01)
  {
    float omt = 1-t;
/*    
    float h = 0; //omt*omt*omt*p0;
    h += 3*t*omt*(omt*p1 + t*p2);
    //h +=  3*t*omt*omt*p1;
    //h +=  3*t*t*omt*p2;
    h +=  t*t*t; //*p3
*/    
    float h = t*( (t*t) + 3*omt*(omt*p1+t*p2));
    
    float nx = x0+ ( t*kx );
    float ny = y0+ ( h*ky );
    line(x,y, nx,ny);
    x=nx;
    y=ny;     
  }
    
  
}



void cuBezier(float p1,float p2)
{
   float x = x0;
   float y = y0;
  
  for(float t=0;t<=1.0;t+= 0.01)
  {
    float omt = 1-t;    
    float h = 0; //omt*omt*omt*p0;
    h +=  3*t*omt*omt*p1;
    h +=  3*t*t*omt*p2;
    h +=  t*t*t; //*p3
    float nx = x0+ ( t*kx );
    float ny = y0+ ( h*ky );
    line(x,y, nx,ny);
    x=nx;
    y=ny;     
  }
    
  
}

void hermite(float m0,float m1)
  {
    float x = x0;
   float y = y0;
    
    for(float t=0;t<=1.0;t+= 0.01)
    {
      float t2 = t*t;
      float t3 = t2*t;
      float h1 = t2+t2+t2-t3-t3;
      float g0 = (t3-t2-t2+t)*m0;
      float g1 = (t3-t2)*m1;
      
      float nx = x0+ ( t*kx );
      float ny = y0+ (h1+g0+g1)*ky;
      line(x,y, nx,ny);
      x=nx;
      y=ny;
    }    
    
    
    
    
  }
  
};
