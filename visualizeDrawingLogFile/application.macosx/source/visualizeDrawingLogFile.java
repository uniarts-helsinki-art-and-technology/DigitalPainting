import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import peasy.*; 
import peasy.org.apache.commons.math.*; 
import peasy.org.apache.commons.math.geometry.*; 
import shiffman.box2d.*; 
import controlP5.*; 
import processing.pdf.*; 
import processing.svg.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class visualizeDrawingLogFile extends PApplet {







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

public void settings() {
  size(900, 900, P3D);
}

public void setup() {
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




public void draw() {

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



public void savePDF() {
  println(sketchPath());
  beginRecord(PDF, "pdf/pdf_"
    + year() + day() + hour() + minute() + second()+ ".pdf");
  //image(screen, width/2, height/2, width, height);
  drawNormalDrawingConnectedSmooth(start, end, step);
  endRecord();
  println("PDF SAVED");
}

public void saveSVG() {
  println(sketchPath());
  beginRecord(SVG, "svg/svg_"
    + year() + day() + hour() + minute() + second()+ ".svg");
  //image(screen, width/2, height/2, width, height);
  drawNormalDrawingConnectedSmooth(start, end, step);
  endRecord();
  println("SVG SAVED");
}

public void keyPressed() {

  if (key == 's') {
    screen.save("drawing " + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }

  if (key == 'l') {
    loadLogFile() ;
  }
}

public void loadLogFile() {
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

public void parseFile(String s) {

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
      myFrame.append(PApplet.parseInt(pieces[0]));
      millis.append(PApplet.parseInt(pieces[1]));
      x_pos.append(PApplet.parseFloat(pieces[2]));
      y_pos.append(PApplet.parseFloat(pieces[3]));
      pressure.append(PApplet.parseFloat(pieces[4]));
      mousePress.append(PApplet.parseInt(pieces[5]));
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
/*
Copyright (c) 2014 Ale González

This software is free; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License version 2.1 as published by the Free Software Foundation.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General
Public License along with this library; if not, write to the
Free Software Foundation, Inc., 59 Temple Place, Suite 330,
Boston, MA 02111-1307 USA
*/

/**
 * BrightnessContrastController
 *
 * Shifts the global brightness and contrast of an image.
 *
 * Ported from Gimp's implementation, as explained by Pippin here:
 * http://pippin.gimp.org/image_processing/chap_point.html 
 * The following excerpts are from that--excellent btw--documentation:
 * "Changing the contrast of an image, changes the range of luminance values present. 
 *  Visualized in the histogram it is equivalent to expanding or compressing the histogram around the midpoint value. 
 *  Mathematically it is expressed as:
 *    new_value = (old_value - 0.5) × contrast + 0.5
 *  It is common to bundle brightness and control in a single operations, the mathematical formula then becomes:
 *   new_value = (old_value - 0.5) × contrast + 0.5 + brightness
 * The subtraction and addition of 0.5 is to center the expansion/compression of the range around 50% gray." 
 *
 * @author ale
 * @version 1.0
 */

class BrightnessContrastController
{        
    /**
    * Shifts brightness and contrast in the given image. Keeps alpha of the source pixels.
    * 
    * @param img
    *            Image to be adjusted.
    * @param brightness
    *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
    * @param contrast
    *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
    */  
    public void destructiveShift(PImage img, int brightness, float contrast)
    {
        img.loadPixels();
        int l = img.pixels.length;
        
        //Variables to hold single pixel color and its components 
        int c = 0;
        int a = 0;
        int r = 0;
        int g = 0;
        int b = 0;
        
        for(int i = 0; i < l; i++)
        {
            c = img.pixels[i];
            a = c >> 24 & 0xFF;
            r = adjustedComponent(c >> 16 & 0xFF, brightness, contrast);
            g = adjustedComponent(c >> 8  & 0xFF, brightness, contrast);
            b = adjustedComponent(c       & 0xFF, brightness, contrast);
            img.pixels[i] = a << 24 | r << 16 | g << 8 | b;
        }
        img.updatePixels(); 
    }
  
    /**
    * Shifts brightness in the given image. Keeps alpha of the source pixels.
    * 
    * @param img
    *            Image to be adjusted.
    * @param brightness
    *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
    */
    public void destructiveShift(PImage img, int brightness)
    {
        destructiveShift(img, brightness, 1.0f);  
    }
    
    /**
    * Shifts contrast in the given image. Keeps alpha of the source pixels.
    * 
    * @param img
    *            Image to be adjusted.
    * @param contrast
    *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
    */
    public void destructiveShift(PImage img, float contrast)
    {
        destructiveShift(img, 0, contrast);  
    }
  
    /**
    * Shifts brightness and contrast in a defensive copy of the given image. Keeps alpha of the source pixels.
    * 
    * @param img
    *            Source image.
    * @param brightness
    *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
    * @param contrast
    *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
    * @return An adjusted defensive copy of the given image.
    */
    public PImage nondestructiveShift(PImage img, int brightness, float contrast)
    {
        PImage out = createImage(img.width, img.height, ARGB);
        img.loadPixels();
        out.loadPixels();
        int l = img.pixels.length;
        
        //Variables to hold single pixel color and its components 
        int c = 0;
        int a = 0;
        int r = 0;
        int g = 0;
        int b = 0;
        
        for(int i = 0; i < l; i++)
        {
            c = img.pixels[i];
            a = c >> 24 & 0xFF;
            r = adjustedComponent(c >> 16 & 0xFF, brightness, contrast);
            g = adjustedComponent(c >> 8  & 0xFF, brightness, contrast);
            b = adjustedComponent(c       & 0xFF, brightness, contrast);
            out.pixels[i] = a << 24 | r << 16 | g << 8 | b;
        }
        out.updatePixels();
        return out;  
    }  
    
    /*
    * Shifts brightness in a defensive copy of the given image. Keeps alpha of the source pixels.
    * 
    * @param img
    *            Image to be adjusted.
    * @param brightness
    *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
    */ 
    public void nondestructiveShift(PImage img, int brightness)
    {
        nondestructiveShift(img, brightness, 1.0f);  
    }
 
    /**
    * Shifts contrast in a defensive copy of the given image. Keeps alpha of the source pixels.
    * 
    * @param img
    *            Image to be adjusted.
    * @param contrast
    *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
    */   
    public void nondestructiveShift(PImage img, float contrast)
    {
        nondestructiveShift(img, 0, contrast);  
    } 
        
    /**
    * Calculates the transformation of a single color component.
    * 
    * @param component
    *            Integer value of the component in a range 0-255.
    * @param brightness
    *            Value of the brightness adjustment. Integer in a range from -255 (all pixels to black) to 255 (all pixels to white). 0 causes no effect.
    * @param contrast
    *            Value of the contrast adjustment. Its range starts in 1f (no effect). Values over 1f increase contrast and below that value decrease contrast. Negative values will invert the image.
    * @return The adjusted value of the component, constrained in its natural range 0-255.
    */
    private int adjustedComponent(int component, int brightness, float contrast)
    {
        component = PApplet.parseInt((component - 128) * contrast) + 128 + brightness;
        return component < 0 ? 0 : component > 255 ? 255 : component;  
    }  
}


class Brush {

   // position, velocity, and acceleration 
  PVector position;
  PVector velocity;
  PVector acceleration;

  // Mass is tied to size
  float mass;

  float life;

  boolean dead = false;
  
  float brushSize;

  Brush(float x, float y) {
    
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    
  }

  public void updateBrush() {
  }

  public void drawBrush() {
  }
  
    public void drawBrush(float x, float y,float _pressure) {
      
      position.set(x,y);
      pushMatrix();
      pushStyle();
      stroke(0,120);
      translate(x,y);
      
      for(int i=0;i<_pressure;i++){   
        
       point(random(-_pressure,_pressure),random(-_pressure,_pressure) );
      }
      
      popStyle();
      popMatrix();
      
  }
  
  
}

ControlFrame cf;
ControlP5 cp5;




float waterDilution, globalBrushSize, zoom_factor;

float contrast, blurFactor;
int bright, start, end;

class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  Slider2D s, pan2D;

 RadioButton xDim, yDim;


  Range range;

  public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
    super();   
    parent = _parent;
    w=_w;
    h=_h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {

    start = 0;
    end = myFrame.size();

    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);

    cp5.addRange("range_frames")
      // disable broadcasting since setRange and setRangeValues will trigger an event
      .setBroadcast(false) 
      .setSize(400, 30).setDecimalPrecision(0)
      .setHandleSize(20)
      .setRange(start, end)
      .setRangeValues(start, end)
      // after the initialization we turn broadcast back on again
      .setBroadcast(true)
      .setColorForeground(color(255, 40))
      .setColorBackground(color(255, 40)).linebreak().linebreak();
    ;

    cp5.addSlider("step").plugTo(parent).setRange(1, 300).setSize(300, 10).linebreak();
    ;

    xDim =   cp5.addRadioButton("xDimension")
      .setPosition(120, 60)
      .setSize(20, 20)
      .setColorForeground(color(120))
      .setColorActive(color(255))
      .setColorLabel(color(255))
      .setItemsPerRow(4)
      .setSpacingColumn(70)
      .addItem("x_x_position", 1)
      .addItem("x_y_position", 2)
      .addItem("x_presures", 3)
      .addItem("x_frame", 4)
      ;
       yDim =   cp5.addRadioButton("yDimension")
      .setPosition(120, 90)
      .setSize(20, 20)
      .setColorForeground(color(120))
      .setColorActive(color(255))
      .setColorLabel(color(255))
      .setItemsPerRow(4)
      .setSpacingColumn(70)
      .addItem("y_x_position", 1)
      .addItem("y_y_position", 2)
      .addItem("y_presures", 3)
      .addItem("y_frame", 4)
      ;

cp5.addButton("loadLogFile").plugTo(parent).linebreak();

    cp5.addButton("saveLog").linebreak();
    cp5.addButton("saveImage").linebreak();
    cp5.addButton("saveSVG").linebreak();
    cp5.addButton("savePDF").linebreak();

    cp5.addSlider("bright").plugTo(parent)
      .setRange(-255, 255).setValue(0).setSize(100,10).setPosition(10,200)
      ;
    cp5.addSlider("contrast").plugTo(parent)
      .setRange(0.0f, 10.f).setValue(1).setSize(100,10).setPosition(160,200);
      ;
    cp5.addSlider("blurFactor").plugTo(parent)
      .setRange(0.0f, 10.f).setValue(0.f).setSize(100,10).setPosition(320,200).linebreak();
    ;

    cp5.addToggle("drawingScatterPlot").plugTo(parent).setValue(false).setPosition(10,240).linebreak();
    cp5.addToggle("showFrameNumber").plugTo(parent).setValue(false).setPosition(150,240).linebreak();
    cp5.addToggle("drawingScore").plugTo(parent).setValue(false).linebreak();
    cp5.addToggle("drawingSpiral").plugTo(parent).setValue(false).linebreak();

    cp5.addSlider("revolutions").plugTo(parent).setRange(1, 100).setSize(120,10).setPosition(90,340);
    cp5.addSlider("pressureX").plugTo(parent)
      .setRange(0.0f, 100).setPosition(270,320).linebreak();
    cp5.addSlider("pressureY").plugTo(parent)
      .setRange(0.0f, 100).setPosition(270,340);
      
    cp5.addToggle("drawingVis1").plugTo(parent).setValue(false).setPosition(10,380).linebreak();
    cp5.addToggle("drawingConcentricTriangles").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingTimeMap").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingNormalDrawing").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingDynamicDrawing").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingNormalDrawingConnectedSmooth").plugTo(parent).setValue(false).linebreak();
    cp5.addToggle("drawingNormalDrawingZHeight").plugTo(parent).setValue(false).linebreak();
  }

  public void saveImage() {  
    screen.save("savedImages/drawing_" + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }



  public void saveLog() {

    logger.saveLog();
  }
  public void draw() {
    background(20);
  }
  public void controlEvent(ControlEvent theControlEvent) {
    //parent.redraw();
    //println("received event");
    if(theControlEvent.isFrom(xDim)) {
      if(PApplet.parseInt(theControlEvent.getValue())>0){
      xDimension = PApplet.parseInt(theControlEvent.getValue());
        }
    }
        if(theControlEvent.isFrom(yDim)) {
      if(PApplet.parseInt(theControlEvent.getValue())>0){
      yDimension = PApplet.parseInt(theControlEvent.getValue());
      }
    }
    
    
    if (theControlEvent.isFrom("range_frames")) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.
      start = PApplet.parseInt(theControlEvent.getController().getArrayValue(0));
      end = PApplet.parseInt(theControlEvent.getController().getArrayValue(1));
    }
    if (theControlEvent.isFrom("savePDF")) {
      savePDF=true;
    }
    if (theControlEvent.isFrom("saveSVG")) {
      saveSVG=true;
    }
  }
}
class Logger {

  PrintWriter log_file;

  Logger() {
  }

  public void saveLog() {

    // Create a new file in the sketch directory
    log_file = createWriter("logFiles/logFile_" +year()+month()+day()+hour()+minute() + ".txt");
    int index = 1;
    for (int i=start; i< myFrame.size() && i< end; i+= step) {

      log_file.println(index + "\t" + millis() + "\t" + x_pos.get(i)+ "\t" + y_pos.get(i) 
        + "\t" + pressure.get(i) + "\t" + mousePress.get(i));

      index++;
    }

    log_file.flush(); // Writes the remaining data to the file
    log_file.close(); // Finishes the file
  }
}
// new log file

// vector graphic
boolean  drawingScore, drawingSpiral, drawingVis1, drawingConcentricTriangles, drawingTimeMap, 
  drawingNormalDrawing, drawingNormalDrawingConnectedSmooth, drawingDynamicDrawing, drawingNormalDrawingZHeight, 
  drawingScatterPlot, showFrameNumber;



public void drawScatterPlot(int dimX, int dimY, int startFrame, int endFrame, int step) {

  FloatList x = new FloatList();
  FloatList y = new FloatList();

  switch (dimX) {
  case 1:
    x =xAxis.copy();
    break;
  case 2:
    x=yAxis.copy();
    break;
  case 3:  
    x=pressureAxis.copy();
    break;
  case 4:

    x=myFrameAxis.copy();

    break;
  }
  switch (dimY) {
  case 1:
    y=xAxis.copy();
    break;
  case 2:
    y=yAxis.copy();
    break;
  case 3:

    y=pressureAxis.copy();

    break;
  case 4:

    y=myFrameAxis.copy();

    break;
  }


  pushMatrix();
  translate(-startFrame, height);
  scale(1, -1);
  scale(width*1.0f/(endFrame - startFrame), 1);
  translate(0, 0);

  stroke(50, 120);
  //println(x);
  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) { 
    strokeWeight(pressureAxis.get(i)*0.08f);
    point(x.get(i), y.get(i));
    //println(x.get(i) + " "+ y.get(i));
    if (showFrameNumber) {
      pushStyle();
      fill(20);
      text(i, x.get(i), y.get(i));
      popStyle();
    }
  }
  popMatrix();
}



public void drawNormalDrawing(int startFrame, int endFrame, int step) {

  pushMatrix();
  pushStyle();
  stroke(0, 120);
  strokeWeight(1);
  noFill();

  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {
    beginShape();
    while (mousePress.get(i)==1 ) {
      strokeWeight(10.0f * sqrt(pressure.get(i)));
      vertex(x_pos.get(i), y_pos.get(i));

      i++;
    } 
    endShape();
  }  
  popStyle();
  popMatrix();
}

public void drawNormalDrawingZHeight(int startFrame, int endFrame, int step) {

  pushMatrix();
  pushStyle();
  strokeWeight(3);
  stroke(0, 120);
  noFill();

  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {

    beginShape();
    boolean out = false;
    while (mousePress.get(i)==1 && !out) {
     
      float b = map(pressure.get(i), 0, 1, 0, 500);
      curveVertex(x_pos.get(i), y_pos.get(i),  b);
      if(i< endFrame-1){
      i++;
      }
      else{
        out = true;
      }     
    } 
    endShape();
  }  
  popStyle();
  popMatrix();
}

public void drawDynamicDrawing(int startFrame, int endFrame, int step) {

  pushMatrix();
  stroke(0, 120);
  noFill();

  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {

    beginShape();
    while (mousePress.get(i)==1 ) {

      float b = map(pressure.get(i), 0, 1, 0, 100);
      brush.drawBrush(x_pos.get(i), y_pos.get(i), b);

      i++;
    } 
    endShape();
  }  

  popMatrix();
}

public void drawNormalDrawingConnectedSmooth(int startFrame, int endFrame, int step) {

  pushMatrix();
  pushStyle();
  stroke(0, 120);
  strokeWeight(2);
  noFill();
  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {
    //for (int i=1091; i<myFrame.size() && i< 1095; i+= step) {
    beginShape();
    while (mousePress.get(i)==1 ) {

      curveVertex(x_pos.get(i), y_pos.get(i));

      pushStyle();
      fill(20);
      //text(i, x_pos.get(i), y_pos.get(i));
      popStyle();
      i++;
    } 
    endShape();
  }  
  popStyle();
  popMatrix();
}

public void drawTimeMap() {
  tint(255, 100);
  for (int i = 0; i < myFrame.size(); i++) {
    float x = i%PApplet.parseInt(sqrt(myFrame.size()))*30;
    float y = i/PApplet.parseInt(sqrt(myFrame.size()))*30;
    pushMatrix();
    translate(x, y);
    float b = map(pressure.get(i), 0, 1, 0, 500);
    rotate(i);
    image(bill, 0, 0, b, b);
    popMatrix();
  }
}

public void drawPixelBased() {

  loadPixels();
  int frameInPixels = 96;
  for (int i = 0; i < myFrame.size(); i++) {

    int pix = i * frameInPixels;

    float r = map(x_pos.get(i), 0, 1024, 0, 255);
    float g = map(y_pos.get(i), 0, 512, 0, 255);
    float b = map(pressure.get(i), 0, 1, 0, 150);
    int c = color(0, b);
    // how many pixels should i skip ?
    for (int j=0; j<frameInPixels; j++) {
      pixels[pix+j]=color(255);
      pixels[pix+j] = c;
    }
    //int numPixels = int(map(pressure.get(i),0,1,0,60));  
    //i += numPixels;
  }
  updatePixels();
}


public void drawSpiral() {
  pushMatrix();
  translate(width/2, height/2);
  stroke(0, 120);
  strokeWeight(2);
  beginShape();
  int index=0;
  float angle = myFrame.size()*1.0f / TWO_PI;
  for (float i=0; i< revolutions * TWO_PI && index < myFrame.size(); i = i+step) {
    float t = i ;
    float x =  + t * cos(t) * (1 + pressure.get(index)*pressureX);
    float y =  + t * sin(t) * (1 + pressure.get(index)*pressureY);
    //float offSet = 2;
    //float u =  + (t+offSet) * cos(t+offSet);
    //float s =  + (t+offSet) * sin(t+offSet);
    curveVertex(x, y);
    //line(x, y, u, s);
    index++;
  }
  endShape();
  popMatrix();
}

public void drawVis1() {
  pushMatrix();
  translate(width/2, height/2);
  stroke(0, 50);
  strokeWeight(2);
  float angle = myFrame.size()*1.0f / TWO_PI;
  for (int i=0; i<myFrame.size() && i< 1752; i ++) {
    translate(-174, 147);
    rotate(angle);
    float len =  pressure.get(i)*1.0f*width/2;

    line(0, 0, len, 0);
  }
  popMatrix();
}




public void drawConcentricTriangles() {
  pushMatrix();
  translate(width/2, height/2);

  stroke(0, 50);
  strokeWeight(2);
  float angle = myFrame.size()*1.0f / TWO_PI;
  for (int i=0; i<myFrame.size() && i< 544; i ++) {
    translate(i, 0);
    rotate(angle);
    float len =  pressure.get(i)*1.0f*width/2;

    line(0, 0, len, 0);
  }
  popMatrix();
}

public void drawScore(int startFrame, int endFrame, int step) {

  pushMatrix();
  translate(0, height);
  scale(width*1.0f/(endFrame - startFrame), -0.8f);
  translate(-startFrame, 0);
  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {
    strokeWeight(y_pos.get(i)*0.08f);
    stroke(50, y_pos.get(i)*0.46f);
    point(myFrame.get(i), x_pos.get(i));
  }
  popMatrix();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "visualizeDrawingLogFile" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
