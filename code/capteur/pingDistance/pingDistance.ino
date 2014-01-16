//
//code pour Parallax Ping)))
//
//capteur de distance ultrasonique numérique
//range de quelques centimètres à 1m environ (pas précis au delà)
//

//echoTime et startTime nécessaires pour le calcul de distance
long echoTime;
long startTime;
//valeur mesurée par le ping)))
byte distance;
//pin "sig" du ping)))
byte pingPin = 17;



void setup() {
  attachInterrupt(pingPin,pingDistance,CHANGE);
  Serial2.begin(9600);                             
}

void loop() {
  triggerPingDistance(pingPin);
  delay(100);
  SerialUSB.print("LDistance ");
  SerialUSB.println(distance);

}

void triggerPingDistance(int sensorPin){
  pinMode(sensorPin, OUTPUT);
  digitalWrite(sensorPin, LOW);  
  delayMicroseconds(5); 
  digitalWrite(sensorPin, HIGH);
  delayMicroseconds(5);
  pinMode(sensorPin, INPUT);
}

void pingDistance()
{
  echoTime = micros()-startTime;
  startTime = micros();
  distance = echoTime/57;

}





