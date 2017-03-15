class Discours extends SubSketch
{
   DiscoursFlock flock;
   String[] mots = {" ", "Législateurs", "commandement", "suprême", "Venezuela", "auguste", "devoir", "bonheur", "république", "passé", "mort", "enterré", "passé", "Grande-Bretagne", "Europe", "courage", "unie", "ennemi", "destinées", "gloire", "décrets", "liberté", "histoire", "injustice", "raciale", "cafards", "Rwanda", "défendent", "homme", "opposer", "loi", "volonté", "tous", "obéirons", "règles", "acheter", "américain", "embaucher", "américain", "Brésil", "pays", "Hitler", "trois", "millions", "juifs", "trois", "millions", "drogués", "Philippines", "massacrer", "mariage", "comprenions", "acte", "beau", "rose", "pétales", "prolétaires", "travailleurs", "classes", "nations", "ennemi", "tribune", "Etats-Unis", "diable", "monde", "entier", "propriétaire", "guerre", "sanction", "échec", "violences", "femmes", "filles", "tolérance", "zéro", "adversaires", "contrôler", "frontières", "droit", "sol", "migration", "lutter", "concurrence", "mentent", "école, émancipation", "sacrifié", "dieux", "louanges", "but", "consommer", "consommer", "frustration", "pauvreté", "Equatoriens", "ensemble", "impossible", "traîtres", "Syriens", "patriotes", "loyaux", "sacrifices", "martyrs", "blessés", "politique", "terre", "indépendance", "patrie", "je", "vous", "ai", "compris", "messie", "prophète", "vérité", "gifles", "coeur", "menacés", "nucléraire", "vous", "partout", "gagner", "notre", "projet", "machinerie", "courage", "peur", "civilisé", "parlementaires", "passation", "pouvoir", "chaos", "populaire", "Congolaise", "chef", "émotion", "travail", "épouse", "réel", "rêvons", "sérieux", "changement", "Espagne", "difficiles", "rôde", "frappe", "providence", "France", "bonheur", "bien", "grandeur", "au", "revoir"};
   PVector missionPoint; 
   float s = 1;
   float a = 1;
   float c = 1;
   float m = 1;

   int mot = 0;


   public Discours(PApplet parent, int _width, int _height)
   {
      super(parent, _width, _height);
      name = "Discours";
      flock = new DiscoursFlock(this);
      // Add an initial set of boids into the system
      for (int i = 0; i < 100; i++) {
         //flock.addBoid(new Boid(random(0,width),random(0,height)));
      }
      missionPoint = new PVector(width/2, 300);
   }

   public void draw()
   {
      clear();
      fill(255);
      rect(0, 0, width, height);
      flock.run();

      if (s>2.0) s-=0.1;
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
      //missionPoint.set(mouseX, mouseY);
   }

   public void keyPressed() {
      if (key == 'm') {
         if (mot < mots.length) {
            flock.addDiscoursBoid(new DiscoursBoid(this, flock, width/3, height-100));
            mot++;
         } else {
            mot = 0;
         }
      }
   }
}


class DiscoursFlock {
   ArrayList<DiscoursBoid> boids; // An ArrayList for all the boids
   Discours d;
   DiscoursFlock(Discours d) {
      discours = d;
      boids = new ArrayList<DiscoursBoid>(); // Initialize the ArrayList
   }

   void run() {
      for (DiscoursBoid b : boids) {
         b.run(boids);  // Passing the entire list of boids to each boid individually
      }
   }

   void addDiscoursBoid(DiscoursBoid b) {
      boids.add(b);
   }
}



// The DiscoursBoid class

class DiscoursBoid {

   PVector position;
   PVector velocity;
   PVector acceleration;
   float r;
   float maxforce;    // Maximum steering force
   float maxspeed;    // Maximum speed
   String letter;
   int textSize = 12;
   Discours discours;
   DiscoursFlock flock;

   DiscoursBoid(Discours d, DiscoursFlock f, float x, float y) {
      acceleration = new PVector(0, 0);

      discours = d;
      flock = f;
      // This is a new PVector method not yet implemented in JS
      // velocity = PVector.random2D();

      // Leaving the code temporarily this way so that this example runs in JS
      float angle = random(-PI, -PI/4);
      velocity = new PVector(cos(angle), sin(angle));

      position = new PVector(x, y);
      r = 2.0;
      maxspeed = 15; //2
      maxforce = 0.01; //0.03

      letter = discours.mots[discours.mot];
   }

   void run(ArrayList<DiscoursBoid> boids) {
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
   void flock(ArrayList<DiscoursBoid> boids) {
      PVector sep = separate(boids);   // Separation
      PVector ali = align(boids);      // Alignment
      PVector coh = cohesion(boids);   // Cohesion
      PVector mis = mission(discours.missionPoint);
      // Arbitrarily weight these forces
      sep.mult(discours.s);
      ali.mult(discours.a);
      coh.mult(discours.c);
      mis.mult(discours.m);
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

      discours.fill(0);
      discours.stroke(0);
      discours.pushMatrix();
      discours.translate(position.x, position.y);
      discours.rotate(theta);
      /*discours.beginShape(TRIANGLES);
       discours.vertex(0, -r*2);
       discours.vertex(-r, r*2);
       discours.vertex(r, r*2);
       discours.endShape();*/
      //discours.textSize = int(map(missionPoint.dist(position),1,height,0,60));
      //discours.textSize = constrain(textSize,1,60);
      discours.scale(map(discours.missionPoint.dist(position),1,height,.5,4));
      discours.textSize = 12;
      discours.text(letter, 0, 0);
      discours.popMatrix();
   }

   // Wraparound
   void borders() {
      if (position.x < -r) position.x = width+r;
      if (position.y < -r) position.y = height+r;
      if (position.x > width+r) {
         position.x = width-r;
         velocity.x = -velocity.x;
      }  
      if (position.y > height+r) position.y = -r;
   }

   // Separation
   // Method checks for nearby boids and steers away
   PVector separate (ArrayList<DiscoursBoid> boids) {
      float desiredseparation = 25.0f;
      PVector steer = new PVector(0, 0, 0);
      int count = 0;
      // For every boid in the system, check if it's too close
      for (DiscoursBoid other : boids) {
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
   PVector align (ArrayList<DiscoursBoid> boids) {
      float neighbordist = 50;
      PVector sum = new PVector(0, 0);
      int count = 0;
      for (DiscoursBoid other : boids) {
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
      } else {
         return new PVector(0, 0);
      }
   }

   // Cohesion
   // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
   PVector cohesion (ArrayList<DiscoursBoid> boids) {
      float neighbordist = 50;
      PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
      int count = 0;
      for (DiscoursBoid other : boids) {
         float d = PVector.dist(position, other.position);
         if ((d > 0) && (d < neighbordist)) {
            sum.add(other.position); // Add position
            count++;
         }
      }
      if (count > 0) {
         sum.div(count);
         return seek(sum);  // Steer towards the position
      } else {
         return new PVector(0, 0);
      }
   }

   PVector mission (PVector attractivePoint) {
      return seek(attractivePoint);
   }
}