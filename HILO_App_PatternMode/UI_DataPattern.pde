class UIDataPattern extends UIBasicElement {
  
  final static float MIN_LINE_THICKNESS =  0.2;
  final static float MAX_LINE_THICKNESS =  8.0;
  
  UIButtonStatic btnDropImage;
  UIButtonStatic btnShowData;
  UIButtonStatic btnShowTextile;
  
  PImage imgDataSource;
  //PImage imgShowData;
  //PImage imgShowTextile;
  
  int previewAreaX;
  int previewAreaY;
  int previewAreaW;
  int previewAreaH;
  
  int previewDataX;
  int previewDataY;
  int previewDataW;
  int previewDataH;
  
  static final int MAX_UNIT_SIZE = 20;
  float unitSizeW;
  float unitSizeH;
  
  //int previewImageX;
  //int previewImageY;
  int previewImageW;
  int previewImageH;
  
  int dataWidth;
  int dataHeight;
  
  float textileWidth  = 20;
  float textileHeight = 15;
  float lineHeightCm  = 0.5;
  float pixelWidthCm;
  int   numLines;
  float lineHeightPix;
  
  boolean isSourceSet    = false;
  boolean isDataRendered = false;
  PGraphics gPreview;
  
  boolean isShowData    = false;
  boolean isShowTextile = true;
  
  float thicknessWhitePerc =  0.5;
  float thicknessBlackPerc = 10.0;
  
  float maxLineThickness;
  float minLineThickness;
  
  // SHUTTLE
  Shuttle shuttle;
  boolean isShowShuttle = true;
  
  UIDataPattern() {
    super();
  }
  
  
  UIDataPattern (float x, float y, float w, float h) {
    super(x, y, w, h);
  }
  
  
  void init(UICallbackHandler callbackHandler, PImage imgDropImage, PImage imgShowData, PImage imgShowTextile) {
    this.callbackHandler = callbackHandler;
    shuttle = new Shuttle(0, 0);
    
    previewAreaX = (int)this.x;
    previewAreaY = (int)this.y + uiPatternPreviewTop;
    previewAreaW = (int)this.w;
    previewAreaH = (int)this.h - uiPatternPreviewTop;
    
    gPreview = createGraphics(previewAreaW, previewAreaH);
    
    //PImage imgDropImage = loadImage("DropImage.png");
    btnDropImage = new UIButtonStatic(
      (int)(this.w - imgDropImage.width) /2,
      (int)(this.h - imgDropImage.height)/2,
      imgDropImage.width,
      imgDropImage.height
    );
    btnDropImage.image = imgDropImage;
    btnDropImage.setId(UI_BUTTON_LOAD_IMAGE);
    btnDropImage.setCallbackHandler(this.callbackHandler);
    
    //imgShowData    = loadImage("ShowData.png");
    btnShowData = new UIButtonStatic(
      (int)(this.w - (imgShowData.width*2)) /2,
      0,
      imgShowData.width,
      imgShowData.height
    );
    btnShowData.image = imgShowData;
    btnShowData.setId(UI_BUTTON_SHOW_DATA);
    btnShowData.setCallbackHandler(this.callbackHandler);
    
    //imgShowTextile = loadImage("ShowTextile.png");
    btnShowTextile = new UIButtonStatic(
      (int)((this.w - (imgShowTextile.width*2)) /2) + imgShowTextile.width,
      0,
      imgShowTextile.width,
      imgShowTextile.height
    );
    btnShowTextile.image = imgShowTextile;
    btnShowTextile.setId(UI_BUTTON_SHOW_TEXTILE);
    btnShowTextile.setCallbackHandler(this.callbackHandler);
  }
  
  
  boolean hasSource() {
    return isSourceSet;
  }
  
  
  void setSource(PImage imgDataSource) {
    this.imgDataSource = imgDataSource;
    isSourceSet = true;
    calculatePreviewParams();
    refreshPreview();
    shuttle.setSourceSize(dataWidth, numLines);
    shuttle.reset();
  }
  
  
  void clearSource() {
    imgDataSource  = null;
    isSourceSet    = false;
    isDataRendered = false;
  }
  
  
  void setTextileSize(int textileWidth, int textileHeight) {
    this.textileWidth  = textileWidth;
    this.textileHeight = textileHeight;
    if (!isSourceSet) return;
    calculatePreviewParams();
    refreshPreview();
    shuttle.setSourceSize(dataWidth, numLines);
    shuttle.reset();
  }
  
  
  void setLineThicknessPerc(float thicknessWhitePerc, float thicknessBlackPerc) {
    this.thicknessWhitePerc = constrain(thicknessWhitePerc, 0, 100);
    this.thicknessBlackPerc = constrain(thicknessBlackPerc, 0, 100);
  }
  
  
  void toggleShowData() {
    isShowData = !isShowData;
    refreshPreview();
  }
  
  
  void toggleShowTextile() {
    isShowTextile = !isShowTextile;
    refreshPreview();
  }
  
  
  protected void calculatePreviewParams() {
    println("UIDataPattern.calculatePreviewParams()");
    
    dataWidth  = imgDataSource.width;
    dataHeight = imgDataSource.height;

    float textileAspect = (float)textileHeight / (float)textileWidth;
    println("textileAspect: " + textileAspect);

    // resize width
    previewDataH = previewAreaH;
    previewDataW = (int)((float)previewDataH / textileAspect);
    //unitSizeW = unitSizeH = (float)previewDataH/(float)(imgDataSource.height);
    if (previewDataW > previewAreaW) {
      println("scaled width bigger than width");
      // resize height
      previewDataW = previewAreaW;
      previewDataH = (int)(textileAspect * previewDataW);
      //unitSizeW = unitSizeH = (float)previewDataW/(float)(imgDataSource.width);
      //println("scaledH " + nf(scaledH, 0, 2) + " oriAsp " + nf(originalAspect, 0, 2) + " scaledW " + nf(scaledW, 0, 2));
      if (previewDataH > h) {
        println("UIDataPattern.calculatePreviewParams() ERROR: preview data height bigger than element height");
      }
    }
    
    unitSizeW = previewDataW/(float)dataWidth;
    unitSizeH = previewDataH/(float)dataHeight;

    previewDataX = (int)((previewAreaW - (previewDataW)) / 2);
    previewDataY = (int)((previewAreaH - (previewDataH)) / 2);
    
    //println("Preview Data x/y/w/h: " + previewDataX + " " + previewDataY + " " + previewDataW + " " + previewDataH);

    float imageAspect = (float)dataHeight / (float)dataWidth;

    // resize width
    previewImageH = previewAreaH;
    previewImageW = (int)(previewImageH / imageAspect);
    if (previewImageW > previewAreaW) {
      // println("scaled width bigger than width");
      // resize height
      previewImageW = previewAreaW;
      previewImageH = (int)(imageAspect * previewImageW);
      //println("scaledH " + nf(scaledH, 0, 2) + " oriAsp " + nf(originalAspect, 0, 2) + " scaledW " + nf(scaledW, 0, 2));
      if (previewImageH > h) {
        println("UIDataPattern.calculatePreviewParams() ERROR: preview image height bigger than element height");
      }
    }

    //println("Preview Image x/y/w/h: " + previewImageX + " " + previewImageY + " " + previewImageW + " " + previewImageH);
    
    numLines = floor(textileHeight/lineHeightCm);
    lineHeightPix = (float)previewDataH / (textileHeight/lineHeightCm);
    pixelWidthCm  = (float)textileWidth/(float)dataWidth;
    
    minLineThickness = MIN_LINE_THICKNESS;
    maxLineThickness = lineHeightPix -2;
    maxLineThickness = constrain(maxLineThickness, MIN_LINE_THICKNESS + 0.5, MAX_LINE_THICKNESS);
  }
  
  
  @Override
  void draw (PGraphics g) {
    g.pushMatrix();
    g.translate(this.x, this.y);
    if (isDataRendered) {
      g.image(gPreview, 0, uiPatternPreviewTop);
      //renderData(g);
      //g.image(imgDataSource, previewImageX, previewImageY, previewImageW, previewImageH);
      
      g.noStroke();
      g.fill(uiColDark);
      int indicatorOffsetX = (int)(btnShowData.w - uiPatternShowIndicW)/2;
      btnShowData.draw(g);
      if (isShowData)
        g.rect(btnShowData.x + indicatorOffsetX, btnShowData.y + btnShowData.h, uiPatternShowIndicW, uiPatternShowIndicH);
      btnShowTextile.draw(g);
      if (isShowTextile)
        g.rect(btnShowTextile.x + indicatorOffsetX, btnShowTextile.y + btnShowTextile.h, uiPatternShowIndicW, uiPatternShowIndicH);
        
      if (isShowShuttle) {
        g.noFill();
        float alpha = map(sin(millis()/100.0), -1, 1, 0, 255);
        g.stroke(uiColDark, alpha);
        g.strokeWeight(4);
        g.rect(
          previewDataX + (shuttle.x * unitSizeW), 
          uiPatternPreviewTop + previewDataY + (shuttle.y * lineHeightPix), 
          unitSizeW, lineHeightPix
        );
      }
    }
    else {
      btnDropImage.draw(g);
    }
    g.popMatrix();
  }
  
  
  float shuttleValue() {
    if (!isSourceSet) return -1;
    //return brightness(imgDataSource.get(shuttle.x, shuttle.y));
    return brightnessPixelLine(shuttle.x, shuttle.y);
  }
  
  float brightnessPixelLine(int pixelX, float lineY) {
    int pixelY = floor(map(lineY, 0, numLines, 0, dataHeight));
    return brightness(imgDataSource.get(pixelX, pixelY));
  }
  
  
  void refreshPreview() {
    //println("UIDataPattern.refreshPreview()");
    
    if (!isSourceSet) {
      println("UIDataPattern.refreshPreview() WARNING no source has been set!");
      return;
    }
    isDataRendered = false;
    
    gPreview.beginDraw();
    gPreview.background(uiColLight);
    if (isShowData) {
      renderData(gPreview);
    }
    if (isShowTextile) {
      renderTextile(gPreview);
    }
    gPreview.endDraw();
    isDataRendered = true;
  }
  
  
  void renderData(PGraphics g) {
    g.pushStyle();
    g.noStroke();
    for (int j = 0; j < imgDataSource.height; j++) {
      for (int i = 0; i < imgDataSource.width; i++) {
        //color val = imgDataSource.get(i,j);
        color col = imgDataSource.get(i,j);
        float val = (red(col) + green(col) + blue(col)) / 3.0;
        g.fill(val);
        g.rect(
          previewDataX + (i * unitSizeW), 
          previewDataY + (j * unitSizeH),
          unitSizeW,
          unitSizeH
        );
      }
    }
    g.popStyle();
  }
    
  
  void renderTextile(PGraphics g) { 
    float currX1 = 0;
    float currX2 = 0;
    float currY = 0;
    
    float thicknessWhitePix = map(this.thicknessWhitePerc, 0, 100, minLineThickness, maxLineThickness);
    float thicknessBlackPix = map(this.thicknessBlackPerc, 0, 100, minLineThickness, maxLineThickness);
    
    float lineThickness = 1;
    
    g.pushStyle();
    g.noFill();
    g.stroke(uiColDark);
    g.strokeCap(ROUND);
    
    for (int j = 0; j < numLines; j++) {
      currY = previewDataY + (j * lineHeightPix) + (lineHeightPix/2.0); 
      for (int i = 0; i < dataWidth; i++) {
        //int sampleY = floor(map(j, 0, numLines, 0, dataHeight));
        //float val = brightness(imgDataSource.get(i, sampleY));
        float val = brightnessPixelLine(i, j);
        lineThickness = map(val, 0, 255, thicknessBlackPix, thicknessWhitePix);
        //println("lineThickness, thicknessBlack, thicknessWhite " + lineThickness + " " + thicknessBlack + " " + thicknessWhite);
        currX1 = round(previewDataX + (i * unitSizeW));
        currX2 = currX1 + unitSizeW;
        g.strokeWeight(lineThickness);
        g.line(currX1, currY, currX2, currY);
      }
      
      if (j < (numLines-1)) {
        int nextLineX = previewDataX;
        if (j%2 == 0) 
          nextLineX = floor(previewDataX + previewDataW - 0.5); 
        
        //g.strokeWeight(thicknessWhite);
        g.line(nextLineX, currY, nextLineX, currY + lineHeightPix);
        //g.rect(nextLineX, previewDataY + (j * lineHeightPix) + (0.5 * lineHeightPix), thicknessWhite, lineHeightPix);
      }
    }
    g.popStyle();
  }
  
  
  @Override
  void update() {}

  
  @Override
  boolean touch(float x, float y) {
    boolean result = false;
    if (!hasSource())
      result |= btnDropImage.touch(x -this.x, y -this.y);
      
    result |= btnShowData.touch(x -this.x, y -this.y);
    result |= btnShowTextile.touch(x -this.x, y -this.y);
    
    return result; 
  }


  @Override
  boolean drag(float prevX, float prevY, float newX, float newY) { 
    return false; 
  }


  @Override
  boolean release(float x, float y) { 
    boolean result = false;
    result |= btnDropImage.release(x -this.x, y -this.y);
    
    result |= btnShowData.release(x -this.x, y -this.y);
    result |= btnShowTextile.release(x -this.x, y -this.y);
    
    return result; 
  }
}
