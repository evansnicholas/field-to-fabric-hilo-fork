// Command Parser.
// This tab contains the functions for parsing commands and values from
// buffered array of characters, as per the HILO communication protocol.


// Parsed the data stored in the array pointed to by dataBuff, up to a dataSize number of bytes.
// Stores the parsed command in the global parsedCommand variable.
// Stores parsed parameters in the global parsedParams array, 
// incrementing the global parsedParamsCount variable.
int parseData(char* dataBuff, int dataSize) {
  parsedCommand = 0;
  parsedParamsCount = 0;
  int parsePos =  0;
  
  if (dataBuff[0] != CMD_DELIM_BEGIN) {
    // error: the first byte isn't a start-delimiter
    return ERR_BEGIN_MISSING;
  }
  if (dataSize < 3) {
    // error: the message size is too small
    return ERR_DATA_SIZE;
  }
  if (dataBuff[dataSize - 1] != CMD_DELIM_END) {
    // error: the first byte isn't an end-delimiter
    return ERR_END_MISSING;
  }

  parsedCommand = dataBuff[1];  
  parsePos = 2;

  // keep trying to parse integers until the end-delimiter
  while (true) {
    if (dataBuff[parsePos] == CMD_DELIM_END) {
      break;
    }
    else if (dataBuff[parsePos] == CMD_DELIM_PARAM) {
      parsePos++;
      int parsedInt = parseIntFrom(dataBuff, parsePos);
      parsedParams[parsedParamsCount++] = parsedInt;
    }
    else {
      if ((dataBuff[parsePos] >= '0' && dataBuff[parsePos] <= '9') || dataBuff[parsePos] == '-')
        parsePos++;
      else 
        return ERR_DELIM;
    }
  }

  // Uncomment for USB debug only; don't use with the app
  /*
  Serial.println("Parsing successful");
  Serial.print("Command: ");
  Serial.println(parsedCommand);
  Serial.print("Params: ");
  Serial.println(parsedParamsCount);
  for (int i = 0; i < parsedParamsCount; i++) {
    Serial.println(parsedParams[i]);
  }
  */

  return 0;
}


// Parses an integer (positive or negative) from a buffer,
// starting at the specified position.
int parseIntFrom(char* buff, int startPos) {
  bool isNegative = false;
  int result = 0;

  int pos = startPos;
  if (buff[pos] == '-') {
    isNegative = true;
    pos++;
  }
  
  while (true) {
    if (buff[pos] >= '0' && buff[pos] <= '9') {
      result = (result * 10) + (buff[pos] - 48);
      pos++;
    }
    else break;
  }

  if (isNegative) 
    result *= -1;

  return result;
}
