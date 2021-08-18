// Implements the UI slider elements. 
// The slider's range of values correspond to the knob's position, from 0 to 100. 
class UISlider extends UIBasicElement {

  float posSlider = 0;
  float posKnob   = 0;
  
  color colSlider = 255;
  float lineWeight = 3;
  float knobSize   = 14;
  
  boolean selected = false;

  
  UISlider () {
    super();
    updateFromSliderPos();
  }

  UISlider (float x, float y, float w, float h) {
    super(x, y, w, h);
    updateFromSliderPos();
  }
  
  void setPosSlider(float newPos) {
    posSlider = constrain(newPos, 0, 100);
    updateFromSliderPos();
  }
  
  @Override
  void update() {
    updateFromKnobPos();
  }
  
  @Override
  void draw(PGraphics g) {
    float lineH = y+(h/2);
        
    g.pushStyle();
    g.stroke(colSlider);
    g.strokeWeight(lineWeight);
    g.line(x, lineH, x+w, lineH);
    g.noStroke();
    g.fill(colSlider);
    g.ellipse(posKnob, lineH, knobSize, knobSize);
    g.popStyle();
  }
  
  @Override
  boolean touch(float x, float y) { 
    if (this.isInside(x, y)) {
      selected = true;
      posKnob = x;
      updateFromKnobPos();
      if (callbackHandler != null) callbackHandler.callbackUISliderSelected(this.id, posSlider);
      return true;
    }
    return false;
  }
  
  @Override
  boolean drag(float prevX, float prevY, float newX, float newY) { 
    if (selected) {
      float dX = newX - prevX;
      posKnob += dX;
      updateFromKnobPos();
      if (callbackHandler != null) callbackHandler.callbackUISliderDragged(this.id, posSlider);
      return true;
    }
    return false; 
  }

  @Override
  boolean release(float x, float y) { 
    if (selected) {
      if (callbackHandler != null) callbackHandler.callbackUISliderReleased(this.id, posSlider);
      selected = false;
      println("Slider released");
      return true;
    }
    return false; 
  }
  
  protected void updateFromKnobPos() {
    posKnob = constrain(posKnob, x + (knobSize/2) -2, x+w - (knobSize/2) +2);
    posSlider = constrain(map(posKnob, x + (knobSize/2), x+w - (knobSize/2), 0, 100), 0, 100);
  }
  
  protected void updateFromSliderPos() {
    posKnob = map(posSlider, 0, 100, x + (knobSize/2) -2, x+w - (knobSize/2) +2);
  }
}
