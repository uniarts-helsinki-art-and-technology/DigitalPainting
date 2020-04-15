import codeanticode.tablet.*;

Tablet tablet;

boolean enableKinect = false;
boolean kinectDebug = false;

boolean showCursor = false;

PVector tiltTablet;
PVector previousKinectPos = new PVector(0, 0);

PImage img;

PGraphics canvas;

boolean live = false;

Logger logger;


void settings() {
  size(1024, 512);
}

void setup() {

  canvas = createGraphics(4096, 2048);
  canvas.beginDraw();
  canvas.smooth();
  canvas.background(255);  
  canvas.endDraw();


  tablet = new Tablet(this); 
  stroke(0, 50);
  background(255);

  tiltTablet = new PVector(0, 0);
  img = loadImage("texture.png");

  cf = new ControlFrame(this, 400, 400, "Controls");
  surface.setLocation(420, 10);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 7400);

  logger = new Logger();
}



boolean inCanvas() {
  boolean in = false;
  if (width - handPositionXY.x*zoom_factor - cf.pan2D.getArrayValue()[0]*zoom_factor < 0) {

    in = false;
  } else if ( handPositionXY.x*zoom_factor + cf.pan2D.getArrayValue()[0]*zoom_factor < 0) {

    in = false;
  } else if (height - handPositionXY.y*zoom_factor - cf.pan2D.getArrayValue()[1]*zoom_factor < 0) {

    in = false;
  } else if ( handPositionXY.y*zoom_factor + cf.pan2D.getArrayValue()[1]*zoom_factor < 0) {

    in = false;
  } else {
    in = true;
  }
  return in;
}

void draw() {


  logger.update();

  background(255);
  //translate(-width/2 ,-height/2 );
  translate(cf.pan2D.getArrayValue()[0]*zoom_factor, cf.pan2D.getArrayValue()[1]*zoom_factor);
  scale(zoom_factor);  

  
  if (!enableKinect) {

    canvas.beginDraw();
    if(useTablet){
    cf.cp5.getController("tabletPressure").setValue(tablet.getPressure());
    }
 
    if (mousePressed) {
      // read values from mouse or tablet

      brush.setStart(new PVector(pmouseX, pmouseY));
      brush.setEnd(new PVector(mouseX, mouseY));

      float distance = brush.getStart().dist(brush.getEnd());

      globalBrushSize = 10.0 * sqrt(tablet.getPressure());

      if (distance >= 1) {
        if (brush.getStart().x > brush.getEnd().x) {
          brush.getEnd().x = brush.getEnd().x+1;
        } else if (brush.getStart().x < brush.getEnd().x) {
          brush.getEnd().x = brush.getEnd().x-1 ;
        }
        if (brush.getStart().y > brush.getEnd().y) {
          brush.getEnd().y = brush.getEnd().y+1;
        } else if (brush.getStart().y < brush.getEnd().y) {
          brush.getEnd().y = brush.getEnd().y-1 ;
        }   
        canvas.strokeWeight(globalBrushSize);
        canvas.stroke(0, 255);
        canvas.line(brush.getStart().x, brush.getStart().y, brush.getEnd().x, brush.getEnd().y);
      } else {
      } 
      float mass = constrain(map(distance, 0, 5, 10, 1), 1, 10);

      //println("mass " + mass);

      brush.dripping.addDrop(random(1, mass), brush.getEnd().x, brush.getEnd().y, globalBrushSize);
    } 
    canvas.endDraw();
  } 
  //println(dripping.getSize());

  stroke(0);
  strokeWeight(15);
  noFill();
  rect(0, 0, canvas.width, canvas.height);

  image(canvas, 0, 0);

  if (showCursor) {
    pushMatrix();
    translate(brush.getEnd().x, brush.getEnd().y);
    strokeWeight(3);
    line(-5, -5, 5, 5);
    popMatrix();
  }
}


void keyPressed() {
  //clear canvas
  if (key == 'c') {
    canvas.beginDraw();
    canvas.background(255);
    canvas.endDraw();
  }
 

  if (key == 's') {
    canvas.save("drawing " + year() + day() + hour() + minute() + second()+ ".png" );
    println("FRAME SAVED");
  }
  if (key == 'l') {
    logger.log_file.flush(); // Writes the remaining data to the file
    logger.log_file.close(); // Finishes the file
    exit(); // Stops the program
  }
}
