import oscP5.*;
import netP5.*;

OscP5 oscP5;
/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

Float activeChan, activeLevel = 99999.0;
int queriedCueList, cueCount = 999999;
int[] queriedCues;

CueList activeCueList = new CueList(1, "Main");

void setup(){
  size(400,400);
  frameRate(25);
  
  /* create a new instance of oscP5. 
   * 12000 is the port number you are listening for incoming osc messages.
   */
  oscP5 = new OscP5(this,12000);
  
  /* create a new NetAddress. a NetAddress is used when sending osc messages
   * with the oscP5.send method.
   */
  
  /* the address of the osc broadcast server */
  myBroadcastLocation = new NetAddress("192.168.0.187",32000);
}

void draw(){
  background(0);
}

void mousePressed() {
  //setChannelLevel(1, 60);
  capitalizeLabels();
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  parseEosOSC(theOscMessage);
  checkAddrPatternContains(theOscMessage, "");
}


/* BACKEND FUNCTIONS */

void parseEosOSC(OscMessage theOscMessage){
  //ACTIVE CHANNEL
  if(theOscMessage.checkAddrPattern("/eos/out/active/chan")){  
    /* get and print the address pattern and the typetag of the received OscMessage */
   String[] activeChanArr = split(theOscMessage.get(0).toString(), " ");
   activeChan = float(activeChanArr[0]);
   activeLevel = float(activeChanArr[2].replace("[", "").replace("]",""));
  }
  //CUE LIST
  if(theOscMessage.checkAddrPattern("/eos/out/get/cue/" + queriedCueList + "/count")){  
    /* get and print the address pattern and the typetag of the received OscMessage */
    cueCount = theOscMessage.get(0).intValue();
  }
  //parse for cues returned that match the queried cue list, and filter out all but main cue message
  if(checkAddrPatternContains(theOscMessage, "/eos/out/get/cue/" + queriedCueList + "/") 
    && !checkAddrPatternContains(theOscMessage, "fx")
    && !checkAddrPatternContains(theOscMessage, "links")
    && !checkAddrPatternContains(theOscMessage, "actions")){  
    /* get and print the address pattern and the typetag of the received OscMessage */
    //activeCueList.addCue(theOscMessage.get(0).intValue(), theOscMessage.get(2).toString(),
    //               theOscMessage.get(3).intValue(), theOscMessage.get(4).intValue());
    //activeCueList.addCue(int(theOscMessage.get(1).intValue), "",
    //    0, 0);
    float cueNum;
    try{
     cueNum = float(theOscMessage.addrPattern().toString().split("/")[6]);
    }catch(Exception e){
      cueNum = -1;
    }
    if(Float.isNaN(cueNum)){
      cueNum = -1;
    }
    
    int cueIndex = theOscMessage.get(0).intValue();  
    String cueLabel;
    try{
      cueLabel = theOscMessage.get(2).toString();
    }catch(Exception e){
      cueLabel = "";
    }
    int upTime;
    try{
      upTime = theOscMessage.get(3).intValue();
    }catch(Exception e){
      upTime = -1;
    }
    int downTime;
    try{
      downTime = theOscMessage.get(4).intValue();
    }catch(Exception e){
      downTime = -1;
    }
    int follow;
    follow = theOscMessage.get(20).intValue();
    int hang;
    hang = theOscMessage.get(21).intValue();
    //print(cueIndex + " RAW::: CUE LABEL: " + cueLabel + " CUE NUM: " + cueNum + " CUE upTIME: " + upTime + " CUE downTIME: " + downTime +"\n");


    try{
      this.activeCueList.addCue(cueIndex, cueNum, cueLabel, upTime, downTime, follow, hang);
      //print("CUE ADDED");
      //print(this.activeCueList.cues.size() + this.activeCueList.label);
    }catch(Exception e){
      print(e);
    }
    
    //activeCueList.printCues();
  
    //theOscMessage.print();
    
    
  }
}

boolean checkAddrPatternContains(OscMessage theOscMessage, String addrPattern){
  return theOscMessage.addrPattern().toString().contains(addrPattern);
}

/* Request EOS to notify changes to show data*/
void subscribe(){
  OscMessage oscMessage = new OscMessage("/eos/subscribe/1");
  oscP5.send(oscMessage, myBroadcastLocation);
}

void syncCueList(int listID){
  OscMessage oscMessage = new OscMessage("/eos/chan/" + 1 + "/");
  oscP5.send(oscMessage, myBroadcastLocation);
}


/* GET FUNCTIONS */
float getChannelLevel(float channel){
   /* Post the channel to the command line to make it active. */
  OscMessage oscMessage = new OscMessage("/eos/chan/" + channel + "/");
  oscP5.send(oscMessage, myBroadcastLocation);
  
  /* Save the current active level */
  float level = activeLevel;
    
  print(level);
  
  return level;
}

float getActiveChannel(){
  print(activeChan);
  return activeChan;
}

void pullCueList(int listNum){
  queriedCueList = listNum;
  OscMessage oscMessage = new OscMessage("/eos/get/cue/" + queriedCueList + "/count/");
  oscP5.send(oscMessage, myBroadcastLocation);
  //oscP5.plug(this, "parseCueList", "/eos/out/get/cue/"+ queriedCueList + "/count/");
  
  this.activeCueList = new CueList(listNum, "NEW");
  
  queriedCues = new int[cueCount];
  
  for(int i = 0; i<cueCount; i+=1){
    oscMessage = new OscMessage("/eos/get/cue/" + queriedCueList + "/index/" + i);
    oscP5.send(oscMessage, myBroadcastLocation);
    append(queriedCues, i);
  }  
}

//void parseCueList(


/* SET FUNCTIONS */
void setChannelLevel(float channel, int level){
  /* create a new OscMessage with an address pattern, in this case /test. */
  OscMessage myOscMessage = new OscMessage("/eos/chan/" + channel + "/" + level);
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(level);
  /* send the OscMessage to a remote location specified in myNetAddress */
  oscP5.send(myOscMessage, myBroadcastLocation);
}


/* SCRIPTING UTILITIES*/

void wait(float time){
  delay(int(time * 1000));
}


/* KEY UTILITIES */

/* Allows to post a custom string to the command line*/
void command(String cmd){
  OscMessage oscMessage = new OscMessage("/eos/cmd/" + cmd);
  oscP5.send(oscMessage, myBroadcastLocation);
}

/* Clear the command line */
void clearCMD(){
  OscMessage oscMessage = new OscMessage("/eos/key/clear_cmdline");
  oscP5.send(oscMessage, myBroadcastLocation);
}

/* Switch to Blind */
void blind(){
  OscMessage oscMessage = new OscMessage("/eos/key/blind");
  oscP5.send(oscMessage, myBroadcastLocation);
}

/* Switch to Live */
void live(){
  OscMessage oscMessage = new OscMessage("/eos/key/live");
  oscP5.send(oscMessage, myBroadcastLocation);
}


/* MACROS */
//ADD A LABEL TO ALL CUES SUBSEQUENT TO CUES WITH FOLLOWS OR HANGS
//THE LABEL, SPECIFIED BY PARAMETER "LABEL", WILL BE ADDED BEFORE THE EXISTING LABEL

void labelAutos(String label){
  pullCueList(1);
  wait(0.5);
  for(int i = 0; i < this.activeCueList.cues.size(); i += 1){
    Cue cue = this.activeCueList.cues.get(i);
    if(cue.hasFollow() || cue.hasHang()){
      Cue nextCue = activeCueList.getNextCue(cue.index);
      if(nextCue != null){
        if(!nextCue.label.contains(label)){
          command("Cue " + nextCue.cueNum + " Label " + label + " " + nextCue.label + " Enter");
        }
      }
    }
  }
}

void capitalizeLabels(){
  pullCueList(1);
  wait(0.5);
  for(int i = 0; i < this.activeCueList.cues.size(); i += 1){
    Cue cue = this.activeCueList.cues.get(i);
    command("Cue " + cue.cueNum + " Label " + cue.label.toUpperCase() + " Enter");
   }
}
