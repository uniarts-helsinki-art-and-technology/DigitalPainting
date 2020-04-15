/**
 * Basic Drawing
 * by Andres Colubri. 
 * 
 * This program shows how to access position and pressure from the pen tablet.
 */

import codeanticode.tablet.*;

Tablet tablet;
PrintWriter logFile;

float pressure, posX, posY, prevPosX, prevPosY, timeinms;

boolean quitSafety = false;
boolean recording = false;

PFont font;
String logStartTime;

PGraphics scribble;

void setup() {
  size(1280, 720);
  font = loadFont("LucidaBright-48.vlw");
  textFont(font, 12);
  textAlign(CENTER);

  tablet = new Tablet(this); 

  scribble = createGraphics(width, height);

  background(0);
  stroke(255);
  scribble.beginDraw();
  scribble.background(0);
  scribble.endDraw();

  setupControls();
}

void draw() {
  background(0);
  // Instead of mousePressed, one can use the Tablet.isMovement() method, which
  // returns true when changes not only in position but also in pressure or tilt
  // are detected in the tablet. 

  pressure = tablet.getPressure();
  posX = tablet.getPenX();
  posY = tablet.getPenY();
  prevPosX = tablet.getSavedPenX();
  prevPosY = tablet.getSavedPenY();
  timeinms = millis();

  if (tablet.isMovement()) {
    scribble.beginDraw();
    scribble.strokeWeight(20 * pressure);
    scribble.stroke(255, 30 * pressure);

    // The tablet getPen methods can be used to retrieve the pen current and 
    // saved position (requires calling tablet.saveState() at the end of 
    // draw())...
    scribble.line(prevPosX, prevPosY, posX, posY);

    // ...but it is equivalent to simply use Processing's built-in mouse 
    // variables.
    //line(pmouseX, pmouseY, mouseX, mouseY);

    scribble.endDraw();
  }
  int mouseDown = 0;
  if (mousePressed) {
    mouseDown = 1;
    posX = mouseX;
    posY = mouseY;
    prevPosX = pmouseX;
    prevPosY = pmouseY;
    scribble.beginDraw();
    scribble.strokeWeight(2);
    scribble.stroke(255, 100);
    scribble.line(prevPosX, prevPosY, posX, posY);
    scribble.endDraw();
  }

  // Write the coordinate to a file
  if (recording) {
    logFile.println(frameCount + "\t" + millis() + "\t" + posX + "\t" + posY +  ", " + pressure   + "\t" + tablet.getPressure() + "\t" + mouseDown);
  } else {
  }




  // The current values (pressure, tilt, etc.) can be saved using the saveState() method
  // and latter retrieved with getSavedxxx() methods:
  tablet.saveState();
  tablet.getSavedPressure();

  image(scribble, 0, 0);
  textAlign(CENTER);
  if (recording) {
    text("recording now participant " + name + " on log file" + logStartTime + " frame count " + frameCount, width * 0.5, height * 0.8);
  } else {
    text("NOT recording. PRESS 'n' to start a new recording", width * 0.5, height * 0.8);
  }
  textAlign(LEFT);
  text("posX: " + posX + "\n"  +  "posY: " + posY + "\n" + "pressure: " + pressure + "\n" + "time in ms: " + timeinms, 50, 50);
}

void keyPressed() { // Press a key to save the data
  if (key == ESC) {
    key = 0;  // Empêche d'utiliser la touche ESC
  }
  switch(key) {
  case 's': 
    if (recording) { 
      logFile.flush(); // Write the remaining data
      logFile.close(); // Finish the file
      scribble.save("logFiles/" + logStartTime + ".png");
      println("logFile saved");
      recording = false;
    }
    break;
  case 'n': 
    if (logFile != null) {
      logFile.flush();
    } else {
      if (recording) {        
        logFile.flush(); // Write the remaining data
        logFile.close(); // Finish the file
        scribble.save("logFiles/" + logStartTime + ".png");
        println("logFile " + logStartTime + " saved");
      }
    }

    logStartTime = "log-" + name + "_" + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second();
    logFile = createWriter("logFiles/" + logStartTime + ".txt");
    recording = true;
    scribble.beginDraw();
    scribble.background(0);
    scribble.endDraw();
    println("started a new recording at time " + logStartTime);  // Does not execute
    break;

  case 'q':
    if (!quitSafety) {
      quitSafety = true;
    } else {
      exit();
    }
    break;
  default:             // Default executes if the case labels
    //println("None");   // don't match the switch parameter
    break;
  }
}
