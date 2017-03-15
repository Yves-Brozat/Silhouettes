class SubSketch extends PGraphics3D
{
   public boolean active;
   public String name;
   
   public SubSketch(PApplet parent, int _width, int _height)
   {
      println("SubSketch");
      setParent(parent);
      setPrimary(false);
      setSize(_width, _height);
   }


   public void drawBase()
   {
      if(active) 
      {
         beginDraw();
         draw();
         endDraw();
      }
   }
   
   public void keyPressedBase()
   {
    if(active) keyPressed();  
   }
   
   public void mouseReleasedBase() 
   {
      if(active) mouseReleased();
   }
   
   public void mousePressedBase()
   {
      if(active) mousePressed();
   }

   public void mouseDraggedBase()
   {
      if(active) mouseDragged();
   }
   
   public void draw()
   {
   }
   
   public void keyPressed()
   {
   }
   
   public void mouseReleased() 
   {
   }
   
   public void mousePressed()
   {
   }

   public void mouseDragged()
   {
   }
}