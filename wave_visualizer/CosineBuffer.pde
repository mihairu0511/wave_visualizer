//
// This file provides a CosineBuffer class, which you can pass to WavePlayer to
// generate cosine-shaped waveforms.  You can include this file in your homework
// sketch.
//
// Create a new instance of a CosineBuffer in your homework code via:
//    Buffer cosineBuffer = new CosineBuffer.getDefault();
// You can then configure a WavePlayer to use cosine waves via:
//    wavePlayer.setBuffer(cosineBuffer);
//
import beads.*;

public class CosineBuffer extends BufferFactory {
    /* (non-Javadoc)
     * @see net.beadsproject.beads.data.BufferFactory#generateBuffer(int)
     */
    public Buffer generateBuffer(int bufferSize) {
      Buffer b = new Buffer(bufferSize);
        for(int i = 0; i < bufferSize; i++) {
            b.buf[i] = (float)Math.cos(2.0 * Math.PI * (double)i / (double)bufferSize);
        }
      return b;
    }

    /* (non-Javadoc)
     * @see net.beadsproject.beads.data.BufferFactory#getName()
     */
    public String getName() {
      return "Cosine";
    }
}
