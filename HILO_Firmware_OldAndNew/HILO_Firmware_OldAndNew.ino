// Main Tab.
// This tab contains the definitions for the HILO communication protocol
// and the main Arduino functions

#include <AccelStepper.h>

#define HILO_VERSION "HILO Firmware 0.1.1"


// #define USE_START_STOP  // uncomment when using a start/stop button on the machine
// #define HILO_DEBUG         // comment to suppress debug messages

// serial port speed; must be the same in the app
#define HILO_SERIAL_BAUDRATE 115200


// Protocol definitions ==============================================

// Command delimiters
#define CMD_DELIM_BEGIN '['
#define CMD_DELIM_END   ']'
#define CMD_DELIM_PARAM ','

// Commands (settings)
#define CMD_DELIVERY_SPEED 'D'  // [D]elivery
#define CMD_SPINDLE_SPEED  'P'  // s[P]indle
#define CMD_ELEVATOR_SPEED 'L'  // e[L]evator

// Commands (spin)
#define CMD_RUN            'R'  // [R]un
#define CMD_STOP           'S'  // [S]top

// Commands (other)
#define CMD_PING           'A'
#define CMD_INFO           'I'  // [I]nfo
#define CMD_STATUS         'T'  // s[T]atus
#define CMD_ELEVATOR_RESET 'V'  // ele[V]ate  

// Error/Debug
#define CMD_ERROR          'E'
#define CMD_DEBUG          'X'

// Error codes
#define ERR_BUFF_FULL       1   // buffer is full
#define ERR_BEGIN_MISSING   2   // no begin delimiter
#define ERR_END_MISSING     3   // no end delimiter
#define ERR_DATA_SIZE       4   // command is too small (less than 3 bytes)
#define ERR_DELIM           5   // unknow delimiter/character
#define ERR_UNKNOWN_CMD     6   // unknown command
#define ERR_PARAM_COUNT     7   // wrong number of parameters
#define ERR_VALUE_SPEED     8   // speed value invalid or speed value pair inconsistent
#define ERR_BUSY            9   // machine is busy (spinning or resetting)
#define ERR_NO_DEBUG       10   // firmware isn't debug-able


// Buffer for incoming commands (from Serial)
#define COMMAND_BUFF_SIZE 64
char commandBuff [COMMAND_BUFF_SIZE];
int  commandBuffPos = 0;

// Storage for parsed commands
#define MAX_NUM_PARAMS 10
char parsedCommand     = 0;
int  parsedParamsCount = 0;
int  parsedParams [MAX_NUM_PARAMS];


void setup() {
  initMachineControlPins();
  initMachineControlSteppers();

  Serial.begin(HILO_SERIAL_BAUDRATE);
}


void loop() {
  serialCommunicationLoop();
  machineControlLoop();
}


// Reads from the serial port, buffering until a complete message is received.
// Once a complete message has been buffered, parses the contents and handles the requested command.
void serialCommunicationLoop() {
  if (Serial.available() > 0) {
    // read a character from serial, if one is available
    int data = Serial.read();
    
    if (data == 10 || data == 13) {
      // ignore CR and LF
    }
    else {
      // add the character to our buffer until we have a complete message
      commandBuff[commandBuffPos++] = (char)data;
      if (commandBuffPos >= COMMAND_BUFF_SIZE) {
        printError(ERR_BUFF_FULL);
        commandBuffPos = 0;
      }
      else if (data == CMD_DELIM_END) {
        // when the end delimiter is received, parse the buffer contents (a complete message)
        int parseResult = parseData(commandBuff, commandBuffPos);
        commandBuffPos = 0;
        if (parseResult != 0) {
          printError(parseResult);
        }
        else {
          // handle the parsed command and parameters
          handleCommand(parsedCommand, parsedParams, parsedParamsCount);
        }
      }
    }
  }
}


// Handles a command according to the HILO communication protocol,
// by invoking machine control functions. 
void handleCommand(char command, int* params, int numParams) {
  switch (command) {
    case CMD_RUN:
      handleCommandRun();
      break;
    case CMD_STOP:
      handleCommandStop();
      break;
    case CMD_DELIVERY_SPEED:
      handleCommandDeliverySpeed();
      break;
    case CMD_SPINDLE_SPEED:
      handleCommandSpindleSpeed();
      break;
    case CMD_ELEVATOR_SPEED:
      handleCommandElevatorSpeed();
      break;
    case CMD_PING:
      handleCommandPing();
      break;
    case CMD_ELEVATOR_RESET:
      handleCommandElevatorReset();
      break;
    case CMD_INFO:
      handleCommandInfo();
      break;
    case CMD_STATUS:
      handleCommandStatus();
      break;
    default:
      printError(ERR_UNKNOWN_CMD);
      break;
  }
}
