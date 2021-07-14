interface HILODataInterface {
  boolean reset();
  int     getSize();
  int     getDataWidth();
  int     getDataHeight();
  Object  getObject();
  float[] getData();
  int     getPos();
  boolean setPos(int pos);
  boolean next();
  boolean previous();
  float   value();
  float   value(int pos);
}

class HILODataImage implements HILODataInterface {
  protected PImage image;
  protected int    pos   = 0;
  protected int    posX  = 0;
  protected int    posY  = 0;
  protected float  value = 0.0;
  protected float  [] data;
  protected int    dataWidth;
  protected int    dataHeight;
  protected int    dataMin;
  protected int    dataMax;
  
  HILODataImage() {
  }
  
  boolean setImage(PImage image) {
    this.image = image;
    dataWidth  = image.width;
    dataHeight = image.height;
    createData();
    return true;
  }
  
  boolean setImage(PImage image, int dataWidth, int dataHeight) {
    this.image      = image;
    this.dataWidth  = dataWidth;
    this.dataHeight = dataHeight;
    createData();
    return true;
  }
  
  boolean setDataSize(int dataWidth, int dataHeight) {
    this.dataWidth  = dataWidth;
    this.dataHeight = dataHeight;
    if (this.image != null) createData();
    return true;
  }
  
  boolean setDataRange(int dataMin, int dataMax) {
    this.dataMin = dataMin;
    this.dataMax = dataMax;
    if (this.image != null) createData();
    return true;
  }
  
  int imageWidth()  { return image.width; }
  
  int imageHeight() { return image.height; }
  
  // HILODataInterface
  int getDataWidth()   { return dataWidth; }
  
  // HILODataInterface
  int getDataHeight()  { return dataHeight; }
  
  protected void createData() {
    PImage    workingImage = this.image;
    PGraphics scaledImage  = null;
    
    if (dataWidth != image.width || dataHeight != image.height) {
      println("HILODataImage.createData(): creating scaled canvas " + dataWidth + "x" + dataHeight);
      scaledImage = createGraphics(dataWidth, dataHeight);
      scaledImage.beginDraw();
      scaledImage.background(100, 0, 100);
      scaledImage.image(this.image, 0, 0, dataWidth, dataHeight);
      scaledImage.endDraw();
      
      workingImage = scaledImage;
    }
    
    workingImage.loadPixels();
    data = new float[workingImage.pixels.length];
    for (int i = 0; i < workingImage.pixels.length; i++) {
      color pixel = workingImage.pixels[i];
      // 0.0 <= pixelAverage <= 1.0
      //float pixelAverage = (red(pixel) + green(pixel) + blue(pixel)) / 3.0 / 255.0;
      //data[i] = pixelAverage;
      float pixelAverage = (red(pixel) + green(pixel) + blue(pixel)) / 3.0;
      pixelAverage = map(pixelAverage, 0, 255, dataMin, dataMax);
      float mappedValue = map(pixelAverage, 0, 255, 0.0, 1.0);
      data[i] = mappedValue;
    }
    
    if (workingImage == scaledImage) {
      workingImage = null;
      //scaledImage.dispose();
    }
    
    posX = posY = pos = 0;
    value = data[pos];
  }
  
  void drawImage(PGraphics g, float x, float y, float w, float h) {
    g.image(this.image, x, y, w, h);
   
    float stepX = w/dataWidth;
    float stepY = h/dataHeight;
    
    noFill();
    strokeWeight(5);
    stroke(255, 0, 255);
    //stroke(#348DF7);
    rect(x + (posX * stepX), y + (posY * stepY), stepX, stepY);
    strokeWeight(1);
  }
  
  void drawImage(PGraphics g, float x, float y) {
    drawImage(g, x, y, image.width, image.height);
  }
  
  void drawData(PGraphics g, float x, float y, float w, float h) {
    float stepX = (float)w / (float)dataWidth;
    float stepY = (float)h / (float)dataHeight;
    
    int dataPos = 0;
    
    noStroke();
    for (int i = 0; i < dataHeight; i++) {
      for (int j = 0; j < dataWidth; j++) {
        fill(data[dataPos] * 255);
        rect(floor(x + (j*stepX)), floor(y + (i*stepY)), ceil(stepX), ceil(stepY));
        dataPos++;
      }
    }
    
    noFill();
    strokeWeight(5);
    //stroke(255, 0, 255);
    stroke(#348DF7);
    rect(x + (posX * stepX), y + (posY * stepY), stepX, stepY);
    strokeWeight(1);
  }
  
  void drawData(PGraphics g, float x, float y) {
    drawData(g, x, y, image.width, image.height);
  }
  
  protected boolean updatePos(int newPosX, int newPosY) {
    println("HILODataImage.updatePos(): (" + newPosX + ", " + newPosY + ")");
    int newPos = newPosX + (newPosY * dataWidth);
    //return updatePos(newPos);
    if (newPos < 0) {
      println("HILODataImage.updatePos() WARNING: newPos is less than zero (" + newPos + "), correcting");
      pos  = 0;
      posX = 0;
      posY = 0;
      value = data[pos];
      return false;
    }
    else if (newPos >= data.length) {
      println("HILODataImage.updatePos() WARNING: newPos is larger than data array (" + newPos + " >= " + data.length + "), correcting");
      pos  = data.length -1;
      posX = dataWidth   -1;
      posY = dataHeight  -1;
      if (posY % 2 != 0) {
        posX = dataWidth -1 - posX;  
      }
      value = data[pos];
      return false;
    }
    println("OLD/NEW POS " + pos + "/" + newPos);
    posX = newPosX;
    posY = newPosY;
    pos = newPos;
    value = data[pos];
    return true;
  }
  
  protected boolean updatePos(int newPos) {
    if (newPos < 0) {
      println("HILODataImage.updatePos() WARNING: newPos is less than zero (" + newPos + "), correcting");
      pos  = 0;
      posX = 0;
      posY = 0;
      value = data[pos];
      return false;
    }
    else if (newPos >= image.pixels.length) {
      println("HILODataImage.updatePos() WARNING: newPos is larger than data array (" + newPos + " >= " + data.length + "), correcting");
      pos  = data.length -1;
      posX = dataWidth   -1;
      posY = dataHeight  -1;
      if (posY % 2 != 0) {
        posX = dataWidth -1 - posX;  
      }
      value = data[pos];
      return false;
    }
    else {
      pos = newPos;
      posY = pos / dataHeight;
      posX = pos % dataWidth;
      if (posY % 2 != 0) {
        posX = dataWidth -1 - posX;  
      }
      println("POS " + pos + " = (" + posX + ", " + posY + ")");
      value = data[pos];
      return true;
    }
  }
  
  // HILODataInterface
  boolean reset() {
    updatePos(0);
    return true;
  }
  
  // HILODataInterface
  int getPos() {
    return pos;
  }
  
  int getPosX() {
    return posX;
  }
  
  int getPosY() {
    return posY;
  }
  
  // HILODataInterface
  int getSize() {
    return data.length;
  }
  
  // HILODataInterface
  boolean setPos(int pos) {
    return updatePos(pos);
  }
  
  // HILODataInterface
  boolean next() {
    // even row, going right
    if ((posY +2) % 2 == 0) {   // add 2 to posY because 1 % 2 is still 0 
      posX++;
      if (posX > dataWidth -1) {
        posX = dataWidth -1;
        posY++;
      }
    }
    // odd row, going left
    else {
      posX--;
      if (posX < 0) {
        posX = 0;
        posY++;
      }
    }
    return updatePos(posX, posY);
  }
  
  // HILODataInterface
  boolean previous() {
    // even row, going right
    if (posY % 2 == 0) {
      posX--;
      if (posX < 0) {
        posX = 0;
        posY--;
      }
    }
    // odd row, going left
    else {
      posX++;
      if (posX > dataWidth -1) {
        posX = dataWidth -1;
        posY--;
      }
    }
    return updatePos(posX, posY);
  }
  
  boolean nextRow() {
    return updatePos(posX, posY+1);
  }
  
  boolean previousRow() {
    return updatePos(posX, posY-1);
  }
  
  // HILODataInterface
  float value() { return value; }
  
  // HILODataInterface
  float value(int pos) { 
    pos = constrain(pos, 0, data.length-1);
    return data[pos]; 
  }
  
  // HILODataInterface
  Object  getObject() { return this.image; }
  
  // HILODataInterface
  float[] getData() { return this.data; }
}
