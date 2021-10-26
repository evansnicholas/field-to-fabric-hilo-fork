// Implements a horizontal grid of evenly-spaced elements, typically buttons.
// The grid can be anchored by its center.
class UIHorizontalGrid extends UIGroup {
  
  float centerX;
  float centerY;
  
  float spacingH;
  
  UIHorizontalGrid() {
    super();
  }

  UIHorizontalGrid (float x, float y, float w, float h) {
    super(x, y, w, h);
    centerX = x + (w/2);
    centerY = y + (y/2);
  }
  
  void center() {
    centerOn(this.centerX, this.centerY);
  }
  
  void centerOn(float x, float y) {
    this.centerX = x;
    this.centerY = y;
    updateLayout();
  }
  
  void updateLayout() {
    this.w = 0;
    this.h = 0;
    
   for (UIElement elem : elements) {
      this.w += elem.w();
      this.h = max(this.h, elem.h());
    }
    this.w += elements.size() * spacingH;
    if (elements.size() > 0)
      this.w -= spacingH;

    this.x = this.centerX - (this.w/2f);
    this.y = this.centerY - (this.h/2f);
    
    float currElemX = 0;
    for (UIElement elem : elements) {
      elem.setPos(currElemX, 0);
      currElemX += elem.w() + spacingH;
    }
  }

}
