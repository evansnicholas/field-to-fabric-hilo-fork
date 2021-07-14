class UIControls implements CallbackListener {
  
  final static int ACTION_CONNECT        =  0;
  final static int ACTION_DISCONNECT     =  1;
  final static int ACTION_OPEN_FILE      =  2;
  final static int ACTION_DRAFTING_SPEED =  3;
  final static int ACTION_DELIVERY_SPEED =  4;
  final static int ACTION_ELEVATOR_SPEED =  5;
  final static int ACTION_SPINDLE_SPEED  =  6;
  final static int ACTION_PIXEL_LENGTH   =  7;
  final static int ACTION_SAMPLES_X      =  8;
  final static int ACTION_SAMPLES_Y      =  9;
  final static int ACTION_GRAY_RANGE     = 10;
  
  PApplet   parent;
  ControlP5 cp5;
  
  ScrollableList ddlSerialPort;
  Textfield txtSerialPort;
  Button    btnConnect;
  Range     rngDraftingSpeeds;
  Slider    sldDeliverySpeed;
  Slider    sldElevatorSpeed;
  Slider    sldSpindleSpeed;
  Slider    sldStepsPerCm;
  Slider    sldPixelLength;
  Button    btnOpen;
  Slider    sldSamplesX;
  Slider    sldSamplesY;
  Range     rngGrayRange;
  
  int x, y, w, h;
  
  PFont pFont;
  int fontSize;
  ControlFont font;
  
  int elementHeight;
  int sliderWidth;
  
  int borderX = 20;
  int borderY = 20;
  int spacingX = 20;
  int spacingY = 25;
  
  boolean isConnected = false;
  
  color statusColor = color(0);
  int   statusX, statusY, statusSize;
  
  UIControls(PApplet parent) {
    this.parent = parent;
  }
  
  void init(
    int x, int y, int w, int h,
    int draftingSpeedMin, int draftingSpeedMax,
    int deliverySpeed,
    int elevatorSpeed,
    int spindleSpeed,
    int pixelLength,
    int samplesX, int samplesY,
    int grayMin, int grayMax
  ) {
    
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    
    cp5 = new ControlP5(parent);
    
    //fontSize = 20;
    //pFont = createFont("Comic", fontSize, false); // use true/false for smooth/no-smooth
    pFont = loadFont("Roboto-Regular-16.vlw"); // use true/false for smooth/no-smooth
    fontSize = pFont.getSize();
    font = new ControlFont(pFont, fontSize);
    
    cp5.setFont(font);
    
    textFont(pFont, fontSize);
    
    elementHeight = (int)(fontSize * 2);
    sliderWidth   = (int)(this.w - (2*borderX) - (textWidth("Motor Speeds ") *1.2));

    int currX = x + borderX;
    int currY = y + borderY;
    
    btnOpen = cp5.addButton("Open File");
    btnOpen.addListenerFor(Button.ACTION_RELEASE, this);
    btnOpen.setSize((int)(textWidth(btnOpen.getLabel()) * 2), elementHeight);
    btnOpen.setPosition(currX, currY);
    
    currY += btnOpen.getHeight() + spacingY;
    
    sldSamplesX = cp5.addSlider("Samples hori");
    sldSamplesX.setDecimalPrecision(0);
    sldSamplesX.setMin(2);
    sldSamplesX.setMax(DATA_UI_MAX_SAMPLES);
    sldSamplesX.setValue(samplesX);
    sldSamplesX.addListenerFor(Button.ACTION_RELEASE, this);
    sldSamplesX.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    sldSamplesX.setSize(sliderWidth, elementHeight);
    sldSamplesX.setPosition(currX, currY);
    
    currY += sldSamplesX.getHeight() + spacingY;
    
    sldSamplesY = cp5.addSlider("Samples vert");
    sldSamplesY.setDecimalPrecision(0);
    sldSamplesY.setMin(2);
    sldSamplesY.setMax(DATA_UI_MAX_SAMPLES);
    sldSamplesY.setValue(samplesY);
    sldSamplesY.addListenerFor(Button.ACTION_RELEASE, this);
    sldSamplesY.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    sldSamplesY.setSize(sliderWidth, elementHeight);
    sldSamplesY.setPosition(currX, currY);
    
    currY += sldSamplesY.getHeight() + spacingY;
    
    rngGrayRange = cp5.addRange("Tone Range");
    rngGrayRange.setDecimalPrecision(0);
    rngGrayRange.addListenerFor(Button.ACTION_RELEASE, this);
    rngGrayRange.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    rngGrayRange.setSize(sliderWidth, elementHeight);
    rngGrayRange.setPosition(currX, currY);
    //rngGrayRange.setMin(0);
    //rngGrayRange.setMax(255);
    rngGrayRange.setRange(0, 255);
    //rngGrayRange.setLowValue(grayMin);
    //rngGrayRange.setHighValue(grayMax);
    rngGrayRange.setRangeValues(grayMin, grayMax);
    
    currY += rngGrayRange.getHeight() + spacingY;
    currY += spacingY;
    
    sldDeliverySpeed = cp5.addSlider("Delivery Speed");
    sldDeliverySpeed.setSliderMode(Slider.FIX);
    sldDeliverySpeed.setDecimalPrecision(0);
    sldDeliverySpeed.setMin(0);
    sldDeliverySpeed.setMax(STEPPER_MAX_SPEED);
    sldDeliverySpeed.setValue(deliverySpeed);
    sldDeliverySpeed.addListenerFor(Button.ACTION_RELEASE, this);
    sldDeliverySpeed.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    sldDeliverySpeed.setSize(sliderWidth, elementHeight);
    sldDeliverySpeed.setPosition(currX, currY);
    
    currY += sldDeliverySpeed.getHeight() + spacingY;
    
    rngDraftingSpeeds = cp5.addRange("Drafting perc.");
    rngDraftingSpeeds.setDecimalPrecision(0);
    rngDraftingSpeeds.addListenerFor(Button.ACTION_RELEASE, this);
    rngDraftingSpeeds.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    rngDraftingSpeeds.setSize(sliderWidth, elementHeight);
    rngDraftingSpeeds.setPosition(currX, currY);
    rngDraftingSpeeds.setMin(0);
    rngDraftingSpeeds.setMax(100);
    rngDraftingSpeeds.setLowValue(draftingSpeedMin);
    rngDraftingSpeeds.setHighValue(draftingSpeedMax);
    
    currY += rngDraftingSpeeds.getHeight() + spacingY;
    
    sldElevatorSpeed = cp5.addSlider("Elevator Speed");
    sldElevatorSpeed.setSliderMode(Slider.FIX);
    sldElevatorSpeed.setDecimalPrecision(0);
    sldElevatorSpeed.setMin(0);
    sldElevatorSpeed.setMax(STEPPER_MAX_SPEED);
    sldElevatorSpeed.setValue(elevatorSpeed);
    sldElevatorSpeed.addListenerFor(Button.ACTION_RELEASE, this);
    sldElevatorSpeed.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    sldElevatorSpeed.setSize(sliderWidth, elementHeight);
    sldElevatorSpeed.setPosition(currX, currY);
    
    currY += sldElevatorSpeed.getHeight() + spacingY;
    
    sldSpindleSpeed = cp5.addSlider("Spindle Speed");
    sldSpindleSpeed.setSliderMode(Slider.FIX);
    sldSpindleSpeed.setDecimalPrecision(0);
    sldSpindleSpeed.setMin(0);
    sldSpindleSpeed.setMax(STEPPER_MAX_SPEED);
    sldSpindleSpeed.setValue(spindleSpeed);
    sldSpindleSpeed.addListenerFor(Button.ACTION_RELEASE, this);
    sldSpindleSpeed.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    sldSpindleSpeed.setSize(sliderWidth, elementHeight);
    sldSpindleSpeed.setPosition(currX, currY);
    
    currY += sldSpindleSpeed.getHeight() + spacingY;
    
    sldPixelLength = cp5.addSlider("Pixel Length (mm)");
    sldPixelLength.setDecimalPrecision(0);
    sldPixelLength.setMin(10);
    sldPixelLength.setMax(300);
    sldPixelLength.setValue(pixelLength);
    sldPixelLength.addListenerFor(Button.ACTION_RELEASE, this);
    sldPixelLength.addListenerFor(Button.ACTION_RELEASE_OUTSIDE, this);
    sldPixelLength.setSize(sliderWidth, elementHeight);
    sldPixelLength.setPosition(currX, currY);
    
    currY += sldPixelLength.getHeight() + spacingY;
    currY += spacingY;
    
    /*
    txtSerialPort = cp5.addTextfield("Serial Port");
    txtSerialPort.getValueLabel().getStyle().marginLeft = 10;
    txtSerialPort.getCaptionLabel().getStyle().marginTop = (int)(-fontSize * 1.5);
    txtSerialPort.getCaptionLabel().getStyle().marginLeft = sliderWidth + 5;
    txtSerialPort.setValue(port);
    txtSerialPort.setSize(sliderWidth, elementHeight -4); // there seems to be an issue with bigger heights: the text is cut
    txtSerialPort.setPosition(currX, currY);
    
    currY += txtSerialPort.getHeight() + spacingY;
    */
    
    btnConnect = cp5.addButton("Connect");
    btnConnect.addListenerFor(Button.ACTION_RELEASE, this);
    //btnConnect.setHeight(elementHeight);
    btnConnect.setSize((int)(textWidth(btnConnect.getLabel()) * 2), elementHeight);
    btnConnect.setPosition(currX, currY);
    
    statusSize = btnConnect.getHeight() -10;
    statusX = (int)btnConnect.getPosition()[0] + btnConnect.getWidth() + statusSize;
    statusY = (int)btnConnect.getPosition()[1] + (btnConnect.getHeight()/2);
    
    currY += btnConnect.getHeight() + spacingY;
    
    ddlSerialPort = cp5.addScrollableList("Serial Port");
    ddlSerialPort.setOpen(false);
    ddlSerialPort.getCaptionLabel().getStyle().marginTop = 5;
    ddlSerialPort.getValueLabel().getStyle().marginTop = 5;
    ddlSerialPort.setBarHeight(elementHeight);
    ddlSerialPort.setItemHeight(elementHeight);
    ddlSerialPort.setSize(this.w - (2 * borderX), elementHeight*5);
    //ddlSerialPort.setSize(sliderWidth, elementHeight); // there seems to be an issue with bigger heights: the text is cut
    ddlSerialPort.setPosition(currX, currY);
    populateSerialPorts();
    ddlSerialPort.addListenerFor(DropdownList.ACTION_ENTER, this);
    /*
    for (int i = 0; i < 10; i++) {
      ddlSerialPort.addItem("Item " +i, i);
    }
    */
    
    currY += ddlSerialPort.getHeight() + spacingY;
    currY += spacingY;
  }
  
  
  protected void populateSerialPorts() {
    println("UIControls.populateSerialPorts()");
    
    ddlSerialPort.clear();
    ddlSerialPort.addItem("Simulator", 0);
    
    String [] serialPortList = Serial.list();
    for (int i = 0; i < serialPortList.length; i++) {
      ddlSerialPort.addItem(serialPortList[i], i+1);
    }
  }
  
  void update() {
  }
  
  void draw() {
    update();
    
    //noFill();
    //stroke(255, 0, 255);
    //rect(x, y, w, h);
    
    noStroke();
    fill(statusColor);
    ellipse(statusX, statusY, statusSize, statusSize);
  }
  
  String getSerialPort() {
    return ddlSerialPort.getLabel();
  }
  
  int getDraftingSpeedMin() {
    return (int)rngDraftingSpeeds.getLowValue();
  }
  
  int getDraftingSpeedMax() {
    return (int)rngDraftingSpeeds.getHighValue();
  }
  
  int getDeliverySpeed() {
    return (int)sldDeliverySpeed.getValue();
  }
  
  int getElevatorSpeed() {
    return (int)sldElevatorSpeed.getValue();
  }
  
  int getSpindleSpeed() {
    return (int)sldSpindleSpeed.getValue();
  }
  
  int getPixelLength() {
    return (int)sldPixelLength.getValue();
  }
  
  int getSamplesX() {
    return (int)sldSamplesX.getValue();
  }
  
  int getSamplesY() {
    return (int)sldSamplesY.getValue();
  }
  
  int getGrayRangeMin() {
    return (int)rngGrayRange.getLowValue();
  }
  
  int getGrayRangeMax() {
    return (int)rngGrayRange.getHighValue();
  }
  
  void setConnected(boolean value) {
    if (isConnected == value) return;
    
    isConnected = value;
    
    if (!isConnected) {
      btnConnect.setLabel("Connect");
    }
    else  {
      btnConnect.setLabel("Disconnect");
    }
    
    println("LABEL is now: " + btnConnect.getLabel());
  }
  
  void setStatusColor(color statusColor) {
    this.statusColor = statusColor; 
  }
  
  void controlEvent(CallbackEvent event) {
    int action = event.getAction();
    Controller controller = event.getController();
    println("UIControls.controlEvent(): action " + action);
    println("UIControls.controlEvent(): controller " + controller.getLabel());
    
    if (event.getController() == btnConnect && action == Button.ACTION_RELEASE) {
      if (!isConnected)
        uiCallback(ACTION_CONNECT);
      else
        uiCallback(ACTION_DISCONNECT);
    }
    
    else if (event.getController() == btnOpen && action == Button.ACTION_RELEASE) {
      uiCallback(ACTION_OPEN_FILE);
    }
    
    else if (event.getController() == rngDraftingSpeeds && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_DRAFTING_SPEED);
    }
    
    else if (event.getController() == sldDeliverySpeed && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_DELIVERY_SPEED);
    }
    
    else if (event.getController() == sldElevatorSpeed && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_ELEVATOR_SPEED);
    }
    
    else if (event.getController() == sldSpindleSpeed && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_SPINDLE_SPEED);
    }
    
    else if (event.getController() == sldPixelLength && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_PIXEL_LENGTH);
    }
    
    else if (event.getController() == sldSamplesX && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_SAMPLES_X);
    }
    else if (event.getController() == sldSamplesY && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_SAMPLES_Y);
    }
    
    else if (event.getController() == rngGrayRange && (action == Button.ACTION_RELEASE || action == Button.ACTION_RELEASE_OUTSIDE)) {
      uiCallback(ACTION_GRAY_RANGE);
    }
    
    else if (event.getController() == ddlSerialPort && action == DropdownList.ACTION_ENTER) {
      populateSerialPorts();
      println("ENTER " + nf(millis()/1000, 0, 2));
    }
  }
}
