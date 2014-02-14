# Sensor information

## Info

Two kind of distance sensors are present in the toolkit : the *Parallax Ping)))* and the *sharp GP2Y0A21YK0F*.

* **Ping)))** : ultrasonic digital sensor. Ranges from 10cm to 1m.
* **Sharp** : infrared anolog sensor. Ranges from 10cm to 80cm.

## How to connect the sensors

The sensors have to be connected directly to the breadboard on which the openCM is plugged.

* **Ping)))** :

| Sensor | CM9 pin | Breadboard | 
| ---- | ---- | ---- | 
| black | GND | blue line |  
| red | 5v | red line |  
| white | 15 and 13 | 


* **Sharp** :

| Sensor | CM9 pin | Breadboard |
| ---- | ---- | ---- |
| black | GND | blue line |
| red | 5v | red line |
| white | 7 |  |

## Inside the GUI

The sensors are numbered as follow :

| GUI | Sensor | CM9 pin |
| ---- | ---- | ---- |
| Sensor 1 | ping))) | 15 |
| Sensor 2 | ping))) | 13 |
| Sensor 3 | sharp | 7 |
