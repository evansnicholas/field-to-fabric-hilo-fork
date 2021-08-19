// Utilities.
// This tab contains the functions for writing commands and 
// debug information to the serial port.


// Print a reply, as a confirmation of a received command (code).
void printReply(char code) {
  Serial.print(CMD_DELIM_BEGIN);
  Serial.print(code);
  Serial.print(CMD_DELIM_END);
  Serial.println();
}


// Print an error reply, with the provided errorCode.
void printError(int errorCode) {
  Serial.print(CMD_DELIM_BEGIN);
  Serial.print(CMD_ERROR);
  Serial.print(CMD_DELIM_PARAM);
  Serial.print(errorCode, DEC);
  Serial.print(CMD_DELIM_END);
  Serial.println();
}


// Print a complete message specified by a String.
void printMessage(String message) {
#ifdef HILO_DEBUG
  Serial.print(CMD_DELIM_BEGIN);
  Serial.print(CMD_DEBUG);
  Serial.print(CMD_DELIM_PARAM);
  Serial.print(message);
  Serial.print(CMD_DELIM_END);
  Serial.println();
#endif
}


// Print the beginning of a message 
// (i.e. the beginning delimiter, debug message command and parameter separator). 
// After printing the actual message using printMessageContent()
// you should call printMessageEnd().
void printMessageBegin() {
#ifdef HILO_DEBUG
  Serial.print(CMD_DELIM_BEGIN);
  Serial.print(CMD_DEBUG);
  Serial.print(CMD_DELIM_PARAM);
#endif
}

// Print the content of a message.
// You should call printMessageBegin() at some point before; 
// and printMessageEnd() at some point after.
void printMessageContent(String message) {
#ifdef HILO_DEBUG
  Serial.print(message);
#endif
}

// Print the content of a message.
// You should call printMessageBegin() at some point before; 
// and printMessageEnd() at some point after.
void printMessageContent(char message) {
#ifdef HILO_DEBUG
  Serial.print(message);
#endif
}

// Print the content of a message.
// You should call printMessageBegin() at some point before; 
// and printMessageEnd() at some point after.
void printMessageContent(int message) {
#ifdef HILO_DEBUG
  Serial.print(message);
#endif
}

// Print the end of a message (i.e. the end delimiter).
// You should call printMessageBegin() at some point before; 
// and printMessageEnd() at some point after.
void printMessageEnd() {
#ifdef HILO_DEBUG
  Serial.print(CMD_DELIM_END);
  Serial.println();
#endif
}

