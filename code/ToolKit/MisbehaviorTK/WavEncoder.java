/*******************************************************************************                                                   
*   Copyright 2013-2014 EnsadLab/Reflective interaction                        *
*   Copyright Dr. Andrew Greensted                                             *
*   http://www.labbookpages.co.uk/audio/javaWavFiles.html                      *
*                                                                              *
*   This file is part of MisB.                                                 *
*                                                                              *
*   MisB is free software: you can redistribute it and/or modify               *
*   it under the terms of the Lesser GNU General Public License as             *
*   published by the Free Software Foundation, either version 3 of the         *
*   License, or (at your option) any later version.                            *
*                                                                              *
*   MisB is distributed in the hope that it will be useful,                    *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of             *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
*   GNU Lesser General Public License for more details.                        *
*                                                                              *
*   You should have received a copy of the GNU Lesser General Public License   *
*   along with MisB.  If not, see <http://www.gnu.org/licenses/>.              *
*******************************************************************************/

import java.io.*;


public class WavEncoder{
    
  WavEncoder()
  { 
  
  }
 
  double[][] readWav(String path)
  {
     try
      {
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
  
  
  public void writeWav(String path, int numFrames,float[][] values)
  {

    try
    {
      int sampleRate = 40; 
      double duration = numFrames/sampleRate;
      int nbChannels = values.length;
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
        for (int s=0 ; s<toWrite ; s++, frameCounter++)
        {
          for(int c=0; c<nbChannels; c++)
          {
            buffer[c][s] = (double)(values[c][(int)frameCounter]);
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
    
 
  
}




















