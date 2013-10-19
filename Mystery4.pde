/*
  Mystery4
  --------
  Controlling a robot from a particle system
  
  Created by RobotGrrl - Oct. 19, 2013
  robotgrrl.com
  
  CC BY-SA
*/

import traer.physics.*;

ParticleSystem physics;

// -- BIG -- //
final int numOutputs = 6; // left wing, right wing, beak, eyes, top led, speaker
final int numActions = 5; // up, down, middle, modulate, special

int outputsStren[] = {1200, 1000, 100, 500, 100, 50};
int actionsStren[] = {500, 500, 250, 1000, 2000};

Particle pOutputs[] = new Particle[numOutputs];
Particle pActions[] = new Particle[numActions];


// -- SMALL -- //
final int numFlies = 20;
final int numFrogs = 6;
final int numBats = 3;

int fliesStren = 1000;
int frogsStren = 1500;
int batsStren = 2000;

Particle pFlies[] = new Particle[numFlies];
Particle pFrogs[] = new Particle[numFrogs];
Particle pBats[] = new Particle[numBats];


// -- ENVIRONMENT -- //
float dispX[] = new float[numOutputs];
float dispY[] = new float[numOutputs];
float dispTotal[] = new float[numOutputs];
float proximities[][] = new float[numOutputs][numActions];
int closestAction[] = new int[numOutputs];

int lastDispRecord = 0;
int lastDispUpdate = 0;
int lastDispChange = 0;

int lastProxRecord = 0;
int lastProxFind = 0;


void setup() {

  size(1000, 720);
  smooth();
  ellipseMode(CENTER);
  noStroke();
  
  println("hello");
  
  physics = new ParticleSystem(0.0, 0.0);
  
  resetParticles();
  resetEnvironment();
  
}


void draw() {

  fill(color(0, 0, 0, 100));
  rect(0, 0, width, height);
  
  physics.tick();
  
  drawBigParticles();
  
  drawSmallParticles();
  
  updateDisplacement();
  updateProximities();
  
}



void updateProximities() {
 
  int mill = millis();
  
  // first, record the proximities
  if(mill-lastProxRecord >= 100) {
    for(int i=0; i<numOutputs; i++) {
      for(int j=0; j<numActions; j++) {
        proximities[i][j] += sqrt( pow(abs(pOutputs[i].position().x()-pActions[j].position().x()),2) + pow(abs(pOutputs[i].position().y()-pActions[j].position().y()),2) );
      }
    }
    lastProxRecord = mill;
  }
  
  // second, find the closest ones for each output
  if(mill-lastProxFind >= 1000) {
    for(int i=0; i<numOutputs; i++) {
      for(int j=0; j<numActions; j++) {
        
        proximities[i][j] /= 100;
        
        if(proximities[i][j] < proximities[i][closestAction[i]]) {
          closestAction[i] = j;
        }
      }
    }
    
    // throw out ones that are not so close
    for(int i=0; i<numOutputs; i++) {
      //println(i +": closest action: " + closestAction[i] + " " + proximities[i][closestAction[i]]);
      
      if(proximities[i][closestAction[i]] > 25.0) {
        closestAction[i] = 99;
      } else {
        println("output: " + i + " action: " + closestAction[i]);
        sendAction(i, closestAction[i]);
      }
    }
   
    // reset it
    for(int i=0; i<numOutputs; i++) {
      closestAction[i] = 0;
      for(int j=0; j<numActions; j++) {
        proximities[i][j] = 0;
      }
    }
   
   lastProxFind = mill;
    
  }
  
}



void updateDisplacement() {
 
  int mill = millis();
  float addingVel = 10.0;
  
  // first, record the displacements
  if(mill-lastDispRecord >= 100) {
    for(int i=0; i<numOutputs; i++) {
      dispX[i] += pOutputs[i].position().x()-(width/2);
      dispY[i] += pOutputs[i].position().y()-(height/2);
    }
    lastDispRecord = mill;
  }
  
  // second, update the total
  if(mill-lastDispUpdate >= 1000) {
    for(int i=0; i<numOutputs; i++) {
      dispTotal[i] = sqrt( (pow(dispX[i], 2) + pow(dispY[i], 2)) );
      dispX[i] = 0;
      dispY[i] = 0;
    }
    lastDispUpdate = mill;
  }
  
  // third, change the environment
  if(mill-lastDispChange >= 1000) {
    for(int i=0; i<numOutputs; i++) {
      for(int j=i+1; j<numOutputs; j++) {
        
        float delta = abs(dispTotal[i]-dispTotal[j]);
        //println(i + ": delta: " + delta);
        
        if(delta < 10.0) {
          println("changing velocity: " + i + " & " + j); 
          pOutputs[i].velocity().add(-1*addingVel, -1*addingVel, 0);
          pOutputs[j].velocity().add(addingVel, addingVel, 0);
        }
        
      }
    }
    lastDispChange = mill; 
  }
  
}



void drawSmallParticles() {

  // flies
  fill(color(96,39,73,255)); // purpleish
  for(int i=0; i<numFlies; i++) {
    handleBoundaryCollisions(pFlies[i]);
    ellipse(pFlies[i].position().x(), pFlies[i].position().y(), 10, 5);
  }
  
  // frogs
  fill(color(177,70,35,255)); // orangeish
  for(int i=0; i<numFrogs; i++) {
    handleBoundaryCollisions(pFrogs[i]);
    ellipse(pFrogs[i].position().x(), pFrogs[i].position().y(), 10, 5);
  }
  
  // bats
  fill(color(246,146,29,255)); // yellowish
  for(int i=0; i<numBats; i++) {
    handleBoundaryCollisions(pBats[i]);
    ellipse(pBats[i].position().x(), pBats[i].position().y(), 10, 5);
  }
  
}


void drawBigParticles() {
 
  int _w = 25;
  int _h = 15;
  int _s = 24;
  
  for(int i=0; i<numOutputs; i++) {
    handleBoundaryCollisions(pOutputs[i]);
  }
  
  for(int i=0; i<numActions; i++) {
    handleBoundaryCollisions(pActions[i]);
    fill(color(255,255,255, 255));
    ellipse(pActions[i].position().x(), pActions[i].position().y(), _w, _h);
  }
  
  
  textSize(_s);
  fill(246,146,29);
  text("L", pOutputs[0].position().x()-(_w/2), pOutputs[0].position().y()-(_h/2));
  fill(color(255, 0, 0, 255));
  ellipse(pOutputs[0].position().x(), pOutputs[0].position().y(), _w, _h);
  
  textSize(_s);
  fill(246,146,29);
  text("R", pOutputs[1].position().x()-(_w/2), pOutputs[1].position().y()-(_h/2));
  fill(color(255, 255, 0, 255));
  ellipse(pOutputs[1].position().x(), pOutputs[1].position().y(), _w, _h);
  
  textSize(_s);
  fill(246,146,29);
  text("B", pOutputs[2].position().x()-(_w/2), pOutputs[2].position().y()-(_h/2));
  fill(color(0, 255, 0, 255));
  ellipse(pOutputs[2].position().x(), pOutputs[2].position().y(), _w, _h);
  
  textSize(_s);
  fill(246,146,29);
  text("E", pOutputs[3].position().x()-(_w/2), pOutputs[3].position().y()-(_h/2));
  fill(color(0, 255, 255, 255));
  ellipse(pOutputs[3].position().x(), pOutputs[3].position().y(), _w, _h);
  
  textSize(_s);
  fill(246,146,29);
  text("T", pOutputs[4].position().x()-(_w/2), pOutputs[4].position().y()-(_h/2));
  fill(color(0, 0, 255, 255));
  ellipse(pOutputs[4].position().x(), pOutputs[4].position().y(), _w, _h);
  
  textSize(_s);
  fill(246,146,29);
  text("S", pOutputs[5].position().x()-(_w/2), pOutputs[5].position().y()-(_h/2));
  fill(color(255, 0, 255, 255));
  ellipse(pOutputs[5].position().x(), pOutputs[5].position().y(), _w, _h);
  
}



void resetParticles() {
 
  // outputs
  for(int i=0; i<numOutputs; i++) {
    pOutputs[i] = physics.makeParticle(1.0, random(0, width), random(0, height), 0);
  }
  
  for(int i=0; i<numOutputs; i++) {
    for(int j=i+1; j<numOutputs; j++) {
      physics.makeAttraction(pOutputs[i], pOutputs[j], outputsStren[i], 50);
    }
  }
  
  // actions
  for(int i=0; i<numActions; i++) {
    pActions[i] = physics.makeParticle(1.0, random(0, width), random(0, height), 0);
  }
  
  for(int i=0; i<numActions; i++) {
    for(int j=i+1; j<numActions; j++) {
      physics.makeAttraction(pActions[i], pActions[j], actionsStren[i], 50);
    }
  }
  
  // flies
  for(int i=0; i<numFlies; i++) {
    pFlies[i] = physics.makeParticle(1.0, random(0, width), random(0, height), 0);
  }
  
  for(int i=0; i<numFlies; i++) {
    for(int j=i+1; j<numFlies; j++) {
      physics.makeAttraction(pFlies[i], pFlies[j], fliesStren, 50);
    }
  }
  
  // frogs
  for(int i=0; i<numFrogs; i++) {
    pFrogs[i] = physics.makeParticle(1.0, random(0, width), random(0, height), 0);
  }
  
  for(int i=0; i<numFrogs; i++) {
    for(int j=i+1; j<numFrogs; j++) {
      physics.makeAttraction(pFrogs[i], pFrogs[j], frogsStren, 50);
    }
  }
  
  // bats
  for(int i=0; i<numBats; i++) {
    pBats[i] = physics.makeParticle(1.0, random(0, width), random(0, height), 0);
  }
  
  for(int i=0; i<numBats; i++) {
    for(int j=i+1; j<numBats; j++) {
      physics.makeAttraction(pBats[i], pBats[j], batsStren, 50);
    }
  }
  
  // ------
  
  // outputs & actions
  for(int i=0; i<numOutputs; i++) {
    for(int j=0; j<numActions; j++) {
      physics.makeAttraction(pOutputs[i], pActions[j], outputsStren[i], 50);
    }
  }
  
  // outputs & flies
  for(int i=0; i<numOutputs; i++) {
    for(int j=0; j<numFlies; j++) {
      physics.makeAttraction(pOutputs[i], pFlies[j], outputsStren[i], 50);
    }
  }
  
  // outputs & frogs
  for(int i=0; i<numOutputs; i++) {
    for(int j=0; j<numFrogs; j++) {
      physics.makeAttraction(pOutputs[i], pFrogs[j], outputsStren[i], 50);
    }
  }
  
  // outputs & bats
  for(int i=0; i<numOutputs; i++) {
    for(int j=0; j<numBats; j++) {
      physics.makeAttraction(pOutputs[i], pBats[j], outputsStren[i], 50);
    }
  }
  
  // actions & flies
  for(int i=0; i<numActions; i++) {
    for(int j=0; j<numFlies; j++) {
      physics.makeAttraction(pActions[i], pFlies[j], actionsStren[i], 50);
    }
  }
  
  // actions & frogs
  for(int i=0; i<numActions; i++) {
    for(int j=0; j<numFrogs; j++) {
      physics.makeAttraction(pActions[i], pFrogs[j], actionsStren[i], 50);
    }
  }
  
  // flies & frogs
  for(int i=0; i<numFlies; i++) {
    for(int j=0; j<numFrogs; j++) {
      physics.makeAttraction(pFlies[i], pFrogs[j], fliesStren, 50);
    }
  }
  
}


void resetEnvironment() {
 
  for(int i=0; i<numOutputs; i++) {
    dispX[i] = 0;
    dispY[i] = 0;
    dispTotal[i] = 0;
    
    for(int j=0; j<numActions; j++) {
      proximities[i][j] = 0;
    }
    
    closestAction[i] = 0;
    
  }
  
  lastDispRecord = 0;
  lastDispUpdate = 0;
  lastDispChange = 0;
  
}



void handleBoundaryCollisions( Particle p ) {
  if ( p.position().x() < 0 || p.position().x() > width ) {
    p.velocity().set(-0.9*p.velocity().x(), p.velocity().y(), 0);
  }
  if ( p.position().y() < 0 || p.position().y() > height ) {
    p.velocity().set(p.velocity().x(), -0.9*p.velocity().y(), 0);
  }
  p.position().set( constrain( p.position().x(), 0, width ), constrain( p.position().y(), 0, height ), 0 ); 
}




