class UIDataImage extends UIBasicElement {
  protected HILODataImage hiloData;
  protected boolean showOriginalImage = false;

  int previewImageX;
  int previewImageY;
  int previewImageW;
  int previewImageH;

  int previewDataX;
  int previewDataY;
  int previewDataW;
  int previewDataH;

  UIDataImage() {
  }

  void setData(HILODataImage hiloDataImage) {
    this.hiloData = hiloDataImage;
    calculatePreviewParams();
  }

  void setDataSize(int dataWidth, int dataHeight) {
    hiloData.setDataSize(dataWidth, dataHeight);
    calculatePreviewParams();
  }
  
  void setDataRange(int dataMin, int dataMax) {
    hiloData.setDataRange(dataMin, dataMax);
  }

  boolean isShowOriginalImage() {
    return showOriginalImage;
  }

  void setShowOriginalImage(boolean value) {
    showOriginalImage = value;
  }

  protected void calculatePreviewParams() {
    println("UIDataImage.calculatePreviewParams()");

    int dataWidth  = hiloData.getDataWidth();
    int dataHeight = hiloData.getDataHeight();

    float dataAspect = (float)dataHeight / (float)dataWidth;

    // resize width
    previewDataH = (int)this.h;
    previewDataW = (int)(previewDataH / dataAspect);
    if (previewDataW > this.w) {
      // println("scaled width bigger than width");
      // resize height
      previewDataW = (int)this.w;
      previewDataH = (int)(dataAspect * previewDataW);
      //println("scaledH " + nf(scaledH, 0, 2) + " oriAsp " + nf(originalAspect, 0, 2) + " scaledW " + nf(scaledW, 0, 2));
      if (previewDataH > h) {
        println("UIDataImage.calculatePreviewParams() ERROR: preview data height bigger than element height");
      }
    }

    previewDataX = (int)(this.x + ((this.w - previewDataW) / 2));
    previewDataY = (int)(this.y + ((this.h - previewDataH) / 2));
    
    //println("Preview Data x/y/w/h: " + previewDataX + " " + previewDataY + " " + previewDataW + " " + previewDataH);


    PImage dataImage = (PImage)hiloData.getObject();
    int imageWidth  = dataImage.width;
    int imageHeight = dataImage.height;

    float imageAspect = (float)imageHeight / (float)imageWidth;

    // resize width
    previewImageH = (int)this.h;
    previewImageW = (int)(previewImageH / imageAspect);
    if (previewImageW > this.w) {
      // println("scaled width bigger than width");
      // resize height
      previewImageW = (int)this.w;
      previewImageH = (int)(imageAspect * previewImageW);
      //println("scaledH " + nf(scaledH, 0, 2) + " oriAsp " + nf(originalAspect, 0, 2) + " scaledW " + nf(scaledW, 0, 2));
      if (previewImageH > h) {
        println("UIDataImage.calculatePreviewParams() ERROR: preview image height bigger than element height");
      }
    }

    previewImageX = (int)(this.x + ((this.w - previewImageW) / 2));
    previewImageY = (int)(this.y + ((this.h - previewImageH) / 2));

    //println("Preview Image x/y/w/h: " + previewImageX + " " + previewImageY + " " + previewImageW + " " + previewImageH);
  }


  @Override
  void draw(PGraphics g) {
    //g.noStroke();
    //g.fill(#26263B);
    //g.rect(x, y, w, h);

    float sourceWidth  = hiloData.getDataWidth();
    float sourceHeight = hiloData.getDataHeight();

    if (showOriginalImage) {
      sourceWidth  = hiloData.imageWidth();
      sourceHeight = hiloData.imageHeight();
    }

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

    //g.fill(100);
    //g.rect(x, y, scaledW, scaledH);
    if (showOriginalImage) {
      //hiloData.drawImage(g, imgX, imgY, scaledW, scaledH);
      //drawImage(g, imgX, imgY, scaledW, scaledH);
      drawImage(g, previewImageX, previewImageY, previewImageW, previewImageH);
    }
    else {
      //hiloData.drawData(g, imgX, imgY, scaledW, scaledH);
      //hiloData.drawData(g, previewDataX, previewDataY, previewDataW, previewDataH);
      drawData(g, previewDataX, previewDataY, previewDataW, previewDataH);
    }
  }


  void drawImage(PGraphics g, float x, float y, float w, float h) {
    PImage dataImage = (PImage)hiloData.getObject();
    g.image(dataImage, x, y, w, h);

    float stepX = w / hiloData.getDataWidth();
    float stepY = h / hiloData.getDataHeight();

    noFill();
    strokeWeight(5);
    stroke(255, 0, 255);
    //stroke(#348DF7);
    rect(x + (hiloData.getPosX() * stepX), y + (hiloData.getPosY() * stepY), stepX, stepY);
    strokeWeight(1);
  }


  void drawImage(PGraphics g, float x, float y) {
    PImage dataImage = (PImage)hiloData.getObject();
    drawImage(g, x, y, dataImage.width, dataImage.height);
  }
  

  void drawData(PGraphics g, float x, float y, float w, float h) {
    int dataWidth  = hiloData.getDataWidth();
    int dataHeight = hiloData.getDataHeight();
    
    float stepX = (float)w / (float)dataWidth;
    float stepY = (float)h / (float)dataHeight;
    
    float [] data = hiloData.getData();
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
    rect(x + (hiloData.getPosX() * stepX), y + (hiloData.getPosY() * stepY), stepX, stepY);
    strokeWeight(1);
  }

}
