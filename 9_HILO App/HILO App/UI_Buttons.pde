// UI - Buttons
// This tab contains the classes for UI buttons, images and animated icons.


// An image or icon, drawn at it's original size.
class UIImage extends UIBasicElement {
  protected PImage image;
  
  UIImage() {
    super();
  }

  UIImage (float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  UIImage(PImage image, float x, float y) {
    super(x, y, image.width, image.height);
    this.image = image;
  }
  
  void setImage(PImage image) {
    this.image = image;
    this.w = image.width;
    this.h = image.height;
  }
  
  PImage getImage() {
    return this.image;
  }
  
  @Override
  void draw(PGraphics g) {
    if (this.image != null) g.image(this.image, this.x, this.y);
  }
}


// A basic "in progress" spinner, consisting of an rotating image.
// The rotation's pivot is the center of the image.
class UISpinnerBasic extends UIImage {
  
  UISpinnerBasic(PImage image, float x, float y) {
    super(image, x, y);
  }
  
  @Override
  void draw(PGraphics g) {
    g.pushMatrix();
    g.translate(this.x, this.y);
    g.rotate(-millis()/300.0);
    g.translate(-image.width/2, -image.height/2);
    g.image(image, 0, 0);
    g.popMatrix();
  }
}


// A simple, static button without animations.
// Represented by a single image, which is optional.
// If no image is provided, the button is "invisible" but will trigger callbacks when clicked.
class UIButtonStatic extends UIImage {
  
  UIButtonStatic() {
    super();
  }

  UIButtonStatic (float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  UIButtonStatic(PImage image, float x, float y) {
    super(image, x, y);
  }
  
  @Override
  void draw(PGraphics g) {
    if (this.image != null) g.image(this.image, x, y);
  }

  @Override
  boolean touch(float x, float y) {
    if (isInside(x, y)) {
      if (callbackHandler != null) callbackHandler.callbackUIButtonPressed(this.id);
      else println("UIButtonStatic.touch() button id " + this.id + " nas no handler");
      return true;
    }
    return false;
  }
}


// A simple button/icon without animations like UIButtonStatic, but with text below the image.
class UIButtonSubText extends UIButtonStatic {
  
  int spacing;
  UIText text;
  boolean isEnabled = true;
  color colDisableMask = color(255, 180);
  
  UIButtonSubText() {
    super();
  }

  UIButtonSubText (float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  UIButtonSubText (PImage image, float x, float y) {
    super(image, x, y);
  }
  
  void setSubText(String strText, PFont font, int fontSize, color fontColor, int spacing) {
    this.text = new UIText(
      0, 0, 10, 10,
      strText,
      font, fontSize, fontColor
    );
    this.spacing = spacing;
    updateTextPos();
    updateHeight();
  }
  
  void updateTextPos() {
    this.text.tightenDimensions();
    int textX = (int)(this.x + ((this.w - text.w)/2));
    int textY = this.image != null ? (this.image.height + spacing) : 0;
    this.text.setPos(textX, textY);
  }
  
  void updateHeight() {
    int textY = this.image != null ? this.image.height : 0;
    this.h = textY + spacing + text.fontSize;
  }
  
  void setEnabled(boolean isEnabled) {
    this.isEnabled = isEnabled;
  }
  
  void setDisableMaskColor(color colDisableMask) {
    this.colDisableMask = colDisableMask;
  }
  
  @Override
  void setPos(float x, float y) {
    super.setPos(x, y);
    updateTextPos();
  }

  @Override
  void setSize(float w, float h) {
    super.setSize(w, h);
    updateTextPos();
  }

  @Override
  void setRect(float x, float y, float w, float h) {
    super.setRect(x, y, w, h);
    updateTextPos();
  }
  
  @Override
  void draw(PGraphics g) {
    super.draw(g);
    this.text.draw(g);
    if (!isEnabled) {
      g.pushStyle();
      g.stroke(colDisableMask);
      g.fill(colDisableMask);
      if (image != null) g.rect(x, y, image.width, image.height);
      g.rect(text.x(), text.y(), text.w(), text.h());
      g.popStyle();
    }
  }
}


// A toggle button which can have multiple states.
// Each state is an integer starting at 0 and corresponds to an image in an array 
// (the button's visual representation for each state).
// The button's current state can be cycled with nextState(), set with setState() and queried with getState().
class UIButtonToggle extends UIButtonStatic {
  
  PImage [] imageStates;
  int       state;
  
  UIButtonToggle() {
    super();
  }

  UIButtonToggle (float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  UIButtonToggle(PImage [] imageStates, float x, float y) {
    super(imageStates[0], x, y);
    setImages(imageStates);
  }
  
  void setImages(PImage [] imageStates) {
    this.imageStates = new PImage [imageStates.length];
    for (int i = 0; i < imageStates.length; i++) {
      this.imageStates[i] = imageStates[i];
    }
  }
  
  void nextState() {
    if (state +1 >= imageStates.length) 
      state = 0;
    else 
      state++;
  }
  
  void setState(int state) {
    debugMessage("UIButtonToggle.setState(): " + state);
    if (state < 0 || state >= imageStates.length) {
      debugMessage("UIButtonToggle.setState() WARN: state " + state + " isn't valid, constraining");
      state = constrain(state, 0, imageStates.length);
    }
    this.state = state;
    this.image = this.imageStates[state];
  }
  
  int getState() {
    return this.state;
  }
}
