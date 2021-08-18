// App - Settings and Strings
// Contains classes that load, store and save:
// - App Settings (e.g. screen size, MRU serial port)
// - Machine Settings (machine configuration parameters)
// - App Strings (localized text that is used in the app)

import java.util.Map;
import java.util.Iterator;


// Loads, stores and saves app Settings
class AppSettings {
  
  boolean fullscreen;  // running fullscreen
  int     width;       // window width
  int     height;      // window height
  String  langFile;    // name of the language file to use
  String  prefPort;    // name of the last connected serial port 
  
  AppSettings() {
    resetToDefault();
  }
  
  // Assign default values to the object's fields
  void resetToDefault() {
    this.fullscreen = false;
    this.width      = 1024;
    this.height     = 768;
    this.langFile   = "HILO_AppText_EN.json";
    this.prefPort   = "";
  }
  
  // Load the settings from a file specified by filename (including path)
  boolean load(String filename) {
    JSONObject jsonObj;
    try {
      jsonObj = loadJSONObject(filename);
    } catch (Exception e) {
      return false;
    }
    try {
      this.fullscreen = jsonObj.getBoolean("fullscreen");
      this.width      = jsonObj.getInt    ("width");
      this.height     = jsonObj.getInt    ("height");
      this.langFile   = jsonObj.getString ("langFile");
      this.prefPort   = jsonObj.getString ("prefPort");
    } catch (Exception e) {
      println("AppSettings.load() ERROR: file [" + filename + "] isn't properly formatted");
      println(e.getMessage());
      this.resetToDefault();
      return false;
    }
    if (this.langFile == null) {
      println("AppSettings.load() ERROR: file [" + filename + "] isn't properly formatted (missing String)");
      this.resetToDefault();
      return false;
    }
    return true;
  }
  
  // Save the settings to a file specified by filename (including path)
  boolean save(String filename) {
    JSONObject jsonObj = new JSONObject();
    jsonObj.setBoolean("fullscreen", this.fullscreen);
    jsonObj.setInt    ("width",      this.width);
    jsonObj.setInt    ("height",     this.height);
    jsonObj.setString ("langFile",   this.langFile);
    jsonObj.setString ("prefPort",   this.prefPort);
    try {
      return saveJSONObject(jsonObj, filename);
    } catch (Exception e) {
      println("AppSettings.save() ERROR: can't write to file [" + filename + "]");
      println(e.getMessage());
      return false;
    }
  }
  
  // Overrides the default toString() method, useful for printing the object to the console
  @Override
  String toString() {
    String result = "";
    result += "fullscreen: " + this.fullscreen + "\n";
    result += "width: " + this.width + "\n";
    result += "height: " + this.height + "\n";
    result += "langFile: " + this.langFile;
    result += "prefPort: " + this.prefPort;
    return result;
  }
}


// Loads, stores and saves app Settings
class MachineSettings {
  
  int   deliverySpeedSteps;   // the delivery speed in steps/second
  int   draftingSpeedPercMin; //  lowest value for the drafting speed, as a percentage of the delivery speed (0-100)
  int   draftingSpeedPercMax; // highest value for the drafting speed, as a percentage of the delivery speed (0-100)
  int   spindleSpeedStepsMin; //  lowest value for the spindle speed, in steps/second
  int   spindleSpeedStepsMax; // highest value for the spindle speed, in steps/second
  float stepsPerCm;
  
  MachineSettings() {
    resetToDefault();
  }
  
  // Assign default values to the object's fields
  void resetToDefault() {
    this.deliverySpeedSteps   = 300;
    this.draftingSpeedPercMin = 20;
    this.draftingSpeedPercMax = 80;
    this.spindleSpeedStepsMin = 200;
    this.spindleSpeedStepsMax = 700;
    this.stepsPerCm           = 30.476;
  }
  
  // Load the machine settings from a file specified by filename (including path)
  boolean load(String filename) {
    JSONObject jsonObj;
    try {
      jsonObj = loadJSONObject(filename);
    } catch (Exception e) {
      return false;
    }
    try {
      this.deliverySpeedSteps   = jsonObj.getInt   ("deliverySpeedSteps");
      this.draftingSpeedPercMin = jsonObj.getInt   ("draftingSpeedPercMin");
      this.draftingSpeedPercMax = jsonObj.getInt   ("draftingSpeedPercMax");
      this.spindleSpeedStepsMin = jsonObj.getInt   ("spindleSpeedStepsMin");
      this.spindleSpeedStepsMax = jsonObj.getInt   ("spindleSpeedStepsMax");
      this.stepsPerCm           = jsonObj.getFloat ("stepsPerCm");
    } catch (Exception e) {
      println("AppSettings.load() ERROR: file [" + filename + "] isn't properly formatted");
      println(e.getMessage());
      this.resetToDefault();
      return false;
    }
    return true;
  }
  
  // Save the settings to a file specified by filename (including path)
  boolean save(String filename) {
    JSONObject jsonObj = new JSONObject();
    jsonObj.setInt   ("deliverySpeedSteps",   this.deliverySpeedSteps);
    jsonObj.setInt   ("draftingSpeedPercMin", this.draftingSpeedPercMin);
    jsonObj.setInt   ("draftingSpeedPercMax", this.draftingSpeedPercMax);
    jsonObj.setInt   ("spindleSpeedStepsMin", this.spindleSpeedStepsMin);
    jsonObj.setInt   ("spindleSpeedStepsMax", this.spindleSpeedStepsMax);
    jsonObj.setFloat ("stepsPerCm",           this.stepsPerCm);
    try {
      return saveJSONObject(jsonObj, filename);
    } catch (Exception e) {
      println("MachineSettings.save() ERROR: can't write to file [" + filename + "]");
      println(e.getMessage());
      return false;
    }
  }
  
  // Overrides the default toString() method, useful for printing the object to the console
  @Override
  String toString() {
    String result = "";
    result += "deliverySpeedSteps: " + this.deliverySpeedSteps + "\n";
    result += "draftingSpeedPercMin: " + this.draftingSpeedPercMin + "\n";
    result += "draftingSpeedPercMax: " + this.draftingSpeedPercMax + "\n";
    result += "spindleSpeedStepsMin: " + this.spindleSpeedStepsMin + "\n";
    result += "spindleSpeedStepsMax: " + this.spindleSpeedStepsMax + "\n";
    result += "stepsPerCm" + this.stepsPerCm;
    return result;
  }
}


// Loads and stores the text strings used in the app
class AppStrings {  
  
  // Map to store and provide access to the strings by name
  HashMap<String, String> strings;
  
  AppStrings() {
    strings = new HashMap<String, String>();
    resetToDefault();
  }  
  
  // Assign default values to the app strings
  void resetToDefault() {
    strings.clear();
    strings.put("welcome",       "Welcome to HILO!\nWhat would you like to do?");
    strings.put("fibre",         "Choose a fibre to spin");
    strings.put("connect",       "Connect to the HILO machine");
    strings.put("choosePort",    "Choose a USB port");
    strings.put("fibreWool",     "Wool");
    strings.put("fibreCotton",   "Cotton");
    strings.put("fibreSynth",    "Synthetic");
    strings.put("fibreSilk",     "Silk");
    strings.put("fibreNew",      "New Material");
    strings.put("selection",     "Selection");
    strings.put("yarnThickness", "Yarn Thickness");
    strings.put("numTwists",     "Number of Twists");
    strings.put("machineStatus", "MACHINE STATUS");
  }
  
  // Load the machine settings from a file specified by filename (including path)
  boolean load(String filename) {
    JSONObject jsonObj;
    try {
      jsonObj = loadJSONObject(filename);
    } catch (Exception e) {
      println("AppStrings.load() ERROR: file [" + filename + "] isn't properly formatted");
      return false;
    }
    // loop through the strings map and fetch the values from JSON
    for (Map.Entry pair : strings.entrySet()) {
      String key = (String)pair.getKey();
      strings.put(key, jsonObj.getString(key));
    }
    return true;
  }
  
  // Get a text string by name (key)
  String get(String key) {
    String val = strings.get(key);
    if (val == null) return "";
    return val;
  }
  
  // Overrides the default toString() method, useful for printing the object to the console
  @Override
  String toString() {
    String result = "";
    int size = strings.size();
    int count = 0;
    for (Map.Entry pair : strings.entrySet()) {
      result += pair.getKey() + ": \"" + pair.getValue() + "\"";
      count++;
      if (count != size) result += "\n";
    }
    return result;
  }
}
