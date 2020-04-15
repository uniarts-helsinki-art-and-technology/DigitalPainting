/**
 * oscP5sendreceive by andreas schlegel
 * example shows how to send and receive osc messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag());

  if (theOscMessage.checkAddrPattern("/accelerometer/gravity/x")==true) {  
    
    tiltTablet.x  = map(theOscMessage.get(0).floatValue(), -1.8, 1.8, -1.,1.);
    
     tiltTablet.x = constrain(tiltTablet.x,-1., 1.);
    
    if(tiltTablet.x > 0){
      tiltTablet.x = sqrt(abs(tiltTablet.x));
    }
    else{
      tiltTablet.x = -sqrt(abs(tiltTablet.x));
    }
    
   cf.s.setValue(tiltTablet.x, tiltTablet.y);

  }
  
  if (theOscMessage.checkAddrPattern("/accelerometer/gravity/y")==true) {     
    tiltTablet.y =  map(theOscMessage.get(0).floatValue(), -1.8, 1.8, -1.,1.);
    
     tiltTablet.y = constrain(tiltTablet.y, -1., 1.);
    
    
        if(tiltTablet.y > 0){
      tiltTablet.y = sqrt(abs(tiltTablet.y));
    }
    else{
      tiltTablet.y = -sqrt(abs(tiltTablet.y));
    }
    
       cf.s.setValue(tiltTablet.x, tiltTablet.y);

  }
  
   if (theOscMessage.checkAddrPattern("/brush1/position")==true) {    
     
     
   }
  
  if (theOscMessage.checkAddrPattern("/brush2/position")==true) {    
     
     
   }
  
}
