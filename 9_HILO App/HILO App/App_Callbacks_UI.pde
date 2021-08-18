// App - Callbacks UI
// This tab defines the object which handles callbacks from UI elements.


// An object that handles callbacks from UI elements - i.e objects which implement UIElement or subclasses of UIBasicElement.
// A UI callback handler object is passed to a UI Element using the setCallbackHandler() method.
// The callback handler implements methods from the UICallbackHandler as a way to be notified of
// interaction with or changes in the state of UI elements.
// Each callback is usually related to a type of element (button, slider, numeric field) and receives the element's identifier.
// Some callbacks also indicate the new value or state of the UI element.
// Typically, we check the element's identifier and then react accordingly. Complex operations should be deferred for later.
class AppUICallbackHandler extends UICallbackHandler {

  // Called when a button is pressed.
  // Receives the button's identifier, defined by the developer when creating the button.
  void callbackUIButtonPressed(int buttonID) {
    switch (buttonID) {
      case UI_BUTTON_SPLASH:
        // user clicked the "splash" screen, so roll it up
        uiSplash.animateClose();
      break;
      case UI_BUTTON_SPIN:
        // user selected "spin" mode; switch to the fibre selection view
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_FIBRE);
      break;
      case UI_BUTTON_FIBRE_WOOL:
        // user selected the material "wool"; switch to the "spin" view and open the tool pane
        uiSetFibre(FIBRE_WOOL);
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_SPIN);
        uiToolPaneSpin.animateOpen();
      break;
      case UI_BUTTON_FIBRE_BACK:
        // user clicked the back arrow in the fibre view; switch back to the welcome view (mode selection)
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_WELCOME);
      break;
      case UI_BUTTON_SPIN_BACK:
        // user clicked the back arrow in the spin view
        // stop the machine if it's spinning, close the tool pane and switch back to the fibre selection view
        if (hilo.isSpinning()) {
          hilo.stop();
        }
        uiToolPaneSpin.animateClose();
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_FIBRE);
      break;
      case UI_BUTTON_PLAY_PAUSE:
        // user clicked the play/pause button
        playPause();
      break;
      case UI_BUTTON_REFRESH_PORTS:
        // user clicked the port list title; refresh the port list
        refreshPortList();
      break;
      case UI_BUTTON_CONNECT_BACK:
        // user clicked the back arrow in the connect view
        // cancel connecting the machine, switch back to the spin view and open the tool pane
        if (!hilo.isConnected()) {
          disconnectHILO();
        }
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_SPIN);
        uiToolPaneSpin.animateOpen();
      break;
      case UI_BUTTON_SPINNER_BACK:
        // user clicked the back arrow in the spinner (conecting) view; refresh and return to the port list
        disconnectHILO();
        refreshPortList();
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_CONNECT);
      break;
    }
  }

  // Called when a slider is selected (i.e. the slider's active area is clicked).
  // Receives the slider's identifier and the updated slider value (because clicking the slider may move the indicator/knob).
  void callbackUISliderSelected(int sliderID, float value) {
    // in our case, we do the same as when the slider is dragged, see below
    callbackUISliderDragged(sliderID, value);
  }

  // Called when a slider is dragged.
  // Receives the slider's identifier and the updated slider value.
  void callbackUISliderDragged(int sliderID, float value) {
    // we do not immediatelly update the actual machine settings when a slider is dragged, to avoid flooding the serial port;
    // instead, the machine settings are updated only when the slider is released
    switch(sliderID) {
      case UI_SLIDER_THICKNESS:
        // update the thickness of the "yarn" visualization
        uiYarnTwists.thickness = map(value, 0, 100, 0.3, 1.0);
      break;
      case UI_SLIDER_TWISTS:
        // update the twist amount of the "yarn" visualization
        uiYarnTwists.frequency = map(value, 0, 100, 10, 50);
      break;
    }
  }

  // Called when a slider is released.
  // Receives the slider's identifier and the updated slider value.
  void callbackUISliderReleased(int sliderID, float value) {
    switch(sliderID) {
      case UI_SLIDER_THICKNESS:
        // update the thickness of the "yarn" visualization
        uiYarnTwists.thickness = map(value, 0, 100, 0.3, 1.0);
        // re-send the spin command to update the thickness value in the machine
        if (hilo.isSpinning()) startSpinning();
      break;
      case UI_SLIDER_TWISTS:
        // update the twist amount of the "yarn" visualization
        uiYarnTwists.frequency = map(value, 0, 100, 10, 50);
        // calculate the actual spindle speed based on the twist amount, and update the machine settings
        int valueSpindleSpeed = (int)map(value, 0, 100, machineSettings.spindleSpeedStepsMin, machineSettings.spindleSpeedStepsMax);
        hilo.setSpindleSpeed(valueSpindleSpeed);
      break;
    }
  }

  // Called when a numeric field's value changes.
  // Receives the element's identifier and the updated value.
  void callbackUINumFieldUpdated(int numFieldID, int value) {
    // there are currently no numeric fields in the UI
  }

  // Called when a list item is selected.
  // Receives the list's identifier and the index of the selected item.
  void callbackUIListItemSelected(int listID, int itemIndex) {
    switch(listID) {
      case UI_LIST_PORT:
        // the user selected an item from the USB ports list
        // store the selected port, switch to the spinner view and launch a thread to connect the machine
        selectedSerialPort = uiPortList.getItem(itemIndex);
        println("callbackUIListItemSelected() selected serial port " + selectedSerialPort);
        uiMainCanvas.switchTo(UIMainCanvas.VIEW_SPINNER);
        thread("connectHILO");
        break;
    }
  }

  // Called when a view has finished fading in.
  void callbackUIViewFadeIn() {
    // propagate the event to our main canvas element, which hosts the views
    uiMainCanvas.onViewFadeIn();
  }

  // Called when a view has finished fading out.
  void callbackUIViewFadeOut() {
    // propagate the event to our main canvas element, which hosts the views
    uiMainCanvas.onViewFadeOut();
  }
}
