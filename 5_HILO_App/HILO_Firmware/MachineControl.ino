// Machine Control.
// This tab contains the definitions for machine pins and hardware
// and functions that drive the machine's behavior.


#define PIN_LED               13  // Arduino on-board LED

#define PIN_START_STOP        19  // RAMPS pin for run/stop switch (last endstop, Z positive)
#define PIN_ELEVATOR_ENDSTOP   3  // RAMPS pin for the first endstop (X negative)

#define PIN_DRAFTING_STEP     54  // Drafting Motor Step Pin
#define PIN_DRAFTING_DIR      55  // Drafting Motor Direction Pin
#define PIN_DRAFTING_ENABLE   38  // Drafting Motor Enable Pin

#define PIN_DELIVERY_STEP     60  // Delivery Motor Step Pin
#define PIN_DELIVERY_DIR      61  // Delivery Motor Direction Pin
#define PIN_DELIVERY_ENABLE   56  // Delivery Motor Enable Pin

#define PIN_SPINDLE_STEP      46  // Spindle Motor Step Pin
#define PIN_SPINDLE_DIR       48  // Spindle Motor Direction Pin
#define PIN_SPINDLE_ENABLE    62  // Spindle Motor Enable Pin

#define PIN_ELEVATOR_A_STEP   26  // Elevator Motors Step Pin
#define PIN_ELEVATOR_A_DIR    28  // Elevator Motors Direction Pin
#define PIN_ELEVATOR_A_ENABLE 24  // Elevator Motors Enable Pin

#define PIN_ELEVATOR_B_STEP   36  // Elevator Motors Step Pin
#define PIN_ELEVATOR_B_DIR    34  // Elevator Motors Direction Pin
#define PIN_ELEVATOR_B_ENABLE 30  // Elevator Motors Enable Pin


#define STEPPER_MAX_SPEED     1000   // speed cap for all stepper motors
#define STEPPER_ACCELERATION  0.01f  // acceleration for all stepper motors (in steps per second per second)

// Speeds in steps (except in old machine's spindle).

// Default drafting and delivery speeds are negative, given the motor orientation in new machine.
#define DEFAULT_DRAFTING_SPEED         -160
#define DEFAULT_DELIVERY_SPEED         -240
#define DEFAULT_SPINDLE_SPEED           700  
#define DEFAULT_ELEVATOR_SPEED          200
#define DEFAULT_ELEVATOR_RESET_SPEED    500
#define ELEVATOR_HEIGHT_STEPS        -18000
#define ELEVATOR_RESET_STEPS          -1000


AccelStepper motorDrafting(AccelStepper::DRIVER, PIN_DRAFTING_STEP, PIN_DRAFTING_DIR);
AccelStepper motorDelivery(AccelStepper::DRIVER, PIN_DELIVERY_STEP, PIN_DELIVERY_DIR);
AccelStepper motorElevatorA(AccelStepper::DRIVER, PIN_ELEVATOR_A_STEP, PIN_ELEVATOR_A_DIR);
AccelStepper motorElevatorB(AccelStepper::DRIVER, PIN_ELEVATOR_B_STEP, PIN_ELEVATOR_B_DIR);
AccelStepper motorSpindle  (AccelStepper::DRIVER, PIN_SPINDLE_STEP,    PIN_SPINDLE_DIR);


// the current speeds for the steppers
int draftingSpeed  = DEFAULT_DRAFTING_SPEED;
int deliverySpeed  = DEFAULT_DELIVERY_SPEED;
int spindleSpeed   = DEFAULT_SPINDLE_SPEED;
int elevatorSpeed      = DEFAULT_ELEVATOR_SPEED;
int elevatorResetSpeed = DEFAULT_ELEVATOR_RESET_SPEED; // current speed for the elevator when resetting its position

// the current drafting speed as a percentage of the delivery speed (integer from 0 to 100)
int draftingSpeedPerc = (DEFAULT_DRAFTING_SPEED * 100) / DEFAULT_DELIVERY_SPEED;

int valueEndstop = LOW;    // current value of the elevator's endstop
int valueStartStop = LOW;  // current value of the start/stop button (when used)

// time at which the start/stop button was last triggered (when used)
unsigned long timeLastStartStop = 0; 

// machine state flags
bool isSpinning          = false;
bool isElevatorResetting = false;

// machine state (i.e., latest command)
char currentState      = CMD_STOP;


// Initializes the pins (input/output) used to control the motor drivers.
void initMachineControlPins() {
  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, LOW);

  // set the mode for the stepper driver enable pins
  pinMode (PIN_DRAFTING_ENABLE,   OUTPUT);
  pinMode (PIN_DELIVERY_ENABLE,   OUTPUT);
  pinMode (PIN_ELEVATOR_A_ENABLE, OUTPUT);
  pinMode (PIN_ELEVATOR_B_ENABLE, OUTPUT);
  pinMode (PIN_SPINDLE_ENABLE,    OUTPUT);
}


// Initializes the stepper motor via the AccelStepper objects
void initMachineControlSteppers() {
  setupStepper(motorDrafting, draftingSpeed);
  setupStepper(motorDelivery, deliverySpeed);
  
  setupStepper(motorElevatorA, elevatorSpeed);
  setupStepper(motorElevatorB, elevatorSpeed);
  setupStepper(motorSpindle, spindleSpeed);

  // disable steppers while not in use
  setSteppersEnabled(false);
}


// Sets up a stepper motor via it's AccelStepper object
void setupStepper(AccelStepper & stepper, int motorSpeed) {
  stepper.setMaxSpeed(STEPPER_MAX_SPEED);
  stepper.setAcceleration(STEPPER_ACCELERATION);
  stepper.setSpeed(motorSpeed);
}


// Enables or disables all steppers. Used for saving power
// and allowing adjustments by hand when the machine isn't running.
void setSteppersEnabled(bool enabled) {
  int value = LOW;
  if (!enabled) value = HIGH;

  digitalWrite(PIN_DRAFTING_ENABLE,   value);
  digitalWrite(PIN_DELIVERY_ENABLE,   value);
  digitalWrite(PIN_ELEVATOR_A_ENABLE, value);
  digitalWrite(PIN_ELEVATOR_B_ENABLE, value);
  digitalWrite(PIN_SPINDLE_ENABLE,    value);
}


// Enables or disables elevator steppers
void setElevatorSteppersEnabled(bool enabled) {
  int value = LOW;
  if (!enabled) value = HIGH;
  
  digitalWrite(PIN_ELEVATOR_A_ENABLE, value);
  digitalWrite(PIN_ELEVATOR_B_ENABLE, value);
}


// Handles a "ping" command by sending back a "ping"
void handleCommandPing() {
  printReply(CMD_PING);
}


// Resets the elevator's position (unless the machine is spinning or already resetting the elevator)
void handleCommandElevatorReset() {
  if (isSpinning) {
    printMessage("handleCommandElevatorReset() ERROR: machine is currently spinning");
    printError(ERR_BUSY);
  }
  else if (isElevatorResetting) {
    printMessage("handleCommandElevatorReset(): elevator is already resetting");
    printReply(CMD_ELEVATOR_RESET);
  }
  else {
    printMessage("handleCommandElevatorReset(): resetting elevator");
    isElevatorResetting = true;
    setElevatorSteppersEnabled(true);
    currentState = CMD_ELEVATOR_RESET;
    motorElevatorA.setCurrentPosition(0);
    motorElevatorB.setCurrentPosition(0);
    motorElevatorA.setSpeed(elevatorResetSpeed);
    motorElevatorB.setSpeed(elevatorResetSpeed);
    digitalWrite(PIN_LED, HIGH);
    printReply(CMD_ELEVATOR_RESET);
  }
}


// Start spinning, with a drafting speed provided as a percentage (0-100) of the delivery speed
void handleCommandRun() {
  if (parsedParamsCount != 1) {
    // no parameter for percentage was parsed
    printError(ERR_PARAM_COUNT);
    return;
  }

  // verify that the drafting speed is within limits
  int newDraftingSpeedPerc = parsedParams[0];
  if (newDraftingSpeedPerc < 0 || draftingSpeedPerc > 100) {
    printError(ERR_VALUE_SPEED);
    return;
  }

  // store and calculate the actual drafting speed in steps/second
  draftingSpeedPerc = newDraftingSpeedPerc;
  draftingSpeed = (int)map(draftingSpeedPerc, 0, 100, 0, deliverySpeed);

  if (isElevatorResetting) {
    // can't spin while the elevator is resetting
    printMessage("handleCommandRun() ERROR: elevator is resetting");
    printError(ERR_BUSY);
  }
  else if (isSpinning) {
    // if already spinning, adjust the drafting speed
    printMessage("handleCommandRun(): HILO is already spinning");
    motorDrafting.setSpeed(draftingSpeed);
  }
  else {
    startSpinning();
  }
  
  printReply(CMD_RUN);
}


// Stop the machine, by setting the current state.
// Actually stopping/disabling the motors is handled in the machineControlLoop()
void handleCommandStop() {
  if (isSpinning) {
    printMessage("handleCommandStop(): stop spinning");
    // state is set here as a signal to be handled in the control loop
    currentState = CMD_STOP;
  }
  else if (isElevatorResetting) {
    printMessage("handleCommandStop(): stop elevator resetting");
    currentState = CMD_STOP;
  }
  else {
    printMessage("handleCommandStop(): was already stopped");
    printReply(CMD_STOP);
  }
}


// Sets the machine's delivery speed, in steps/second.
// Also re-calculates the drafting speed from the stored percentage value.
void handleCommandDeliverySpeed() {
  if (parsedParamsCount != 1) {
    // no parameter for speed was parsed
    printError(ERR_PARAM_COUNT);
    return;
  }

  // verify that the delivery speed is within limits
  int newSpeed = parsedParams[0];
  if (newSpeed < 0 || newSpeed > STEPPER_MAX_SPEED) {
    printError(ERR_VALUE_SPEED);
    return;
  }

  // the speed is reversed, given the motor's orientation
  deliverySpeed = -newSpeed;
  
  motorDelivery.setSpeed(deliverySpeed);

  // The delivery speed changed, so we need to update the drafting to match.
  // We calculate a new drafting speed in steps based on the drafting speed as percentage.
  draftingSpeed = (int)map(draftingSpeedPerc, 0, 100, 0, deliverySpeed);
  motorDrafting.setSpeed(draftingSpeed);

  // Debug message
  printMessageBegin();
  printMessageContent("draftingSpeed/Perc: ");
  printMessageContent(draftingSpeed);
  printMessageContent(" ");
  printMessageContent(draftingSpeedPerc);
  printMessageEnd();
  
  printReply(CMD_DELIVERY_SPEED);
}


// Set the spindle speed.
void handleCommandSpindleSpeed() {
  if (parsedParamsCount != 1) {
    // no parameter for speed was parsed
    printError(ERR_PARAM_COUNT);
    return;
  }

  // verify that the spindle speed is within limits
  int newSpeed = parsedParams[0];
  if (newSpeed < 0 || newSpeed > STEPPER_MAX_SPEED) {
    printError(ERR_VALUE_SPEED);
    return;
  }

  spindleSpeed = newSpeed;

  // set the motor speed
  motorSpindle.setSpeed(spindleSpeed);
    
  printReply(CMD_SPINDLE_SPEED);
}


// Set the speed for the spindle's elevator.
void handleCommandElevatorSpeed() {
  if (parsedParamsCount != 1) {
    // no parameter for speed was parsed
    printError(ERR_PARAM_COUNT);
    return;
  }

  // verify that the elevator speed is within limits
  int newSpeed = parsedParams[0];  
  if (newSpeed < -STEPPER_MAX_SPEED || newSpeed > STEPPER_MAX_SPEED) {
    printError(ERR_VALUE_SPEED);
    return;
  }

  if (isElevatorResetting) {
    printMessage("handleCommandElevatorSpeed() ERROR: elevator is resetting");
    printError(ERR_BUSY);
    return;
  }

  int elevatorDirection = 1;
  if (elevatorSpeed < 0) elevatorDirection = -1;

  // if the new speed is negative, reverse the current direction
  if (newSpeed < 0) {
    elevatorDirection *= -1;
  }

  // set the speed of the elevator motors
  elevatorSpeed = abs(newSpeed) * elevatorDirection;
  motorElevatorA.setSpeed(elevatorSpeed);
  motorElevatorB.setSpeed(elevatorSpeed);
  
  printReply(CMD_ELEVATOR_SPEED);
}


// Print the machine's current state: stopped, running or resetting (elevator).
void handleCommandStatus() {
  if (isSpinning) printReply(CMD_RUN);
  else if (isElevatorResetting) printReply(CMD_ELEVATOR_RESET);
  else printReply(CMD_STOP);
}


// Print textual information about the machine.
// Useful only in debug mode.
void handleCommandInfo() {
  #ifndef HILO_DEBUG
    printError(ERR_NO_DEBUG);
    return;
  #endif
  
  printMessageBegin();
  printMessageContent(HILO_VERSION);
  printMessageContent(". ");
  printMessageContent("State ");
  printMessageContent(currentState);
  printMessageContent(". Delivery speed ");
  printMessageContent(deliverySpeed);
  printMessageContent(". Spindle speed ");
  printMessageContent(spindleSpeed);
  int elevatorCurrPos = (int)motorElevatorA.currentPosition();
  printMessageContent(". Elevator height ");
  printMessageContent(elevatorCurrPos);
  printMessageEnd();
}


// Starts spinning. 
// Sets the machine's state, lightts up the LED, enables motors.
void startSpinning() {
  printMessage("Start spinning");
  currentState = CMD_RUN;

  digitalWrite(PIN_LED, HIGH);
  
  isSpinning = true;
  printMessage("Enabling steppers");
  setSteppersEnabled(true);
}


// Called by machineControlLoop() when resetting the elevator.
void elevatorResetLoop() {
  float currSpeed = motorElevatorA.speed();
  if (motorElevatorA.currentPosition() <= ELEVATOR_RESET_STEPS) {
    // elevator reached the reset position, we are done! 
    isElevatorResetting = false;
    setElevatorSteppersEnabled(false);
    motorElevatorA.setSpeed(elevatorSpeed);
    motorElevatorB.setSpeed(elevatorSpeed);
    printReply(CMD_STOP);
    printMessageBegin();
    printMessageContent("Elevator is reset. Current pos: ");
    printMessageContent((int)motorElevatorA.currentPosition());
    printMessageEnd();
  }
  else {
    if (currSpeed > 0) {
      // elevator is travelling up, check if the endstop has been reached
      if (valueEndstop == HIGH) {
        // setCurrentPosition() also clears the motor's speed, so we set speeds afterwards
        motorElevatorA.setCurrentPosition(0);
        motorElevatorB.setCurrentPosition(0);
        // endstop has been reached, so make the motors travel in the opposite direction
        motorElevatorA.setSpeed(-currSpeed);
        motorElevatorB.setSpeed(-currSpeed);
      }
    }
    else {
      // elevator is travelling down, nothing to do except print debug info
      printMessageBegin();
      printMessageContent("Elevator pos: ");
      printMessageContent((int)motorElevatorA.currentPosition());
      printMessageEnd();
    }

    // run the motors
    motorElevatorA.runSpeed();
    motorElevatorB.runSpeed();
  }
}


// Called by machineControlLoop() when spinning, to update the elevator's state.
void elevatorUpdate() {
  float currSpeed = motorElevatorA.speed();
  if (currSpeed < 0 && motorElevatorA.currentPosition() <= ELEVATOR_HEIGHT_STEPS) {
    // The elevator is descending and has reached the bootom position,
    // so reverse the elevator's speed.
    elevatorSpeed = -currSpeed;
    motorElevatorA.setSpeed(elevatorSpeed);
    motorElevatorB.setSpeed(elevatorSpeed);
  }
  else if (currSpeed > 0 && valueEndstop == HIGH) {
    // The elevator is ascending and has reached the top position,
    // so reverse the elevator's speed.
    motorElevatorA.setCurrentPosition(0);
    motorElevatorB.setCurrentPosition(0);
    elevatorSpeed = -currSpeed;
    motorElevatorA.setSpeed(elevatorSpeed);
    motorElevatorB.setSpeed(elevatorSpeed);
  } 
}


// Main loop for the machine's behaviour.
// Runs or stops the motors depending on global state variables/flags.
void machineControlLoop() {
  // update the reading of the elevator's endstop
  valueEndstop = digitalRead(PIN_ELEVATOR_ENDSTOP);

  // when the elevator is resetting, check for stop states
  // or run the elevator reset loop, then return
  if (isElevatorResetting) {
    if (currentState == CMD_STOP) {
      printMessage("Received stop command while resetting");
      isElevatorResetting = false;
      setElevatorSteppersEnabled(false);
      digitalWrite(PIN_LED, LOW);
      printReply(CMD_STOP);
    }
    else {
      elevatorResetLoop();
    }
    return;  // stop the main loop here
  }

  #ifdef USE_START_STOP

    // when using the start stop button, a period of 300 msec is given for debouncing.
    if (millis() < timeLastStartStop + 300) {
      // nothing to do
    }
    else {
      // store the previous value and update the current value of the start/stop button
      int prevValueStartStop = valueStartStop;
      valueStartStop = digitalRead(PIN_START_STOP);
      
      if (valueStartStop == HIGH && prevValueStartStop == LOW) {
        // if the button was pressed, start or stop spinning
        if (isSpinning) {
          printMessage("Button: stop spinning");
          currentState = CMD_STOP;
        }
        else {
          printMessage("Button: start spinning");
          startSpinning();
        }
      }
      else if (valueStartStop == LOW && prevValueStartStop == HIGH) {
        // store the time of activation, for debouncing
        timeLastStartStop = millis();
        printMessage("Button: reset");
      }
    }
  #endif

  // while the machine is spinning, update the elevator and check if a stop command was received;
  // if not, run the motors at their current speeds
  if (isSpinning) {
    elevatorUpdate();
    
    if (currentState == CMD_STOP) {
      printMessage("Received stop command while spinning");
      isSpinning = false;
      printMessage("Disabling steppers");
      setSteppersEnabled(false);
      digitalWrite(PIN_LED, LOW);
      printReply(CMD_STOP);
    }
    else {
      motorDrafting.runSpeed();
      motorDelivery.runSpeed();
      motorElevatorA.runSpeed();
      motorElevatorB.runSpeed();
      motorSpindle.runSpeed();
    }
  }
}

