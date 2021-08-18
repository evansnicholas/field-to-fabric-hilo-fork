// Implements a sliding "view" or panel in the UI, that is, a group of elements to be drawn on the main canvas, 
// which can slide in and out. Used for the splash screen and toolpanes.
class UIViewSlide extends UIGroup {

  static final int DEFAULT_ANIM_SPEED  = 1000;   
  
  static final int STATE_OPEN    = 0;
  static final int STATE_CLOSING = 1;
  static final int STATE_CLOSED  = 2;
  static final int STATE_OPENING = 3;

  int state = STATE_OPEN;

  float openX = 0;
  float openY = 0;
  float closedX = 0;
  float closedY = 0;

  int animSpeed     = DEFAULT_ANIM_SPEED;
  int timeAnimStart = 0;
  int timeAnimEnd   = 0;


  UIViewSlide () {
    super();
  }


  UIViewSlide (float x, float y, float w, float h) {
    super(x, y, w, h);
    this.openX = x;
    this.openY = y;
  }


  void setClosedPos(float closedX, float closedY) {
    this.closedX = closedX;
    this.closedY = closedY;
  }
  

  @Override
  void update() {
    super.update();
    
    int timeCurr = millis();
    float startX, startY, endX, endY;
    
    if (state == STATE_OPENING) {
      if (timeCurr >= timeAnimEnd) {
        state = STATE_OPEN;
        this.x = openX;
        this.y = openY;
        return;
      }
      startX = closedX;
      startY = closedY;
      endX   = openX;
      endY   = openY;
    } 
    else if (state == STATE_CLOSING) {
      if (timeCurr >= timeAnimEnd) {
        state = STATE_CLOSED;
        this.x = closedX;
        this.y = closedY;
        return;
      }
      startX = openX;
      startY = openY;
      endX   = closedX;
      endY   = closedY;
    }
    else {
      return;
    }
    
    float newX = easeOutQuart (millis(), timeAnimStart, timeAnimEnd, startX, endX);
    float newY = easeOutQuart (millis(), timeAnimStart, timeAnimEnd, startY, endY);
    this.x = newX;
    this.y = newY;
  }
  
  
  @Override
  void draw (PGraphics g) {
    if (state != STATE_CLOSED) super.draw(g);
  }
  

  void animateOpen() {
    if (state == STATE_OPENING || state == STATE_OPEN) return;

    timeAnimStart = millis();
    timeAnimEnd = timeAnimStart + animSpeed;
    state = STATE_OPENING;
  }


  void animateClose() {
    if (state == STATE_CLOSING || state == STATE_CLOSED) return;

    timeAnimStart = millis();
    timeAnimEnd = timeAnimStart + animSpeed;
    state = STATE_CLOSING;
  }
  
  
  void close() {
    state = STATE_CLOSED;
    this.x = closedX;
    this.y = closedY;
    return;
  }
  
  
  void open() {
    state = STATE_OPEN;
    this.x = openX;
    this.y = openY;
    return;
  }


  void toggle() {
    if (state == STATE_OPEN)
      this.animateClose();
    else if (state == STATE_CLOSED)
      this.animateOpen();
  }
}
