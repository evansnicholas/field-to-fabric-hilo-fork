// HILO App (main tab)
// Contains general, app-related global definitions and objects
// as well as Processing's core functions (e.g. setup, draw, mouse and keyboard)

// name and location of settings files
final static String APP_DEFAULT_SETTINGS_FILE         = "HILO_AppSettings.json";
final static String APP_DEFAULT_MACHINE_SETTINGS_FILE = "HILO_MachineSettings.json";
final static String APP_DEFAULT_SETTINGS_FOLDER       = "settings/";

// identifiers the fibre being worked on; 
// only FIBRE_WOOL is currently supported
final static int FIBRE_WOOL   = 0;
final static int FIBRE_COTTON = 1;
final static int FIBRE_SYNTH  = 2;
final static int FIBRE_SILK   = 3;

AppSettings appSettings;         // loads and stores global settings for the app
MachineSettings machineSettings; // loads and stores settings for the HILO machine
AppStrings appStrings;           // loads and stores text strings used in the app

// callback handler for the UI; receives callbacks when UI elements change
// (e.g. clicked, dragged, released, scrolled)
AppUICallbackHandler   appUICallbackHandler;

// Callback handler for the machine; receives callbacks when the machine's state changes
// (e.g. connected/disconnected, spinning/stopped)
AppHILOCallbackHandler appHILOCallbackHandler;

// the abstract HILO object through which we control the machine (or simulator)
HILOInterface hilo;

// The serial port selected by the user (default is simulator)
String selectedSerialPort = HILOSimulator.SIMULATOR_PORT_NAME;

// The fibre type selected by the user (default is wool)
int selectedFibre = FIBRE_WOOL;


// == PROCESSING MAIN FUNCTIONS =========================================================


// Called by Processing before the app starts
void settings() {
  // load the app settings
  appSettings = new AppSettings();
  appSettings.load(APP_DEFAULT_SETTINGS_FOLDER + APP_DEFAULT_SETTINGS_FILE);
  
  if (appSettings.fullscreen) {
    debugMessage("Starting fullscreen.");
    fullScreen();
  }
  else {
    debugMessage("Starting at " + appSettings.width + "x" + appSettings.height);
    size(appSettings.width, appSettings.height);
  }
  
  // load the app strings (text that is displayed in the app) from the file indicated in the app settings
  appStrings = new AppStrings();
  debugMessage("Loading app strings from " + APP_DEFAULT_SETTINGS_FOLDER + appSettings.langFile);
  appStrings.load(APP_DEFAULT_SETTINGS_FOLDER + appSettings.langFile);
  
  // load the machine settings; these are used to configure the machine once it connects
  machineSettings = new MachineSettings();
  debugMessage("Loading machine settings from " + APP_DEFAULT_SETTINGS_FOLDER + APP_DEFAULT_MACHINE_SETTINGS_FILE);
  machineSettings.load(APP_DEFAULT_SETTINGS_FOLDER + APP_DEFAULT_MACHINE_SETTINGS_FILE);
}


// Called by Processing when the app starts 
void setup() {
  debugMessage("Display size " + width + "x" + height);
  // called here because width/height are both 100 in settings()
  
  // create the handler objects
  appUICallbackHandler   = new AppUICallbackHandler();
  appHILOCallbackHandler = new AppHILOCallbackHandler();
  
  // create and set-up UI elements
  uiSetup();
  
  // create a HILO object (by default, a simulator)
  hilo = new HILOSimulator(appHILOCallbackHandler);
}


// Called by Processing to draw a new frame; updates and draws the UI
void draw() {
  uiUpdate();
  uiDraw();
}


// == KEYBOARD FUNCTIONS =========================================================


// Called by Processing when a key is pressed
void keyPressed() {
  if (key == CODED) {
    debugMessage("keyCode " + (int)keyCode);
  }
  else {
    switch (key) {
      case 'c':
        thread("connectHILO");
        break;
      case 'C':
        thread("disconnectHILO");
        break;
      case ' ':
        playPause();
        break;
      case 'l':
        if (isDebug) {
          String [] serialList = Serial.list();
          println("Serial list =========");
          for (int i = 0; i < serialList.length; i++)
            println(serialList[i]);
          println("=====================");
        }
        break;
      default:
        debugMessage("key " + (int)key + " [" + (char)key + "]");
        break;
    }
  }
}


// == MOUSE FUNCTIONS =========================================================


// Called by Processing when a mouse button is pressed; we don't distinguish between mouse buttons.
void mousePressed() {
  // If the splash screen was clicked, return immediately
  if (uiSplash.touch(mouseX, mouseY)) return;

  // Propagate the event to the UI elements;
  // each element is then responsible for handling the event (updating and triggering callbacks)  
  uiMainCanvas.touch(mouseX, mouseY);
  uiToolPaneSpin.touch(mouseX, mouseY);
}

// Called by Processing when the mouse is dragged (i.e. mouse moved while a mouse button is pressed)
void mouseDragged() {
  // Propagate the event to the UI elements;
  // each element is then responsible for handling the event (updating and triggering callbacks)
  uiMainCanvas.drag(pmouseX, pmouseY, mouseX, mouseY);
  uiToolPaneSpin.drag(pmouseX, pmouseY, mouseX, mouseY);
}

// Called by Processing when a mouse button is released
void mouseReleased() {
  // Propagate the event to the UI elements;
  // each element is then responsible for handling the event (updating and triggering callbacks)
  uiMainCanvas.release(mouseX, mouseY);
  uiToolPaneSpin.release(mouseX, mouseY);
}

// Called by Processing when the mouse wheel is scrolled
void mouseWheel(MouseEvent event) {
  // get the mouse's current position and the amount of scrolling
  int x = event.getX();
  int y = event.getY();
  float amount = event.getCount();

  // Propagate the event to the UI elements;
  // each element is then responsible for handling the event (updating and triggering callbacks)
  uiMainCanvas.scroll(x, y, amount);
  uiToolPaneSpin.scroll(x, y, amount);
}
