// UI - List
// This tab contains the classes for the UI list and the scrollbar used by it.


// Implements a vertical scrollable list of text elements, with a scrollbar.
// The scrollbar is automatically displayed/hidden 
// depending on the list (container) height and number of elements.
class UIList extends UIBasicElement {
  
  ArrayList<UIText> listItems; 
  
  PFont   font;
  color   fontColor;
  color   backgroundColor;
  float   lineWeight;
  int     hAlign = LEFT;
  int     vAlign = TOP;
  int     itemHeight;
  int     itemSpacing;
  int     scrollbarWidth = 20;
  int     scrollbarLeftPadding = 10;
  
  UIVerticalScrollbar uiScrollbar;
  boolean isScrollbarVisible  = false;
  
  int totalHeight;
  int offsetHeight;
  
  PGraphics listCanvas;        // the list is rendered onto it's own canvas
  boolean shouldUpdateCanvas;  // signals whether the list needs to be rendered again 
  
  
  UIList () {
    super();
    listItems = new ArrayList<UIText>();
    listCanvas = createGraphics(10, 10);
    updateScrollbarLayout();
    shouldUpdateCanvas = false;
  }
  
  
  UIList (float x, float y, float w, float h) {
    super(x, y, w, h);
    listItems = new ArrayList<UIText>();
    listCanvas = createGraphics((int)w, (int)h);
    updateScrollbarLayout();
    shouldUpdateCanvas = true;
  }
  
  
  void setStyle(PFont font, color fontColor, color backgroundColor, int hAlign, int vAlign, int itemHeight, int itemSpacing, float lineWeight, int scrollbarWidth) {
    this.font            = font;
    this.fontColor       = fontColor;
    this.backgroundColor = backgroundColor;
    this.hAlign          = hAlign;
    this.vAlign          = vAlign;
    this.itemHeight      = itemHeight;
    this.itemSpacing     = itemSpacing;
    this.lineWeight      = lineWeight;
    this.scrollbarWidth  = scrollbarWidth;
    
    updateScrollbarLayout();
    shouldUpdateCanvas  = true;
  }
    
  
  protected void updateScrollbarLayout() {
    if (uiScrollbar == null) uiScrollbar = new UIVerticalScrollbar(); 
    uiScrollbar.setRect(this.w - scrollbarWidth, 0, scrollbarWidth, this.h);
    uiScrollbar.setStyle(fontColor, lineWeight);
  }
  
  
  void clearItems() {
    listItems.clear();
    if (isScrollbarVisible) {
      // scrollbar became visible, so we need to resize the canvas width
      debugMessage("UIList.addItem(): scrollbar became invisible, resizing list canvas");
      listCanvas = createGraphics((int)w, (int)h);
    }
    isScrollbarVisible = false;
    shouldUpdateCanvas = true;
  }
  
  
  // Add a single item to the end/bottom of the list.
  void addItem(String itemText) {
    int currHeight = (itemHeight + itemSpacing) * listItems.size();
    UIText uiText = new UIText(
      0, currHeight, w, itemHeight,
      itemText,
      font, font.getSize(), fontColor
    );
    uiText.underlineWeight = this.lineWeight;
    uiText.textAlign(hAlign, vAlign);
    uiText.tightenWidth();
    listItems.add(uiText);
    
    totalHeight = ceil(uiText.y() + uiText.h());
    uiScrollbar.setScrollerSize(totalHeight, this.h);
    
    if (totalHeight > this.h) {
      if (!isScrollbarVisible) {
        // scrollbar became visible, so we need to resize the canvas width
        debugMessage("UIList.addItem(): scrollbar became visible, resizing list canvas");
        listCanvas = createGraphics((int)w - scrollbarWidth - scrollbarLeftPadding, (int)h);
      }
      isScrollbarVisible = true;
    }
    else {
      isScrollbarVisible = false;
    }
    
    shouldUpdateCanvas = true;
  }
  
  
  // Replace the contents of the list with new Strings from an array.
  void setItems (String [] newItems) {
    listItems.clear();
    for (int i = 0; i < newItems.length; i++) {
      addItem(newItems[i]);
    }
    shouldUpdateCanvas = true;
  }
  
  
  // Get the index for the item at coordinates (x, y), starting at 0.
  // If there is none, return -1.
  int indexAt(float x, float y) {
    if (isInside(x, y)) {
      int index = floor((y -this.y -offsetHeight) / (itemHeight + itemSpacing));
      if (index < listItems.size()) return index;
    }
    return -1;
  }
  
  
  // Get the item at the given index (starting at 0). Returns null if the index is invalid.
  String getItem(int index) {
    if (index < 0) return null;
    if (index >= listItems.size()) return null;
    return listItems.get(index).getText();
  }
  
  
  // Get the item at item at coordinates (x, y). Returns null if there is none.
  String itemTextAt(float x, float y) {
    int index = indexAt(x, y);
    if (index < 0) return null;
    if (index >= listItems.size()) return null;
    return listItems.get(index).getText();
  }
  
  
  // Draw the list to a specific canvas, commonly used to render the list onto it's own canvas.
  protected void drawToCanvas(PGraphics g) {
    g.beginDraw();
    g.background(backgroundColor);

    g.pushMatrix();
    g.translate(0, offsetHeight);
    for (UIText item : listItems) {
      item.draw(g);
    }
    g.popMatrix();
    
    g.endDraw();
  }
  
  
  // Update the list's own canvas. Called during UIList.draw() 
  // when the list has visibly changed - e.g. an item was added, or the list scrolled.
  void updateCanvas() {
    drawToCanvas(listCanvas);
    shouldUpdateCanvas = false;
  }
  
  
  @Override
  void draw (PGraphics g) {
    if (shouldUpdateCanvas) 
      updateCanvas();

    g.pushMatrix();
    g.translate(this.x, this.y);
    g.image(listCanvas, 0, 0);
    if (isScrollbarVisible)
      uiScrollbar.draw(g);
    g.popMatrix();
  }
  
  
  @Override
  boolean touch(float x, float y) {
    // if the scrollbar was touched, update the list rendering
    if (isScrollbarVisible && uiScrollbar.touch(x -this.x, y -this.y)) {
      shouldUpdateCanvas  = true;
      return true;
    }
    
    // otherwise, check if an item was selected
    int index = indexAt(x, y);
    if (callbackHandler != null && index >= 0) {
      callbackHandler.callbackUIListItemSelected(this.id, index);
      return true;
    }
    return false;
  }
  
  
  @Override
  boolean drag(float prevX, float prevY, float newX, float newY) {
    // dragging only works when there is a scrollbar
    if (!isScrollbarVisible) return false;
    
    // check if the scrollbar moved; if so, update the list's position
    boolean scrollbarMoved = uiScrollbar.drag(prevX -this.x, prevY -this.y, newX -this.x, newY -this.y);
    if (scrollbarMoved) {
      float offsetPerc = uiScrollbar.getScrollerPosPerc();
      offsetHeight = (int)map(offsetPerc, 0, 1, 0, - totalHeight -lineWeight +this.h);
      shouldUpdateCanvas = true;
    }
    return scrollbarMoved;
  }
 
  
  @Override
  boolean release(float x, float y) {
    // if the scrollbar was released, update the list rendering
    if (isScrollbarVisible && uiScrollbar.release(x -this.x, y -this.y)) {
      shouldUpdateCanvas  = true;
      return true;
    }
    return false;
  }
  
  
  @Override
  boolean scroll(float x, float y, float amount) {
    // scrolling only works when the scrollbar is visible and the cursor is within the list's area 
    if (isScrollbarVisible && this.isInside(x, y)) {
      // check if the scrollbar moved; if so, update the list's position
      boolean scrollbarMoved = uiScrollbar.scroll(uiScrollbar.x() +1, uiScrollbar.y() +1, amount);
      if (scrollbarMoved) {
        float offsetPerc = uiScrollbar.getScrollerPosPerc();
        offsetHeight = (int)map(offsetPerc, 0, 1, 0, - totalHeight -lineWeight +this.h);
        shouldUpdateCanvas = true;
      }
      return true;
    }
    return false;
  }
}


// Implements a vertical scrollbar, which is used by UIList.
class UIVerticalScrollbar extends UIBasicElement {
  
  protected color colForeground;
  protected float lineWeight;
  
  protected boolean isSelected;
  protected float scrollerSizePerc;
  protected float scrollerPosPerc;
  
  protected float scrollerSizePix;
  protected float scrollerPosPix;
  protected float scrollerMaxPosPix;
  
  protected float scrollingFactor = 4;

  UIVerticalScrollbar() {
    super();
  }

  UIVerticalScrollbar(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  void setStyle(color colForeground, float lineWeight) {
    this.colForeground = colForeground;
    this.lineWeight    = lineWeight;
  }
  
  void setScrollerSize(float collectionSize, float viewportSize) {
    scrollerSizePerc  = viewportSize/collectionSize;
    scrollerSizePix   = floor(this.h * scrollerSizePerc);
    scrollerMaxPosPix = this.h - scrollerSizePix;
  }
  
  float getScrollerPosPerc() {
    return scrollerPosPerc;
  }

  @Override
    void draw(PGraphics g) {
    g.noFill();
    g.stroke(colForeground);
    g.strokeWeight(lineWeight);
    g.rect(this.x, this.y, this.w, this.h);
    g.noStroke();
    g.fill(colForeground);
    g.rect(
      this.x, scrollerPosPix,
      this.w, scrollerSizePix
    );
  }
  
  @Override
  boolean touch(float x, float y) {
    if (isInside(x, y)) {
      isSelected = true;
      return true;
    }
    return false;
  }
  
  @Override
  boolean drag(float prevX, float prevY, float newX, float newY) {
    if (!isSelected) return false;

    float dYPix = newY - prevY;
    float dYPerc = dYPix / (this.h - scrollerSizePix);
    
    float newPosPerc = scrollerPosPerc + dYPerc;
    newPosPerc = constrain(newPosPerc, 0, 1);
    scrollerPosPerc = newPosPerc;
    scrollerPosPix  = map(scrollerPosPerc, 0, 1, 0, scrollerMaxPosPix);
    
    return true;
  }
  
  @Override
  boolean release(float x, float y) {
    if (isSelected) {
      isSelected = false;
      return true;
    }
    return false;
  }
  
  @Override
  boolean scroll(float x, float y, float amount) {
    if (!isInside(x, y)) return false;
    
    float dYPix = amount * scrollingFactor;
    float dYPerc = dYPix / (this.h - scrollerSizePix);
    
    float newPosPerc = scrollerPosPerc + dYPerc;
    newPosPerc = constrain(newPosPerc, 0, 1);
    scrollerPosPerc = newPosPerc;
    scrollerPosPix  = map(scrollerPosPerc, 0, 1, 0, scrollerMaxPosPix);
    
    return true;
  }
}
