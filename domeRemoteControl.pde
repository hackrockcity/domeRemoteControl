import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import controlP5.*;

import oscP5.*;
import netP5.*;

// Realtime controller for the domeTransmitter
// By Matt Mets

String server_ip = "127.0.0.1";
int server_port  = 5601;

OscP5 oscP5;
ControlP5 cp5;

NetAddress myRemoteLocation;

Minim minim;
AudioInput in;
FFT shortFft;

boolean enableFft = false;
float system_brightness;

void setup() {
  size(340,400);
  frameRate(30);
  oscP5 = new OscP5(this,server_port + 1);
  cp5 = new ControlP5(this);
  
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  myRemoteLocation = new NetAddress(server_ip, server_port);

  cp5.addSlider("framerate")
    .setPosition(10,10)
    .setRange(10,150)
    .setValue(45)
    .setWidth(250)
    .setHeight(30)
    ;

  cp5.addSlider("brightness")
    .setPosition(10,50)
    .setRange(0,1)
    .setValue(.1)
    .setWidth(250)
    .setHeight(30)
    ;
    
  cp5.addToggle("enableFft")
    .setPosition(10,90)
    .setHeight(30)
    .setWidth(30)
    .setValue(false)
    ;
    
  // for brightness fft
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  shortFft = new FFT(in.bufferSize(), in.sampleRate());
  shortFft.linAverages(1);
}


void draw() {
  background(0);
  
  if (enableFft) {
    shortFft.forward(in.mix);
  
    float f = shortFft.getAvg(0);
    
    float bright = .03 + (f - .12)/5;
    bright = min(bright, system_brightness);
    
    updateVariable("brightness", bright);
//    println(f + ", " + avg + ", " + bright);
  }    
}

void updateVariable(String variable, int setting) {
  OscMessage myMessage = new OscMessage("/" + variable);
  myMessage.add(setting);
  oscP5.send(myMessage, myRemoteLocation); 
}

void updateVariable(String variable, float setting) {
  OscMessage myMessage = new OscMessage("/" + variable);
  myMessage.add(setting);
  oscP5.send(myMessage, myRemoteLocation); 
}


void framerate(float setting) {
  updateVariable("framerate", int(setting));
}

void brightness(float setting) {
  updateVariable("brightness", setting);
  system_brightness = setting;
}
