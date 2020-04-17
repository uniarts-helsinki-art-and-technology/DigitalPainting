import controlP5.*;

ControlP5 cp5;

String idParticipant = "";

String name = "";

void setupControls(){

cp5 = new ControlP5(this);
ControlFont font = new ControlFont(loadFont(fontName), 16);
  
                 
  cp5.addTextfield("name")
     .setPosition(leftMargin,170)
     .setSize(200,40)
     .setFont(font)
     .setAutoClear(false)
     .setLabel("Title (optional)");
     ;
  cp5.addButton("rec")
    .setPosition(leftMargin,250)
    .setSize(195, 30)
    .setCaptionLabel("Start")
    .setFont(font)
  ;
    cp5.addButton("stopRec")
    .setPosition(leftMargin,290)
    .setSize(195, 30)
    .setCaptionLabel("Stop")
    .setFont(font)
  ;
    cp5.addButton("quitApp")
    .setPosition(leftMargin,330)
    .setSize(195, 30)
    .setCaptionLabel("Quit")
    .setFont(font)
  ;  
  
}

public void name(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
  if(!recording){
  idParticipant = "";
  idParticipant = theText;
  }
}

public void rec(int theValue) {
  println("Recording started"+theValue);
  startRecording();
}

public void stopRec(int theValue) {
  println("Recording stopped"+theValue);
  stoptRecording();
}

public void quitApp(int theValue) {
  println("Quitting... "+theValue);
  quitApplication();
}
