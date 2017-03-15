class Nuee extends SubSketch
{
   NueeFlock flock;
   String[] alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
   PVector missionPoint; 
   float s = 4.0;
   float a = 1.0;
   float c = 1.0;
   float m = 3.0;
   
   int fill = 255;

   public Nuee(PApplet parent, int _width, int _height)
   {
      super(parent,_width,_height);
      name = "(r) Nuee";
      flock = new NueeFlock(this);
     // Add an initial set of boids into the system
     for (int i = 0; i < 300; i++) {
       flock.addBoid(new NueeBoid(this,flock, 1.5*width,random(0,height)));
     }
     
     missionPoint = new PVector(width/2,height/2);
   }

   public void draw()
   {
      background(fill);
      flock.run();
  
      if (s>2.0) s-=0.1;
   }
   
   public void keyPressed()
   {
      if (key == 'o') {
         
      }
   }
   
   public void mouseReleased() {
     s = 15.0;
   }
   
   public void mousePressed()
   {
     m=3.0;
   }

   public void mouseDragged()
   {
      missionPoint.set(mouseX,mouseY);
   }
}


class NueeFlock {
   Nuee nuee;
  ArrayList<NueeBoid> boids; // An ArrayList for all the boids

  NueeFlock(Nuee n) {
     nuee = n;
    boids = new ArrayList<NueeBoid>(); // Initialize the ArrayList
  }

  void run() {
    for (NueeBoid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(NueeBoid b) {
    boids.add(b);
  }

}

// The Boid class

class NueeBoid {

   NueeFlock flock;
   Nuee nuee;
   
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  String letter;
  int textSize = 12;

    NueeBoid(Nuee n, NueeFlock f, float x, float y) {
       nuee = n;
       flock = f;
       letter = nuee.alphabet[int(random(0,26))];
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 2.0;
    maxspeed = 15; //2
    maxforce = 0.1; //0.03
  }

  void run(ArrayList<NueeBoid> boids) {
    flock(boids);
    update();
    //borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<NueeBoid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector mis = mission(nuee.missionPoint);
    // Arbitrarily weight these forces
    sep.mult(nuee.s);
    ali.mult(nuee.a);
    coh.mult(nuee.c);
    mis.mult(nuee.m);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
    applyForce(mis);
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
    
    nuee.fill(0);
    nuee.stroke(0);
    nuee.pushMatrix();
    nuee.translate(position.x, position.y);
    nuee.rotate(theta);
    /*nuee.beginShape(TRIANGLES);
    nuee.vertex(0, -r*2);
    nuee.vertex(-r, r*2);
    nuee.vertex(r, r*2);
    nuee.endShape();*/
    nuee.textSize = int(map(nuee.missionPoint.dist(position),1,nuee.height,0,60));
    nuee.textSize = constrain(nuee.textSize,1,60);
    nuee.text(letter,0,0);
    nuee.popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = nuee.width+r;
    if (position.y < -r) position.y = nuee.height+r;
    if (position.x > nuee.width+r) {
      position.x = nuee.width-r;
      velocity.x = -velocity.x;
    }  
    if (position.y > nuee.height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<NueeBoid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (NueeBoid other : boids) {
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
  PVector align (ArrayList<NueeBoid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (NueeBoid other : boids) {
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
  PVector cohesion (ArrayList<NueeBoid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (NueeBoid other : boids) {
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
  
  PVector mission (PVector attractivePoint) {
    return seek(attractivePoint);
  }
}