// UI - Layout
// This tab contains variables, objects and methods used to create, compose and update the app's UI.
// It does not contain the UI classes; those cane be found in the other UI tabs.
// Additionally, the object which handles UI callbacks (when UI elements are clicked, dragged, etc.) 
// can be found in a separate tab (see AppUICallbackHandler).


// Identifiers for each UI element, which allow us to know
// which element is being handled in a callback (see AppUICallbackHandler).
final static int UI_BUTTON_SPLASH          = 10;  // splash screen (acts as a giant button)
final static int UI_BUTTON_SPIN            = 11;  // spin mode button
final static int UI_BUTTON_TWIST           = 12;  // twist mode button
final static int UI_BUTTON_PATTERN         = 13;  // pattern mode button
final static int UI_BUTTON_FIBRE_WOOL      = 14;  // wool fibre button
final static int UI_BUTTON_FIBRE_BACK      = 21;  // back button on fibre selection 
final static int UI_BUTTON_SPIN_BACK       = 22;  // back button on spin view
final static int UI_BUTTON_CONNECT_BACK    = 24;  // back button on connect view
final static int UI_BUTTON_SPINNER_BACK    = 25;  // back button on connecting (spinner) view
final static int UI_BUTTON_PLAY_PAUSE      = 31;  // play/pause button
final static int UI_SLIDER_THICKNESS       = 41;  // thickness slider on spin view
final static int UI_SLIDER_TWISTS          = 42;  // number of twists slider on spin view
final static int UI_LIST_PORT              = 70;  // serial port list
final static int UI_BUTTON_REFRESH_PORTS   = 71;  // serial port list refresh (acts as a button) 

// states for the play/pause button
final static int BUTTON_STATE_PLAY  = 0;
final static int BUTTON_STATE_PAUSE = 1;


// UI resolution, used in the choice of layout and assets
final static int LOW_RES  = 0;
final static int MID_RES  = 1;
final static int HIGH_RES = 2;

// window width/height thresholds for mid- and high-resolution modes
final static int MID_RES_MIN_WIDTH   = 1024;
final static int MID_RES_MIN_HEIGHT  =  768;
final static int HIGH_RES_MIN_WIDTH  = 1280;
final static int HIGH_RES_MIN_HEIGHT =  800;

// assets folder locations for each resolution mode 
final static String ASSET_FOLDER_LOW  = "icons/small/";
final static String ASSET_FOLDER_MID  = "icons/medium/";
final static String ASSET_FOLDER_HIGH = "icons/large/";

// the current resolution and corresponding asset folder (default low)
int    uiResolution       = LOW_RES;
String uiImageAssetFolder = ASSET_FOLDER_LOW;


// == UI LAYOUT PARAMETERS ===================================================================


// Following are layout parameters for the UI.
// These include position and size of elements, spacing between them, among others.
// Variables that don't have a value assigned are calculated while the UI is being built at run-time, 
// once the size of the window and assets is know.
// Ideally, we would have a consistent metric, but given the UI's visual design, this wasn't always possible.
// Variable names should be self explanatory in most cases. In some cases, however, comments help to understand the variable's purpose.

int uiPadding                = 20; 
int uiPaddingTop             = 62; // will be re-calculated depending on the height of the logo

int uiHeaderLogoY;
int uiCanvasHeight;
int uiCanvasLargeWidth;  // width of canvas when the toolpane is hidden
int uiCanvasSmallWidth;  // width of canvas when the toolpane is visible

int uiSpacingUnderTitle     =  58;
int uiSpacingMainIcons      =  45;
int uiSpacingIconsSubText   =  15;

float uiToolPaneWidthRatio  = 0.28; // the toolpane takes up 28% of the overall width...
int   uiToolPaneWidthMin    = 365;  // ...but is at least 365 pixels wide
int   uiToolPaneWidth;

int uiToolPaneOuterPadding  =  20;
int uiToolPaneInnerPadding  =  20;
int uiToolPaneSliderPadding =  25;
int uiToolPaneElemHeight    =  25;
int uiToolPaneElemSpacing   =  20;
int uiToolPaneElemSpacingS  =  10;  // a smaller spacing between elements
int uiSpacingPlayPause      =  30;

int uiSliderX;
int uiSliderH               =  20;  // sliders have a consistent height
int uiSliderW;

int uiStatusIndicatorSize   =  16;

int uiTwistWidth            = 370;
int uiTwistHeight           =  44;

int uiPortListLineWeight    =   2;
int uiPortListPadding       =  12;
int uiPortListScrollW       =  18;

int uiPortListRelativeY     = 264;
int uiPortListW             = 230;
int uiPortListH             = 162;

int uiBackButtonPadding     =  10;


// == UI ASSETS ===================================================================


// UI colors
color uiColDark  = #211646;
color uiColLight = #FFFFFF;

// UI fonts (Objectivity with different sizes and styles)
PFont fontTitle;
PFont fontMode;
PFont fontTool;
PFont fontToolBold;
PFont fontSlider;
PFont fontNumField;
PFont fontStatus;
PFont fontUSBList;

// UI images/icons
PImage imgLogoMain;
PImage imgLogoHeader;
PImage imgBackArrow;
PImage imgModeSpin;
PImage imgModeTwist;
PImage imgModeEffect;
PImage imgFibreWool;
PImage imgFibreCotton;
PImage imgFibreSynth;
PImage imgFibreSilk;
PImage imgFibreNew;
PImage imgFibreWoolS;
PImage imgClose;
PImage imgPlay;
PImage imgPause;
PImage imgUSB;
PImage imgSpinner;


// == UI ELEMENTS ===================================================================


UIMainCanvas     uiMainCanvas;

UIViewSlide      uiSplash;

UIViewFade       uiViewWelcome;
UIText           uiTextWelcome;
UIHorizontalGrid uiGridMode;

UIViewFade       uiViewFibre;
UIText           uiTextFibre;
UIHorizontalGrid uiGridFibre;
UIButtonStatic   uiBtnFibreBack;

UIViewFade       uiViewSpin;
UIYarnTwists     uiYarnTwists;
UIButtonStatic   uiBtnSpinBack;

UIViewFade       uiViewConnect;
UIGroup          uiGroupPortList;
UIList           uiPortList;
UIButtonStatic   uiBtnConnectBack;

UIViewFade       uiViewSpinner;
UIButtonStatic   uiBtnSpinnerBack;

UIViewSlide      uiToolPaneSpin;
UIGroup          uiGroupSpinSelection;
UIImage          uiIconSpinFibre;
UIText           uiTextSpinFibre;
UIButtonStatic   uiBtnFiberClose;
UIGroup          uiGroupSpinControls;
UISlider         uiSliderThickness;
UISlider         uiSliderTwists;

UIText           uiTextStatus;
UIMachineStatus  uiStatusIndicator;
UIButtonToggle   uiBtnPlayPause;


// == UI CREATION/SETUP ===================================================================


// Set up the UI by loading assets, then creating and laying out UI elements (e.g. views, buttons, sliders). 
// This includes determining the resolution mode, so that the correct assets can be loaded 
// and the position and size of UI elements be calculated when necessary.
void uiSetup() {
  
  // fonts are scaled on creation, depending on the resolution
  float fontSizeFactor = 1.0;
  
  // determine wether to run in low, mid or high resolution, based on the window dimensions
  if (width >= HIGH_RES_MIN_WIDTH || height >= HIGH_RES_MIN_HEIGHT) {
    debugMessage("uiSetup(): UI in high res. mode");
    uiResolution       = HIGH_RES;
    uiImageAssetFolder = ASSET_FOLDER_HIGH;
    fontSizeFactor     = 1.0;
  }
  else if (width >= MID_RES_MIN_WIDTH || height >= MID_RES_MIN_HEIGHT) {
    debugMessage("uiSetup(): UI in mid res. mode");
    uiResolution       = MID_RES;
    uiImageAssetFolder = ASSET_FOLDER_MID;
    fontSizeFactor     = 0.84;
  }
  else {
    debugMessage("uiSetup(): UI in low res. mode");
    uiResolution       = LOW_RES;
    uiImageAssetFolder = ASSET_FOLDER_LOW;
    fontSizeFactor     = 0.65;
  }
  
  // create fonts
  fontTitle    = createFont("fonts/Objectivity-Regular.otf", 36 * fontSizeFactor);
  fontMode     = createFont("fonts/Objectivity-Regular.otf", 24 * fontSizeFactor);
  fontTool     = createFont("fonts/Objectivity-Regular.otf", 26 * fontSizeFactor);
  fontToolBold = createFont("fonts/Objectivity-Bold.otf",    26 * fontSizeFactor);
  fontSlider   = createFont("fonts/Objectivity-Regular.otf", 18 * fontSizeFactor);
  fontNumField = createFont("fonts/Objectivity-Regular.otf", 20 * fontSizeFactor);
  fontStatus   = createFont("fonts/Objectivity-Bold.otf",    22 * fontSizeFactor);
  fontUSBList  = createFont("fonts/Objectivity-Regular.otf", 24 * fontSizeFactor);

  // load image assets; the uiLoadImageAsset() function will fetch thse from 
  // the respective folder depending on whether the app is running in low, mid or high resolution
  imgLogoMain       = uiLoadImageAsset("LogoMain.png");
  imgLogoHeader     = uiLoadImageAsset("LogoHeader.png");
  imgBackArrow      = uiLoadImageAsset("Back.png");
  imgModeSpin       = uiLoadImageAsset("ModeSpin.png");
  imgModeTwist      = uiLoadImageAsset("ModeTwist.png");
  imgModeEffect     = uiLoadImageAsset("ModeEffect.png");
  imgFibreWool      = uiLoadImageAsset("FibreWool.png");
  imgFibreCotton    = uiLoadImageAsset("FibreCotton.png");
  imgFibreSynth     = uiLoadImageAsset("FibreSynth.png");
  imgFibreSilk      = uiLoadImageAsset("FibreSilk.png");
  imgFibreNew       = uiLoadImageAsset("FibreNew.png");
  imgFibreWoolS     = uiLoadImageAsset("FibreWool_S.png");
  imgClose          = uiLoadImageAsset("Close.png");
  imgPlay           = uiLoadImageAsset("Play.png");
  imgPause          = uiLoadImageAsset("Pause.png");
  imgUSB            = uiLoadImageAsset("USB.png");
  imgSpinner        = uiLoadImageAsset("Spinner.png");
  
  // calculate the top padding (or margin) depending on the height of the header logo 
  uiPaddingTop = imgLogoHeader.height + (2 * uiPadding);

  uiToolPaneWidth = (int)(width * uiToolPaneWidthRatio);
  if (uiResolution == LOW_RES) uiToolPaneWidthMin = 240;
  uiToolPaneWidth = max(uiToolPaneWidth, uiToolPaneWidthMin);

  uiCanvasHeight     = height -uiPaddingTop -uiPadding;
  uiCanvasLargeWidth = width - (uiPadding*2);
  uiCanvasSmallWidth = width -uiPadding -uiToolPaneWidth;
  uiHeaderLogoY      = (uiPaddingTop - imgLogoHeader.height) /2;

  uiSliderX = uiToolPaneSliderPadding;
  uiSliderW = uiToolPaneWidth - uiToolPaneSliderPadding - uiToolPaneInnerPadding - (2*uiToolPaneOuterPadding);
  
  uiMainCanvas = new UIMainCanvas(uiPadding, uiPaddingTop, uiCanvasLargeWidth, uiCanvasHeight);
  uiMainCanvas.setBackgroundColor(uiColLight);

  // SPLASH SCREEN  --------------------------------------------------------------------------------------
  
  uiSplash = new UIViewSlide(0, 0, width, height);
  uiSplash.setId(12345);
  uiSplash.setClosedPos(0, -height);
  uiSplash.animSpeed = 1500;
  uiSplash.setBackgroundColor(uiColDark);
  
  UIImage uiIconLogoMain = new UIImage(imgLogoMain, (uiSplash.w() - imgLogoMain.width)/2, (uiSplash.h() - imgLogoMain.height)/2);
  uiSplash.add(uiIconLogoMain);
  
  UIButtonStatic uiBtnSplash = new UIButtonStatic(0, 0, uiSplash.w(), uiSplash.h());
  uiBtnSplash.setId(UI_BUTTON_SPLASH);
  uiBtnSplash.setCallbackHandler(appUICallbackHandler);
  uiSplash.add(uiBtnSplash);

  // VIEW: WELCOME --------------------------------------------------------------------------------------

  uiViewWelcome = new UIViewFade(0, 0, uiCanvasLargeWidth, uiCanvasHeight);
  uiViewWelcome.setCallbackHandler(appUICallbackHandler);
  uiViewWelcome.setBackgroundColor(uiColLight);
  uiMainCanvas.add(uiViewWelcome);

  UIGroup uiGroupWelcome = new UIGroup(0, 0, uiViewWelcome.w(), uiViewWelcome.h());
  uiViewWelcome.add(uiGroupWelcome);

  uiTextWelcome = uiCreateText(appStrings.get("welcome"), fontTitle, uiColDark, 0, 0);
  uiTextWelcome.textAlign(CENTER, TOP);
  uiTextWelcome.setSize(uiTextWelcome.w(), fontTitle.getSize()*2.4);
  uiGroupWelcome.addToBottom(uiTextWelcome, 0); 

  uiGridMode = new UIHorizontalGrid();
  uiGridMode.setBackgroundColor(uiColLight);
  UIButtonSubText uiBtnModeSpin   = uiCreateButtonSub(UI_BUTTON_SPIN,    imgModeSpin,   0, 0, "Spin",   fontMode, uiColDark);
  UIButtonSubText uiBtnModeTwist  = uiCreateButtonSub(UI_BUTTON_TWIST,   imgModeTwist,  0, 0, "Twist",  fontMode, uiColDark);
  UIButtonSubText uiBtnModeEffect = uiCreateButtonSub(UI_BUTTON_PATTERN, imgModeEffect, 0, 0, "Effect", fontMode, uiColDark);
  uiBtnModeTwist.setEnabled(false);
  uiBtnModeEffect.setEnabled(false);
  uiGridMode.add(uiBtnModeSpin);
  uiGridMode.add(uiBtnModeTwist);
  uiGridMode.add(uiBtnModeEffect);
  uiGridMode.spacingH = uiSpacingMainIcons;
  uiGridMode.updateLayout();
  uiGroupWelcome.addToBottom(uiGridMode, uiViewWelcome.h() * 0.08); 
  
  uiGroupWelcome.centerElements(UIGroup.HORIZONTALLY);
  uiGroupWelcome.tightDimensions();
  uiViewWelcome.centerElements();

  // VIEW: FIBRE --------------------------------------------------------------------------------------------

  uiViewFibre = new UIViewFade(0, 0, uiCanvasLargeWidth, uiCanvasHeight);
  uiViewFibre.setCallbackHandler(appUICallbackHandler);
  uiViewFibre.setBackgroundColor(uiColLight);
  uiMainCanvas.add(uiViewFibre);
  
  UIGroup uiGroupFibre = new UIGroup(0, 0, uiViewFibre.w(), uiViewFibre.h());
  uiViewFibre.add(uiGroupFibre);

  uiTextFibre = uiCreateText(appStrings.get("fibre"), fontTitle, uiColDark, 0, 0);
  uiTextFibre.textAlign(CENTER, TOP);
  uiTextFibre.tightenDimensions();
  uiGroupFibre.addToBottom(uiTextFibre, 0); 

  uiGridFibre = new UIHorizontalGrid();
  uiGridFibre.setBackgroundColor(uiColLight);
  UIButtonSubText uiBtnFibreWool   = uiCreateButtonSub(UI_BUTTON_FIBRE_WOOL, imgFibreWool,   0, 0, appStrings.get("fibreWool"),   fontMode, uiColDark);
  UIButtonSubText uiBtnFibreCotton = uiCreateButtonSub(UIElement.ID_UNKNOWN, imgFibreCotton, 0, 0, appStrings.get("fibreCotton"), fontMode, uiColDark);
  UIButtonSubText uiBtnFibreSynth  = uiCreateButtonSub(UIElement.ID_UNKNOWN, imgFibreSynth,  0, 0, appStrings.get("fibreSynth"),  fontMode, uiColDark);
  UIButtonSubText uiBtnFibreSilk   = uiCreateButtonSub(UIElement.ID_UNKNOWN, imgFibreSilk,   0, 0, appStrings.get("fibreSilk"),   fontMode, uiColDark);
  UIButtonSubText uiBtnFibreNew    = uiCreateButtonSub(UIElement.ID_UNKNOWN, imgFibreNew,    0, 0, appStrings.get("fibreNew"),    fontMode, uiColDark);
  uiBtnFibreCotton.setEnabled(false);
  uiBtnFibreSynth.setEnabled(false);
  uiBtnFibreSilk.setEnabled(false);
  uiBtnFibreNew.setEnabled(false);
  uiGridFibre.add(uiBtnFibreWool);
  uiGridFibre.add(uiBtnFibreCotton);
  uiGridFibre.add(uiBtnFibreSynth);
  uiGridFibre.add(uiBtnFibreSilk);
  uiGridFibre.add(uiBtnFibreNew);
  uiGridFibre.spacingH = uiSpacingMainIcons;
  uiGridFibre.updateLayout();
  uiGroupFibre.addToBottom(uiGridFibre, uiViewFibre.h() * 0.08); 
  
  uiGroupFibre.centerElements(UIGroup.HORIZONTALLY);
  uiGroupFibre.tightDimensions();
  uiViewFibre.centerElements();
  
  uiBtnFibreBack = uiCreateBackButton(UI_BUTTON_FIBRE_BACK);
  uiViewFibre.add(uiBtnFibreBack);

  // VIEW: SPIN ------------------------------------------------------------------------------------------

  uiViewSpin = new UIViewFade(0, 0, uiCanvasSmallWidth, uiCanvasHeight);
  uiViewSpin.setCallbackHandler(appUICallbackHandler);
  uiViewSpin.setBackgroundColor(uiColLight);
  uiMainCanvas.add(uiViewSpin);

  uiYarnTwists = new UIYarnTwists(0, 0, uiTwistWidth, uiTwistHeight);
  uiYarnTwists.frequency = 50;
  uiViewSpin.add(uiYarnTwists);
  uiViewSpin.centerElement(uiYarnTwists);

  uiBtnSpinBack = uiCreateBackButton(UI_BUTTON_SPIN_BACK);
  uiViewSpin.add(uiBtnSpinBack);

  // VIEW: CONNECT --------------------------------------------------------------------------------------

  uiViewConnect = new UIViewFade(0, 0, uiCanvasLargeWidth, uiCanvasHeight);
  uiViewConnect.setCallbackHandler(appUICallbackHandler);
  uiViewConnect.setBackgroundColor(uiColLight);
  uiMainCanvas.add(uiViewConnect);
  
  UIGroup uiGroupConnect = new UIGroup(0, 0, uiViewConnect.w(), uiViewConnect.h());
  uiViewConnect.add(uiGroupConnect);

  UIText uiTextConnect = uiCreateText(appStrings.get("connect"), fontTitle, uiColDark, 0, 0);
  uiTextConnect.textAlign(CENTER, TOP);
  uiTextConnect.tightenDimensions();
  uiGroupConnect.addToBottom(uiTextConnect, 0);
  
  UIImage uiIconUSB = new UIImage(imgUSB, 0, 0);
  uiGroupConnect.addToBottom(uiIconUSB, 25);
  
  uiGroupPortList = new UIGroup(0, 0, uiViewConnect.w(), uiViewConnect.h());
  uiGroupPortList.setFrame(uiColDark, 3);
  
  UIText uiTextChoosePort = uiCreateText(appStrings.get("choosePort"), fontUSBList, uiColDark, 0, 0);
  uiTextChoosePort.underlineWeight = 2;
  uiTextChoosePort.textAlign(CENTER, TOP);
  uiTextChoosePort.tightenDimensions();
  uiGroupPortList.addToBottom(uiTextChoosePort, uiPortListPadding);
  
  UIButtonStatic uiBtnRefreshPortList = new UIButtonStatic(uiTextChoosePort.x(), uiTextChoosePort.y(), uiTextChoosePort.w(), uiTextChoosePort.h());
  uiBtnRefreshPortList.setId(UI_BUTTON_REFRESH_PORTS);
  uiBtnRefreshPortList.setCallbackHandler(appUICallbackHandler);
  uiGroupPortList.add(uiBtnRefreshPortList);
  
  // we calculate the dimensions for the port list at run-time;
  // the width is adapted to the text, and the height is adapted to show 3 list items
  int uiPortListItemHeight = fontUSBList.getSize() +1;
  uiPortListW = (int)(uiTextChoosePort.w() * 1.5);
  uiPortListH = (3* uiPortListItemHeight) + (2* uiPortListPadding) + uiPortListLineWeight;

  uiPortList = new UIList(0, 0, uiPortListW, uiPortListH);
  uiPortList.setStyle(fontUSBList, uiColDark, uiColLight, LEFT, TOP, uiPortListItemHeight, uiPortListPadding, uiPortListLineWeight, uiPortListScrollW);
  uiPortList.setId(UI_LIST_PORT);
  uiPortList.setCallbackHandler(appUICallbackHandler);
  uiGroupPortList.addToBottom(uiPortList, uiPortListPadding);
  
  // we now resize the port list group, which contains the actual list, plus header and spacing
  uiGroupPortList.setSize(
    uiPortListW + (2* uiPortListPadding),
    (int)(uiPortListH + uiTextChoosePort.h() + (3* uiPortListPadding))
  );
  uiGroupPortList.centerElements(UIGroup.HORIZONTALLY);
  uiGroupConnect.addToBottom(uiGroupPortList, 25);
  
  uiGroupConnect.tightDimensions();
  uiGroupConnect.centerElements(UIGroup.HORIZONTALLY);
  uiViewConnect.centerElements();

  uiBtnConnectBack = uiCreateBackButton(UI_BUTTON_CONNECT_BACK);
  uiViewConnect.add(uiBtnConnectBack);

  // VIEW: CONNECTING ------------------------------------------------------------------------------------

  uiViewSpinner = new UIViewFade(0, 0, uiCanvasLargeWidth, uiCanvasHeight);
  uiViewSpinner.setCallbackHandler(appUICallbackHandler);
  uiViewSpinner.setBackgroundColor(uiColLight);
  uiMainCanvas.add(uiViewSpinner);
  
  UISpinnerBasic uiSpinnerConnecting = new UISpinnerBasic(imgSpinner, uiViewSpinner.w()/2, uiViewSpinner.h()/2);
  uiViewSpinner.add(uiSpinnerConnecting);
  
  uiBtnSpinnerBack = uiCreateBackButton(UI_BUTTON_SPINNER_BACK);
  uiViewSpinner.add(uiBtnSpinnerBack);

  // TOOL PANE: SPIN --------------------------------------------------------------------------------------

  uiToolPaneSpin = new UIViewSlide(width -uiToolPaneWidth, 0, uiToolPaneWidth, height);
  uiToolPaneSpin.setClosedPos(width, 0);
  uiToolPaneSpin.setBackgroundColor(uiColDark);
  
  // group height = 2 elements + 2 spaces + 1 small space
  int uiSpinSelectionHeight = (2 * uiToolPaneElemHeight) + (2 * uiToolPaneElemSpacing) + uiToolPaneElemSpacingS; 

  uiGroupSpinSelection = new UIGroup(uiToolPaneOuterPadding, 0, uiToolPaneSpin.w() - (2*uiToolPaneOuterPadding), uiSpinSelectionHeight);
  uiGroupSpinSelection.setFrame(uiColLight, 1);
  uiToolPaneSpin.addToBottom(uiGroupSpinSelection, uiPaddingTop);

  UIText uiTextSelectionTitle = uiCreateText(appStrings.get("selection"), fontToolBold, uiColLight, uiToolPaneInnerPadding, 0);
  uiGroupSpinSelection.addToBottom(uiTextSelectionTitle, uiToolPaneElemSpacing); 

  uiIconSpinFibre = new UIImage(imgFibreWoolS, uiToolPaneInnerPadding, 0);
  uiGroupSpinSelection.addToBottom(uiIconSpinFibre, uiToolPaneElemSpacingS);

  uiTextSpinFibre = uiCreateText(appStrings.get("fibreWool"), fontTool, uiColLight, 0, 0);
  uiTextSpinFibre.textAlign(LEFT, BOTTOM);
  uiGroupSpinSelection.addRightOf(uiTextSpinFibre, uiIconSpinFibre, uiToolPaneElemSpacingS);
  
  uiBtnFiberClose = uiCreateButton(UI_BUTTON_SPIN_BACK, imgClose, 0, 0);
  uiGroupSpinSelection.addRightOf(uiBtnFiberClose, uiTextSpinFibre, uiToolPaneElemSpacingS);

  float uiSpinControlsY = uiGroupSpinSelection.y() + uiGroupSpinSelection.h() + uiToolPaneElemSpacing;
  
  // spin controls' height is later updated to extend to the status indicator
  uiGroupSpinControls = new UIGroup(uiToolPaneOuterPadding, uiSpinControlsY, uiToolPaneSpin.w() - (2*uiToolPaneOuterPadding), height);
  uiGroupSpinControls.setFrame(uiColLight, 1);
  uiToolPaneSpin.addToBottom(uiGroupSpinControls, uiToolPaneElemSpacing);

  UIText uiTextThickness = uiCreateText(appStrings.get("yarnThickness"), fontTool, uiColLight, uiToolPaneOuterPadding, 0);
  uiGroupSpinControls.addToBottom(uiTextThickness, uiToolPaneElemSpacing);

  uiSliderThickness = uiCreateSlider(UI_SLIDER_THICKNESS, uiSliderX, 0, 100);
  uiGroupSpinControls.addToBottom(uiSliderThickness, uiToolPaneElemSpacingS);

  UIText uiTextTwists = uiCreateText(appStrings.get("numTwists"), fontTool, uiColLight, uiToolPaneOuterPadding, 0);
  uiGroupSpinControls.addToBottom(uiTextTwists, uiToolPaneElemSpacing);

  uiSliderTwists = uiCreateSlider(UI_SLIDER_TWISTS, uiSliderX, 0, 100);
  uiGroupSpinControls.addToBottom(uiSliderTwists, uiToolPaneElemSpacingS);

  UIText uiTextTwistMin = uiCreateText("5", fontSlider, uiColLight, 0, 0);
  uiTextTwistMin.hAlign = CENTER;
  uiGroupSpinControls.addUnder(uiTextTwistMin, uiSliderTwists, uiToolPaneElemSpacingS);
  
  UIText uiTextTwistMax = uiCreateText("100", fontSlider, uiColLight, 0, 0);
  uiTextTwistMin.hAlign = CENTER;
  uiGroupSpinControls.addUnder(uiTextTwistMax, uiSliderTwists, uiToolPaneElemSpacingS);
  // correct the horizontal position for the "max. value" text
  uiTextTwistMax.setPos(uiSliderTwists.x() + uiSliderTwists.w() - uiTextTwistMax.w(), uiTextTwistMax.y());
  
  PImage [] statesPlayPause = { imgPlay, imgPause };
  uiBtnPlayPause = new UIButtonToggle(statesPlayPause, 0, 0);
  uiBtnPlayPause.setId(UI_BUTTON_PLAY_PAUSE);
  uiBtnPlayPause.setCallbackHandler(appUICallbackHandler);
  uiBtnPlayPause.setPos(
    (uiToolPaneWidth - uiBtnPlayPause.w()) / 2,
    height -uiPadding -uiBtnPlayPause.h()
  );
  uiToolPaneSpin.add(uiBtnPlayPause);
  
  uiTextStatus = uiCreateText(appStrings.get("machineStatus"), fontStatus, uiColLight, 0, 0);
  uiStatusIndicator = new UIMachineStatus(0, 0, uiStatusIndicatorSize, uiStatusIndicatorSize);
  
  uiToolPaneSpin.add(uiTextStatus);
  uiToolPaneSpin.add(uiStatusIndicator);
  
  int statusWidth = (int)(uiTextStatus.w() + uiToolPaneElemSpacingS + uiStatusIndicator.w());
  int statusHeight = (int)max(uiTextStatus.h(), uiStatusIndicator.h());
  
  int statusTextX = (uiToolPaneWidth - statusWidth)/2;
  int statusIndicX = (int)(statusTextX + statusWidth - uiStatusIndicator.w());
  int statusY = (int)(uiBtnPlayPause.y() - uiToolPaneElemSpacingS - statusHeight);
  
  uiTextStatus.setPos(statusTextX, statusY);
  uiStatusIndicator.setPos(statusIndicX, statusY);

  // update the height of the spin controls, to extend to just above the status indicator 
  uiGroupSpinControls.setSize(
    uiGroupSpinControls.w(), 
    uiStatusIndicator.y() - uiToolPaneElemSpacing - uiGroupSpinControls.y()
  );

  // SET THE INITIAL VIEW ---------------------------------------------------------------------------

  uiSplash.open();
  uiToolPaneSpin.close();

  uiMainCanvas.currView = uiViewWelcome;
  uiMainCanvas.mode = UIMainCanvas.VIEW_WELCOME;
}


// == ASSET LOADING ========================================================================


// Loads an asset by filename from the asset folder for the current resolution mode.
PImage uiLoadImageAsset(String filename) {
  debugMessage("uiLoadImageAsset() loading " + uiImageAssetFolder + filename);
  return loadImage(uiImageAssetFolder + filename);
}


// == ELEMENT CREATION UTILITIES ===============================================================


// Returns a newly-created and initialized UI text element
UIText uiCreateText(String text, PFont font, color col, float x, float y) {
  UIText uiText;
  uiText = new UIText(
    x, y, 100, 100, 
    text, 
    font, font.getSize(), col
    );
  uiText.tightenDimensions();
  return uiText;
}


// Returns a newly-created and initialized UI button element
UIButtonStatic uiCreateButton(int id, PImage imgButton, float x, float y) {
  UIButtonStatic uiButton;
  uiButton = new UIButtonStatic(imgButton, x, y);
  uiButton.setId(id);
  uiButton.setCallbackHandler(appUICallbackHandler);
  return uiButton;
}


// Returns a newly-created and initialized UI button with sub-text
UIButtonSubText uiCreateButtonSub(int id, PImage imgButton, float x, float y, String strText, PFont font, color textColor) {
  UIButtonSubText uiButton;
  uiButton = new UIButtonSubText(imgButton, x, y);
  uiButton.setId(id);
  uiButton.setCallbackHandler(appUICallbackHandler);
  uiButton.setSubText(strText, font, font.getSize(), textColor, uiSpacingIconsSubText);
  return uiButton;
}


// Returns a newly-created and initialized UI back button
UIButtonStatic uiCreateBackButton(int id) {
  UIButtonStatic uiButton;
  uiButton = new UIButtonStatic(imgBackArrow, uiBackButtonPadding, uiCanvasHeight - uiBackButtonPadding - imgBackArrow.height);
  uiButton.setImage(imgBackArrow);
  uiButton.setId(id);
  uiButton.setCallbackHandler(appUICallbackHandler);
  return uiButton;
}


// Returns a newly-created and initialized UI slider element
UISlider uiCreateSlider(int id, int newSliderX, int newSliderY, int initVal) {
  UISlider uiSlider;
  uiSlider = new UISlider(newSliderX, newSliderY, uiSliderW, uiSliderH); //uiToolPaneElemHeight);
  uiSlider.setId(id);
  uiSlider.setCallbackHandler(appUICallbackHandler);
  uiSlider.posSlider = initVal;
  uiSlider.updateFromSliderPos();
  return uiSlider;
}


// == UPDATE AND DRAW ===================================================================


// Update the app UI
void uiUpdate() {
  uiSplash.update();
  uiMainCanvas.update();
  uiToolPaneSpin.update();
}


// Draw the UI onto the app's canvas
void uiDraw() {
  background(uiColDark);
  image(imgLogoHeader, uiPadding, uiHeaderLogoY);

  uiMainCanvas.draw(this.g);
  uiToolPaneSpin.draw(this.g);
  uiSplash.draw(this.g);
}


// Set the appropriate fiber icon in the "selection" section of the toolpane
void uiSetFibre(int type) {
  switch (type) {
    case FIBRE_WOOL:
      uiIconSpinFibre.setImage(imgFibreWoolS);
      uiTextSpinFibre.setText(appStrings.get("fibreWool"));
    break;
    // other cases aren't implemented yet
  }
  uiBtnFiberClose.setPos(uiTextSpinFibre.x() + uiTextSpinFibre.w() + uiToolPaneElemSpacingS, uiBtnFiberClose.y());
}
