/** Defines an interface for UI elements in the app. */
interface UIElement {

  /** Draw the element onto a canvas. */
  void draw(PGraphics g);
  /** Update the element's animation. */
  void update();
  /** Signal a touch event, return the resulting action. */
  int touch(float x, float y);
  /** Signal a drag event, return the resulting action. */
  int drag(float prevX, float prevY, float newX, float newY);
  /** Signal a release event, return the resulting action. */
  int release(float x, float y);
  /** Test whether the provided coordinates are inside the element. */
  boolean isInside(float pX, float pY);

  /** Set the element's position. */
  void setPos(float x, float y);
  /** Set the element's dimensions. */
  void setSize(float w, float h);
  /** Set the element's position and dimensions. */
  void setRect(float x, float y, float w, float h);

  // selectors for position and dimensions
  float x();
  float y();
  float w();
  float h();
}


/**
 * Implements a basic element conforming to the UIElement interface.
 * Most UI classes will extend this one.
 */
class UIBasicElement implements UIElement {
  protected float x;
  protected float y;
  protected float w;
  protected float h;

  UIBasicElement() {
  }

  UIBasicElement (float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void draw(PGraphics g) {}

  void update() {}

  int touch(float x, float y) { return -1; }

  int drag(float prevX, float prevY, float newX, float newY) { return -1; }

  int release(float x, float y) { return -1; }

  float x() { return this.x; }
  float y() { return this.y; }
  float w() { return this.w; }
  float h() { return this.h; }

  boolean isInside(float pX, float pY) {
    return (pX > x && pX < (x+w) && pY > y && pY < (y+h));
  }

  void setPos(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void setSize(float w, float h) {
    this.w  = w;
    this.h = h;
  }

  void setRect(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  /** Utility function for subclasses to handle touch events in nested elements. */
  protected int touch(ArrayList<UIElement> elements, float x, float y) {
    int result = -1;
    for (UIElement element : elements) {
      result = element.touch(x, y);
      if (result >= 0) return result;
    }
    return result;
  }

  /** Utility function for subclasses to handle drag events in nested elements. */
  protected int drag(ArrayList<UIElement> elements, float prevX, float prevY, float newX, float newY) {
    int result = -1;
    for (UIElement element : elements) {
      result = element.drag(prevX, prevY, newX, newY);
      if (result >= 0) return result;
    }
    return result;
  }

  /** Utility function for subclasses to handle release events in nested elements. */
  protected int release(ArrayList<UIElement> elements, float x, float y) {
    int result = -1;
    for (UIElement element : elements) {
      int action = element.release(x, y);
      if (result < 0 && action >= 0)
        result = action;
    }
    return result;
  }
}
