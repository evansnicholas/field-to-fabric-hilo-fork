boolean isDebug = true;

void debugMessage(String message) {
  if (isDebug) println(message);  
}


// easing functions used in animations and transitions; based on:
//   https://gist.github.com/gre/1650294

float easeInQuad (float t, float tMin, float tMax, float min, float max) {
  float mapT = map(t, tMin, tMax, 0, 1);
  float ease = easeInQuad(mapT);
  return map(ease, 0, 1, min, max);
}

float easeOutQuad (float t, float tMin, float tMax, float min, float max) {
  float mapT = map(t, tMin, tMax, 0, 1);
  float ease = easeOutQuad(mapT);
  return map(ease, 0, 1, min, max);
}

float easeInQuart (float t, float tMin, float tMax, float min, float max) {
  float mapT = map(t, tMin, tMax, 0, 1);
  float ease = easeInQuart(mapT);
  return map(ease, 0, 1, min, max);
}

float easeOutQuart (float t, float tMin, float tMax, float min, float max) {
  float mapT = map(t, tMin, tMax, 0, 1);
  float ease = easeOutQuart(mapT);
  return map(ease, 0, 1, min, max);
}

float easeInQuad (float t) {
  return t*t;
}

float easeOutQuad (float t) {
  return t*(2-t);
}

float easeInQuart (float t) {
  return t*t*t*t;
}

float easeOutQuart (float t) {
  return 1-(--t)*t*t*t;
}


void drawSineWave(PGraphics g, float x, float y, float w, float h, float frequency, float offset, int steps) {
  float prevX = x;
  float currX = x;
  for (int i = 0; i < steps; i++) {
    float posPrev = offset + (frequency * (i-1) / (float)steps);
    float posCurr = offset + (frequency * i / (float)steps);
    
    float valPrev = y + (h/2.0) + h/2.0*sin(posPrev);
    float valCurr = y + (h/2.0) + h/2.0*sin(posCurr);
    
    g.line(prevX, valPrev, currX, valCurr); 
    
    prevX = currX;
    currX = x + (w/(float)steps) *i; 
  }
}
