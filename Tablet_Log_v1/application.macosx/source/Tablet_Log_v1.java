import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import codeanticode.tablet.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Tablet_Log_v1 extends PApplet {

/**
 * Basic Drawing
 * by Andres Colubri. 
 * 
 * This program shows how to access position and pressure from the pen tablet.
 */



Tablet tablet;
PrintWriter logFile;

float pressure, posX, posY, prevPosX, prevPosY, timeinms;

boolean quitSafety = false;
boolean recording = false;

PFont font;
String logStartTime;

PGraphics scribble;

int frameOffset = 0;

public void setup() {
  
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

public void draw() {
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
    pressure = 0.5f;
  }

  // Write the coordinate to a file
  if (recording) {
    logFile.println((frameCount-frameOffset) + "\t" + millis() + "\t" + posX + "\t" + posY + "\t" + pressure + "\t" + mouseDown);
  } else {
  }




  // The current values (pressure, tilt, etc.) can be saved using the saveState() method
  // and latter retrieved with getSavedxxx() methods:
  tablet.saveState();
  tablet.getSavedPressure();

  image(scribble, 0, 0);
  textAlign(CENTER);
  if (recording) {
    text("recording now participant " + name + " on log file" + logStartTime + " frame count " + frameCount, width * 0.5f, height * 0.8f);
  } else {
    text("NOT recording. PRESS 'n' to start a new recording", width * 0.5f, height * 0.8f);
  }
  textAlign(LEFT);
  text("posX: " + posX + "\n"  +  "posY: " + posY + "\n" + "pressure: " + pressure + "\n" + "time in ms: " + timeinms, 50, 50);
}

public void keyPressed() { // Press a key to save the data
  if (key == ESC) {
    key = 0;  // Empêche d'utiliser la touche ESC
  }
  switch(key) {
  case 's': 
    if (recording) { 
      logFile.flush(); // Write the remaining data
      logFile.close(); // Finish the file
      scribble.save(dataPath("") + "/logFiles/" + logStartTime + ".png");
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
        scribble.save(dataPath("") + "/logFiles/" + logStartTime + ".png");
        println("logFile " + logStartTime + " saved");
      }
    }
    frameOffset = frameCount;
    logStartTime = "log-" + name + "_" + year() + "_" + month() + "_" + day() + "_" + hour() + "_" + minute() + "_" + second();
    logFile = createWriter(dataPath("") + "/logFiles/" + logStartTime + ".txt");
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


ControlP5 cp5;

String idParticipant = "";

String name = "";

public void setupControls(){

cp5 = new ControlP5(this);
  
                 
  cp5.addTextfield("name")
     .setPosition(20,170)
     .setSize(200,40)
     .setFont(createFont("arial",20))
     .setAutoClear(false)
     ;

}

public void idParticipant(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
  if(!recording){
  idParticipant = theText;
  }
}
  public void settings() {  size(1280, 720); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Tablet_Log_v1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
