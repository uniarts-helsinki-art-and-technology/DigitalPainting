class Logger {

  PrintWriter log_file;

  Logger() {
  }

  void saveLog() {

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