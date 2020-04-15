import codeanticode.tablet.*;
import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

Tablet tablet;

boolean enableKinect = false;
boolean kinectDebug = false;

boolean showCursor = false;

PVector tiltTablet;
PVector previousKinectPos = new PVector(0, 0);

PImage img;

PGraphics canvas;

boolean live = false;

Brush brush;
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

  kinect = new Kinect(this);
  tracker = new KinectTracker();

  // Leap motion
  setupLeap();

  tablet = new Tablet(this); 
  stroke(0, 50);
  background(255);

  brush = new Brush(1, 1.0, 1.0, 1.0, 1.0);

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

  // osc tilt control
  if (!useAccelerometer || !useLeap) {
    tiltTablet.x = cf.s.getArrayValue()[0];
    tiltTablet.y = cf.s.getArrayValue()[1];
  }


  // use kinect
  if (enableKinect) {
    // Run the tracking analysis
    tracker.track();

    if (kinectDebug) {
      background(255);
      // Let's draw the raw location
      PVector kinectPos = tracker.getPos();
      // Show the image
      tracker.display(); 
      fill(50, 100, 250, 200);
      noStroke();
      ellipse(kinectPos.x, kinectPos.y, 10, 10);
      return;
    }
  }




  if (useLeap) {

    canvas.beginDraw();
    drawLeap();

    if (!inCanvas()) {
      //println(frameCount + " OUT");
      live = false;
    }

    if (inCanvas() && !live) {

      endLeap = new PVector(handPositionXY.x, handPositionXY.y);

      println(endLeap + " endLeap");

      live = true;
    }


    if (inCanvas() && live) {
      // read values from LEAP
      startLeap = new PVector(endLeap.x, endLeap.y);
      endLeap = new PVector(handPositionXY.x, handPositionXY.y);

      float distance = startLeap.dist(endLeap);

      tiltTablet.x = constrain(map(handRoll, -80, 80, -1., 1.), -1., 1.);
      tiltTablet.y = constrain(map(handPitch, -60, 60, -1., 1.), -1., 1.);

      cf.s.setValue(tiltTablet.x, tiltTablet.y);

      if (handPinch > 0.01) {
        globalBrushSize = map(handPinch, 0., 1., 10., 1.);   

        if (distance >= 1) {
          if (startLeap.x > endLeap.x) {
            endLeap.x = endLeap.x+1;
          } else if (startLeap.x < endLeap.x) {
            endLeap.x = endLeap.x-1 ;
          }
          if (startLeap.y > endLeap.y) {
            endLeap.y = endLeap.y+1;
          } else if (startLeap.y < endLeap.y) {
            endLeap.y = endLeap.y-1 ;
          }   
          canvas.strokeWeight(globalBrushSize);
          canvas.stroke(0);
          canvas.line(startLeap.x, startLeap.y, endLeap.x, endLeap.y);
        } else {
        } 
        float mass = constrain(map(distance, 0, 5, 10, 1), 1, 50);

        //println("mass " + mass);

        brush.dripping.addDrop(random(0, 10), endLeap.x, endLeap.y, globalBrushSize);
      } else {
        globalBrushSize = 0;

        showCursor = true;
        // cursor
      }
    }
    canvas.endDraw();
  }




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
  } else {
    // using kinect
    if (enableKinect) {

      // read values from mouse or tablet
      PVector start = previousKinectPos;
      PVector end = tracker.getPos();

      if (tracker.getClosestP()<1000) {

        //start = previousKinectPos;
        //end = tracker.getPos();

        float distance = start.dist(end);

        // TODO: Change to variable to measure depth
        println(tracker.getClosestP());
        globalBrushSize = map(tracker.getClosestP(), 0, 600, 100, 1);

        if (distance >= 1) {
          if (start.x > end.x) {
            end.x = end.x+1;
          } else if (start.x < end.x) {
            end.x = end.x-1 ;
          }
          if (start.y > end.y) {
            end.y = end.y+1;
          } else if (start.y < end.y) {
            end.y = end.y-1 ;
          }   

          strokeWeight(globalBrushSize);
          stroke(0, 255);
          if (distance<50) {
            line(start.x, start.y, end.x, end.y);
            //  point(start.x, start.y);
          }
        } else {
        }
      }
      //  float mass = constrain(map(distance, 0, 5, 10, 1), 1, 50);
      //println("mass " + mass);
      // dripping.addDrop(random(1, mass), end.x, end.y, globalBrushSize);
      // update start position
      previousKinectPos=end;
    } else {
      println("kinect not enabled");
    }
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
  if (key == 'k') {
    enableKinect=!enableKinect;
    println("hello kinect: "+ enableKinect);
  }
  if (key == 'd') {
    kinectDebug=!kinectDebug;
    println("kinect debug: "+kinectDebug );
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
