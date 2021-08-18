// Implements a UI element containing a line or block of plain text.
class UIText extends UIBasicElement {
  
  String strText;

  // layout parameters
  PFont  font;
  int    fontSize;
  color  fontColor;
  int    hAlign = LEFT;
  int    vAlign = TOP;
  float  underlineWeight;

  float tightPaddingRatio = 0.08;

  
  UIText() {
    super();
  }


  UIText(float x, float y, float w, float h) {
    super(x, y, w, h);
  }


  UIText(float x, float y, float w, float h,
    String strText,
    PFont font,
    int fontSize,
    color fontColor )
  {
    super(x, y, w, h);
    this.strText = strText;
    this.font = font;
    this.fontSize = fontSize;
    this.fontColor = fontColor;
  }


  String getText() {
    return strText;
  }


  void setText(String strText) {
    this.strText = strText;
  }


  void setFont(PFont font) {
    this.font = font;
  }
  
  
  void textAlign(int hAlign, int vAlign) {
    this.hAlign = hAlign;
    this.vAlign = vAlign;
  }


  // Calculate the element's dimensions so that it wraps the text tight.
  // This only covers single-line text, and is commonly used for buttons and other
  // simple text-based elements.
  void tightenDimensions() {
    tightenWidth();
    tightenHeight();
  }
  
  void tightenWidth() {
    textFont(font, fontSize);
    // empirically, text dimensions are occasionally underestimated, which causes text
    // to not be displayed, so we add a small margin relative to the font size
    w = textWidth(strText) + (fontSize * tightPaddingRatio);
  }
  
  void tightenHeight() {
    textFont(font, fontSize);
    // empirically, text dimensions are occasionally underestimated, which causes text
    // to not be displayed, so we add a small margin relative to the font size
    h = textAscent() + textDescent() + (fontSize * 0.08);
  }


  @Override
  void draw(PGraphics g) {
    g.pushStyle();
    g.fill(fontColor);
    g.textFont(font, fontSize);
    g.textAlign(hAlign, vAlign);
    g.text(strText, x, y, w, h);
    
    if (underlineWeight > 0) {
      g.noFill();
      g.stroke(fontColor);
      g.strokeWeight(underlineWeight);
      g.line(x, y+h, x+w, y+h);
    }
    
    g.popStyle();
  }
}
