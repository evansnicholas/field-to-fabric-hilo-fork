// Implements an editable numeric field, for integer values only. 
// The displayed number can have a suffix, such as "cm" or "meters".
class UINumField extends UIText {
  
  int     value     = 0;
  String  strSuffix = "";
  color   bgColor   = uiColLight;
  boolean selected  = false;


  UINumField() {
    super();
  }


  UINumField(float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  
  UINumField(float x, float y, float w, float h,
    int value, String strSuffix,
    PFont font,
    int fontSize,
    color fontColor, color bgColor )
  {
    super(x, y, w, h, "", font, fontSize, fontColor);
    this.value     = value;
    this.strSuffix = strSuffix;
    this.bgColor   = bgColor;
    update();
  }
  
  
  @Override
  void update() {
    strText = nf(value, 0);
  }
  
  
  @Override
  void draw(PGraphics g) {
    g.pushStyle();
    g.noStroke();
    
    if (selected)
      g.fill(fontColor);
    else 
      g.fill(bgColor);
    
    g.rect(x, y, w, h);
    
    if (selected)
      g.fill(bgColor);
    else 
      g.fill(fontColor);
    
    g.textFont(font, fontSize);
    g.textAlign(hAlign, vAlign);
    
    if (selected)
      g.text(strText, x, y, w, h);
    else   
      g.text(strText + strSuffix, x, y, w, h);
    
    if (selected) {
      g.noFill();
      g.stroke(bgColor);
      g.strokeWeight(2);
      g.rect(x, y, w, h);
    }

    g.popStyle();
  }
  
  
  @Override
  boolean touch(float x, float y) { 
    if (this.isInside(x, y)) {
      selected = true;
      return true;
    }
    else if (selected) {
      selected = false;
      if (callbackHandler != null) callbackHandler.callbackUINumFieldUpdated(this.id, this.value);
      return true;
    }
    return false;
  }
  
  
  void keyPressed(char keyChar) {
    if (!selected) return;
    
    if (keyChar >= '0' && keyChar <= '9') {
      int keyVal = (int)(keyChar - '0');
      println("Mult val " + value);
      value *= 10;
      println("add " + keyVal + " to " + value);
      value += keyVal;
      println("val is " + value);
    }
    else if (keyChar == 8) {  // DELETE
      value = value/10;
    }
    else if (keyChar == 10) { // RETURN
      selected = false;
    }
    
    if (callbackHandler != null) callbackHandler.callbackUINumFieldUpdated(this.id, this.value);
  }
}
