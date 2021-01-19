/*
The original sketch is taken from: 

Thomas Sanchez Lengeling.
 http://codigogenerativo.com/

 KinectPV2, Kinect for Windows v2 library for processing

 Skeleton color map example.
 Skeleton (x,y) positions are mapped to match the color Frame
 */

import KinectPV2.KJoint;
import KinectPV2.*;
import processing.sound.*;
import ddf.minim.*;

//mambo no. 5 song for a single user
AudioPlayer mambo;

//popping sounds 
SoundFile file1;
SoundFile file2;
SoundFile file3;

//playlist of songs
AudioPlayer [] songs = new AudioPlayer[11];

Minim minim;

KinectPV2 kinect;

PFont font; 

//variable that keeps track whether the squares were ever popped by a user
boolean ballEverPopped = false;

//array of joint types
int [] jointTypes = {  KinectPV2.JointType_Head, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder,  KinectPV2.JointType_SpineMid,
                       KinectPV2.JointType_SpineBase,  KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ShoulderLeft,  KinectPV2.JointType_HipRight, 
                       KinectPV2.JointType_HipLeft, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight, 
                       KinectPV2.JointType_HandTipRight, KinectPV2.JointType_ThumbRight, KinectPV2.JointType_ElbowLeft,  KinectPV2.JointType_WristLeft, 
                       KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft, KinectPV2.JointType_ThumbLeft, KinectPV2.JointType_KneeRight, 
                       KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight,  KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft, 
                       KinectPV2.JointType_FootLeft };

//array which holds the state of each square: 0 not touched, 1 touched
int [] ballTouched = {0,0,0,0,0,0,0,0,0};

//maximum number of particles
int MAX = 50;

//list of particles
ArrayList plist = new ArrayList();

//intial font size - it pulsates by 1 px
int fontSize = 60;
int increment = 1;

//length of squares 
float rad = 50;

//initial color of squares
float R = 255;
float G = 0;
float B = 0;

//initial x positions of the squares
float [] ballsX = { 400, 300, 1600, 1200, 1400, 900, 500, 700, 350};

//initial y positions of the squares
float [] ballsY = { 350, 700, 400, 500, 700, 500, 900, 300, 200};

//matrix for colors of the bodies 
ArrayList<float[]> bodyColors = new ArrayList<float[]>();

//array for the indexes of the random heads
int [] randomHeads = new int[3];

//array holding the background images
PImage [] backgrounds = new PImage[12];

//array holding the head images
PImage [] heads = new PImage[6];

//the index of the backgrounds used for incrementing and changing the images
float backgroundIndex = -1;

void setup() {
  fullScreen(P3D);
  kinect = new KinectPV2(this);

  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();
  
  minim = new Minim(this);
  
  //load all the background images
  backgrounds[0] = loadImage("BarbieGirl.jpg");
  backgrounds[1] = loadImage("CaptainJack.jpg");
  backgrounds[2] = loadImage("Genie.jpg");
  backgrounds[3] = loadImage("HitMe.jpg");
  backgrounds[4] = loadImage("Informer.jpg");
  backgrounds[5] = loadImage("Wannabe.jpg");
  backgrounds[6] = loadImage("Blue.jpg");
  backgrounds[7] = loadImage("Friends.jpg");
  backgrounds[8] = loadImage("IWantIt.jpg");
  backgrounds[9] = loadImage("PrettyFly.jpg");
  backgrounds[10] = loadImage("TeenSpirit.jpg");
  backgrounds[11] = loadImage("90s.png");
  
  //load all the head images
  heads[0] = loadImage("britney.png");
  heads[1] = loadImage("justin_timberlake.png");
  heads[2] = loadImage("beyonce.png");
  heads[3] = loadImage("christina.png");
  heads[4] = loadImage("WILL_SMITH.png");
  heads[5] = loadImage("crazy_frog.png");
  
  //load the font
  font = loadFont("bubbleboddy-Fat-48.vlw");
  
  //load the intial song for the single user
  mambo = minim.loadFile("mambo.mp3");
  
  //load the songs 
  songs[0] = minim.loadFile("BarbieGirl.mp3");
  songs[1] = minim.loadFile("CaptainJack.mp3");
  songs[2] = minim.loadFile("GenieInABottle.mp3");
  songs[3] = minim.loadFile("HitMe.mp3");
  songs[4] = minim.loadFile("Informer.mp3");
  songs[5] = minim.loadFile("Wannabe.mp3");
  songs[6] = minim.loadFile("Blue.mp3");
  songs[7] = minim.loadFile("Friends.mp3");
  songs[8] = minim.loadFile("IWantIt.mp3");
  songs[9] = minim.loadFile("PrettyFly.mp3");
  songs[10] = minim.loadFile("TeenSpirit.mp3");  
  
  //load the popping sounds
  file1 = new SoundFile(this, "Pop1.mp3"); 
  file2 = new SoundFile(this, "Pop2.wav"); 
  file3 = new SoundFile(this, "Pop3.wav"); 
 
 //randomize the head indexes
  for(int i = 0; i < randomHeads.length; i++){
    randomHeads[i] = int(random(heads.length));
  }
  
 //if there is a duplicate index, re-randomize until the indexes in randomHeads are distinct
  for(int i = 0; i < randomHeads.length; i++){
    while(checkDuplicate(randomHeads, randomHeads.length, i) == true){
       randomHeads[i] = int(random(heads.length));
    }
  }
  
  //give random colors to the bodies 
  for(int i = 0; i < 5; i++){
      bodyColors.add(i, new float[3]);
  }
 
  for(int i = 0; i < 5; i++){
      float [] colors = bodyColors.get(i);
      for(int j = 0; j < 3 ; j++){
          colors[j] = random(0,255);
  }
 }

  
}

void draw() {
    background(0);
    
    //if no square was ever popped, set the background to the intial image
    if(ballEverPopped == false){
       tint(150);
       image(backgrounds[11], 0, 0);
    } 
    //else, if the squares have been popped 3 times, change the background and the songs to the corresponding ones
    else {
      if(floor(backgroundIndex)/9 < backgrounds.length-1){
      backgrounds[floor(backgroundIndex)/9].resize(width, height);
      tint(150);
      image(backgrounds[floor(backgroundIndex)/9], 0, 0); 
      songs[int(backgroundIndex)/9].play();
      if(floor(backgroundIndex)/9 > 0){
      songs[floor(backgroundIndex)/9-1].pause();
      songs[floor(backgroundIndex)/9-1].rewind();
      }
      }
    }
  
//make squares stroke yellow if touched, then set their state to 0 - not touched
    for(int j = 0; j < ballsX.length; j++){
      if(ballTouched[j] == 1){
               stroke(255,255,0);
               strokeWeight(20);
               drawEllipse(ballsX[j], ballsY[j], rad*2+10, rad*2, R, G, B);
               strokeWeight(0);
      } else { drawEllipse(ballsX[j], ballsY[j], rad*2+10, rad*2, R, G, B); }
    }  
   
              
    for(int n = 0; n < ballTouched.length; n++){
      ballTouched[n] = 0;
    } 
    
 //get the skeletons of the users 
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();

  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      
      //fill the joints with random colors if there is only one user 
      fill(random(0,255), random(0,255), random(0,255));
      drawBody(joints, random(0,255), random(0,255), random(0,255));
      
      //if there are less or equal to 3 users, give them random heads
      if(i<=2){
      drawHead(joints, KinectPV2.JointType_Head, randomHeads[i]);
      }
    }
    
    //if there is only one user, display the intial text, stop any other previous song played, play mambo no.5 and display the initial background
    if(skeletonArray.size() == 1){
      animateText("Hey, sexy! Grab somebody and let's move like it's '99!");
      mambo.play();
      ballEverPopped = false;
      for(int m = 0; m < songs.length; m++){
        songs[m].pause();
        songs[m].rewind();
      }
      backgroundIndex = -1;
    } 
    
    //if there are 2 or more players, stop mambo no. 5 
    if(skeletonArray.size() >= 2 ){
      mambo.pause();
      mambo.rewind();
      fontSize = 60;

    }
    
  }

  //if there are no users in sight, restart everything: stop mambo no.5, set the state of the squares to never popped, stop any songs and display the initial background
  if(skeletonArray.isEmpty()){
    mambo.pause();
    mambo.rewind();
    fontSize = 60;
     ballEverPopped = false;
      for(int m = 0; m < songs.length; m++){
        songs[m].pause();
        songs[m].rewind();
      }
      backgroundIndex = -1;
  }
  
  //for any two users 
  for (int i = 0; i < skeletonArray.size(); i++) {
    for (int j = 0; j < skeletonArray.size(); j++){
          KSkeleton a = (KSkeleton) skeletonArray.get(i);
          KSkeleton b = (KSkeleton) skeletonArray.get(j);
        if(a.isTracked() && b.isTracked()){
          
          //if they are different, give them the random body colors set at the beginning
          if(a != b){  
            KJoint[] ajoints = a.getJoints();
            KJoint[] bjoints = b.getJoints();
            fill(bodyColors.get(i)[0], bodyColors.get(i)[1], bodyColors.get(i)[2]);
            drawBody(ajoints, bodyColors.get(i)[0], bodyColors.get(i)[1], bodyColors.get(i)[2]);
            fill(bodyColors.get(j)[0], bodyColors.get(j)[1], bodyColors.get(j)[2]);
            drawBody(bjoints, bodyColors.get(j)[0], bodyColors.get(j)[1], bodyColors.get(j)[2]);
       
       //check if any square is touched by any user
       for(int p = 0; p < ballsX.length; p++){
              checkIfTouched(p, ajoints, ballsX[p], ballsY[p], rad);
              checkIfTouched(p, bjoints, ballsX[p], ballsY[p], rad);
       } 
            }
   
       //if any two squares are touched, draw a line between them     
        for(int m = 0; m < ballTouched.length; m ++){
          for(int n = 0; n < ballTouched.length; n++){
            if(ballTouched[m] == 1 && ballTouched[n] == 1){
              strokeWeight(3);
              stroke(R,G,B,50);
              line(ballsX[m], ballsY[m], ballsX[n], ballsY[n]);
              stroke(255);
              noStroke();
            }
          }
        }
            
    
    //if all the squares are touched at the same time, shoot particles, redraw the pattern at random positions and with random colors, increase the background index and play the popping sounds
    if(ballTouched[0] == 1 && ballTouched[1] == 1 && ballTouched[2] == 1 
    && ballTouched[3] == 1  && ballTouched[4] == 1 && ballTouched[5] == 1
    && ballTouched[6] == 1 && ballTouched[7] == 1 && ballTouched[8] == 1){    
         ballEverPopped = true;
         for(int d = 0; d < ballsX.length; d++){       
               //shoot particles
               particleEff(ballsX[d], ballsY[d]);
               //redraw
               randomizeDistance(ballsX, ballsY);
               R = random(0, 255);
               G = random(0, 255);
               B = random(0, 255);
               drawEllipse(ballsX[d], ballsY[d], rad*2, rad*2, R, G, B);
         }
         //increase background index
          backgroundIndex ++;
         //play popping sounds
          file1.play();file2.play();file3.play();
     }
          }
        }
    }           
          //update particles
              for (int q = 0; q < plist.size(); q++) {
                    Particle p = (Particle) plist.get(q); 
                    //makes p a particle equivalent to ith particle in ArrayList
                    p.run();
                    p.update();
                    p.gravity();
                  }
}

//DRAW BODY with a certain R, G, B color
void drawBody(KJoint[] joints, float R, float G, float B) {
  //drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
 // drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
 drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid, R, G, B);
  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase, R, G, B);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft, R, G, B);

  // Right Arm
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight, R, G, B);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft, R, G, B);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight, R, G, B);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight, R, G, B);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft, R, G, B);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft, R, G, B);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);
}

//particle effects
void particleEff(float Ellipsex, float Ellipsey) {
  for (int i = 0; i < MAX; i ++) {
    plist.add(new Particle(Ellipsex, Ellipsey)); // fill ArrayList with particles

    if (plist.size() > 5*MAX) {
      plist.remove(0);
    }
  }
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 10, 10);
  popMatrix();
}

//draw head with a head image with index s
void drawHead(KJoint[] joints, int jointType, int s) {
  pushMatrix();
  PImage head = heads[s];
  head.resize(400, 700);
  tint(255);
  //translate the image to the position of the head joint
  translate(joints[jointType].getX() -200,joints[jointType].getY() - 260, joints[jointType].getZ());
  image(head,0,0);
  popMatrix();
}



//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2, float R, float G, float B) {
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 70, 70);
  popMatrix();
  strokeWeight(5);
  stroke (R,G,B);
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}


//draw a square at position x,y with width w and height h and color R,G,B
void drawEllipse(float x, float y, float w, float h, float R, float G, float B){
  fill(R,G,B);
  rect(x,y,w,h);
}


//method to check a duplicate element in an array
boolean checkDuplicate(int [] array, int noPlayers, int elementIndex){
    for(int j = 0; j < noPlayers; j++){
     if(elementIndex != j){
       if(array[elementIndex] == array[j]) {
         return true;
       } 
     }
    }    
   return false;
}

//method to check if a joint touches a square - it checks whether the x position of a joint and the y position of a joint are within the x respectively the y positions of a square
void checkIfTouched(int ballNo, KJoint[] joints, float ellX, float ellY, float rad){
  int i;
  for(i = 0; i < jointTypes.length; i++){
    if(joints[jointTypes[i]].getX() > ellX &&  joints[jointTypes[i]].getX() < (ellX + 2*rad) &&
       joints[jointTypes[i]].getY() > ellY &&  joints[jointTypes[i]].getY() < (ellY + 2*rad)){
       ballTouched[ballNo] = 1;
    }
  }
         
}

//method to animate the text on the screen if only one user is detected - it constantly increases the font size by 1 px from 60 px until it reaches 80 px and then decreases it back to 80 px
void animateText(String t){
   textFont(font, 32);
      textSize(fontSize+1);
      fill(204, 0, 153);
      textAlign(CENTER, CENTER);
      text(t, width/2 , height/2);
      textSize(fontSize);
      fill(255, 204, 0);
      text(t, width/2 , height/2);     
      fontSize += increment;
      if(fontSize > 80) { increment = -1;} 
      if(fontSize < 60) {increment = +1;}
   }
   
//method to randomize the x and y positions of the squares and make sure that the distance between two squares is at least 200 pixels
   void randomizeDistance(float[] Xs, float[] Ys){
     float distance = 0;
     for(int i = 0; i < Ys.length; i++){
        Xs[i] = random (350, 1700);
        Ys[i] = random (300, 850);
     }
     for(int i = 0; i < Ys.length; i++){
       for(int j = 0; j < Ys.length; j++){
         if(i!=j){
           distance = sqrt(pow((Xs[i] - Xs[j]), 2) + pow((Ys[i] - Ys[j]), 2));
           if(distance < 200){
             randomizeDistance(Xs, Ys);
           }
         }
       }
     }
   }
  