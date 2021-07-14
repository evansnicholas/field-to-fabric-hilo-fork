import controlP5.*;

final static float  ROLL_PERIMETER              = 8.64; // centimeters
final static int    STEPPER_TOTAL_STEPS         = 200;  // amount of steps for a complete turn
final static int    STEPPER_MAX_SPEED           = 1000; // steps/second

final static int    DATA_UI_MAX_SAMPLES         = 100;  // maximum value for the x/y samples slider

final static int    DEFAULT_DRAFTING_SPEED_MIN  = 20;   // percentage of delivery speed
final static int    DEFAULT_DRAFTING_SPEED_MAX  = 60;   // percentage of delivery speed
final static int    DEFAULT_DELIVERY_SPEED      = 150;  // steps/second
final static int    DEFAULT_ELEVATOR_SPEED      = 600;  // steps/second
final static int    DEFAULT_SPINDLE_SPEED       = 600;  // steps/second
final static int    DEFAULT_PIXEL_LENGTH        = 50;   // millimeters
final static int    DEFAULT_SAMPLES_X           = 5;
final static int    DEFAULT_SAMPLES_Y           = 5;
final static int    DEFAULT_GRAY_MIN            = 150;
final static int    DEFAULT_GRAY_MAX            = 255;

static final int    PARAM_UPDATE_DELAY          = 200;
final static String DEFAULT_IMAGE_FILE          = "Checkers_5x5.png";

boolean useSimulator = true;

HILOInterface          hilo;
AppHILOCallbackHandler hiloHandler;
HILODataImage          data;

UIPreview  uiData;
UIControls uiControls;
UIYarn     uiYarn;

int draftingSpeedPercMin = DEFAULT_DRAFTING_SPEED_MIN;
int draftingSpeedPercMax = DEFAULT_DRAFTING_SPEED_MAX;

boolean autoMode    = false;
boolean showPreview = false;

boolean isHandlingPixel = false;

int uiSpacing;
int uiCtrlX, uiCtrlY, uiCtrlW, uiCtrlH;
int uiImageX, uiImageY, uiImageW, uiImageH;
int uiYarnX, uiYarnY, uiYarnW, uiYarnH;

int timePixelStarted;
int timeSinglePixel;

int timeCurr;
int timePrev;
int timeDiff;

void setup() {
  //fullScreen();
  size(1200, 800);
  //size(800, 800);
  println("### SETUP ###");
  println("display: " + displayWidth + "x" + displayHeight);
  println("window: "  + width + "x" + height);
  
  uiSpacing = 10;
  
  uiCtrlW = 400 - (2*uiSpacing);
  uiCtrlH = (int)(height * 0.9) - (2*uiSpacing);
  uiCtrlX = width - uiSpacing - uiCtrlW;
  uiCtrlY = uiSpacing;
  
  uiImageW = width - uiCtrlW - (3*uiSpacing);
  uiImageH = (int)(height * 0.9) - (2*uiSpacing);
  uiImageX = uiSpacing;
  uiImageY = uiSpacing;
  
  uiYarnX = uiSpacing;
  uiYarnY = uiImageY + uiImageH + uiSpacing;
  uiYarnW = width - (2*uiSpacing);
  uiYarnH = height - uiImageY - uiImageH - (2*uiSpacing);
  
  PImage dataImage = loadImage(DEFAULT_IMAGE_FILE);
  
  data = new HILODataImage();
  data.setImage(dataImage, DEFAULT_SAMPLES_X, DEFAULT_SAMPLES_Y);
  data.setDataRange(DEFAULT_GRAY_MIN, DEFAULT_GRAY_MAX);
  
  //uiData = new UIDataImage();
  uiData = new UIPreview();
  uiData.setRect(uiImageX, uiImageY, uiImageW, uiImageH);
  uiData.setData(data);
  
  uiControls = new UIControls(this);
  uiControls.init(
    uiCtrlX, uiCtrlY, uiCtrlW, uiCtrlH,
    DEFAULT_DRAFTING_SPEED_MIN, DEFAULT_DRAFTING_SPEED_MAX,
    DEFAULT_DELIVERY_SPEED,
    DEFAULT_ELEVATOR_SPEED,
    DEFAULT_SPINDLE_SPEED,
    DEFAULT_PIXEL_LENGTH,
    DEFAULT_SAMPLES_X, DEFAULT_SAMPLES_Y,
    DEFAULT_GRAY_MIN, DEFAULT_GRAY_MAX
  );
  
  uiYarn = new UIYarn();
  uiYarn.setRect(uiYarnX, uiYarnY, uiYarnW, uiYarnH);
  
  hiloHandler = new AppHILOCallbackHandler();
  
  if (useSimulator)
    hilo = new HILOSimulator(hiloHandler);
  else
    hilo = new HILODevice(this, hiloHandler);
}

void stop() {
  println("### STOP ###");
  hilo.disconnect();
}

void update() {
  timePrev = timeCurr;
  timeCurr = millis();
  timeDiff = timeCurr - timePrev;
  
  if (hilo.isConnected() && hilo.isSpinning()) {
    if (timeCurr - timePixelStarted > timeSinglePixel) {
      // retrive the value of next pixel
      // call hilo.spin() with the value
      // otherwise call hilo.stop()
      
      if (!data.next()) {
        println("update() WARNING: reached the end of data, press 'r' to reset");
        if (autoMode) {
          println("update(): turning off auto mode");
          autoMode = false;
        }
      }
      
      if (autoMode) {
        sendPixel();
      }
      else {
        hilo.stop();
      }
    }
  }
}

void draw() {
  update();
  
  background(#E3E5F5); //#E1C5E8);
  
  noStroke();
  //fill(0, 140); //#434F6C);
  fill(#677A90);
  rect(uiCtrlX, uiCtrlY, uiCtrlW, uiCtrlH);
  
  noStroke();
  color statusColor = color(180);
  if (hilo.getState() == HILOStatus.CONNECTING) {
    statusColor = color(#FFE200);
  }
  else if (hilo.isSpinning()) {
    statusColor = color(#00FFFF);
  }
  else if (hilo.hasError()) {
    statusColor = color(#FF0000);
  }
  else if (hilo.isConnected()) {
    statusColor = color(#00FF00);
  }
  
  uiControls.setStatusColor(statusColor);
  uiControls.draw();
  
  noStroke();
  fill(0);
  uiYarn.draw(g);
  
  if (!showPreview) uiData.draw(g);
  else uiData.drawPreview(g);
}

void onHILOConnected() {
  println("onHILOConnected()");
  uiControls.setConnected(true);
  thread("uploadConfig");
  //uploadConfig();
}


void sendPixel() {  
  // convert a grayscale range 0.0 - 1.0 (black/white) to a high/low drafting speed (respectively), so that:
  // - a black pixel corresponds to a HIGH drafting speed (thick yarn)
  // - a white pixel corresponds to a LOW  drafting speed (thin yarn)
  
  int hiloPixelValue = (int)map(data.value(), 0.0, 1.0, uiControls.getDraftingSpeedMax(), uiControls.getDraftingSpeedMin());
  println("sendPixel(): calling spin() with drafting speed " + hiloPixelValue + " percent");
  timePixelStarted = timeCurr;
  hilo.spin(hiloPixelValue);
  uiYarn.addValue(hiloPixelValue);
}


void keyPressed() {
  if (key != CODED) {
    switch (key) {
      case 'c':
        thread("connectHILO");
      break;
      case 'C':
        thread("disconnectHILO");
      break;
      case 'p':
       sendPixel();
      break;
      case 'P':
      case ' ':
        if (!hilo.isConnected()) {
          // do nothing
        }
        else if (!autoMode) {
          println("keyPressed(): auto mode ON");
          autoMode = true;
          if (hilo.isConnected() && !hilo.isSpinning()) {
            sendPixel();
          }
        }
        else {
          println("keyPressed(): auto mode OFF");
          autoMode = false;
        }
      break;
      case 'r':
        data.reset();
      break;
      case 'd':
        uiData.setShowOriginalImage(!uiData.isShowOriginalImage());
      break;
      case 'D':
        showPreview = (!showPreview);
      break;
      case 'S':
        thread("uploadConfig");
      break;
    }
  }
  else {
    //println ("keyPressed(): key (coded) " + keyCode);
    switch (keyCode) {
      case LEFT:
        data.previous();
      break;
      case RIGHT:
        data.next();
      break;
      case UP:
        data.previousRow();
      break;
      case DOWN:
        data.nextRow();
      break;
    }
  }
}

void connectHILO() {
  if (hilo.isConnected()) {
    println("connectHILO() WARNING: HILO is already connected");
  }
  else {
    String portName = uiControls.getSerialPort();
    println("connectHILO(): connecting on port <" + portName + ">");
    
    if (portName.equalsIgnoreCase("simulator") || portName.equalsIgnoreCase("-") || portName.equalsIgnoreCase("Serial Port")) {
      if (!useSimulator) {
        println("connectHILO(): switching to simulator");
        useSimulator = true;
        hilo = new HILOSimulator(hiloHandler);
      }
    }
    else {
      if (useSimulator) {
        println("connectHILO(): switching to device");
        useSimulator = false;
        hilo = new HILODevice(this, hiloHandler);
      }
    }
    
    hilo.connect(portName);
  }
}

void disconnectHILO() {
  hilo.disconnect();
  uiControls.setConnected(false);
}

void setDraftingSpeedFromUI() {
  draftingSpeedPercMin = floor(uiControls.getDraftingSpeedMin());
  draftingSpeedPercMax = floor(uiControls.getDraftingSpeedMax());
}

void setDeliverySpeedFromUI() {
  hilo.setDeliverySpeed(uiControls.getDeliverySpeed());
  delay(PARAM_UPDATE_DELAY);
  // we need to recalculate the drafting speed
  setDraftingSpeedFromUI();
  // we need to realculate the time required to spin a pixel
  calcTimeSinglePixel();
}

void setElevatorSpeedFromUI() {
  hilo.setElevatorSpeed(uiControls.getElevatorSpeed());
}

void setSpindleSpeedFromUI() {
  hilo.setSpindleSpeed(uiControls.getSpindleSpeed());
}

void setPixelLengthFromUI() {
  calcTimeSinglePixel();
}

void calcTimeSinglePixel() {
  float pixelLengthCm = uiControls.getPixelLength() / 10f;
  float stepsPerCm = (float)STEPPER_TOTAL_STEPS / (float) ROLL_PERIMETER;
  float pixelLengthSteps = pixelLengthCm * stepsPerCm;
  timeSinglePixel = floor(pixelLengthSteps * 1000f / (float)uiControls.getDeliverySpeed()); //(float)hilo.getDeliverySpeed());
  println("calcTimeSinglePixel() updated pixel length:");
  println("  " + nf(pixelLengthCm, 0, 1) + " centimeters");
  println("  " + floor(pixelLengthSteps) + " steps");
  println("  " + nf(timeSinglePixel/1000.0, 0, 2) + " seconds");
}

void uploadConfig() {
  setDeliverySpeedFromUI();
  // the following already happens within the previous call
  //delay(100);
  //setDraftingSpeedFromUI();
  delay(PARAM_UPDATE_DELAY);
  setElevatorSpeedFromUI();
  delay(PARAM_UPDATE_DELAY);
  setSpindleSpeedFromUI();
  delay(PARAM_UPDATE_DELAY);
  setPixelLengthFromUI();
  delay(PARAM_UPDATE_DELAY);
}


//## CALLBACKS #########################################

void uiCallback(int action) {
  //autoMode = false;
  switch (action) {
    case UIControls.ACTION_CONNECT:
      println("uiCallback(): ACTION_CONNECT");
      thread("connectHILO");
    break;
    case UIControls.ACTION_DISCONNECT:
      println("uiCallback(): ACTION_DISCONNECT");
      thread("disconnectHILO");
    break;
    case UIControls.ACTION_OPEN_FILE:
      println("uiCallback(): ACTION_OPEN_FILE");
      selectInput("Select an image file to open", "imageFileSelected");
    break;
    case UIControls.ACTION_DRAFTING_SPEED:
      println("uiCallback(): ACTION_SPINDLE_SPEED");
      setDraftingSpeedFromUI();
    break;
    case UIControls.ACTION_DELIVERY_SPEED:
      println("uiCallback(): ACTION_DELIVERY_SPEED");
      setDeliverySpeedFromUI();
    break;
    case UIControls.ACTION_ELEVATOR_SPEED:
      println("uiCallback(): ACTION_ELEVATOR_SPEED");
      setElevatorSpeedFromUI();
    break;
    case UIControls.ACTION_SPINDLE_SPEED:
      println("uiCallback(): ACTION_SPINDLE_SPEED");
      setSpindleSpeedFromUI();
    break;
    case UIControls.ACTION_PIXEL_LENGTH:
      println("uiCallback(): ACTION_PIXEL_LENGTH");
      setPixelLengthFromUI();
    break;
    case UIControls.ACTION_SAMPLES_X:
      println("uiCallback(): ACTION_SAMPLES_X");
      uiData.setDataSize(uiControls.getSamplesX(), uiControls.getSamplesY());
    break;
    case UIControls.ACTION_SAMPLES_Y:
      println("uiCallback(): ACTION_SAMPLES_Y");
      uiData.setDataSize(uiControls.getSamplesX(), uiControls.getSamplesY());
    break;
    case UIControls.ACTION_GRAY_RANGE:
      println("uiCallback(): ACTION_GRAY_RANGE");
      uiData.setDataRange(uiControls.getGrayRangeMin(), uiControls.getGrayRangeMax());
    break;
  }
}

void imageFileSelected(File selection) {
  if (selection == null) {
    println("imageFileSelected(): cancelled");
    return;
  }
  println("imageFileSelected(): selected <" + selection.getAbsoluteFile() + ">");
  
  PImage newDataImage = loadImage(selection.getAbsoluteFile().toString());
  if (newDataImage != null && !newDataImage.isLoaded()) {
    data.setImage(newDataImage, uiControls.getSamplesX(), uiControls.getSamplesY());
    uiData.setData(data);
  }
  else {
    println("imageFileSelected() ERROR: couldn't open file!");
  }
}


// == HILO CALLBACK HANDLER =================================================================


class AppHILOCallbackHandler implements HILOCallbackHandler {
  
  // Called when HILO is connected (i.e. the serial port is open)
  void onHILOConnected() {
    println("AppHILOCallbackHandler.onHILOConnected()");
    uiControls.setConnected(true);
    thread("uploadConfig");
  }
  
  // Called when HILO is disconnected.
  void onHILODisconnected() {
    println("AppHILOCallbackHandler.onHILODisconnected()");
    uiControls.setConnected(false);
  }
  
  // Called when HILO starts spinning.
  void onStartSpinning() {
    println("AppHILOCallbackHandler.onStartSpinning()");
  }
  
  // Called when HILO stops spinning.
  void onStopSpinning() {
    println("AppHILOCallbackHandler.onStopSpinning()");
  }
}
