boolean  drawingScore, drawingSpiral, drawingVis1, drawingConcentricTriangles, drawingTimeMap, 
  drawingNormalDrawing, drawingNormalDrawingConnectedSmooth, drawingDynamicDrawing, drawingNormalDrawingZHeight, 
  drawingScatterPlot, showFrameNumber;


void drawNormalDrawingZHeight(PGraphics pg, int startFrame, int endFrame, int step){
  
  
  
  
  
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
