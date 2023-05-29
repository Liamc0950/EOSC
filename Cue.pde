class Cue{
  int index;
  float cueNum;
  String label;
  int upTime, downTime;
  int follow, hang;
  
  Cue(int index, float cueNum, String label, int upTime, int downTime, int follow, int hang){
    this.index = index; //0
    this.cueNum = cueNum;
    this.label = label; //2
    this.upTime = upTime; //3
    this.downTime = downTime; //4
    this.follow = follow; //20
    this.hang = hang; //21
  }
  
  
  boolean hasFollow(){
    return (this.follow != -1);
  }
  boolean hasHang(){
    return (this.hang != -1);
  }
  
}
