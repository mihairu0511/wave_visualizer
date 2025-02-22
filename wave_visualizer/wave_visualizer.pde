import beads.*;
import controlP5.*;

AudioContext ac;
WavePlayer[] wp;
Gain[] gain;
Gain masterGain;
ControlP5 p5;
Slider[] slider;
boolean isInteractive = false;

void setup() {
  size(1200, 500);

  ac = new AudioContext();

  p5 = new ControlP5(this);
  
  p5.addButton("fundamental")
    .setPosition(830, 30)
    .setSize(60, 50)
    .setLabel("Fundamental");
  
  p5.addButton("square")
    .setPosition(900, 30)
    .setSize(60, 50)
    .setLabel("Square");
  
  p5.addButton("sawtooth")
    .setPosition(970, 30)
    .setSize(60, 50)
    .setLabel("Sawtooth");
  
  p5.addButton("triangle")
    .setPosition(1040, 30)
    .setSize(60, 50)
    .setLabel("Triangle");
    
  p5.addButton("interactive")
    .setPosition(1110, 30)
    .setSize(60, 50)
    .setLabel("Interactive");
  
  p5.addButton("close")
   .setPosition(1180, 10)
   .setSize(15, 15)
   .setColorBackground(color(255, 0, 0))
   .setLabel("");

  wp = new WavePlayer[10];
  gain = new Gain[10];
  slider = new Slider[10];
  
  masterGain = new Gain(ac, 1, 1);

  for (int i = 0; i < 10; i++) {
    float frequency = 440 * (i + 1);
    wp[i] = new WavePlayer(ac, frequency, Buffer.SINE);
    gain[i] = new Gain(ac, 1, 0);
    gain[i].addInput(wp[i]);
    masterGain.addInput(gain[i]);

    slider[i] = p5.addSlider("Harmonic " + (i + 1))
                          .setPosition(830, 100 + i * 40)
                          .setSize(300, 20)
                          .setRange(0, 1)
                          .setValue(0);
  }

  ac.out.addInput(masterGain);

  ac.start();
}

void draw() {
  background(0);
  drawWaveform();
  
  if (isInteractive) {
    for (int i = 0; i < 10; i++) {
      float sliderValue = slider[i].getValue();
      gain[i].setGain(sliderValue);
    }
  } else {
    for (int i = 0; i < 10; i++) {
      slider[i].setValue(gain[i].getGain());
    }
  }
  
  fill(0);
  rect(800, 0, 400, 500);
}

void stop() {
  for (int i = 0; i < 10; i++) {
    gain[i].setGain(0);
  }
}

void resetBuffer() {
  for (int i = 0; i < 10; i++) {
    wp[i].setBuffer(Buffer.SINE);
  }
}

void fundamental() {
  stop();
  isInteractive = false;
  resetBuffer();
  gain[0].setGain(0.5);
  for (int i = 0; i < 10; i++) {
    if (i == 0) {
      slider[i].setValue(0.5);
    } else {
      slider[i].setValue(0);
    }
  }
}

void square() {
  stop();
  isInteractive = false;
  resetBuffer();
  for (int i = 0; i < 10; i++) {
    if (i % 2 == 0) {
      float gainValue = 0.5 / (i + 1);
      gain[i].setGain(gainValue);
      slider[i].setValue(gainValue);
    } else {
      slider[i].setValue(0);
      gain[i].setGain(0);
    }
  }
}

void sawtooth() {
  stop();
  isInteractive = false;
  resetBuffer();
  for (int i = 0; i < 10; i++) {
    float gainValue = 0.5 / (i + 1);
    gain[i].setGain(gainValue);
    slider[i].setValue(gainValue);
  }
}

void triangle() {
  stop();
  isInteractive = false;
  
  Buffer cosineBuffer = new CosineBuffer().getDefault();

  for (int i = 0; i < 10; i++) {
    wp[i].setBuffer(cosineBuffer);

    if (i % 2 == 0) {
      float gainValue = 0.5 / ((i + 1) * (i + 1));
      gain[i].setGain(gainValue);
      slider[i].setValue(gainValue);
    } else {
      slider[i].setValue(0);
      gain[i].setGain(0);
    }
  }
}

void interactive() {
  stop();
  isInteractive = true;
}

void close() {
  stop();
  resetBuffer();
  isInteractive = false;
}

// Oscilloscope trace
void drawWaveform() {
  fill(0, 32, 0, 32); // set our fill color to very dark green
  rect(0, 0, width, height); // draw a rectangle across the entire window
  stroke(64); // set our stroke color to be gray
  for (int i=0; i < 11; i++) {
    line(0, i*75, width, i*75); // draw horizontal grid lines
    line(i*75+25, 0, i*75+25, height); //draw vertical grid lines
  }
  stroke(255); // set stroke color to white
  line(width/2, 0, width/2, height); // draw vertical midpoint line
  line(0, height/2, width, height/2); // draw horizontal midpoint line
  stroke(128, 255, 128); // set stroke color to green
  
  int crossing=0; // keep track of which buffer index "starts" the waveform
  
  // Now, draw the waveforms so we can see what we are monitoring
  for (int i = 0; i < ac.getBufferSize() - 1 && i<width+crossing; i++) {
    // Find the "crossing point" where the wave crosses the X axis
    // (that is, the value at i is negative but the value at i+1 is positive)
    // This lets us start drawing the waveform shape at the origin each time
    // rather than having it bouncing around the window depending on where
    // we are in the buffer.
    if (crossing == 0 && ac.out.getValue(0, i) < 0 && ac.out.getValue(0, i+1) > 0) {
      crossing=i;
    }
    // Once we have the crossing point, draw a line segment between the current
    // buffer value and the next one, offsetting the i by whatever our crossing was.
    // For the Y coordinates we scale the buffer values by 3/4 of the window height.
    if (crossing != 0) {
      line(i-crossing, height/2 + ac.out.getValue(0, i) * (3*height/4), i+1-crossing, height/2 + ac.out.getValue(0, i+1) * (3*height/4));
    }
  }
}
