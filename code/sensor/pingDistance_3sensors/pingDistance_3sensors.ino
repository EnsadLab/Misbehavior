//
//code pour Parallax Ping)))
//
//capteur de distance ultrasonique numérique
//range de quelques centimètres à 1m environ (pas précis au delà)
//
//Le fonctionnement des interrupt sur arduino ne permet pas de créer une seule fonction générique, j'ai donc du créer trois fonctions pingDistance#...
//

//echoTime et startTime nécessaires pour le calcul de distance
long echoTime[3];
long startTime[3]; 
//valeur mesurée par le ping)))
byte distance[3];

//pin "sig" du ping)))
byte pingPin[] = {
  17,18,19};



void setup() {
  attachInterrupt(pingPin[0],pingDistance0,CHANGE);
  attachInterrupt(pingPin[1],pingDistance1,CHANGE);
  attachInterrupt(pingPin[2],pingDistance2,CHANGE);
  Serial2.begin(9600);                             
}

void loop() {
  for(int i=0; i<3; i++){
    triggerPingDistance(i); // Permet de mettre en fonctionnement le ping pour une mesure et de lancer le calcul de distance dans la cm9 par la meme occasion
    delay(20); // le ping se réfréchi à une fréquence de 50Hz
  }

  SerialUSB.print(distance[0]);
  SerialUSB.print(" : ");
  SerialUSB.print(distance[1]);
  SerialUSB.print(" : ");
  SerialUSB.println(distance[2]);
}

void triggerPingDistance(int sensorNumber){
  pinMode(pingPin[sensorNumber], OUTPUT);
  digitalWrite(pingPin[sensorNumber], LOW);  
  delayMicroseconds(5); 
  digitalWrite(pingPin[sensorNumber], HIGH);
  delayMicroseconds(5);
  pinMode(pingPin[sensorNumber], INPUT);
}

void pingDistance0(){
    echoTime[0] = micros()-startTime[0];
    startTime[0] = micros();
    distance[0] = echoTime[0]/57;
}

void pingDistance1(){
    echoTime[1] = micros()-startTime[1];
    startTime[1] = micros();
    distance[1] = echoTime[1]/57;
}

void pingDistance2(){
    echoTime[2] = micros()-startTime[2];
    startTime[2] = micros();
    distance[2] = echoTime[2]/57;
}







