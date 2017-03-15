class Bordel extends SubSketch
{
   BordelFlock flock;
   String[] alphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
   PVector missionPoint; 
   float s = 4.0;
   float a = 1.0;
   float c = 1.0;
   float m = 0.1;
   
   int rayon = 100;

   public Bordel(PApplet parent, int _width, int _height)
   {
      super(parent,_width,_height);
      name = "(t) Bordel";
      flock = new BordelFlock();
     missionPoint = new PVector(width/2,height/2);
   }

   public void draw()
   {
      background(255);
  flock.run();
  
  if (s>2.0) s-=0.1;
   }
   
   public void keyPressed()
{
  if (key == 'q')
  {
    for (int i = 0; i < 10; i++) {
    flock.addBordelBoid(new BordelBoid(this,flock,0,random(0,height)));   
    flock.addBordelBoid(new BordelBoid(this,flock,width,random(0,height)));
    flock.addBordelBoid(new BordelBoid(this,flock,random(0,height),0));
    flock.addBordelBoid(new BordelBoid(this,flock,random(0,height),height));
  }
  }
}
// Add a new boid into the System
 public void mouseReleased() {
  s = 15.0;
  rayon = 100;
}

public void mousePressed()
{
  m=3.0;
}

public void mouseDragged()
{
  rayon ++;
  missionPoint.set(mouseX,mouseY);
}
}

class BordelFlock {
  ArrayList<BordelBoid> boids; // An ArrayList for all the boids

  BordelFlock() {
    boids = new ArrayList<BordelBoid>(); // Initialize the ArrayList
  }

  void run() {
    for (BordelBoid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBordelBoid(BordelBoid b) {
    boids.add(b);
  }

}


// The BordelBoid class

class BordelBoid {

   Bordel bordel;
   BordelFlock flock;
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  String letter;
  int textSize = 50;

    BordelBoid(Bordel b, BordelFlock f, float x, float y) {
       bordel = b;
       flock = f;
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
    letter =  bordel.alphabet[int(random(0,26))];
  }

  void run(ArrayList<BordelBoid> boids) {
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
  void flock(ArrayList<BordelBoid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    PVector mis = mission(bordel.missionPoint);
    // Arbitrarily weight these forces
    sep.mult(bordel.s);
    ali.mult(bordel.a);
    coh.mult(bordel.c);
    mis.mult(bordel.m);
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
    
    bordel.fill(0);
    bordel.stroke(0);
    bordel.pushMatrix();
    bordel.translate(position.x, position.y);
    bordel.rotate(theta);
    /*bordel.beginShape(TRIANGLES);
    bordel.vertex(0, -r*2);
    bordel.vertex(-r, r*2);
    bordel.vertex(r, r*2);
    bordel.endShape();*/
    bordel.textSize = int(map(bordel.missionPoint.dist(position),1,bordel.height,0,60));
    bordel.textSize = constrain(bordel.textSize,1,60);
    bordel.text(letter,0,0); 
    bordel.popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = bordel.width+r;
    if (position.y < -r) position.y = bordel.height+r;
    if (position.x > bordel.width+r) {
      position.x = bordel.width-r;
      velocity.x = -velocity.x;
    }  
    if (position.y > bordel.height+r) position.y = -r;
  
    if (position.dist(bordel.missionPoint) < bordel.rayon)
    {
      velocity.y = -0.8*velocity.y;
    }
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<BordelBoid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (BordelBoid other : boids) {
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
  PVector align (ArrayList<BordelBoid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (BordelBoid other : boids) {
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
  PVector cohesion (ArrayList<BordelBoid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (BordelBoid other : boids) {
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