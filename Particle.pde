//Class for the particles of the explosion. When the body joints collide with the circles of the projection, the circles explode and create particles.  

class Particle {
  float r = 15;
  PVector pos,speed,grav; 
  ArrayList tail;
  float splash = 25;
  int margin = 0;
  int taillength = 15;
  int Opacity = 250;

  Particle(float tempx, float tempy) {
    float startx = tempx + random(-splash,splash);
    float starty = tempy + random(-splash,splash);
    startx = constrain(startx,0,width);
    starty = constrain(starty,0,height);
    float xspeed = random(-10,10);
    float yspeed = random(-10,10);

    pos = new PVector(startx,starty);
    speed = new PVector(xspeed,yspeed);
    grav = new PVector(0,1);
    
    tail = new ArrayList();
  }

  void run() {
    pos.add(speed);

    tail.add(new PVector(pos.x,pos.y,0));
    if(tail.size() > taillength) {
      tail.remove(0);
    }

    float damping = random(-0.5,-0.6);
    if(pos.x > width - margin || pos.x < margin) {
      speed.x *= damping;
    }
    if(pos.y > height -margin) {
      speed.y *= damping;
    }
  }

  void gravity() {
   // speed.add(grav);
  }

  void update() {
    Opacity = Opacity - 10;
    for (int i = 0; i < tail.size(); i++) {
      PVector tempv = (PVector)tail.get(i);
      noStroke();
      //tint(255,Opacity);    //Make the fade background
      fill(R,G, B, Opacity);   //Make the particle balls dissapear slowely
      ellipse(tempv.x,tempv.y,r,r);
    }
  }
}
