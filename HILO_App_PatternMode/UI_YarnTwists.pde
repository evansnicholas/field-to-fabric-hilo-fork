// Implements an animated "yarn twists" UI element, for use in the spinning view/mode.
// The "yarn" is drawn as two sinewaves, with the frequency indeicating 
// amount of twist and amplitude indicating yarn thickness.
class UIYarnTwists extends UIBasicElement {
  
  float thickness = 1.0; // percentage
  int   steps = 500;
  float frequency = 10;
  float offset = 0;
  boolean isAnimating = false;

  
  UIYarnTwists () {
    super();
  }


  UIYarnTwists (float x, float y, float w, float h) {
    super(x, y, w, h);
    steps = (int)(w*2);
  }

  
  @Override
  void update() {
    if (isAnimating) {
      offset = millis()*0.0002*frequency;
    }
  }
  
  
  @Override
  void draw (PGraphics g) {
    float twistHeight = this.h * thickness;
    float offsetH = (this.h - twistHeight)/2.0;
    
    g.pushStyle();
    g.strokeWeight(4);
    g.stroke(uiColDark);
    float offsetA = offset;
    float offsetB = offsetA + PI;
    drawSineWave(g, x, y+offsetH, w, twistHeight, frequency, offsetA, (int)(w*2));
    drawSineWave(g, x, y+offsetH, w, twistHeight, frequency, offsetB, (int)(w*2));
    g.popStyle();
  }
  
}
