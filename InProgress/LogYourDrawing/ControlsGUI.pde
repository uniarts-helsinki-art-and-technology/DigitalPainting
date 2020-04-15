import controlP5.*;
ControlFrame cf;
ControlP5 cp5;

float waterDilution, globalBrushSize, zoom_factor;
boolean useAccelerometer, useLeap, useTablet;


class ControlFrame extends PApplet {

  int w, h;
  PApplet parent;
  ControlP5 cp5;

  Slider2D s, pan2D;

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
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);
    s = cp5.addSlider2D("tilt")
      .setPosition(10, 10)
      .setSize(100, 100)
      .setMinMax(-1, -1, 1, 1)
      .setValue(0.00, 0.00)
      //.disableCrosshair()
      ;

    pan2D = cp5.addSlider2D("pan")
      .setPosition(150, 10)
      .setSize(100, 100)
      .setMinMax(-canvas.width/2, -canvas.height/2, canvas.width/2, canvas.height/2)
      .setValue(0.00, 0.00)
      //.disableCrosshair()
      ;

    cp5.addSlider("waterDilution").plugTo(parent)
      .setPosition(10, 150)
      .setRange(0.05, 1)
      ;
    cp5.addSlider("globalBrushSize").plugTo(parent)
      .setPosition(10, 190)
      .setRange(1, 10)
      ;

    cp5.addToggle("useAccelerometer").plugTo(parent).setValue(false)
      .setPosition(10, 240);

  cp5.addToggle("useTablet").plugTo(parent).setValue(false)
      .setPosition(90, 240);

    cp5.addToggle("enableKinect").plugTo(parent).setValue(false)
      .setPosition(150, 240);

    cp5.addToggle("useLeap").plugTo(parent).setValue(false)
      .setPosition(230, 240);


    cp5.addSlider("hand_Pinch").setRange(0., 1.).setSize(100, 20).setPosition(10, 350);

    cp5.addSlider("tabletPressure").setRange(0., 1.).setSize(100, 20).setPosition(150, 190);


    cp5.addSlider("zoom_factor").plugTo(parent).setRange(0.25, 1.).setValue(1.9).setSize(250, 20).setPosition(10, 300);
    
    cp5.addBang("logAndExit").plugTo(parent).setSize(70, 70).setPosition(280, 20).setLabel("Save Log File and Exit");
    
    
  }
  
  void logAndExit(){
    
    logger.log_file.flush(); // Writes the remaining data to the file
    logger.log_file.close(); // Finishes the file
    exit(); // Stops the program
    
  }
  

  void draw() {
    background(190);
  }
}
