set gaSet(javaLocation) C:\\Program\ Files\\Java\\jre1.8.0_181\\bin\\

switch -exact -- $gaSet(pair) {
  1 {
      set gaSet(comDut)     2
      set gaSet(comGen1)    4
      console eval {wm geometry . +150+1}
      console eval {wm title . "Con 1"} 
      set gaSet(pioBoxSerNum) FTLVLMJ  
#       set gaSet(pioPwr1)     1
#       set gaSet(pioPwr2)     2
#       set gaSet(pioDrc)      1
  }
  2 {
      set gaSet(comDut)    5
      set gaSet(comGen1)   6
      console eval {wm geometry . +150+200}
      console eval {wm title . "Con 2"} 
      set gaSet(pioBoxSerNum) FTEDQHC         
#       set gaSet(pioPwr1)     3
#       set gaSet(pioPwr2)     4
#       set gaSet(pioDrc)      2      
  }
  3 {
      set gaSet(comDut)    6
      set gaSet(comGen1)    10
      console eval {wm geometry . +150+400}
      console eval {wm title . "Con 3"}  
      set gaSet(pioBoxSerNum) FTLVGHC   
#       set gaSet(pioPwr1)     5
#       set gaSet(pioPwr2)     6
#       set gaSet(pioDrc)      3
  }
  4 {
      set gaSet(comDut)    7
      set gaSet(comGen1)    11
      console eval {wm geometry . +150+600}
      console eval {wm title . "Con 4"}  
      set gaSet(pioBoxSerNum) FTLVHTH         
#       set gaSet(pioPwr1)     7
#       set gaSet(pioPwr2)     8 
#       set gaSet(pioDrc)      4     
  }
  
}  
source lib_PackSour.tcl
