import java.io.*;


public class WavEncoder{
  
  WavEncoder(){   System.out.println("-> Create Wav Encoder"); }
  
  public void readWav()
  {
    try
      {
         // Open the wav file specified as the first argument
         WavFile wavFile = WavFile.openWavFile(new File("/Users/cecbucher/Projects/Diip/Misbehavior/code/ToolKit/DxlBehav15/test.wav"));//new File(args[0]));

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
  
  public void writeWav()
  {
    
    
    try
    {
      int sampleRate = 50;//44100;    // Samples per second
      double duration = 5.0;    // Seconds

      // Calculate the number of frames required for specified duration
      long numFrames = (long)(duration * sampleRate);

      // Create a wav file with the name specified as the first argument
      WavFile wavFile = WavFile.newWavFile(new File("/Users/cecbucher/Projects/Diip/Misbehavior/code/ToolKit/DxlBehav15/testWrite.wav"), 6, numFrames, 16, sampleRate);

      // Create a buffer of 100 frames
      double[][] buffer = new double[6][100];

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
          buffer[0][s] = dataTest;
          buffer[1][s] = dataTest;
          buffer[2][s] = dataTest;
          buffer[3][s] = dataTest;
          buffer[4][s] = dataTest;
          buffer[5][s] = dataTest;
          
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




















