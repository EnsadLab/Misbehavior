

MidiHandler midiHandler;


void setup()
{
  midiHandler = new MidiHandler();

  //liste les ports midi disponibles, ( "transmitter" = MIDI INPUT ) 
  midiHandler.printdevices();

  //puis décomonter cette et choisir le nom du device à tester
  //midiHandler.openIn("BCR2000"); //BCR2000 est mon behringer rotary sur Window ... autre nom sur Mac!

  //... les messages midi reçus devraient s'afficher dans la console.
}

void draw()
{
}

void exit()
{
  midiHandler.close();
  super.exit();
}
