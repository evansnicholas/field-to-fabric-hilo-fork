class Shuttle {
  
  int sourceWidth;
  int sourceHeight;
  
  int x;
  int y;
  
  
  Shuttle(int sourceWidth, int sourceHeight) {
    setSourceSize(sourceWidth, sourceHeight);
  }
  
  
  void setSourceSize(int sourceWidth, int sourceHeight) {
    this.sourceWidth  = sourceWidth;
    this.sourceHeight = sourceHeight;
  }
  
  
  void reset() {
    x = 0;
    y = 0;
  }
  
  
  boolean next() {  
    if (y % 2 != 0) {
      // odd line, travel LEFT
      x--;
      if (x < 0) {
        x = 0;
        y++;
      }
    }
    else {
      // even line, travel RIGHT
      x++;
      if (x >= sourceWidth) {
        x = sourceWidth -1;
        y++;
      }
    }
    if (y >= sourceHeight) {
      y = sourceHeight -1;
      return false;
    }
    return true;
  }
  
  
  boolean previous() {
    if (y % 2 != 0) {
      // odd line, travel RIGHT
      x++;
      if (x >= sourceWidth) {
        x = sourceWidth -1;
        y++;
      }
    }
    else {
      // even line, travel LEFT
      x--;
      if (x < 0) {
        x = 0;
        y++;
      }
    }
    if (y < 0) {
      y = 0;
      return false;
    }
    return true;
  }
  
  
  boolean up() {
    if (y == 0) return false;
    y--;
    return true;
  }
  
  
  boolean down() {
    if (y == sourceHeight -1) return false;
    y++;
    return true;
  }
  
  
  boolean left() {
    if (x == 0) return false;
    x--;
    return true;
  }
  
  
  boolean right() {
    if (x == sourceWidth -1) return false;
    x++;
    return true;
  }
}
