import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

import shiffman.box2d.*;

import nervoussystem.obj.*;

boolean record;

PeasyCam cam;

String[] logFile;
int index = 0;
FloatList x_pos, y_pos, pressure;
FloatList myFrame, millis, mousePress;

FloatList xAxis, yAxis, myFrameAxis, pressureAxis;

float pressureX, pressureY, revolutions;
int step;

PImage bill;

PFont frameNumFont;

BrightnessContrastController brightnessContrastController;

Brush brush;

PImage screen;

Logger logger;

boolean saveSVG, savePDF = false;

int xDimension, yDimension;

void settings() {
  size(900, 900, P3D);
  smooth(8);
}

void setup() {

  frameNumFont = createFont("Georgia", 10);
  textFont(frameNumFont);
  textAlign(CENTER, CENTER);
  stroke(0);

  imageMode(CENTER);
  brightnessContrastController = new BrightnessContrastController();

  brush = new Brush(0, 0);

  parseFile("logFile.txt");

  cf = new ControlFrame(this, 500, 150, "Controls");
  surface.setLocation(420, 10);

  cam = new PeasyCam(this, 800);
  

  logger = new Logger();
  xDimension=1;
  yDimension=1;
}

void draw() {

  background(255); 
 if (record) {
    OBJExport obj = (OBJExport) createGraphics(10,10,"nervoussystem.obj.OBJExport","drawing.obj");
    obj.setColor(true);
    obj.beginDraw();
    obj.noFill();
    drawNormalDrawingZHeight(obj,start, end, step);
    obj.endDraw();
    obj.dispose();
  }
  pushMatrix();

  translate(-width/2, -height/2);

  drawNormalDrawingZHeight(start, end, step);
  popMatrix();
  
  if (record) {
    endRecord();
    record = false;
  }
}


void keyPressed() {

  if (key == 's') {
    screen.save("drawing " + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }
  
  if (key == 'r') {
    record = true;
  }

}

void loadLogFile() {
  selectInput("Select a log file to visualize:", "fileSelected");
}

public  void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    //println("User selected " + selection.getAbsolutePath());
    parseFile(selection.getAbsolutePath());
    cf.cp5.getController("range_frames").setMax(myFrame.size());
    cf.cp5.getController("range_frames").setValue(0);
    cam.reset();
  }
}

void parseFile(String s) {

  myFrame = new FloatList();
  millis = new FloatList();
  x_pos = new FloatList();
  y_pos = new FloatList();
  pressure = new FloatList();
  mousePress = new FloatList();

  xAxis = new FloatList();
  yAxis = new FloatList();
  myFrameAxis = new FloatList();
  pressureAxis = new FloatList();


  // Open the file from the createWriter() example
  BufferedReader reader = createReader(s);
  String line = null;
  try {
    while ((line = reader.readLine()) != null) {
      String[] pieces = split(line, TAB);
      myFrame.append(int(pieces[0]));
      millis.append(int(pieces[1]));
      x_pos.append(float(pieces[2]));
      y_pos.append(float(pieces[3]));
      pressure.append(float(pieces[4]));
      mousePress.append(int(pieces[5]));
    }
    reader.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  for (int i = 0; i < myFrame.size(); i++) {
    xAxis.append(map(x_pos.get(i), 0, 800, 1, myFrame.size()));
    yAxis.append(map(y_pos.get(i), 0, 800, 1, myFrame.size()));
    myFrameAxis.append(myFrame.get(i));
    pressureAxis.append(map(pressure.get(i), 0, 1, 1, myFrame.size()));
  }

  println("myFrame.size() " + myFrame.size());

} 