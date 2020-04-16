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
      .setColorBackground(color(255, 40))     
      .linebreak().linebreak();
    ;

    cp5.addSlider("step").plugTo(parent).setRange(1, 300).setSize(300, 10).linebreak();
    ;



    cp5.addButton("loadLogFile").plugTo(parent).linebreak();
  }

  void saveImage() {  
    screen.save(path + "/savedImages/drawing_" + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }




  void draw() {
    background(20);

    text("click and drag to rotate the camera", 10, 100);
    text("mouse wheel to zoom", 10, 120);
    text("centre mouse button for panning", 10, 140);
  }
  void controlEvent(ControlEvent theControlEvent) {


    if (theControlEvent.isFrom("range_frames")) {
      // min and max values are stored in an array.
      // access this array with controller().arrayValue().
      // min is at index 0, max is at index 1.
      start = int(theControlEvent.getController().getArrayValue(0));
      end = int(theControlEvent.getController().getArrayValue(1));
    }
  }
}
