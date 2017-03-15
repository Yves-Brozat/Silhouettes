class Chute extends SubSketch
{
   ChuteFlock flock;
int flockSize = 1;
String[] alphabet = {"A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","B","B","B","B","B","C","C","C","C","C","C","C","C","C","C","C","C","C","C","D","D","D","D","D","D","D","D","D","D","D","D","D","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","E","F","F","F","G","G","G","G","G","H","H","H","H","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","I","J","K","L","L","L","L","L","L","L","L","L","L","L","L","L","L","L","M","M","M","M","M","M","M","M","N","N","N","N","N","N","N","N","N","N","N","N","N","N","N","N","N","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","O","P","P","P","P","P","P","P","Q","R","R","R","R","R","R","R","R","R","R","R","R","R","R","R","R","R","S","S","S","S","S","S","S","S","S","S","S","S","S","S","S","S","S","S","T","T","T","T","T","T","T","T","T","T","T","T","T","T","T","T","T","U","U","U","U","U","U","U","U","U","U","U","U","U","U","V","V","V","V","W","X","Y","Z"};
PVector missionPoint; 
float s = 15.0;
float a = 1.0;
float c = 0.1;
float m = 0.1;
float f = 10.0;

int hArms;

   public Chute(PApplet parent, int _width, int _height)
   {
      super(parent,_width,_height);
      name = "(e) Chute";
      flock = new ChuteFlock();
  // Add an initial set of boids into the system
  missionPoint = new PVector(width/2,height/3);
  hArms = height;
  flockSize = 200;
  
  for (int i =0; i<flockSize; i++)
  {
    flock.addChuteBoid(new ChuteBoid(this,flock,random(0,width),0));
  }
   }

   
   public void draw() {
     background(255);
     flock.run();
     
     if (s>2.0) s-=0.1;
   }
   
   // Add a new boid into the System
   public void mouseReleased() {
     s = 15.0;
   }
   
   public void mousePressed()
   {
     m=3.0;
   }
   
   public void mouseDragged()
   {
     flockSize++;
     flock.addChuteBoid(new ChuteBoid(this,flock,random(0,width),0));
     hArms = mouseY;
     //println(flock.boids.size());
   }
}

class ChuteFlock {
  ArrayList<ChuteBoid> boids; // An ArrayList for all the boids

  ChuteFlock() {
    boids = new ArrayList<ChuteBoid>(); // Initialize the ArrayList
  }

  void run() {
    ArrayList<ChuteBoid> boidsToRemove = new ArrayList<ChuteBoid>();
    for (ChuteBoid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
      if(b.shouldRemove) boidsToRemove.add(b);
    }
    
    for(ChuteBoid b : boidsToRemove)
    {
      boids.remove(b);
    }
    
  }

  void addChuteBoid(ChuteBoid b) {
    boids.add(b);
  }

  void removeChuteBoid(ChuteBoid b){
    boids.remove(b);
  }
}


// The ChuteBoid class

class ChuteBoid {
  
   ChuteFlock flock;
   Chute chute;
  boolean shouldRemove;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  String letter ;
  int textSize = 12;

    ChuteBoid(Chute c, ChuteFlock f, float x, float y) {
       chute = c;
       flock = f;
    shouldRemove = false;
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 2.0;
    maxspeed = 11; //2
    maxforce = 0.01; //0.03
    
    letter = chute.alphabet[int(random(0,chute.alphabet.length))];
  }

  void run(ArrayList<ChuteBoid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<ChuteBoid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector mis = mission(chute.missionPoint);
    PVector fal = fall();
    // Arbitrarily weight these forces
    sep.mult(chute.s);
    ali.mult(chute.a);
    coh.mult(chute.c);
    mis.mult(chute.m);
    fal.mult(chute.f);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(mis);
    applyForce(fal);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    chute.fill(0);
    chute.stroke(0);
    chute.pushMatrix();
    chute.translate(position.x, position.y);
    chute.rotate(theta);
    /*chute.beginShape(TRIANGLES);
    chute.vertex(0, -r*2);
    chute.vertex(-r, r*2);
    chute.vertex(r, r*2);
    chute.endShape();*/
    chute.textSize = int(map(position.y,chute.height,0,0,30));
    chute.textSize = constrain(chute.textSize,1,30);
    chute.text(letter,0,0);
    chute.popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) {
      velocity.x = -0.1*velocity.x;
    }
    if (position.x > chute.width+r) {
      velocity.x = -0.1*velocity.x;
    }  
    if (position.y > chute.height+r) 
    {
      //flock.removeChuteBoid(this);
      shouldRemove = true;
    }
    if (position.dist(chute.missionPoint) < 100) 
    {
      velocity.y = -0.4*velocity.y;
      if (position.x < chute.width/2) velocity.x -= 0.3;
      else velocity.x += 0.3;
    }
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<ChuteBoid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (ChuteBoid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<ChuteBoid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (ChuteBoid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<ChuteBoid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (ChuteBoid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  //Reach a point
  PVector mission (PVector attractivePoint) {
    return seek(attractivePoint);
  }
  
  //Fall down
  
  PVector fall (){
    return seek(new PVector(position.x,chute.height));
  }
}