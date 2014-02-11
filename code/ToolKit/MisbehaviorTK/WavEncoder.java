import java.io.*;


public class WavEncoder{
    
  WavEncoder()
  { 
  
  }
 
  double[][] readWav(String path)
  {
     try
      {
        //DIB WavFile wavFile = WavFile.openWavFile(new File("/Users/cecbucher/Projects/Diip/Misbehavior/code/ToolKit/MisbehaviorTK/"+path));
        WavFile wavFile = WavFile.openWavFile(new File(path.trim()));
       
        // Display information about the wav file
        wavFile.display();
        
        int numChannels = wavFile.getNumChannels();
        int nbFrames = (int)wavFile.getNumFrames();
        double[][] values = new double[numChannels][nbFrames];
        double[][] buffer = new double[numChannels][100];
        int currFrame = 0;
        int framesRead;
        do
        {
            // Read frames into buffer
            framesRead = wavFile.readFrames(buffer, 100);

            // Loop through frames and look for minimum and maximum value
            for (int s=0 ; s<framesRead; s++)
            {
               for(int c=0; c<numChannels; c++)
               {
                 values[c][currFrame] = buffer[c][s];
               }
               currFrame++;
            }
         }
         while (framesRead != 0);

         // Close the wavFile
         wavFile.close();
         
         return values;
      }
      catch (Exception e)
      {
         System.err.println(e);
         double[][] values = new double[0][0];
         return values;
      }
  }
  
  public void readWav()
  {
    try
      {
         // Open the wav file specified as the first argument
         //WavFile wavFile = WavFile.openWavFile(new File("/Users/cecbucher/Projects/Diip/Misbehavior/code/ToolKit/MisbehaviorTK/test.wav"));//new File(args[0]));
         WavFile wavFile = WavFile.openWavFile(new File("/anims/test.wav"));//new File(args[0]));

         // Display information about the wav file
         wavFile.display();

         // Get the number of audio channels in the wav file
         int numChannels = wavFile.getNumChannels();

         // Create a buffer of 100 frames
         double[] buffer = new double[100 * numChannels];

         int framesRead;
         double min = Double.MAX_VALUE;
         double max = Double.MIN_VALUE;

         do
         {
            // Read frames into buffer
            framesRead = wavFile.readFrames(buffer, 100);

            // Loop through frames and look for minimum and maximum value
            for (int s=0 ; s<framesRead * numChannels ; s++)
            {
               if (buffer[s] > max) max = buffer[s];
               if (buffer[s] < min) min = buffer[s];
               System.out.printf("Frame: %d, val: %f\n", s, buffer[s]);
            }
         }
         while (framesRead != 0);

         // Close the wavFile
         wavFile.close();

         // Output the minimum and maximum value
         System.out.printf("Min: %f, Max: %f\n", min, max);
      }
      catch (Exception e)
      {
         System.err.println(e);
      }
   
  }
  
  
  public void writeWav(String path, int numFrames,float[][] values)
  {

    try
    {
      int sampleRate = 40; // 1000/25
      double duration = numFrames/sampleRate;
      int nbChannels = values.length;
      //WavFile wavFile = WavFile.newWavFile(new File("/Users/cecbucher/Projects/Diip/Misbehavior/code/ToolKit/MisbehaviorTK/"+path), nbChannels, numFrames, 16, sampleRate);
      WavFile wavFile = WavFile.newWavFile(new File("/"+path), nbChannels, numFrames, 16, sampleRate);
       // Create a buffer of 100 frames
      double[][] buffer = new double[nbChannels][100];

      // Initialise a local frame counter
      long frameCounter = 0;

      // Loop until all frames written
      while (frameCounter < (long)numFrames)
      {
        // Determine how many frames to write, up to a maximum of the buffer size
        long remaining = wavFile.getFramesRemaining();
        int toWrite = (remaining > 100) ? 100 : (int) remaining;

        // on pourrait faire ça un peu plus malin... avancer le pointeur... plutot que de copier inutilement ... une fois que tout marche oui...
        // Fill the buffer, one tone per channel
        for (int s=0 ; s<toWrite ; s++, frameCounter++)
        {
          for(int c=0; c<nbChannels; c++)
          {
            //double val = (double)(values[c][(int)frameCounter]);
            //val = val/1024.0;
            buffer[c][s] = (double)(values[c][(int)frameCounter]);//val;
          }
        }

        // Write the buffer
        wavFile.writeFrames(buffer, toWrite);
      }

      // Close the wavFile
      wavFile.close();
    }
    catch (Exception e)
    {
      System.err.println(e);
    }
 
  }
    
  public void writeWav()
  {
    System.out.printf("WRITE WAV");
    
    try
    {
      int sampleRate = 50;//44100;    // Samples per second
      

      // Calculate the number of frames required for specified duration
      long numFrames = 500;//(long)(duration * sampleRate);
      
      double duration = numFrames/sampleRate;//5.0;    // Seconds
      
      double[] velocities = new double[(int)numFrames];
      
      int v = -1023;
      boolean down = false;
      for(int i=0; i<numFrames; i++)
      {
        velocities[i] = v/1024.0;
        if(down)
        {
          v -= 30;
          if(v < -1023)
          {
            v = -1023;
            down = false;
          }
        }
        else
        {
          v += 30;
          if(v > 1023)
          {
            v = 1023;
            down = true;
          }
        }
       
      }
      
      
      

      // Create a wav file with the name specified as the first argument
      //WavFile wavFile = WavFile.newWavFile(new File("/Users/cecbucher/Projects/Diip/Misbehavior/code/ToolKit/MisbehaviorTK/testWrite.wav"), 2, numFrames, 16, sampleRate);
      WavFile wavFile = WavFile.newWavFile(new File("/anims/testWrite.wav"), 2, numFrames, 16, sampleRate);

      // Create a buffer of 100 frames
      double[][] buffer = new double[2][100];

      // Initialise a local frame counter
      long frameCounter = 0;

      // Loop until all frames written
      double dataTest = -1.0;
      boolean goingUp = true;
      while (frameCounter < numFrames)
      {
        // Determine how many frames to write, up to a maximum of the buffer size
        long remaining = wavFile.getFramesRemaining();
        int toWrite = (remaining > 100) ? 100 : (int) remaining;

        // Fill the buffer, one tone per channel
        for (int s=0 ; s<toWrite ; s++, frameCounter++)
        {
          //buffer[0][s] = 0.5;//Math.sin(2.0 * Math.PI * 400 * frameCounter / sampleRate);
          //buffer[1][s] = -130;//Math.sin(2.0 * Math.PI * 500 * frameCounter / sampleRate);
          if(goingUp) {dataTest += 0.01; if(dataTest >= 1.0) goingUp = false; }
          else {dataTest -= 0.01; if(dataTest <= -1.0) goingUp = true;}
          buffer[0][s] = velocities[(int)frameCounter];
          buffer[1][s] = velocities[(int)frameCounter];
          //buffer[2][s] = dataTest;
          //buffer[3][s] = dataTest;
          //buffer[4][s] = dataTest;
          //buffer[5][s] = dataTest;
          
        }

        // Write the buffer
        wavFile.writeFrames(buffer, toWrite);
      }

      // Close the wavFile
      wavFile.close();
    }
    catch (Exception e)
    {
      System.err.println(e);
    }
  
  
  }
  
}




















