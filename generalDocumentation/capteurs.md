
##CM9


* Analog input : 12b
* Fonctionnement interne : 3,3V
* Voltage de référence : 3,3V 
* Digital output : 3,3V


##Parallax Ping)))
http://www.parallax.com/product/28015


* capteur de distance ultrasonic.
* range de 2 cm à 300cm (précis jusqu'à 1m, non vérifié au dela).
* rafraichissement maximum de 50Hz à priori.
* Nous avons un code pour la cm9 à base d'interrupt qui fonctionne.


##Sound impact sensor

renvoie un état haut si un impact sonore dépasse un certain seuil (réglable), état bas sinon.



##Sharp 2Y0A21
http://www.sharpsma.com/webfm_send/1489


* capteur de distance infra rouge analogique.
* range de 10cm à 80cm.
* rafraichissement max entre 20Hz et 25Hz à priori.
* semble assez précis (surement besoin d'un lissage).
* Pas encore de code, il me manque des infos sur la cm9 (voir plus haut).


##Dynamixel AX-S1
http://support.robotis.com/en/product/auxdevice/sensor/dxl_ax_s1.htm#Ax_S1_Address_1A


* peut détecter de l'infra rouge, du son
* peut émettre du son


###infra rouge et lumiere

#### trois capteurs : gauche, centre, droite 

Il s'agit en réalité du même capteur.

* IR : le capteur émet de l'infra-rouge et observe la quantité réfléchie.
* light : le capteur se contente d'observer la quantité d'infra-rouge de la lumière ambiante.

####mode "valeur" 
* IR : observer les registres 26, 27, 28; valeurs retournées de 0 à 255
* light : observer les registres 29, 30, 31; valeurs retournées de 0 à 255

####mode "seuil" 
* IR : seuil fixé dans les registres 0x14 (ROM) et 0x34 (RAM) (la ROM est automatiquement copiée dans la RAM au moment du boot)
* light : seuil fixé dans les registres 0x15 (ROM) et 0x35 (RAM)
* IR : obstacle détecté : retour dans le registre 0x20 : 1 si détecté, 0 sinon (composition de l'octet : bit0 : capteur gauche ; bit1 : capteur centre ; bit2 ; capteur droite)
* light : obstacle détecté : retour dans le registre 0x21 : 1 si détecté, 0 sinon (composition de l'octet : bit0 : capteur gauche ; bit1 : capteur centre ; bit2 ; capteur droite)

###Son
Je n'ai pas encore approfondi le sujet. 

* possibilité de détecter un niveau sonore, de détecter des impacts sonores, détecter la direction d'un son (par l'utilisation de deux capteurs dynamixels).
* Possibilité d'émettre des sons de buzzers (52 notes chromatiques).
Si cela cous semble intéressant, je me pencherait dessus la semaine prochaine.
