class CueList{
   int id;
   String label;
   ArrayList<Cue> cues;
   
   CueList(int id, String label){
     this.id = id;
     this.label = label;
     this.cues = cues = new ArrayList<Cue>();
   }
   
   void addCue(int index, float cueNum, String label, int upTime, int downTime, int follow, int hang){
     //println("CUE LABEL: " + label + " CUE NUM: " + cueNum + " CUE upTIME: " + upTime + " CUE downTIME: " + downTime);
       if(this.containsCue(index)){
          //this.cues.set(index, new Cue(index, cueNum, label, upTime, downTime));
       }
       else{
          this.cues.add(new Cue(index, cueNum, label, upTime, downTime, follow, hang));
       }  
   }
   
   
   void printCues(){
     //print(this.cues.size());
     //print(this.label);
     for(int i = 0; i < this.cues.size(); i+=1){
       Cue cue = this.cues.get(i);
       println("INDEX: " + cue.index + "CUE LABEL: " + cue.label + " CUE NUM: " + cue.cueNum + " CUE upTIME: " + cue.upTime
       + " CUE downTIME: " + cue.downTime + " CUE follow: " + cue.follow + " CUE hang: " + cue.hang);
     }
   }
   
   
   boolean containsCue(int index){
     for(int i = 0; i < this.cues.size(); i+=1){
       if(this.cues.get(i).index == index){
         return true;
       }
     }
     return false;
   }
   
   
  Cue getNextCue(int index){
    //print(index + " " + this.cues.size());
    if(index <= (this.cues.size() -2)){
      return this.cues.get(index + 1);
    }
    else{
      return null;
    }
 }

   
}
