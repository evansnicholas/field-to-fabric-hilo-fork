// UI - Base Classes
// This tab contains the interface and base classes for the UI elements used in the app,
// as well as for the handler for UI element callbacks.


// Defines an interface for UI elements in the app.
interface UIElement {

  // a null identifier, for non-interactive elements.
  static final int ID_UNKNOWN = 0;

  // denotes no element, used in interactions such as touch and selection
  static final int NO_ELEMENT = -1;

  // Assign a (unique) identifier to the element.
  void setId(int id);

  // Get the element's (unique) identifier.
  int getId();

  // Assign an object to handle callbacks from this element.
  void setCallbackHandler(UICallbackHandler callbackHandler);

  // Draw the element onto a canvas.
  void draw(PGraphics g);

  // Update the element's animation.
  void update();

  // Signal a touch event, return true when the event interacted with the element.
  boolean touch(float x, float y);

  // Signal a drag event, return true when the event interacted with the element.
  boolean drag(float prevX, float prevY, float newX, float newY);

  // Signal a release event, return true when the event interacted with the element.
  boolean release(float x, float y);

  // Signal a scroll event, return true when the event interacted with the element.
  boolean scroll(float x, float y, float amount);

  // Test whether the provided coordinates are inside the element.
  boolean isInside(float pX, float pY);

  // Set the element's position.
  void setPos(float x, float y);

  // Set the element's dimensions.
  void setSize(float w, float h);

  // Set the element's position and dimensions.
  void setRect(float x, float y, float w, float h);

  // Selectors for position and dimensions
  float x();
  float y();
  float w();
  float h();
}


// Implements a basic element conforming to the UIElement interface.
// Most UI classes will extend this one.
class UIBasicElement implements UIElement {

  // the element's id (default unknown)
  protected int id = UIElement.ID_UNKNOWN;

  // the element's callback handler; must be explicitly set using setCallbackHandler()
  protected UICallbackHandler callbackHandler;

  // the element's positionand dimensions
  protected float x;
  protected float y;
  protected float w;
  protected float h;

  // Default constructor
  UIBasicElement() {}

  // Constructor
  UIBasicElement (float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  // Assign a (unique) id to the element.
  void setId(int id) {
    this.id = id;
  }

  // Returns the element's unique ID
  int getId() {
    return this.id;
  }

  // Assign a UICallbackHandler object to receive status updates from this element.
  void setCallbackHandler(UICallbackHandler callbackHandler) {
    this.callbackHandler = callbackHandler;
  }

  // Draw the element onto a Processing graphics object.
  void draw(PGraphics g) {}

  // Update the element's internal logic
  void update() {}

  // Signal a touch event at the coordinates (x,y)
  boolean touch(float x, float y) { return false; }

  // Signal a drag event from the coordinates (prevX, prevY) to the coordinates (newX, newY)
  boolean drag(float prevX, float prevY, float newX, float newY) { return false; }

  // Signal a touch release event at the coordinates (x,y)
  boolean release(float x, float y) { return false; }

  // Signal a scroll event at the coordinates (x,y), with a given amont of scrolling
  boolean scroll(float x, float y, float amount) { return false; }

  // Returns true if the coordinates (pX, pY) are inside the element.
  boolean isInside(float pX, float pY) {
    return (pX >= x && pX <= (x+w) && pY >= y && pY <= (y+h));
  }

  // Set the element's position.
  void setPos(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // Set the element's dimensions.
  void setSize(float w, float h) {
    this.w  = w;
    this.h = h;
  }

  // Set the element's position and dimensions.
  void setRect(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  // Selectors for position and dimensions
  float x() { return this.x; }
  float y() { return this.y; }
  float w() { return this.w; }
  float h() { return this.h; }

  // Utility function for subclasses to handle touch events in nested elements. Should be static when not nested.
  protected boolean touch(ArrayList<UIElement> elements, float x, float y) {
    boolean result = false;
    for (UIElement element : elements) {
      result |=  element.touch(x, y);
    }
    return result;
  }

  // Utility function for subclasses to handle drag events in nested elements. Should be static when not nested.
  protected boolean drag(ArrayList<UIElement> elements, float prevX, float prevY, float newX, float newY) {
    boolean result = false;
    for (UIElement element : elements) {
      result |= element.drag(prevX, prevY, newX, newY);
    }
    return result;
  }

  // Utility function for subclasses to handle release events in nested elements. Should be static when not nested.
  protected boolean release(ArrayList<UIElement> elements, float x, float y) {
    boolean result = false;
    for (UIElement element : elements) {
      result |= element.release(x, y);
    }
    return result;
  }

  // Utility function for subclasses to handle scroll events in nested elements. Should be static when not nested.
  protected boolean scroll(ArrayList<UIElement> elements, float x, float y, float amount) {
    boolean result = false;
    for (UIElement element : elements) {
      result |= element.scroll(x, y, amount);
    }
    return result;
  }
}


// Defines a base class for UI callback handlers.
// In order to be notified of changes in the state of UI elements, 
// the application should implement this interface (or provide an object which does so).
// A UI callback handler object is passed to a UI Element using the setCallbackHandler() method.
// Each callback is usually related to a type of element (button, slider, numeric field) and receives the element's identifier.
// Some callbacks also indicate the new value or state of the UI element.
class UICallbackHandler {

  // Called when a button is pressed.
  // Receives the button's identifier, defined by the developer when creating the button.
  void callbackUIButtonPressed(int id) {
    println("UICallbackHandler.callbackUIButtonPressed(): " + id);
  }

  // Called when a slider is selected (i.e. the slider's active area is clicked).
  // Receives the slider's identifier and the updated slider value (because clicking the slider may move the indicator/knob).
  void callbackUISliderSelected(int id, float value) {
    println("UICallbackHandler.callbackUISliderSelected(): " + id + " value " + nf(value, 0, 2));
  }
  
  // Called when a slider is dragged.
  // Receives the slider's identifier and the updated slider value.
  void callbackUISliderDragged(int id, float value) {
    println("UICallbackHandler.callbackUISliderDragged(): " + id + " value " + nf(value, 0, 2));
  }

  // Called when a slider is released.
  // Receives the slider's identifier and the updated slider value.
  void callbackUISliderReleased(int id, float value) {
    println("UICallbackHandler.callbackUISliderReleased(): " + id + " value " + nf(value, 0, 2));
  }
  
  // Called when a numeric field's value changes.
  // Receives the element's identifier and the updated value.
  void callbackUINumFieldUpdated(int id, int value) {
    println("UICallbackHandler.callbackUINumFieldUpdated(): " + id + " value " + nf(value, 0, 2));
  }
  
  // Called when a list item is selected.
  // Receives the list's identifier and the index of the selected item.
  void callbackUIListItemSelected(int id, int itemIndex) {
    println("UICallbackHandler.callbackUIListItemSelected(): " + id + " index " + itemIndex);
  }

  // Called when a view has finished fading in.
  void callbackUIViewFadeIn() {
    println("UICallbackHandler.callbackUIViewFadeIn()");
  }

  // Called when a view has finished fading out.
  void callbackUIViewFadeOut() {
    println("UICallbackHandler.callbackUIViewFadeOut()");
  }

}
