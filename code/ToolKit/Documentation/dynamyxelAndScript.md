#Dynamixel and script 

## Dynamixel info

The dynamixels motors can be used in two different modes :

* **Join** : like an actual servo motor the dynamixel goes to the position you gave it. *Pro* : you can set to motor to a precise position to create movements. *Con* : you can only use the motor over 270° .
* **Wheel** : Like the motor of a car you can make the dynamixel turn continuously. *Pro* : you can set precisely the speed of the motor. *Con* : you can't set precisely the position of the motor.

In order to work more in depth with the motors, the dynmixels allow you to act on some inner parameters :

* **Compliance** : flexibility of the motor, which correspond to the variation of the motor's torque as it reaches its targeted position. The higher the value, the more flexible the motor is.
* **Compliance Margin** : margin of error allowed between the targeted position of the motor and it's actual position.
* **Torque** : maximum torque the motor is allowed to output.

## Script reference

| FONCTION		  | ACTION 		|
| --------------------------- | ------------------------ |
| <*script* | **Beginning of a new script** named *script* |
| > | **end of script** | 
| #*label* | set a **label** named *label* | 
| @*name* *nb* | **jumps back to index** *name*, *nb* times|
| @*script*.*label* | **Execute another script** named *script* starting at its label named *label* | 
| a *anim* | **Animation** : plays *anim* |
|  j *value* |  Set dynamixel to **join mode** and position to *value* (-512~512 , 0 is the central position)  |
|  w *value* | Set dynamixel to **wheel mode** and speed to *value* ( 0~1023 : counterclockwise , 1023~2047 : clockwise) |
| s *value* | Set dynamixel's **join mode speed** to *value* (0~1023) |
| d *time* | **Duration** to do the action, *time* is in milliseconds |
| [*min* *max*] | **Random** integer between *min* and *max* |
| p  *time* | **Pauses** script for *time* milliseconds |
| c *value* | Set dynamixel's **compliance** to *value* (1~7) |
| m *value* | Set **compliance margin** to *value* (0~255) |
| t *value* | Set dynamixel's maximum **torque** to *value* (0~1023) |

Some functions can be combined. For example :

| COMBINATION	 | ACTION 		|
| -------------------------- | ------------------------- |
| w *100* d *2000* | Set dynamixel to wheel mode at speed *100*, it will take *2000* milliseconds to go from current speed to set speed |
| j [*-30* *150*] | Set dynamixel to join mode and randomly sets the position between *-30* and *150* | 

