

class Brush {

   // position, velocity, and acceleration 
  PVector position;
  PVector velocity;
  PVector acceleration;

  // Mass is tied to size
  float mass;

  float life;

  boolean dead = false;
  
  float brushSize;

  Brush(float x, float y) {
    
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    
  }

  void updateBrush() {
  }

  void drawBrush() {
  }
  
    void drawBrush(float x, float y,float _pressure) {
      
      position.set(x,y);
      pushMatrix();
      pushStyle();
      stroke(0,120);
      translate(x,y);
      
      for(int i=0;i<_pressure;i++){   
        
       point(random(-_pressure,_pressure),random(-_pressure,_pressure) );
      }
      
      popStyle();
      popMatrix();
      
  }
  
  
}
