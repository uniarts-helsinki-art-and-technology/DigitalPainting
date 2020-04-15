class Logger {

  PrintWriter log_file;

  Logger() {

    // Create a new file in the sketch directory
    log_file = createWriter("logFile_" +year()+month()+day()+hour()+minute() + ".txt");
  }

  void update() {

    int mouseDown = 0;
    if(mousePressed){
      mouseDown = 1;
    }

    
    log_file.println(frameCount + "\t" + millis() + "\t" + brush.getEnd().x + "\t" + brush.getEnd().y
      + "\t" + tablet.getPressure() + "\t" + mouseDown);
  }
}
