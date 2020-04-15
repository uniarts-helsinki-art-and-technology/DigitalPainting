import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;

import shiffman.box2d.*;

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
}

void setup() {
  bill = loadImage("variance2.png");
  bill = loadImage("a_dying_fairy_dust_particle_by_colourdance-d3fqspf.png");
  //bill = loadImage("texture.gif");
  bill = loadImage("bill.png");
  bill.filter(INVERT);


  frameNumFont = createFont("Georgia", 10);
  textFont(frameNumFont);
  textAlign(CENTER, CENTER);
  stroke(0);

  imageMode(CENTER);
  brightnessContrastController = new BrightnessContrastController();

  brush = new Brush(0, 0);

  parseFile("logFile.txt");

  cf = new ControlFrame(this, 500, 700, "Controls");
  surface.setLocation(420, 10);

  cam = new PeasyCam(this, 800);

  logger = new Logger();
  xDimension=1;
  yDimension=1;
}




void draw() {

  background(255);

  if (!drawingNormalDrawingZHeight) {
    cam.reset();
    cam.setActive(false);
    camera();
  }

  if (drawingScatterPlot) {
    drawScatterPlot(xDimension, yDimension, start, end, step);
  }


  if (drawingDynamicDrawing) {

    drawDynamicDrawing(start, end, step);
  }

  if (drawingNormalDrawingConnectedSmooth) {

    drawNormalDrawingConnectedSmooth(start, end, step);
  }

  if (drawingNormalDrawing) {

    drawNormalDrawing(start, end, step);
  }


  if (drawingScore) {
    drawScore(start, end, step);
  }
  if (drawingSpiral) {
    drawSpiral();
  }
  if (drawingVis1) {
    drawVis1();
  }
  if (drawingConcentricTriangles) {
    drawConcentricTriangles() ;
  }
  if (drawingTimeMap) {
    //println("draw timemap");
    drawTimeMap();
  }



  if (drawingNormalDrawingZHeight) {
    cam.setActive(true);
    
    pushMatrix();
    
    translate(-width/2,-height/2);
    
    drawNormalDrawingZHeight(start, end, step);
    popMatrix();
  } else {

    filter(BLUR, blurFactor); 

    screen = get();

    brightnessContrastController.destructiveShift(screen, bright, contrast);

    image(screen, width/2, height/2, width, height);
  }


  if (savePDF) {    
    savePDF = false;
    savePDF();
  }

  if (saveSVG) {    
    saveSVG = false;
    saveSVG();
  }
}

// try different brushes
// need to autoscale to the new range



void savePDF() {
  println(sketchPath());
  beginRecord(PDF, "pdf/pdf_"
    + year() + day() + hour() + minute() + second()+ ".pdf");
  //image(screen, width/2, height/2, width, height);
  drawNormalDrawingConnectedSmooth(start, end, step);
  endRecord();
  println("PDF SAVED");
}

void saveSVG() {
  println(sketchPath());
  beginRecord(SVG, "svg/svg_"
    + year() + day() + hour() + minute() + second()+ ".svg");
  //image(screen, width/2, height/2, width, height);
  drawNormalDrawingConnectedSmooth(start, end, step);
  endRecord();
  println("SVG SAVED");
}

void keyPressed() {

  if (key == 's') {
    screen.save("drawing " + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }

  if (key == 'l') {
    loadLogFile() ;
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



  //cf.cp5.addRange("range_frames")
  //   // disable broadcasting since setRange and setRangeValues will trigger an event
  //   .setBroadcast(false) 
  //   .setSize(400, 30)
  //   .setHandleSize(20)
  //   .setRange(start, end)
  //   .setRangeValues(start, end)
  //   // after the initialization we turn broadcast back on again
  //   .setBroadcast(true)
  //   .setColorForeground(color(255, 40))
  //   .setColorBackground(color(255, 40)).linebreak().linebreak();
  // ;


  //println("xAxis " + xAxis.size());
  //println("yAxis " + yAxis.size());
  //println("myFrameAxis " + myFrameAxis.size());
  //println("pressureAxis " + pressureAxis.size());
  //for (int i = 0; i < myFrame.size(); i++) {     
  //  println("myFrameAxis.get(i) " + myFrameAxis.get(i));
  //}
} 
