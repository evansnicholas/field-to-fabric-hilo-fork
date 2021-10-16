// App - Callbacks HILO
// Contains functions that interact with the HILO machine (or simulator)
// as well as the callback handler object, which handles status updates from HILO.


// connect to HILO via the serial port selected by the user
void connectHILO() {
  // if the machine is already connected, do nothing
  if (hilo.isConnected()) {
    debugMessage("connectHILO() WARNING: HILO is already connected to " + hilo.getPortName());
    return;
  }
  
  debugMessage("connectHILO(): connecting on port <" + selectedSerialPort + ">");

  // determine wether the user selected the simulator, and if a simulator is already being used
  boolean selectedSimulator = selectedSerialPort.equalsIgnoreCase(HILOSimulator.SIMULATOR_PORT_NAME);
  boolean isUsingSimulator  = hilo.getPortName().equalsIgnoreCase(HILOSimulator.SIMULATOR_PORT_NAME); 

  // check if we need to create a different HILO object (device or simulator)
  if (selectedSimulator) {
    // create a simulator object, if we weren't using one already
    if (!isUsingSimulator) {
      debugMessage("connectHILO(): switching to simulator");
      isUsingSimulator = true;
      hilo = null;
      hilo = new HILOSimulator(appHILOCallbackHandler);
    }
  } else {
    // create an actual device object, if we weren't using one already
    if (isUsingSimulator) {
      debugMessage("connectHILO(): switching to device");
      isUsingSimulator = false;
      hilo = null;
      hilo = new HILODevice(this, appHILOCallbackHandler);
    }
  }

  // connect to the selected serial port
  debugMessage("connectHILO(): connecting to port " + selectedSerialPort);
  hilo.connect(selectedSerialPort);
  // once connected, the device will reply via the callback onHILOConnected()
}


// Disconnect from the serial port (or simulator)
void disconnectHILO() {
  if (hilo.isSpinning()) {
    debugMessage("disconnectHILO(): stopping HILO");
    hilo.stop();
  }
  debugMessage("disconnectHILO(): disconnecting from HILO");
  hilo.disconnect();
  // once disconnected, the device will reply via the callback onHILODisconnected()
}


// Upload configuration parameters to the machine
void uploadHILOConfig() {
  hilo.setDeliverySpeed(machineSettings.deliverySpeedSteps);
  hilo.setSpindleSpeed(machineSettings.spindleSpeedStepsMax);
}


// Refresh (clear and re-populate) the list of serial ports
void refreshPortList() {
  uiPortList.clearItems();
  
  // add the simulator port (which isn't a real serial port)
  uiPortList.addItem(HILOSimulator.SIMULATOR_PORT_NAME);
  
  // add the preferred port to the top, if any
  if (appSettings.prefPort.length() > 0 && !appSettings.prefPort.equals(HILOSimulator.SIMULATOR_PORT_NAME)) {
    uiPortList.addItem(appSettings.prefPort);
  }
  
  String [] portList = Serial.list();
  for (int i = 0; i < portList.length; i++) {
    boolean shouldListPort = true;
    
    // do not list Bluetoth ports, to un-clutter the port list
    if (portList[i].toUpperCase().contains("BLUETOOTH"))
      shouldListPort = false;
    // do not list the preferred port again
    else if (appSettings.prefPort.length() > 0 && appSettings.prefPort.equalsIgnoreCase(portList[i]))
      shouldListPort = false;
    
    if (shouldListPort)
      uiPortList.addItem(portList[i]);
    
  }
}


// Start/stop spinning; called by pressing the play/bause button in the UI.
void playPause() {
  // if there is no device connected, switch to the connect view
  if (!hilo.isConnected()) {
    uiToolPaneSpin.animateClose();
    refreshPortList();   
    uiMainCanvas.switchTo(UIMainCanvas.VIEW_CONNECT);
    return;
  }

  if (!hilo.isSpinning()) {
    startSpinning();
  } else {
    stopSpinning();
  }
  // the device will reply via either the callback onStartSpinning() or onStopSpinning() respectively
}


// Start spinning, based on the value of the "yarn thickness" slider.
// This method can also be called while the machine is spinning, to update the thickness.
void startSpinning() {
  // convert the thickness slider value into a hilo pixel value
  int hiloDraftingSpeedPercent = (int)map(uiSliderThickness.posSlider, 0, 100, machineSettings.draftingSpeedPercMin, machineSettings.draftingSpeedPercMax);
  
  debugMessage("startSpinning(): starting spinning at " + hiloDraftingSpeedPercent + " percent of delivery speed");
  hilo.spin(hiloDraftingSpeedPercent);
  // the device will reply via the callback onStartSpinning()
}


// Stop spinning
void stopSpinning() {
  hilo.stop();
  // the device will reply via the callback onStopSpinning()
}


// == CALLLBACK HANDLER =========================================================


// An object that handles callbacks from a HILO object (machine or simulator).
// A callback handler object is passed to a newly-created HILO object - see connectHILO() above.
// The callback handler implements methods from the HILOCallbackHandler as a way to be notified of changes in the
// HILO machine/simulator's status, and act accordingly.
class AppHILOCallbackHandler implements HILOCallbackHandler {

  // Called when HILO is connected (i.e. the serial port is open)
  void onHILOConnected() {
    debugMessage("onHILOConnected()");
    // set the play/pause button's state
    uiBtnPlayPause.setState(BUTTON_STATE_PLAY);
    // set the UI "machine status" indicator
    uiStatusIndicator.state = UIMachineStatus.STATE_READY;
    // upload the machine's configuration
    uploadHILOConfig();
    // save the preferred port and machine settings
    String portName = hilo.getPortName();
    if (!portName.equals(appSettings.prefPort)) {
      //debugMessage("new preferred port " + machineSettings.prefPort + "\nsaving...");
      appSettings.prefPort = portName;
      appSettings.save(dataPath(APP_DEFAULT_SETTINGS_FOLDER + APP_DEFAULT_SETTINGS_FILE));
    }
    // if we are in the connect or spinner views, switch to the spin view
    if (uiMainCanvas.mode == UIMainCanvas.VIEW_CONNECT || uiMainCanvas.mode == UIMainCanvas.VIEW_SPINNER) {
      uiToolPaneSpin.animateOpen();
      uiMainCanvas.switchTo(UIMainCanvas.VIEW_SPIN);
    }    
  }

  // Called when HILO is disconnected.
  void onHILODisconnected() {
    debugMessage("onHILODisconnected()");
    // set the play/pause button's state
    uiBtnPlayPause.setState(BUTTON_STATE_PLAY);
    // set the UI "machine status" indicator
    uiStatusIndicator.state = UIMachineStatus.STATE_OFFLINE;
  }

  // Called when HILO starts spinning.
  void onStartSpinning() {
    debugMessage("onStartSpinning()");
    // set the play/pause button's state
    uiBtnPlayPause.setState(BUTTON_STATE_PAUSE);
    // set the UI "machine status" indicator
    uiStatusIndicator.state = UIMachineStatus.STATE_SPINNING;
    // animate the "yarn" visualization
    uiYarnTwists.isAnimating = true;
  }

  // Called when HILO stops spinning.
  void onStopSpinning() {
    debugMessage("onStopSpinning()");
    // set the play/pause button's state
    uiBtnPlayPause.setState(BUTTON_STATE_PLAY);
    // set the UI "machine status" indicator
    uiStatusIndicator.state = UIMachineStatus.STATE_READY;
    // stop the "yarn" animation
    uiYarnTwists.isAnimating = false;
  }
}
