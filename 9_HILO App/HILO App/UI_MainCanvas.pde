// Implements the app's main canvas, based on a group of UIViewFade elements.
// Indexes the app's "views" (or modes) and supports fading transitions between each.
// The app's views are indexed statically, and must be inserted in the correct order 
// when the app is initialized - see the uiSetup() function. 
class UIMainCanvas extends UIGroup {
  
  static final int VIEW_WELCOME  = 0;
  static final int VIEW_FIBRE    = 1;
  static final int VIEW_SPIN     = 2;
  static final int VIEW_CONNECT  = 3;
  static final int VIEW_SPINNER  = 4;
  
  int nextViewID = 0;
  UIViewFade currView;
  
  int mode = VIEW_WELCOME;
  
  UIMainCanvas() {
    super();
  }

  UIMainCanvas(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  @Override
  void draw(PGraphics g) {
    //draw the background
    g.noStroke();
    g.fill(colBackground);
    g.rect(x, y, w, h);
    // draw background image, if any
    if (imgBackground != null) {
      g.image(imgBackground, x, y);
    }
    // draw the current view
    g.pushMatrix();
    g.translate(x, y);
    currView.draw(g);
    g.popMatrix();
  }
  
  @Override
  boolean touch(float x, float y) {
    if (currView.state == UIViewFade.STATE_VISIBLE)
      return currView.touch(x -this.x, y -this.y);
    return false;
  }
  
  @Override
  boolean drag(float prevX, float prevY, float newX, float newY) {
    if (currView.state == UIViewFade.STATE_VISIBLE)
      return currView.drag(prevX -this.x, prevY -this.y, newX -this.x, newY -this.y);
    return false;
  }
  
  @Override
  boolean release(float x, float y) {
    return currView.release(x -this.x, y -this.y);
  }
  
  @Override
  boolean scroll(float x, float y, float amount) {
    return currView.scroll(x -this.x, y -this.y, amount);
  }
  
  void switchTo(int viewID) {
    nextViewID = viewID;
    currView.fadeOut();
  }
  
  void onViewFadeIn() {
    mode = nextViewID;
  }
  
  void onViewFadeOut() {
    currView = (UIViewFade)elements.get(nextViewID);
    currView.fadeIn();
  }
}
