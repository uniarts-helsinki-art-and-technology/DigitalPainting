import controlP5.*;

ControlP5 cp5;

String idParticipant = "";

String name = "";

void setupControls(){

cp5 = new ControlP5(this);
  
  cp5.addTextfield("idParticipant")
     .setPosition(20,100)
     .setSize(200,40)
     .setFont(createFont("arial",20))
     .setFocus(true)
     .setColor(color(255,0,0))
     .setAutoClear(false)
     ;
                 
  cp5.addTextfield("name")
     .setPosition(20,170)
     .setSize(200,40)
     .setFont(createFont("arial",20))
     .setAutoClear(false)
     ;

}

public void idParticipant(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
  if(!recording){
  idParticipant = theText;
  }
}
