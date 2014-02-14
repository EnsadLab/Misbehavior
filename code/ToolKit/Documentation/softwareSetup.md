# Software setup

## Setting up processing

When launching the program processing reads a configuration file : *config.xml* . Keep this file at hand since this is where you will set up the parameters of your robot.

### xbee setup
	
	<arduino port="COM13" bauds="115200" />
	
Setup which port your xbee is using.  Bauds' value has to stay to 115200.
	
### Motor setup
	
	<motor id="1" mode="wheel"/>
	
The id is the number written on the back of your motor.

Select which mode your motor is using : *wheel* or *join*.

First line corresponds to the first motor inside processingg's gui, second line to the second one and so on.

### Midi setup

	 <midi in="nanoKONTROL2" out="nanoKONTROL2"/>   

## System specific setup

### Macintosh

#### xbee

The xbee port can be found running this command line inside the *Terminal.app* :
	
	ls /dev/tty.*
	
The port the xbee use will look this way : ```/dev/tty.usbserial-A600H2BB``` . Copy/paste it in the *config.xml* file :

	<arduino port="/dev/tty.usbserial-A600H2BB" bauds="115200" />
	
### Midi interface

The midi interface is named *SLIDER/KNOB* for input and *CTRL* for output. The *config.xml* should look this way :

		 <midi in="SLIDER/KNOB" out="CTRL"/>   


### Known Processing issue

It might happen that when running processing the console will ask you to run the following line inside *Terminal.app* : 

	sudo mkdir /var/lock
	sudo chmod 777 /var/lock

### Windows

### Midi interface

The midi interface is named *nanoKONTROL2* for input and *nanoKONTROL2* for output. The *config.xml* should look this way :

	 <midi in="nanoKONTROL2" out="nanoKONTROL2"/>   
