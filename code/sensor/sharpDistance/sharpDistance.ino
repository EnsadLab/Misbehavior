//
//Code pour Sharp GP2Y0A21YK0F
//
//Capteur de distance infrarouge analogique
//range 8cm à 80cm environ
//distance n'est pas la valeur exacte de distance mais est très approchante
//

const int analogInputPin = 1;

void setup() {
  SerialUSB.begin();
  pinMode(analogInputPin, INPUT_ANALOG);
}

void loop() {  
  SerialUSB.println(getSharpDistance(analogInputPin));
  delay(50); // rafraichissement entre 20Hz et 25Hz
}

float getSharpDistance(int inputPin){
  float analogValue = analogRead(analogInputPin);
  float distance = pow((analogValue/4096)*3.3,-1.15)*27.86;
  return distance;
  //SerialUSB.print(analogValue);
  //SerialUSB.print("   ");
  //SerialUSB.println(distance);
}


