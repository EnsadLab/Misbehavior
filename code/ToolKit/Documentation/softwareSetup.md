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

Firs line corresponds to the first motor inside processingg's gui, second line to the second one and so on.

### Midi setup

	 <midi in="nanoKONTROL2" out="nanoKONTROL2"/>   

## System specific setup

### Macintosh

The xbee port can be found running this command line inside