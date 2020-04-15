import controlP5.*;
ControlFrame cf;
ControlP5 cp5;

import processing.pdf.*;
import processing.svg.*;

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
      .setRange(0.0, 10.).setValue(1).setSize(100,10).setPosition(160,200);
      ;
    cp5.addSlider("blurFactor").plugTo(parent)
      .setRange(0.0, 10.).setValue(0.).setSize(100,10).setPosition(320,200).linebreak();
    ;

    cp5.addToggle("drawingScatterPlot").plugTo(parent).setValue(false).setPosition(10,240).linebreak();
    cp5.addToggle("showFrameNumber").plugTo(parent).setValue(false).setPosition(150,240).linebreak();
    cp5.addToggle("drawingScore").plugTo(parent).setValue(false).linebreak();
    cp5.addToggle("drawingSpiral").plugTo(parent).setValue(false).linebreak();

    cp5.addSlider("revolutions").plugTo(parent).setRange(1, 100).setSize(120,10).setPosition(90,340);
    cp5.addSlider("pressureX").plugTo(parent)
      .setRange(0.0, 100).setPosition(270,320).linebreak();
    cp5.addSlider("pressureY").plugTo(parent)
      .setRange(0.0, 100).setPosition(270,340);
      
    cp5.addToggle("drawingVis1").plugTo(parent).setValue(false).setPosition(10,380).linebreak();
    cp5.addToggle("drawingConcentricTriangles").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingTimeMap").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingNormalDrawing").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingDynamicDrawing").plugTo(parent).setValue(false).linebreak();

    cp5.addToggle("drawingNormalDrawingConnectedSmooth").plugTo(parent).setValue(false).linebreak();
    cp5.addToggle("drawingNormalDrawingZHeight").plugTo(parent).setValue(false).linebreak();
  }

  void saveImage() {  
    screen.save("savedImages/drawing_" + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }



  void saveLog() {

    logger.saveLog();
  }
  void draw() {
    background(20);
  }
  void controlEvent(ControlEvent theControlEvent) {
    //parent.redraw();
    //println("received event");
    if(theControlEvent.isFrom(xDim)) {
      if(int(theControlEvent.getValue())>0){
      xDimension = int(theControlEvent.getValue());
        }
    }
        if(theControlEvent.isFrom(yDim)) {
      if(int(theControlEvent.getValue())>0){
      yDimension = int(theControlEvent.getValue());
      }
    }
    
    
    if (theControlEvent.isFrom("range_frames")) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.
      start = int(theControlEvent.getController().getArrayValue(0));
      end = int(theControlEvent.getController().getArrayValue(1));
    }
    if (theControlEvent.isFrom("savePDF")) {
      savePDF=true;
    }
    if (theControlEvent.isFrom("saveSVG")) {
      saveSVG=true;
    }
  }
}
