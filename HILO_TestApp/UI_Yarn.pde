class UIYarn extends UIBasicElement {

  protected final static int DEFAULT_SIZE = 10;

  protected float [] values;
  protected int valuesPos;

  UIYarn() {
    init(DEFAULT_SIZE, 9);
  }

  UIYarn(int size) {
    size = constrain(size, 0, 1000);
    init(size, 9);
  }
  
  UIYarn(int size, float value) {
    size  = constrain(size, 0, 1000);
    value = constrain(value, 0 , 9);
    init(size, value);
  }
  
  protected void init(int size, float value) {
    values = new float[size];
    valuesPos = 0;
    
    if (value != 0) {
      for (int i = 0; i < values.length; i++) {
        values[i] = value;
      }
    }
  }
  
  void addValue(int value) {
    valuesPos++;
    if (valuesPos >= values.length) valuesPos = 0;
    values[valuesPos] = value;
  }
  
  @Override
  void update() {
  }
  
  @Override
  void draw(PGraphics g) {
    int drawingPos = valuesPos +1;
    float currX = x;
    float stepX = w / values.length;
    
    for (int i = 0; i < values.length; i++) {
      if (drawingPos >= values.length) drawingPos = 0;
      float val = values[drawingPos];
      float rectH = map(val, DEFAULT_DRAFTING_SPEED_MAX, DEFAULT_DRAFTING_SPEED_MIN, h, h/10);
      float rectY = y + ((h - rectH) / 2);
      rect(currX, rectY, stepX -2, rectH);
      drawingPos++;
      currX += stepX;
    }
  }
}
