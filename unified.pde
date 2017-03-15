import codeanticode.syphon.*;
SyphonServer server;

Onde onde;
Barrage barrage;
Bordel bordel;
Chute chute;
Nuee nuee;
Pluie pluie;
Discours discours;

SubSketch[]  subs;

int activeSub = -1;

PGraphics p;

float blackFactor;
float blackTarget;
float blackSpeed;

void settings() {
   size(1440, 900, P3D);
   PJOGL.profile=1;
}

void setup() {
   //size(300,300,P3D);
   server = new SyphonServer(this, "Processing Syphon");

   p = createGraphics(width,height,P3D);
   
   barrage = new Barrage(this, 400, 600);
   bordel = new Bordel(this, 400, 600);
   chute = new Chute(this, 400, 600);
   nuee = new Nuee(this, 400, 600);
   pluie = new Pluie(this, 400, 600);
   
   onde = new Onde(this, 250, 600);
   discours = new Discours(this, 400, 600);

   subs = new SubSketch[5];
  
   subs[0] = pluie;
   subs[1] = barrage;
   subs[2] = chute;
   subs[3] = nuee;
   subs[4] = bordel;
   
   println("Ready");
   
   discours.active = true;
   onde.active = true;
   
   blackFactor = 0;
   blackTarget = 0;
   blackSpeed = .03;
}

void setSubActive(int sub)
{
   if(activeSub >= 0)
   {
      subs[activeSub].active = false;
   }
   activeSub = sub;
   if(activeSub >= 0)
   {
      subs[activeSub].active = true;
   }
   
}

void draw() {
   background(180);
   
   p.beginDraw();
   p.background(255);
   for (SubSketch ss : subs) ss.drawBase();

   for (SubSketch ss : subs)
   {
      if (ss.active) p.image(ss, 0, 0);
   }
   
   if(discours.active) 
   {
      discours.drawBase();
      p.image(discours, 700,0);
   }
   
   if(onde.active)
   {
      onde.drawBase();
      p.image(onde, 1150,0);
   }
   
   
   blackFactor = blackFactor+(blackTarget-blackFactor)*blackSpeed;
   p.fill(0,blackFactor*255);
   p.rect(0,0,p.width,p.height);
   p.endDraw();
   
   image(p,0,0);
   noFill();
   stroke(0);
   strokeWeight(1);
   rect(0,0,400,600);
   int index = 0;
   for (SubSketch ss : subs)
   {
      fill(activeSub == index?color(255,0,0):color(0));
      if(activeSub >= 0) text((index+1)+" : "+ss.name,550,30+index*30);
      index++;
   }
   fill(0);
   if(discours.active) text("Discours",550,500);
   if(onde.active) text("Onde",550,550);
   server.sendImage(p);
   
};

void keyPressed() {
   switch(key)
   {
      case 'a':
      setSubActive(0);
      break;
      case 'z':
      setSubActive(1);
      break;
      case 'e':
      setSubActive(2);
      break;
      case 'r':
      setSubActive(3);
      break;
      case 't':
      setSubActive(4);
      break;
      //case ',':
      //discours.active = !discours.active;
      //break;
      
      
      case 'k':
      blackTarget = 1-blackTarget;
      break;
      
      case ';':
      onde.active = !onde.active;
      break;
      
   }
   
   for (SubSketch ss : subs) ss.keyPressedBase();
   if(discours.active) discours.keyPressedBase();
   if(onde.active) onde.keyPressedBase();
}

void mouseReleased() {
   for (SubSketch ss : subs) ss.mouseReleasedBase();
   if(discours.active) discours.mouseReleasedBase();
   if(onde.active) onde.mouseReleasedBase();
}

void mousePressed()
{
   for (SubSketch ss : subs) ss.mousePressedBase();
   if(discours.active) discours.mousePressedBase();
   if(onde.active) onde.mousePressedBase();
}

void mouseDragged()
{
   for (SubSketch ss : subs) ss.mouseDraggedBase();
   if(discours.active) discours.mouseDraggedBase();
   if(onde.active) onde.mouseDraggedBase();
}