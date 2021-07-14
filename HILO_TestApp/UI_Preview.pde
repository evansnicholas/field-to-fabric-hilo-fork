class UIPreview extends UIDataImage {
  protected int previewWidth;
  protected int previewHeight;
  protected color colBackground;
  protected color colLine;
  protected float maxThickness;
  protected float minThickness;
  
  PGraphics previewCanvas;
  
  UIPreview() {
    super();
    previewWidth  = 250;
    previewHeight = 400;
    colBackground = color(#E0FFC4);
    colLine = color(#6C0866);
    maxThickness = 4;
    minThickness = 0.5;
    
    println("UIPreview.UIPreview(): creating canvas at " + previewWidth + "x" + previewHeight);
    previewCanvas = createGraphics(previewWidth, previewHeight);
  }
  
  protected void repaintCanvas() {
    PGraphics c = previewCanvas;
    c.beginDraw();
    c.background(colBackground);
    c.noStroke();
    c.fill(colLine);
    
    float stepX = (float)previewWidth / (float)hiloData.getDataWidth();
    float stepY = (float)previewHeight / (float)hiloData.getDataHeight();
    
    int dataPos = 0;
    
    for (int i = 0; i < hiloData.getDataHeight(); i++) {
      for (int j = 0; j < hiloData.getDataWidth(); j++) {
        //fill(hiloData.value(dataPos) * 255);
        //rect(floor(x + (j*stepX)), floor(y + (i*stepY)), ceil(stepX), ceil(stepY));
        float rectH = map(hiloData.value(dataPos), 0, 1, maxThickness, minThickness);
        float rectY = floor(y + (i*stepY)) + ((stepY - rectH) / 2);
        c.rect(floor(x + (j*stepX)), rectY, ceil(stepX), ceil(rectH));
        dataPos++;
      }
    }

    c.endDraw();
  }
  
  @Override
  void setData(HILODataImage hiloImage) {
    super.setData(hiloImage);
    repaintCanvas();
  }
  
  @Override
  void setDataSize(int dataWidth, int dataHeight) {
    super.setDataSize(dataWidth, dataHeight);
    repaintCanvas();
  }
  
  void drawPreview(PGraphics g) {
    g.noStroke();
    //g.fill(255, 210, 255);
    //g.rect(x, y, w, h);
    
    float sourceWidth  = previewWidth;
    float sourceHeight = previewHeight;
    
    float scaledW;
    float scaledH;
    float originalAspect = sourceHeight / sourceWidth;
    // resize width
    scaledH = h;
    scaledW = scaledH / originalAspect;
    //println("Scaled " + scaledW + " " + scaledH);
    if (scaledW > w) {
      //println("scaled width bigger than width");
        // resize height
        scaledW = w;
        scaledH = originalAspect * scaledW;
        //println("scaledH " + nf(scaledH, 0, 2) + " oriAsp " + nf(originalAspect, 0, 2) + " scaledW " + nf(scaledW, 0, 2));
        if (scaledH > h) {
          println("scaled height bigger than height");
        }
    }
    
    float imgX = x + ((w - scaledW) / 2);
    float imgY = y + ((h - scaledH) / 2);
    
    g.image(previewCanvas, imgX, imgY, scaledW, scaledH);
  }
  
  
}
