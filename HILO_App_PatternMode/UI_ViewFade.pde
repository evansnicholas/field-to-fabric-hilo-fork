// Implements a "view" in the UI, that is, a group of elements to be drawn on the main canvas, 
// which can be faded in and out during transitions between views.
class UIViewFade extends UIGroup {
  static final int ANIM_SPEED  = 500; 
  
  static final int STATE_VISIBLE  = 0;
  static final int STATE_FADE_OUT = 1;
  static final int STATE_HIDDEN   = 2;
  static final int STATE_FADE_IN  = 3;
  
  int state = STATE_VISIBLE;
  
  int timeAnimStart = 0;
  int timeAnimEnd   = 0;
  
  float opacity = 0;
  
  
  UIViewFade() {
    super();
  }


  UIViewFade(float x, float y, float w, float h) {
    super(x, y, w, h);
  }

  
  @Override
  void update() {
    if (state == STATE_HIDDEN) return;
    super.update();
    
    int timeCurr = millis();
    
    if (state == STATE_FADE_IN) {
      if (timeCurr >= timeAnimEnd) {
        state = STATE_VISIBLE;
        opacity = 0;
        if (callbackHandler != null) callbackHandler.callbackUIViewFadeIn();
        return;
      }
      opacity = easeOutQuart (millis(), timeAnimStart, timeAnimEnd, 255, 0);   
    }
    else if (state == STATE_FADE_OUT) {
      if (timeCurr >= timeAnimEnd) {
        state = STATE_HIDDEN;
        opacity = 255;
        if (callbackHandler != null) callbackHandler.callbackUIViewFadeOut();
        return;
      }
      opacity = easeOutQuart (millis(), timeAnimStart, timeAnimEnd, 0, 255);   
    }
  }
  
  
  @Override
  void draw(PGraphics g) {
    if (state == STATE_HIDDEN) {
      g.pushStyle();
      g.noStroke();
      g.fill(colBackground);
      g.rect(x, y, w, h);
      g.popStyle();
      return;
    }
    super.draw(g);
    g.pushStyle();
    g.noStroke();
    g.fill(colBackground, opacity);
    g.rect(x, y, w, h);
    g.popStyle();
  }
  
  
  // Start fading-in the view (if not already fading in).
  void fadeIn() {
    if (state == STATE_FADE_IN) return;

    opacity = 255;
    timeAnimStart = millis();
    timeAnimEnd = timeAnimStart + ANIM_SPEED;
    state = STATE_FADE_IN;
  }


  // Start fading-out the view (if not already fading out).
  void fadeOut() {
    if (state == STATE_FADE_OUT) return;

    opacity = 0;
    timeAnimStart = millis();
    timeAnimEnd = timeAnimStart + ANIM_SPEED;
    state = STATE_FADE_OUT;
  }
 
 
  // Instantly toggle the view's visibility, with no fading.
  void toggle() {
    if (state == STATE_VISIBLE)
      this.fadeOut();
    else if (state == STATE_HIDDEN)
      this.fadeIn();
  }
  
}
