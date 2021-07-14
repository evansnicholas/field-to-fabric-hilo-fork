// Implements a group of UI elements, which can act as a moveable container for other elements
// or a complete "view" with a background color or image.
class UIGroup extends UIBasicElement {
  
  // Layout modes
  static final int CENTER_BOTH  = 0;
  static final int HORIZONTALLY = 1;
  static final int VERTICALLY   = 2;

  // Background color
  boolean hasBackground;
  color   colBackground;
  
  // Frame color and wight (thickness)
  color   colFrame; 
  float   weightFrame;  // 0 = no frame
  
  // Background image, optional
  PImage imgBackground = null;

  // The group's nested elements
  ArrayList<UIElement> elements;


  // Constructor.
  UIGroup() {
    super(0, 0, width, height);
    elements = new ArrayList<UIElement>();
  }


  // Constructor.
  UIGroup(float x, float y, float w, float h) {
    super(x, y, w, h);
    elements = new ArrayList<UIElement>();
  }


  // Constructor.
  UIGroup(color colBackground) {
    super(0, 0, width, height);
    elements = new ArrayList<UIElement>();
    this.colBackground = colBackground;
  }


  // Set the group's background color.
  void setBackgroundColor(color colBackground) {
    this.hasBackground = true;
    this.colBackground = colBackground;
  }

  
  // Set the group's background image.
  void setBackgroundImage(PImage imgBackground) {
    this.imgBackground = imgBackground;
  }
  
  
  // Set the group's frame color and weight (thickness)
  void setFrame(color colFrame, float weightFrame) {
    this.colFrame = colFrame;
    this.weightFrame = weightFrame;
  }


  // Add an element to the group.
  void add(UIElement element) {
    elements.add(element);
  }

  
  // Utility function to add and position an element after the lowest one, including a spacing.
  // Useful when constructing the UI vertically, from top to bottom.
  void addToBottom(UIElement element, float spacing) {
    float bottomY = 0;
    for(UIElement elem : elements) {
      bottomY = max(bottomY, elem.y() + elem.h());  // find the lowest position of an element within this group
    }
    element.setPos(element.x(), bottomY + spacing);
    this.add(element);
  }
  
  
  // Utility function to add and position an element to the right of another one.
  // Useful when constructing the UI horizontally, from left to right.
  void addRightOf(UIElement element, UIElement anchorElement, float spacing) {
    element.setPos(anchorElement.x() + anchorElement.w() + spacing, anchorElement.y());
    this.add(element);
  }
  
  
  // Utility function to add and position an element under another, including a spacing.
  // Useful when constructing the UI vertically, from top to bottom.
  void addUnder(UIElement element, UIElement anchorElement, float spacing) {
    element.setPos(anchorElement.x(), anchorElement.y() + anchorElement.h() + spacing);
    this.add(element);
  }


  // Get the nested element at the given index, or null otherwise.
  UIElement getByIndex (int index) {
    if (index < 0 || index >= elements.size()) {
      println("UIGroup.getByIndex() ERROR: no index " + index + " in elements (size " + elements.size() + ")");
      return null;
    }
    return elements.get(index);
  }

  
  // Get the element with the given id, or null otherwise.
  UIElement getById (int id) {
    for(UIElement elem : elements) {
      if (elem.getId() == id) return elem;
    }
    return null;
  }
  
  
  // Tighten the group's dimensions based on the size and position of elements.
  void tightDimensions() {
    float minX = width;
    float minY = height;
    float maxX = 0;
    float maxY = 0;
    
    for (UIElement element : elements) {
      minX = min(element.x(), minX);
      minY = min(element.y(), minY);
      maxX = max(element.x() + element.w(), maxX);
      maxY = max(element.y() + element.h(), maxY);
    }
    
    for (UIElement element : elements) {
      element.setPos(element.x() - minX, element.y() - minY);
    }
    
    int maxW = ceil(maxX - minX);
    int maxH = ceil(maxY - minY);
    
    this.setSize(maxW, maxH);
  }
  
    
  // Center all elements within the group.
  // Aassumes that elements are anchored by their upper-left corners.
  void centerElements(int mode) {
    for (UIElement element : elements) {
      centerElement(element, mode);
    }
  }
  
  
  // Center all elements within the group.
  // Aassumes that elements are anchored by their upper-left corners.
  void centerElements() {
    centerElements(CENTER_BOTH);
  }
  
  
  // Center an element within the group.
  // Assumes that the element is anchored by the its upper-left corner.
  void centerElement(UIElement element, int mode) {
    float newX = (this.w - element.w())/2;
    float newY = (this.h - element.h())/2;
    
    if (mode == HORIZONTALLY) {
      newY = element.y();
    }
    else if (mode == VERTICALLY) {
      newX = element.x();
    }

    element.setPos(newX, newY);
  }
  
  
  /** Used to center an element within the group, assuming the element is anchored by the its upper-left corner **/
  void centerElement(UIElement element) {
    centerElement(element, CENTER_BOTH);
  }
  

  /** Draw the group onto a canvas. */
  @Override
  void draw(PGraphics g) {
    g.pushStyle();
    //draw the background, if any 
    if (hasBackground) {
      g.noStroke();
      g.fill(colBackground);
      g.rect(x, y, w, h);
    }
    // draw background image, if any
    if (imgBackground != null) {
      g.image(imgBackground, x, y);
    }
    // draw frame, if any
    if (weightFrame > 0) {
      g.noFill();
      g.stroke(colFrame);
      g.strokeWeight(weightFrame);
      g.rect(x, y, w, h);
    }
    g.popStyle();
    // draw nested elements
    g.pushMatrix();
    g.translate(x, y);
    for (UIElement element : elements) {
      element.draw(g);
    }
    g.popMatrix();
    
    // draw outline
    //g.pushStyle();
    //g.noFill();
    //g.stroke(#0000FF);
    //g.rect(x, y, w, h);
    //g.popStyle();
  }

  /** Update the group by updating nested elements. */
  @Override
  void update() {
    for (UIElement element : elements) {
      element.update();
    }
  }

  /** Pass a touch event to nested elements, return the resulting action. */
  @Override
  boolean touch(float x, float y) {
    return touch(elements, x -this.x, y -this.y);
  }

  /** Pass a drag event to nested elements, return the resulting action. */
  @Override
  boolean drag(float prevX, float prevY, float newX, float newY) {
    return drag(elements, prevX -this.x, prevY -this.y, newX -this.x, newY -this.y);
  }

  /** Pass a release event to nested elements, return the resulting action. */
  @Override
  boolean release(float x, float y) {
    return release(elements, x -this.x, y -this.y);
  }
  
  /** Pass a scroll event to nested elements, return the resulting action. */
  @Override
  boolean scroll(float x, float y, float amount) {
    return scroll(elements, x -this.x, y -this.y, amount);
  }
}
