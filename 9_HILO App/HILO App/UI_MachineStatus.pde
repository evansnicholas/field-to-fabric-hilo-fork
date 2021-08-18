// Implements a the animated UI indicator for "machine status", i.e. a small circle which is:
//  - un-filled when the machine is disconnected
//  - filled when the machine is connected and stopped
//  - pulsating when the machine is connected and spinning
class UIMachineStatus extends UIBasicElement {
  
  final static int ANIM_TIME = 200;
  
  final static int STATE_OFFLINE = 0;
  final static int STATE_READY   = 1;
  final static int STATE_SPINNING = 2;
  
  int state = STATE_OFFLINE;
  
  UIMachineStatus() {
    super();
  }
  
  UIMachineStatus(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  @Override
  void draw(PGraphics g) {
    g.pushStyle();
    g.strokeWeight(2);
    g.stroke(uiColLight);
    if (state == STATE_OFFLINE) g.fill(uiColDark);
    else if (state == STATE_READY) g.fill(uiColLight);
    else {
      // when the machine is spinning, display a "pulsating" behaviour using a constrained sinewave
      float opacity = map(sin(millis()*0.008), -0.7, 0.2, 0, 255);
      opacity = constrain(opacity, 0, 255);
      g.fill(uiColLight, opacity);
    }
    g.ellipseMode(CORNER);
    g.ellipse(x, y, w, h);
    g.popStyle();
  }
}
