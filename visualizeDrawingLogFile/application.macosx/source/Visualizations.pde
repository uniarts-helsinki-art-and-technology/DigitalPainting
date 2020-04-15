boolean  drawingScore, drawingSpiral, drawingVis1, drawingConcentricTriangles, drawingTimeMap, 
  drawingNormalDrawing, drawingNormalDrawingConnectedSmooth, drawingDynamicDrawing, drawingNormalDrawingZHeight, 
  drawingScatterPlot, showFrameNumber;



void drawScatterPlot(int dimX, int dimY, int startFrame, int endFrame, int step) {

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
  scale(width*1.0/(endFrame - startFrame), 1);
  translate(0, 0);

  stroke(50, 120);
  //println(x);
  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) { 
    strokeWeight(pressureAxis.get(i)*0.08);
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



void drawNormalDrawing(int startFrame, int endFrame, int step) {

  pushMatrix();
  pushStyle();
  stroke(0, 120);
  strokeWeight(1);
  noFill();

  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {
    beginShape();
    while (mousePress.get(i)==1 ) {
      strokeWeight(10.0 * sqrt(pressure.get(i)));
      vertex(x_pos.get(i), y_pos.get(i));

      i++;
    } 
    endShape();
  }  
  popStyle();
  popMatrix();
}

void drawNormalDrawingZHeight(int startFrame, int endFrame, int step) {

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

void drawDynamicDrawing(int startFrame, int endFrame, int step) {

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

void drawNormalDrawingConnectedSmooth(int startFrame, int endFrame, int step) {

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

void drawTimeMap() {
  tint(255, 100);
  for (int i = 0; i < myFrame.size(); i++) {
    float x = i%int(sqrt(myFrame.size()))*30;
    float y = i/int(sqrt(myFrame.size()))*30;
    pushMatrix();
    translate(x, y);
    float b = map(pressure.get(i), 0, 1, 0, 500);
    rotate(i);
    image(bill, 0, 0, b, b);
    popMatrix();
  }
}

void drawPixelBased() {

  loadPixels();
  int frameInPixels = 96;
  for (int i = 0; i < myFrame.size(); i++) {

    int pix = i * frameInPixels;

    float r = map(x_pos.get(i), 0, 1024, 0, 255);
    float g = map(y_pos.get(i), 0, 512, 0, 255);
    float b = map(pressure.get(i), 0, 1, 0, 150);
    color c = color(0, b);
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


void drawSpiral() {
  pushMatrix();
  translate(width/2, height/2);
  stroke(0, 120);
  strokeWeight(2);
  beginShape();
  int index=0;
  float angle = myFrame.size()*1.0 / TWO_PI;
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

void drawVis1() {
  pushMatrix();
  translate(width/2, height/2);
  stroke(0, 50);
  strokeWeight(2);
  float angle = myFrame.size()*1.0 / TWO_PI;
  for (int i=0; i<myFrame.size() && i< 1752; i ++) {
    translate(-174, 147);
    rotate(angle);
    float len =  pressure.get(i)*1.0*width/2;

    line(0, 0, len, 0);
  }
  popMatrix();
}




void drawConcentricTriangles() {
  pushMatrix();
  translate(width/2, height/2);

  stroke(0, 50);
  strokeWeight(2);
  float angle = myFrame.size()*1.0 / TWO_PI;
  for (int i=0; i<myFrame.size() && i< 544; i ++) {
    translate(i, 0);
    rotate(angle);
    float len =  pressure.get(i)*1.0*width/2;

    line(0, 0, len, 0);
  }
  popMatrix();
}

void drawScore(int startFrame, int endFrame, int step) {

  pushMatrix();
  translate(0, height);
  scale(width*1.0/(endFrame - startFrame), -0.8);
  translate(-startFrame, 0);
  for (int i=startFrame; i<myFrame.size() && i< endFrame; i+= step) {
    strokeWeight(y_pos.get(i)*0.08);
    stroke(50, y_pos.get(i)*0.46);
    point(myFrame.get(i), x_pos.get(i));
  }
  popMatrix();
}
