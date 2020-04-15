import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import peasy.*; 
import peasy.org.apache.commons.math.*; 
import peasy.org.apache.commons.math.geometry.*; 
import shiffman.box2d.*; 
import nervoussystem.obj.*; 
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

public class visualizeDrawing3D extends PApplet {









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

public void settings() {
  size(900, 900, P3D);
  smooth(8);
}

public void setup() {

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

public void draw() {

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


public void keyPressed() {

  if (key == 's') {
    screen.save("drawing " + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }
  
  if (key == 'r') {
    record = true;
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
    cam.reset();
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
      .setColorBackground(color(255, 40))     
      .linebreak().linebreak();
    ;

    cp5.addSlider("step").plugTo(parent).setRange(1, 300).setSize(300, 10).linebreak();
    ;



    cp5.addButton("loadLogFile").plugTo(parent).linebreak();
  }

  public void saveImage() {  
    screen.save("savedImages/drawing_" + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }




  public void draw() {
    background(20);

    text("click and drag to rotate the camera", 10, 100);
    text("mouse wheel to zoom", 10, 120);
    text("centre mouse button for panning", 10, 140);
  }
  public void controlEvent(ControlEvent theControlEvent) {


    if (theControlEvent.isFrom("range_frames")) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.
      start = PApplet.parseInt(theControlEvent.getController().getArrayValue(0));
      end = PApplet.parseInt(theControlEvent.getController().getArrayValue(1));
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


public void drawNormalDrawingZHeight(PGraphics pg, int startFrame, int endFrame, int step){
  
  
  
  
  
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "visualizeDrawing3D" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
