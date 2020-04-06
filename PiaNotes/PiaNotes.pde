import javax.sound.midi.*;
import java.util.ArrayList;
import java.util.List;
import java.io.*;
import javax.swing.*;


int pianoKey = -1;
class Main
{
  public void Main()
  {
    MidiDevice device;
    MidiDevice.Info[] infos = MidiSystem.getMidiDeviceInfo();
    for (int i = 0; i < infos.length; i++) {
      try {
        device = MidiSystem.getMidiDevice(infos[i]);
        //does the device have any transmitters?
        //if it does, add it to the device list
        System.out.println(infos[i]);

        //get all transmitters
        List<Transmitter> transmitters = device.getTransmitters();
        //and for each transmitter

        for (int j = 0; j<transmitters.size(); j++) {
          //create a new receiver
          transmitters.get(j).setReceiver(
            //using my own MidiInputReceiver
            new MidiInputReceiver(device.getDeviceInfo().toString())
            );
        }

        Transmitter trans = device.getTransmitter();
        trans.setReceiver(new MidiInputReceiver(device.getDeviceInfo().toString()));

        //open each device
        device.open();
        //if code gets this far without throwing an exception
        //print a success message
        System.out.println(device.getDeviceInfo()+" Was Opened");
      } 
      catch (MidiUnavailableException e) {
      }
    }
  }
  //tried to write my own class. I thought the send method handles an MidiEvents sent to it
  class MidiInputReceiver implements Receiver {
    public String name;
    public MidiInputReceiver(String name) {
      this.name = name;
    }
    public void send(MidiMessage msg, long timeStamp) {


      byte[] aMsg = msg.getMessage();
      // take the MidiMessage msg and store it in a byte array

      // msg.getLength() returns the length of the message in bytes

      if (msg.getLength() == 3 && aMsg[2] != 0) {
        println(aMsg[1]);
        pianoKey = aMsg[1];
        if(pianoKey != keyToPress){
          score = 0;
          reset();
        }
      } 
      // aMsg[0] is something, velocity maybe? Not 100% sure.
      // aMsg[1] is the note value as an int. This is the important one.
      // aMsg[2] is pressed or not (0/100), it sends 100 when they key goes down,  
      // and 0 when the key is back up again. With a better keyboard it could maybe
      // send continuous values between then for how quickly it's pressed? 
      // I'm only using VMPK for testing on the go, so it's either 
      // clicked or not.
    }
    public void close() {
    }
  }
}

int timeToWait = 0;
int score = 0;
int time;
int keyToPress;

PImage note;


Main main = new Main();
void setup() {
  int n = Integer.parseInt(JOptionPane.showInputDialog("How many seconds to wait?"));
  while (n <= 0) {
    n = Integer.parseInt(JOptionPane.showInputDialog("How many seconds to wait?"));
  }
  timeToWait = n;
  frameRate(60);
  size(500, 500);
  background(255);
  main.Main();
  reset();
}

void draw() {
  background(255);
  fill(0);
  text("use keys 60-84", 0, 10);
  text ("Your score is " + score, 0, 20);
  if (pianoKey != -1) {
    text ("you have pressed key " + pianoKey, 0, 30);
  }
  text(time/60 + "s", 480, 10);

  if (time == 0) {
    println("time's up");
    score = 0;
    reset();
  } else {
    time--;
  }

  if (keyToPress == pianoKey) {
    println("you did it right!");
    score++;
    reset();
  }
  image(note, 0, 100);
} 

void reset() {
  keyToPress = (int)random(60, 85);
  while (true) {
    if (keyToPress !=  60 && keyToPress != 62 && keyToPress != 64 && keyToPress != 65 && keyToPress != 67 && keyToPress != 69 && keyToPress != 71 && keyToPress != 72 && keyToPress != 74 && keyToPress != 76 && keyToPress != 77 && keyToPress != 79 && keyToPress != 81 && keyToPress != 83 && keyToPress != 84) {
      keyToPress = (int)random(60, 85);
    } else {
      break;
    }
  }
  println(keyToPress);
  note = loadImage(dataPath(keyToPress + ".png"));
  time = 60 * timeToWait;
}
