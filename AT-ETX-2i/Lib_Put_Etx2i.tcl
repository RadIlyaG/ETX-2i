# ***************************************************************************
# EntryBootMenu
# ***************************************************************************
proc EntryBootMenu {} {
  global gaSet buffer
  puts "[MyTime] EntryBootMenu"; update
  Status "Entry to Boot Menu"
#   set ret [Reset2BootMenu $uut]
#   if {$ret!=0} {return $ret}
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b=="19V"} {
    #set ret [DnfvPower off] 30/07/2018 15:15:26
#     if {$ret!=0} {return $ret}  30/07/2018 15:15:36
  }  
  Power all off
  RLTime::Delay 4
  Power all on
  RLTime::Delay 2
  set gaSet(fail) "Entry to Boot Menu fail"
  set ret [Send $gaSet(comDut) \r "stop auto-boot.." 20]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) \r\r "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  return 0
}

# ***************************************************************************
# DownloadUsbPortApp
# ***************************************************************************
proc DownloadUsbPortApp  {} { 
  global gaSet buffer
  puts "[MyTime] DownloadUsbPortApp"; update
  set gaSet(fail) "Config IP in Boot Menu fail"
  set ret [Send $gaSet(comDut) "c ip\r" "(ip)"]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "10.10.10.1$gaSet(pair)\r" "\[boot\]:"]
  if {$ret!=0} {return $ret}
    
  set gaSet(fail) "Config DM in Boot Menu fail"
  set ret [Send $gaSet(comDut) "c dm\r" "(dm)"]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "255.255.255.0\r" "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Config SIP in Boot Menu fail"
  set ret [Send $gaSet(comDut) "c sip\r" "(sip)"]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "10.10.10.10\r" "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Config GW in Boot Menu fail"
  set ret [Send $gaSet(comDut) "c g\r" "(g)"]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "10.10.10.10\r" "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Config TFTP in Boot Menu fail"
  set ret [Send $gaSet(comDut) "c p\r" "ftp\]"]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "ftp\r" "\[boot\]:"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $gaSet(comDut) "\r" "\[boot\]:"]
  if {$ret!=0} {return $ret} 
  
  set ret [Send $gaSet(comDut) "set-active 1\r" "\[boot\]:" 35]
  if {$ret!=0} {return $ret} 
  set ret [Send $gaSet(comDut) "delete sw-pack-3\r" "\[boot\]:" 35]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Start \'download 3,sw-pack_2i_USB_test.bin\' fail"
  set ret [Send $gaSet(comDut) "download 3,sw-pack_2i_USB_test.bin\r" "transferring" 3]
  if [string match {*you sure(y/n)*} $buffer] {
    set ret [Send $gaSet(comDut) "y\r" "transferring"]    
  }
  if {$ret!=0} {return $ret} 
  
  set startSec [clock seconds]
  while 1 {
    Status "Wait for application downloading"
    if {$gaSet(act)==0} {return -2}
    set nowSec [clock seconds]
    set dwnlSec [expr {$nowSec - $startSec}]
    #puts "dwnlSec:$dwnlSec"
    $gaSet(runTime) configure -text $dwnlSec
    if {$dwnlSec>600} {
      set ret -1 
      break
    }
    set ret [RLSerial::Waitfor $gaSet(comDut) buffer "\[boot\]:" 2]
    puts "<$dwnlSec><$buffer>" ; update
    if {$ret==0} {break}
    if [string match {*\[boot\]*} $buffer] {
      set ret 0
      break
    }
  }  
  if {$ret=="-1"} {
    set gaSet(fail) "Download \'3,sw-pack_2i_usb.bin\' fail"
    return -1 
  }
  
  set gaSet(fail) "\'set-active 3\' fail" 
  set ret [Send $gaSet(comDut) "\r" "\[boot\]:" 1]
  set ret [Send $gaSet(comDut) "\r" "\[boot\]:" 1]
  set ret [Send $gaSet(comDut) "set-active 3\r" "\[boot\]:" 25]
  if {$ret!=0} {return $ret}  
  Status "Wait for Loading/un-compressing sw-pack-3"
  set ret [Send $gaSet(comDut) "run 3\r" "sw-pack-3.." 50]
  if {$ret!=0} {return $ret} 
          
  return 0
}  
# ***************************************************************************
# CheckUsbPort
# ***************************************************************************
proc CheckUsbPort {} {
  puts "[MyTime] CheckUsbPort"; update
  global gaSet buffer accBuffer
  
 ### 13/07/2016 15:06:43 6.0.1 reads the USB port without a special app 
#   set startSec [clock seconds]
#   while 1 {
#     if {$gaSet(act)==0} {return -2}
#     set nowSec [clock seconds]
#     set dwnlSec [expr {$nowSec - $startSec}]
#     #puts "dwnlSec:$dwnlSec"
#     $gaSet(runTime) configure -text $dwnlSec
#     update
#     if {$dwnlSec>120} {
#       set ret -1 
#       break
#     }
#     set ret [RLSerial::Waitfor $gaSet(comDut) buffer "user>" 2]
#     append accBuffer [regsub -all {\s+} $buffer " "]
#     $gaSet(runTime) configure -text $dwnlSec
#     puts "<$dwnlSec><$buffer>" ; update
#     if {$ret==0} {break}
#     if [string match {*user>*} $buffer] {
#       set ret 0
#       break
#     }
#   }  
#   if {$ret=="-1"} {
#     set gaSet(fail) "Getting \'user>\' fail"
#     return -1 
#   }
#   
# #   if [string match {*A device is connected to Bus:000 Port:0*} $accBuffer] {
# #     set ret 0
# #   } else {
# #     set ret -1
# #     set gaSet(fail) "USB port doesn't recognize device on Bus:000 Port:0"
# #   }
#   #set ret [Send $gaSet(comDut) "run 3\r" "sw-pack-3.." 15]
#   
  Status "USB port Test"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
#   Send $com "exit all\r" stam 0.25 
#   Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  Status "Read USB port" 
  
  set gaSet(fail) "Read USB port fail"
  
  set sw $::sw ; # 6.2.1(0.44)
  set majSW [string range $sw 0 [expr {[string first ( $sw] - 1}]]; # 6.2.1
  
  puts "sw:$sw majSW:$majSW"
  if {$majSW<6.3} {
    set ret [Send $com "debug test usb\r" ETX-2I]
    if {$ret!=0} {return $ret}
    
#     if {[string match {*DEV*Mouse*} $buffer] || \
#         [string match {*DEV*Keyboard*} $buffer]} { }
## 05/07/2017 07:46:19 Just DEV
    if {[string match {*DEV*} $buffer]} {     
      set ret 0
    } else {
      set ret -1
      set gaSet(fail) "USB port doesn't recognize an USB Mouse"
    } 
  } else {
    set ret [Send $com "debug usb display-device-param\r" ETX-2I]
    if {$ret!=0} {return $ret}
  
    if {[string match {*USB device in*} $buffer]} {    
      set ret 0
    } else {
      set ret -1
      set gaSet(fail) "USB port doesn't recognize USB device"
    }
  }       
  return $ret
}  
# ***************************************************************************
# DeleteUsbPortApp
# ***************************************************************************
proc DeleteUsbPortApp {} { 
  puts "[MyTime] DeleteUsbPortApp"; update
  global gaSet buffer
  set gaSet(fail) "Delete UsbPort App fail"
  set ret [Send $gaSet(comDut) "set-active 1\r" "\[boot\]:" 35]
  if {$ret!=0} {return $ret} 
  set ret [Send $gaSet(comDut) "delete sw-pack-3\r" "\[boot\]:" 35]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "run\r" "sw-pack-1.." 55]
  if {$ret!=0} {return $ret} 
  return $ret
}  

# ***************************************************************************
# FansTemperatureTest
# ***************************************************************************
proc FansTemperatureTest {} {
  global gaSet buffer
  Status "FansTemperatureTest"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
#   Send $com "exit all\r" stam 0.25 
#   Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  Status "Read thermostat"
  
  set gaSet(fail) "Write to thermostat fail"
  set ret [Send $com "debug thermostat\r" thermostat]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point upper 60\r" thermostat]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point lower 55\r" thermostat]
  if {$ret!=0} {return $ret}
  
  set ret [scan $gaSet(dbrSW) %3d\.%3d\.%3d(%3d\.%3d) v1 v2 v3 v4 v5]
  if {$ret=="-1"} {
    set gaSet(fail) "Check SW Ver in Inventory"
    return -1
  }
  set sw $v1.$v2.$v3.$v4.$v5
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b=="19V"} {
    set fanState1 "off off off off"
  } elseif {$b=="19" && $p=="0" && $d=="0"} {
    set fanState1 "off off off off"
  } elseif {$b=="19" && ($p=="P" || $d=="D")} {
    set fanState1 "off off on on"
  } elseif {$b=="M" && $p=="0" && $d=="0"} {
    set fanState1 "off off off off"
  } elseif {$b=="M" && $p=="P"} {
    set fanState1 "on on on on"
  } elseif {$b=="Half19" && $p=="0" && $d=="0"} {
    set fanState1 "off off off off"
  }
  puts "b:$b r:$r p:$p d:$d sw:$sw"
  puts "fanState1:$fanState1"
      
  set gaSet(fail) "Read from thermostat fail"
  for {set i 1} {$i<=40} {incr i} {
    puts "i:$i wait for \'$fanState1\'" ; update
    set ret [Send $com "show status\r" thermostat]
    if {$ret!=0} {return $ret}

    set res [string match *$fanState1* $buffer]
    if {$res=="1"} {
      break
    }
    after 2000
  }
  if {$res!="1"} {
    set gaSet(fail) "\'$fanState1\' doesn't apprear"
    return -1
  }
  regexp  {Current:\s([\d\.]+)\s} $buffer - ct1
  puts "ct1:$ct1"  
  
  set gaSet(fail) "Write to thermostat fail"
  set ret [Send $com "set-point lower 20\r" thermostat]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point upper 30\r" thermostat]
  if {$ret!=0} {return $ret}
  
  if {$b=="19V"} {
    set fanState2 "on on on off"; # 25/03/2018 07:17:10 "off on on on"
  } elseif {$b=="19" && $p=="0" && $d=="0"} {
    set fanState2 "off off on on"
  } elseif {$b=="19" && ($p=="P" || $d=="D")} {
    set fanState2 "off off on on"
  } elseif {$b=="M" && $p=="0" && $d=="0"} {
    set fanState2 "on on on on"
  } elseif {$b=="M" && $p=="P"} {
    set fanState2 "on on on on"
  } elseif {$b=="Half19" && $p=="0" && $d=="0"} {
    set fanState2 "on off off off"
  }
  puts "b:$b r:$r p:$p d:$d sw:$sw"
  puts "fanState2:$fanState2"
    
  set gaSet(fail) "Read from thermostat fail"
  for {set i 1} {$i<=60} {incr i} {
    puts "i:$i wait for \'$fanState2\'" ; update
    set ret [Send $com "show status\r" thermostat]
    if {$ret!=0} {return $ret}
    set res [string match *$fanState2* $buffer]
    if {$res=="1"} {
      break
    }
    after 2000
  }
  if {$res!="1"} {
    set gaSet(fail) "\'$fanState2\' doesn't apprear"
    return -1
  }
 
  if {$fanState1!=$fanState2} {
    ## if we turn off the fans, the temperature should change and we should check it
    set gaSet(fail) "Read from thermostat fail"
    for {set i 1} {$i<=10} {incr i} {
      set ret [Send $com "show status\r" thermostat 1]
      if {$ret!=0} {return $ret}
      regexp  {Current:\s([\d\.]+)\s} $buffer - ct2 
      puts "i:$i ct2:$ct2" ; update
      if {$ct2!=$ct1} {
        set ret 0
        break
      }
      after 2000
    }  
    if {$ct2==$ct1} {
      
      set gaSet(fail) "\"Current\" doesn't change: $ct2"
      return -1
    }
  }
  
  
  set ret [Send $com "exit all\r" ETX-2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure chassis\r" chassis]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show environment\r" chassis]
  if {$ret!=0} {return $ret}
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b=="19V"} {
    set fanSt "1 OK 2 OK 3 OK"
  } elseif {$b=="19"} {
    #set fanSt "1 OK 2 OK" ; #30/05/2019 10:56:35
    set fanSt "3 OK 4 OK"
  } elseif {$b=="M"} {
    set fanSt "1 OK 2 OK"
  } elseif {$b=="Half19"} {
    set fanSt "1 OK"
  }
  set res [regexp {FAN\s+Status[\-\s]+([\w\s]+)\s+Sensor} $buffer ma val]
  if {$res==0} {
    set gaSet(fail) "Read FANs Status fail"
    return -1
  }
  puts "val:<$val> fanSt:<$fanSt>"
  if {$val!=$fanSt} {
    set gaSet(fail) "FANs Status is \'$val\'. Should be \'$fanSt\'"
    return -1
  } else {
    set ret 0
  }
  
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  set ret [Send $com "debug thermostat\r" thermostat]
  if {$ret!=0} {return $ret}
  set gaSet(fail) "Write to thermostat fail"
  set ret [Send $com "set-point upper 40\r" thermostat 1]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point lower 32\r" thermostat 1]
  if {$ret!=0} {return $ret}
  
  
  return $ret
}
# ***************************************************************************
# SK_IDTest
# ***************************************************************************
proc SK_IDTest {} {
  global gaSet buffer
  Status "SK_ID Test"
  Power all on
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }   
  set com $gaSet(comDut)  
  set gaSet(fail) "Read SK version fail"
  set ret [Send $com "exit all\r" ETX-2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure qos queue-group-profile \"DefaultQueueGroup\" queue-block 0/1\r" (0/1)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" #]
  if {$ret!=0} {return $ret}
  set ret [Send $com "queue-block 0/2\r" (0/2)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" #]
  if {$ret!=0} {return $ret}
  set ret [Send $com "queue-block 0/3\r" stam 1]
  #if {$ret!=0} {return $ret}
  
  if {$gaSet(sk)=="BSK" && [string match {*cli error: License limitation*} $buffer]} {
    set ret 0
  } elseif {$gaSet(sk)=="BSK" && ![string match {*cli error: License limitation*} $buffer]} {
    set ret -1
  } elseif {$gaSet(sk)=="ESK" && [string match {*cli error: License limitation*} $buffer]} {
    set ret -1
  } elseif {$gaSet(sk)=="ESK" && ![string match {*cli error: License limitation*} $buffer]} {
    set ret 0
  }
  if {$ret=="-1"} {
    set gaSet(fail) "The $gaSet(sk) unmatch License limitation"
  }
  return $ret
}
# ***************************************************************************
# PS_IDTest
# ***************************************************************************
proc PS_IDTest {} {
  global gaSet buffer
  Status "PS_ID Test"
  Power all on
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }   
  set com $gaSet(comDut)  
  set ret [Send $com "exit all\r" ETX-2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "info\r" more]  
#   regexp {sw\s+\"(\d+\.\d+\.\d+)\(} $buffer - sw
#   regexp {sw\s+\"(.+)\"\s} $buffer - sw
  regexp {sw\s+\"([\.\d\(\)\w]+)\"\s} $buffer - sw
  
  if ![info exists sw] {
    set gaSet(fail) "Can't read the SW version"
    return -1
  }
  puts "sw:$sw"
  set ::sw $sw
    
  set ret [Send $com "\3" ETX-2I 3]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit all\r" ETX-2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure chassis\r" chassis]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show environment\r" chassis]
  if {$ret!=0} {return $ret}
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  set psQty [regexp -all $ps $buffer]
  if {[string match *ACDC* $gaSet(DutInitName)]} {
    set psQty [regexp -all AC $buffer]
	incr psQty [regexp -all DC $buffer]
  }
  if {$b=="M"} {
    set psQtyShBe 1
  } else {
    set psQtyShBe 2
  }
  puts "PS_ID psQty:$psQty b:$b psQtyShBe:$psQtyShBe"; update
  if {$psQty!=$psQtyShBe} {
    set gaSet(fail) "Qty or type of PSs is wrong."
#     AddToLog $gaSet(fail)
    return -1
  }
  #regexp {\-+\s(.+)\s+FAN} $buffer - psStatus
  regexp {\-+\s(.+\s+FAN)} $buffer - psStatus
  if {$b=="M"} {
    regexp {1\s+\w+\s+([\s\w]+)\s+FAN} $psStatus - ps1Status
  } else { 
    regexp {1\s+\w+\s+([\s\w]+)\s+2} $psStatus - ps1Status
  }
  set ps1Status [string trim $ps1Status]
  
  set markHP 0
  ## remove HP (from "AC HP")
  if {[lindex [split $ps1Status " "] 0]=="HP"} {
    set markHP 1
    set ps1Status [lrange [split $ps1Status " "] 1 end ]
  }
  if {$ps1Status!="OK"} {
    set gaSet(fail) "Status of PS-1 is \'$ps1Status\'. Should be \'OK\'"
#     AddToLog $gaSet(fail)
    return -1
  }
  if {$b=="19V" && $ps=="AC HP" && $markHP=="0"} {
    set gaSet(fail) "The PS-1 is not HP"
#     AddToLog $gaSet(fail)
    return -1
  }
  if {$b!="19V" && $markHP=="1"} {
    set gaSet(fail) "The PS-1 is HP"
#     AddToLog $gaSet(fail)
    return -1
  }
  
  if {$b!="M"} {
    regexp {2\s+\w+\s+([\s\w]+)\s+} $psStatus - ps2Status
    set ps2Status [string trim $ps2Status]
    set markHP 0
    ## remove HP (from "AC HP")
    if {[lindex [split $ps2Status " "] 0]=="HP"} {
      set markHP 1
      set ps2Status [lrange [split $ps2Status " "] 1 end ]
    }
    if {$ps2Status!="OK"} {
      set gaSet(fail) "Status of PS-2 is \'$ps2Status\'. Should be \'OK\'"
  #     AddToLog $gaSet(fail)
      return -1
    }
    if {$b=="19V" && $ps=="AC HP" &&  $markHP=="0"} {
      set gaSet(fail) "The PS-2 is not HP"
  #     AddToLog $gaSet(fail)
      return -1
    }
    if {$b!="19V" && $markHP=="1"} {
      set gaSet(fail) "The PS-2 is HP"
  #     AddToLog $gaSet(fail)
      return -1
    }
  }
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {[string range $sw end-1 end]=="SR" && $r=="R"} {
    set gaSet(fail) "The sw is \"$sw\" and the DUT is RTR"
    return -1
  }
  if {[string range $sw end-1 end]!="SR" && $r=="0"} {
    set gaSet(fail) "The sw is \"$sw\" and the DUT is not RTR"
    return -1
  }
  
  if {[string range $sw end-1 end]=="SR"} {
    puts "sw:$sw"
    set sw [string range $sw 0 end-2]  
    puts "sw:$sw"
  }
  if {$sw!=$gaSet(dbrSW)} {
    set gaSet(fail) "SW is \"$sw\". Should be \"$gaSet(dbrSW)\""
    return -1
  }
  
  #21/04/2020 13:40:03
  set ret [Send $com "exit all\r" 2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure port\r" port]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show summary\r" port]
  if {$ret!=0} {return $ret}
  foreach eth [list ETH-0/1 ETH-0/2 ETH-0/3 ETH-0/4] {
    set res [regexp "$eth\\s+Up\\s+\(Up\|Down\)+\\s" $buffer ma opSt]
    puts "$eth res:$res opSt:<$opSt>"; update
    if {$res==0 || $opSt!="Up"} {
      set gaSet(fail) "Operational Status of $eth is not Up"
      return -1
    }
  }
  
  set ret [ReadCPLD]
  if {$ret!=0} {return $ret}
  
  if {![info exists gaSet(uutBootVers)] || $gaSet(uutBootVers)==""} {
    set ret [Send $com "exit all\r" 2I]
    if {$ret!=0} {return $ret}
    set ret [Send $com "admin reboot\r" "yes/no"]
    if {$ret!=0} {return $ret}
    set ret [Send $com "y\r" "seconds" 20]
    if {$ret!=0} {return $ret}
    set ret [ReadBootVersion]
    if {$ret!=0} {return $ret}
  }
  
  puts "gaSet(uutBootVers):<$gaSet(uutBootVers)>"
  puts "gaSet(dbrBVer):<$gaSet(dbrBVer)>"
  update
  if {$gaSet(uutBootVers)!=$gaSet(dbrBVer)} {
    set gaSet(fail) "Boot Version is \"$gaSet(uutBootVers)\". Should be \"$gaSet(dbrBVer)\""
    return -1
  }
  set gaSet(uutBootVers) ""
  
#   set gRelayState red
#   IPRelay-LoopRed
#   SendEmail "ETX-2I" "Manual Test"
#   RLSound::Play information
#   set txt "Verify on each PS that GREEN led lights"
#   set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
#   update
#   if {$res!="OK"} {
#     set gaSet(fail) "LED Test failed"
#     return -1
#   } else {
#     set ret 0
#   }
#   
#   foreach PS {2 1} {
#     Power $PS off
#     after 3000
#     set ret [Send $com "show environment\r" chassis]
#     if {$ret!=0} {return $ret}
#     if {$PS==1} {
#       regexp {1\s+[AD]C\s+(\w+)\s} $buffer - val
#     } elseif {$PS==2} {
#       regexp {2\s+[AD]C\s+(\w+)\s} $buffer - val
#     }
#     puts "val:<$val>"
#     if {$val!="Failed"} {
#       set gaSet(fail) "PS $PS $val. Expected \"Failed\""
#       AddToLog $gaSet(fail)
#       return -1
#     }
#     RLSound::Play information
#     set txt "Verify on PS $PS that RED led lights"
#     set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
#     update
#     if {$res!="OK"} {
#       set gaSet(fail) "LED Test failed"
#       return -1
#     } else {
#       set ret 0
#     }
#     
#     RLSound::Play information
#     set txt "Remove PS $PS"
#     set res [DialogBox -type "OK Cancel" -icon /images/question -title "LED Test" -message $txt]
#     update
#     if {$res!="OK"} {
#       set gaSet(fail) "PS_ID Test failed"
#       return -1
#     } else {
#       set ret 0
#     }
#     set ret [Send $com "show environment\r" chassis]
#     if {$ret!=0} {return $ret}
#     if {$PS==1} {
#       regexp {1\s+[AD]C\s+(\w+\s\w+)\s} $buffer - val
#     } elseif {$PS==2} {
#       regexp {2\s+[AD]C\s+(\w+\s\w+)\s} $buffer - val
#     }
#     
#     puts "val:<$val>"
#     if {$val!="Not exist"} {
#       set gaSet(fail) "PS $PS $val. Expected \"Not exist\""
#       AddToLog $gaSet(fail)
#       return -1
#     }
#     
#     RLSound::Play information
#     set txt "Verify on PS $PS that led no lights"
#     set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
#     update
#     if {$res!="OK"} {
#       set gaSet(fail) "LED Test failed"
#       return -1
#     } else {
#       set ret 0
#     }
#     
#     RLSound::Play information
#     set txt "Assemble PS $PS"
#     set res [DialogBox -type "OK Cancel" -icon /images/question -title "LED Test" -message $txt]
#     update
#     if {$res!="OK"} {
#       set gaSet(fail) "PS_ID Test failed"
#       return -1
#     } else {
#       set ret 0
#     }
#     Power $PS on
#     after 2000
#   }
 
  return $ret
}
# ***************************************************************************
# DyingGaspSetup
# ***************************************************************************
proc DyingGaspSetup {} {
  global gaSet buffer gRelayState
  Status "DyingGaspTest"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set cf $gaSet(DGaspCF)
  set cfTxt "Dying Gasp"
  set ret [DownloadConfFile $cf $cfTxt 1]
  if {$ret!=0} {return $ret}
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b=="19V"} {
#   ##25/09/2017 11:40:33
#  ## no need power off since "cn no shutdown" was not performed yet  
#     set ret [DnfvPower off] 
#     if {$ret!=0} {return $ret} 
  }  

  Power all off
  after 1000
  Power all on
  
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }

  return $ret
}    
 
# ***************************************************************************
# DyingGaspPerf
# ***************************************************************************
proc DyingGaspPerf {psOffOn psOff} {
  global trp tmsg gaSet
  puts "[MyTime] DyingGaspPerf $psOffOn $psOff"
#   set ret [OpenSession $dutIp]
#   if {$ret!=0} {return $ret}
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
#   set com $gaSet(comDut)
#   Send $com "exit all\r" stam 0.25 

   
  set wsDir C:\\Program\ Files\\Wireshark
  set npfL [exec $wsDir\\tshark.exe -D]
  ## 1. \Device\NPF_{3EEEE372-9D9D-4D45-A844-AEA458091064} (ATE net)
  ## 2. \Device\NPF_{6FBA68CE-DA95-496D-83EA-B43C271C7A28} (RAD net)
  set intf ""
  foreach npf [split $npfL "\n\r"] {
    set res [regexp {(\d)\..*ATE} $npf - intf] ; puts "<$res> <$npf> <$intf>"
    if {$res==1} {break}
  }
  if {$res==0} {
    set gaSet(fail) "Get ATE net's Network Interface fail"
    return -1
  }
  
  Status "Wait for Ping traps"
  set resFile c:\\temp\\te_$gaSet(pair)_[clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"].txt
  set dur 10
  exec [info nameofexecutable] Lib_tshark.tcl $intf $dur $resFile &
  after 1000
  set dutIp 10.10.10.1[set gaSet(pair)]
  set ret [Ping $dutIp]
  if {$ret!=0} {return $ret}
  after "[expr {$dur +1}]000" ; ## one sec more then duration
  set id [open $resFile r]
    set monData [read $id]
    set ::md $monData 
  close $id  

  puts "\r---Frames after 2 pings\r<$monData>---\r"; update
  
  set res [regexp -all "Src: $dutIp, Dst: 10.10.10.10" $monData]
  puts "res:$res"
  if {$res<2} {
    set gaSet(fail) "2 Ping traps did not send"
    return -1
  }
  file delete -force $resFile
  
  catch {exec arp.exe -d $dutIp} resArp
  puts "[MyTime] resArp:$resArp"
  
  Power $psOffOn on
  Power $psOff off
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
#   25/09/2017 13:05:27
#   if {$b=="19V"} {
#     set ret [DnfvPower off] 
#     if {$ret!=0} {return $ret} 
#   }  
   
  
  Status "Wait for Dying Gasp trap"
  set dur 10
  
  puts "1. [MyTime]"; update
  set resFile c:\\temp\\te_$gaSet(pair)_[clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"].txt
  puts "2. [MyTime]"; update
  exec [info nameofexecutable] Lib_tshark.tcl $intf $dur $resFile &  
  puts "3. [MyTime]"; update   
  after 250
  puts "4. [MyTime]"; update
  Power $psOffOn off
  puts "5. [MyTime]"; update
  after 1000
  puts "6. [MyTime]"; update
  Power $psOffOn on
  puts "7. [MyTime]"; update
  
  after "[expr {$dur +1}]000" ; ## one more sec then duration
  puts "8. [MyTime]"; update
  set id [open $resFile r]
    set monData [read $id]
    set ::md $monData 
  close $id  
  puts "9. [MyTime]"; update

  puts "\r---Frames after POWER off\n<$monData>---\r"; update
  
  
  ## 4479696e672067617370
  ## D y i n g   g a s p
#   set framsL [regexp -all -inline "Src: $dutIp.+?\\n\\n" $monData]
  set framsL [wsplit $monData lIsT]
  if {[llength $framsL]==0} {
    set gaSet(fail) "No trap from $dutIp was detected after Power OFF"
    return -1
  }
  puts "\rDying gasp == 4479696e672067617370\r"; update
  set res 0
  foreach fram $framsL {
    puts "\rFrameA---<$fram>---\r"; update
#     if [string match *4479696e672067617370* $fram] {
#       set res 1
#       file delete -force $resFile
#       break
#     }
    if {[string match "*Src: $dutIp*" $fram] && \
       ([string match *4479696e672067617370* $fram] || [string match {*Dying gasp*} $fram])} {
      set res 1
      #file delete -force $resFile
      break
    }
  } 
  if {$res} {
    puts "\rFrameB---<$fram>---\r"; update
  }

  set retLog [ReadLog dying_gasp]
  if {$retLog!=0} {
    set gaSet(fail) "No \"DyingGasp\" trap does not exist in log"
    return -1
  }
  if {$res==1} {
    set ret 0
  } elseif {$res==0} {
    set ret -1
    set gaSet(fail) "No \"DyingGasp\" trap was detected"
  }
  return $ret
  
}

# ***************************************************************************
# DyingGaspPerf
# ***************************************************************************
proc neDyingGaspPerf {psOffOn psOff} {
  global trp tmsg gaSet
#   set ret [OpenSession $dutIp]
#   if {$ret!=0} {return $ret}
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set dutIp 10.10.10.1[set gaSet(pair)]
  set ret [Ping $dutIp]
  if {$ret!=0} {return $ret}
  
  RLScotty::SnmpCloseAllTrap
  for {set wc 1} {$wc<=10} {incr wc} {
    set trp(id) [RLScotty::SnmpOpenTrap tmsg]
    puts "wc:$wc trp(id):$trp(id)"
    if {$trp(id)=="-1"} {
      set ret -1
      set gaSet(fail) "Open Trap failed"
      set ret [Wait "Wait for SNMP session" 5 white]
      if {$ret!=0} {return $ret}
    } else {
      set ret 0
      break
    }
  }
  if {$ret!=0} {return $ret}
  RLScotty::SnmpConfigTrap $trp(id) -version SNMPv3 -user initial ; #SNMPv2c ;# SNMPv1 , SNMPv2c , SNMPv3
  
  set tmsg ""
  #Power $psOff off
  set ret [Send $com "configure port ethernet 0/1\r" "0/1"]
  if {$ret!=0} {
    RLScotty::SnmpCloseTrap $trp(id)
    return $ret
  }
  
  set ret -1
  for {set i 1} {$i<=5} {incr i} {
    set ret [Send $com "shutdown\r" "0/1"]
      if {$ret==0} {
      after 1000
      set ret [Send $com "no shutdown\r" "0/1"]
      if {$ret!=0} {
        RLScotty::SnmpCloseTrap $trp(id)
        return $ret
      }
    }
    puts "tmsgStClk:<$tmsg>"
    if {$tmsg!=""} {
      set ret 0
      break
    }
    after 1000
  }
  if {$ret=="-1"} {
    set gaSet(fail) "Trap is not sent"
    RLScotty::SnmpCloseTrap $trp(id)
    return -1
  }
  
  after 1000
  set tmsg ""
  
  Power $psOffOn on
  Power $psOff off
  Wait "Wait for trap 1" 3 white
  puts "tmsgDG 1.1:<$tmsg>"
  set tmsg ""
  puts "tmsgDG 1.2:<$tmsg>"
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b=="19V"} {
    set ret [DnfvPower off] 
    if {$ret!=0} {return $ret} 
  }  
  
  Power $psOffOn off
  Wait "Wait for trap 2" 3 white 
   
  #set ret [regexp -all "$dutIp\[\\s\\w\\:\\-\\.\\=\]+\\\"\\w+\\\"\[\\s\\w\\:\\-\\.\\=\]+\\\"\[\\w\\:\\-\\.\]+\\\"\[\\s\\w\\:\\-\\.\\=\]+\\\"\[\\w\\-\]+\\\"" $tmsg v]  
  puts "tmsgDG 2:<$tmsg>"
  set res [regexp "from\\s$dutIp:\\s\.\+\:systemDyingGasp" $tmsg -]
  Power $psOffOn on
  
  # Close sesion:
  RLScotty::SnmpCloseTrap $trp(id)  

  if {$res==1} {
    set ret 0
  } elseif {$res==0} {
    set ret -1
    set gaSet(fail) "No \"DyingGasp\" trap was detected"
  }
  return $ret
  
}

# ***************************************************************************
# XFP_ID_Test
# ***************************************************************************
proc XFP_ID_Test {} {
  global gaSet buffer
  Status "XFP_ID_Test"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  
  foreach 10Gp {3/1 3/2 4/1 4/2} {
    if {$gaSet(10G)=="2" && ($10Gp=="3/1" || $10Gp=="3/2")} {
      continue
    }
    if {$gaSet(10G)=="3" && $10Gp=="3/2"} {
      continue
    }
    Status "XFP $10Gp ID Test"
    set gaSet(fail) "Read XFP status of port $10Gp fail"
    Send $com "exit all\r" stam 0.25 
    set ret [Send $com "configure port ethernet $10Gp\r" #]
    if {$ret!=0} {return $ret}
    set ret [Send $com "show status\r" "MAC Address" 20]
    if {$ret!=0} {return $ret}
    set b $buffer
    set ::b1 $b
      
    set ret [Send $com "\r" #]
    if {$ret!=0} {return $ret}
    append b $buffer
    set ::b2 $b
    set res [regexp {Connector Type\s+:\s+(.+)Auto} $b - connType]
    set connType [string trim $connType]
    if {$connType!="XFP In"} {
      set gaSet(fail) "XFP status of port $10Gp is \"$connType\". Should be \"XFP In\"" 
      set ret -1
      break 
    }
    set xfpL [list "XFP-1D" XPMR01CDFBRAD]
    regexp {Part Number[\s:]+([\w\-]+)\s} $b - xfp
    if ![info exists xfp] {
      puts "b:<$b>"
      puts "b1:<$::b1>"
      puts "b2:<$::b2>"
      set gaSet(fail) "Port $10Gp. Can't read XFP's Part Number"
      return -1
    }
#     if {$xfp!="XFP-1D"} {}
    if {[lsearch $xfpL $xfp]=="-1"} {
      set gaSet(fail) "XFP Part Number of port $10Gp is \"$xfp\". Should be one from $xfpL" 
      set ret -1
      break 
    }    
  }
  return $ret  
}

# ***************************************************************************
# SfpUtp_ID_Test
# ***************************************************************************
proc SfpUtp_ID_Test {} {
  global gaSet buffer
#   if {$gaSet(1G)=="10UTP" || $gaSet(1G)=="20UTP"} {
#     ## don't check ports UTP
#     return 0
#   }
  Status "SfpUtp_ID_Test"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  
  foreach 1Gp {1/1 1/2 1/3 1/4 1/5 1/6 1/7 1/8 1/9 1/10 2/1 2/2 2/3 2/4 2/5 2/6 2/7 2/8 2/9 2/10} {
    if {($gaSet(1G)=="10SFP" || $gaSet(1G)=="10UTP") && [lindex [split $1Gp /] 0]==2} {
      ## dont check ports 2/x
      continue
    }
#     if {$gaSet(1G)=="10UTP" || $gaSet(1G)=="20UTP"} {
#       ## dont check ports UTP
#       set ret 0
#       break
#     }
#     if {$gaSet(1G)=="10SFP_10UTP" && [lindex [split $1Gp /] 0]==2} {
#       ## dont check ports UTP  2/x
#       continue
#     }
    Status "SfpUtp $1Gp ID Test"
    set gaSet(fail) "Read SfpUtp status of port $1Gp fail"
    Send $com "exit all\r" stam 0.25 
    set ret [Send $com "configure port ethernet $1Gp\r" #]
    if {$ret!=0} {return $ret}
    if [string match {*Entry instance doesn't exist*} $buffer] {
      set gaSet(fail) "Status of port $1Gp is \"Entry instance doesn't exist\"." 
      set ret -1
      break
    }
    set ret [Send $com "show status\r\r" "#" 20]
    if {$ret!=0} {return $ret}    
    set res [regexp {Connector Type\s+:\s+(.+)Auto} $buffer - connType]
    set connType [string trim $connType]
    if {([lindex [split $1Gp /] 0]==1 && ($gaSet(1G)=="10UTP" || $gaSet(1G)=="20UTP")) ||\
        ([lindex [split $1Gp /] 0]==2 && ($gaSet(1G)=="10SFP_10UTP" || $gaSet(1G)=="20UTP"))} {
      ## 1/x ports
      ## 2/x ports
      set conn "RJ45" 
      set name "UTP"
    } else {
      set conn "SFP In"
      set name "SFP"
    } 
    
    if {$connType!=$conn} {
      set gaSet(fail) "$name status of port $1Gp is \"$connType\". Should be \"$conn\"" 
      set ret -1
      break 
    }
    if {$name=="SFP"} {
      regexp {Part Number[\s:]+([\w\-]+)\s} $buffer - sfp
      if ![info exists sfp] {
        set gaSet(fail) "Can't read SFP's Part Number"
        return -1
      }
      set sfpL [list "SFP-5D" "SFP-6D" "SFP-6H" "SFP-30" "SFP-6" "SPGBTXCNFCRAD" "EOLS-1312-10-RAD" "EOLS131210RAD"]
      if {[lsearch $sfpL $sfp]=="-1"} {
        set gaSet(fail) "SFP Part Number of port $1Gp is \"$sfp\". Should be one from $sfpL" 
        set ret -1
        break 
      }
    }
    
  }
  return $ret  
}

# ***************************************************************************
# DateTime_Test
# ***************************************************************************
proc DateTime_Test {} {
  global gaSet buffer
  Status "DateTime_Test"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "configure system\r" >system]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show system-date\r" >system]
  if {$ret!=0} {return $ret}
  
  regexp {date\s+([\d-]+)\s+([\d:]+)\s} $buffer - dutDate dutTime
  
  set dutTimeSec [clock scan $dutTime]
  set pcSec [clock seconds]
  set delta [expr abs([expr {$pcSec - $dutTimeSec}])]
  if {$delta>300} {
    set gaSet(fail) "Difference between PC and the DUT is more then 5 minutes ($delta)"
    set ret -1
  } else {
    set ret 0
  }
  
  if {$ret==0} {
    set pcDate [clock format [clock seconds] -format "%Y-%m-%d"]
    if {$pcDate!=$dutDate} {
      set gaSet(fail) "Date of the DUT is \"$dutDate\". Should be \"$pcDate\""
      set ret -1
    } else {
      set ret 0
    }
  }
  return $ret
}

# ***************************************************************************
# DataTransmissionSetup
# ***************************************************************************
proc DataTransmissionSetup {} {
  global gaSet buffer
  
  set com $gaSet(comDut)
  Send $com \x1F\r\r -2I 3
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  
  Send $com "exit all\r" stam 0.25 
 
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  puts "dataTransmissionSetup b:<$b> p:<$p>" ; update
  if {$b=="19V"} {
    set ret [DnfvShutdown "no shutdown"] 
    if {$ret!=0} {return $ret} 
    set ret [DnfvBooting $com] 
    if {$ret!=0} {return $ret}
    set ret [Send $com \x1F\r\r -2I]
    if {$ret!=0} {return $ret}
  }  
  
  if {$b=="DNFV" && $p=="Xe"} {
    if {$gaSet(cbTesterMode)=="FTI"} {
      set ret [XeonShortDataSetup] 
    } else {
      set ret [XeonLongDataSetup] 
    }
    if {$ret!=0} {return $ret}          
  } else {
    set cf $gaSet([set b]CF) 
    set cfTxt "$b"
    set ret [DownloadConfFile $cf $cfTxt 1]
    if {$ret!=0} {return $ret} 
  } 
    
  return $ret
}
# ***************************************************************************
# RtrSetup
# ***************************************************************************
proc RtrSetup {} {
  global gaSet
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
 
  set cf $gaSet(RTRCF) 
  set cfTxt "RTR"
      
  set ret [DownloadConfFile $cf $cfTxt 0]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# ExtClkTest
# ***************************************************************************
proc ExtClkTest {mode} {
  puts "[MyTime] ExtClkTest $mode"
  global gaSet buffer
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
#   set ret [Send $com "configure system clock station 1/1\r" "(1/1)"]
#   if {$ret!=0} {return $ret}
#   set ret [Send $com "shutdown\r" "(1/1)"]
#   if {$ret!=0} {return $ret}
#   Send $com "exit all\r" stam 0.25 
  
  if {$mode=="Unlocked"} {
    set ret [Send $com "configure system clock\r" ">clock"]
    if {$ret!=0} {return $ret} 
    set ret [Send $com "domain 1\r" "domain(1)"]
    if {$ret!=0} {return $ret} 
    set ret [Send $com "show status\r" "domain(1)"]
    if {$ret!=0} {return $ret} 
    set syst [set clkSrc [set state ""]]
    regexp {System Clock Source[\s:]+(\d)\s+State[\s:]+(\w+)\s} $buffer syst clkSrc state
    if {$clkSrc!="0" && $state!="Freerun"} {
      set gaSet(fail) "$syst"
      return -1
    }
  }
 
 if {$mode=="Locked"} {
    set cf $gaSet(ExtClkCF) 
    set cfTxt "EXT CLK"
    set ret [DownloadConfFile $cf $cfTxt 0]
    if {$ret!=0} {return $ret}
    
    set ret [Send $com "configure system clock\r" ">clock"]
    if {$ret!=0} {return $ret} 
    set ret [Send $com "domain 1\r" "domain(1)"]
    if {$ret!=0} {return $ret} 
    for {set i 1} {$i<=10} {incr i} {
      set ret [Send $com "show status\r" "domain(1)"]
      if {$ret!=0} {return $ret} 
      set syst [set clkSrc [set state ""]]
      regexp {System Clock Source[\s:]+(\d)\s+State[\s:]+(\w+)\s} $buffer syst clkSrc state
      if {$clkSrc=="1" && $state=="Locked"} {
        set ret 0
        break
      } else {      
        set ret -1
        after 1000
      }
    }
    if {$ret=="-1"} {
      set gaSet(fail) "$syst"
    } elseif {$ret=="0"} {
      set ret [Send $com "no source 1\r" "domain(1)"]
      if {$ret!=0} {return $ret}
    }
  }
  return $ret
}

# ***************************************************************************
# TstAlm
# ***************************************************************************
proc TstAlm {state} {
  global gaSet buffer
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set ret [Send $com "configure reporting\r" ">reporting"]
  if {$ret!=0} {return $ret}
  if {$state=="off"} { 
    set ret [Send $com "mask-minimum-severity log major\r" ">reporting"]
  } elseif {$state=="on"} { 
    set ret [Send $com "no mask-minimum-severity log\r" ">reporting"]
  } 
  return $ret
}

# ***************************************************************************
# ReadMac
# ***************************************************************************
proc ReadMac {} {
  global gaSet buffer
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Read MAC fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25
  set ret [Send $com "configure system\r" ">system"]
  if {$ret!=0} {return $ret} 
  set ret [Send $com "show device-information\r" ">system"]
  if {$ret!=0} {return $ret}
  
  set mac 00-00-00-00-00-00
  regexp {MAC\s+Address[\s:]+([\w\-]+)} $buffer - mac
  if [string match *:* $mac] {
    set mac [join [split $mac :] ""]
  }
  set mac1 [join [split $mac -] ""]
  set mac2 0x$mac1
  puts "mac1:$mac1" ; update
  if {($mac2<0x0020D2500000 || $mac2>0x0020D2FFFFFF) && ($mac2<0x1806F5000000 || $mac2>0x1806F5FFFFFF)} {
    RLSound::Play fail
    set gaSet(fail) "The MAC of UUT is $mac"
    set ret [DialogBox -type "Terminate Continue" -icon /images/error -title "MAC check"\
        -text $gaSet(fail) -aspect 2000]
    if {$ret=="Terminate"} {
      return -1
    }
  }
  set gaSet(${::pair}.mac1) $mac1
  
  return 0
}
# ***************************************************************************
# ReadPortMac
# ***************************************************************************
proc ReadPortMac {port} {
  global gaSet buffer
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Read MAC of port $port fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25
  set ret [Send $com "configure port\r" "port"]
  if {$ret!=0} {return $ret} 
  set ret [Send $com "ethernet $port\r" "($port)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show status\r" "($port)"]
  regexp {MAC\s+Address[\s:]+([\w\-]+)} $buffer - mac
  if {$ret!=0 && [string match {*more*} $buffer]} {
    set ret [Send $com "\r" "($port)"]    
  }
  if {$ret!=0} {return $ret}
  if [string match *:* $mac] {
    set mac [join [split $mac :] ""]
  }
  set mac1 [join [split $mac -] ""]
  return $mac1
}

#***************************************************************************
#**  Login
#***************************************************************************
proc Login {} {
  global gaSet buffer gaLocal
  set ret 0
  set gaSet(loginBuffer) ""
  set statusTxt  [$gaSet(sstatus) cget -text]
  Status "Login into ETX-2i"
  set com $gaSet(comDut)
#   set ret [MyWaitFor $gaSet(comDut) {ETX-2I user>} 5 1]
  Send $com "\r" stam 0.25
  Send $com "\r" stam 0.25
  if {([string match {*-2I*} $buffer]==0) && ([string match {*user>*} $buffer]==0)} {
    set ret -1  
  } else {
    set ret 0
  }
  if {[string match {*Are you sure?*} $buffer]==1} {
   Send $com n\r stam 1
  }
  if {[string match {*\[boot\]*} $buffer]==1} {
   Send $com run\r stam 1
  } 
   
  if {[string match *password* $buffer] || [string match {*press a key*} $buffer]} {
    set ret 0
    Send $com \r stam 0.25
  }
  if {[string match *FPGA* $buffer]} {
    set ret 0
    Send $com exit\r\r -2I
  }
  if {[string match *:~$* $buffer] || [string match *login:* $buffer] || \
      [string match *Password:* $buffer]  || [string match *rad#* $buffer] || \
      [string match *syncope@rad:~$* $buffer]} {
    set ret 0
    Send $com \x1F\r\r -2I
  }
  if {[string match *vpp* $buffer]} {
    Send $com q syncope
    set ret 0
    Send $com \x1F\r\r -2I
  }
  if {[string match *-2I* $buffer]} {
    set ret 0
    return 0
  }
  if {[string match {*C:\\*} $buffer]} {
    set ret 0
    return 0
  } 
  
  if {[string match *user* $buffer]} {
    Send $com su\r stam 0.25
    set ret [Send $com 1234\r "ETX-2I"]
    $gaSet(runTime) configure -text ""
    return $ret
  }
  if {$ret!=0} {
    #set ret [Wait "Wait for ETX up" 20 white]
    #if {$ret!=0} {return $ret}  
  }
  for {set i 1} {$i <= 64} {incr i} { 
    if {$gaSet(act)==0} {return -2}
    Status "Login into ETX-2I"
    puts "Login into ETX-2I i:$i"; update
    $gaSet(runTime) configure -text $i
    Send $gaSet(comDut) \r stam 5
    
    append gaSet(loginBuffer) "$buffer"
    puts "<$gaSet(loginBuffer)>\n" ; update
    foreach ber $gaSet(bootErrorsL) {
      if [string match "*$ber*" $gaSet(loginBuffer)] {
       set gaSet(fail) "\'$ber\' occured during ETX-2I's up"  
        return -1
      } else {
        puts "[MyTime] \'$ber\' was not found"
      } 
    }
  
    #set ret [MyWaitFor $gaSet(comDut) {ETX-2I user> } 5 60]
    if {([string match {*-2I*} $buffer]==1) || ([string match {*user>*} $buffer]==1)} {
      puts "if1 <$buffer>"
      set ret 0
      break
    }
    ## exit from boot menu 
    if {[string match {*\[boot\]*} $buffer]} {
      Send $com run\r stam 1
    }   
    if {[string match *login:* $buffer]} { }
    if {[string match *:~$* $buffer] || [string match *login:* $buffer] || [string match *Password:* $buffer]} {
      Send $com \x1F\r\r -2I
      return 0
    }
    if {[string match {*C:\\*} $buffer]} {
      set ret 0
      return 0
    } 
  }
  if {$ret==0} {
    if {[string match *user* $buffer]} {
      Send $com su\r stam 1
      set ret [Send $com 1234\r "-2I"]
    }
  }  
  if {$ret!=0} {
    set gaSet(fail) "Login to ETX-2I Fail"
  }
  $gaSet(runTime) configure -text ""
  if {$gaSet(act)==0} {return -2}
  Status $statusTxt
  return $ret
}
# ***************************************************************************
# FormatFlash
# ***************************************************************************
proc FormatFlash {} {
  global gaSet buffer
  set com $gaSet(comDut)
  
  Power all on 
  
  return $ret
}
# ***************************************************************************
# FactDefault
# ***************************************************************************
proc FactDefault {mode} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Set to Default fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
 
  Status "Factory Default..."
  if {$mode=="std"} {
    set ret [Send $com "admin factory-default\r" "yes/no" ]
  } elseif {$mode=="stda"} {
    set ret [Send $com "admin factory-default-all\r" "yes/no" ]
  }
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "y\r" "seconds" 20]
  if {$ret!=0} {return $ret}
  
  set ret [ReadBootVersion]
  if {$ret!=0} {return $ret}
  
  Power all off
  after 5000
  Power all on
  
  set ret [Wait "Wait DUT down" 30 white]
  return $ret
}
# ***************************************************************************
# ReadBootVersion
# ***************************************************************************
proc ReadBootVersion {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ::buff ""
  set gaSet(uutBootVers) ""
  set ret -1
  for {set sec 1} {$sec<40} {incr sec} {
    if {$gaSet(act)==0} {return -2}
    RLSerial::Waitfor $com buffer xxx 1
    puts "sec:$sec buffer:<$buffer>" ; update
    append ::buff $buffer
    if {[string match {*to view available commands*} $buffer]==1} {      
      set ret 0
      break
    }
  }
  if {$ret!=0} {
    set gaSet(fail) "Can't read the boot"
    return $ret
  }
  set res [regexp {Boot version:\s([\d\.\(\)]+)\s} $::buff - value]
  if {$res==0} {
    set gaSet(fail) "Can't read the Boot version"
    return -1
  } else {
    set gaSet(uutBootVers) $value
    puts "gaSet(uutBootVers):$gaSet(uutBootVers)"
    set ret 0
  }
  return $ret
}
# ***************************************************************************
# ShowPS
# ***************************************************************************
proc ShowPS {ps} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  Status "Read PS-$ps status"
  set gaSet(fail) "Read PS-$ps status fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "configure chassis\r" chassis]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show environment\r" chassis]
  if {$ret!=0} {return $ret}
  if {$ps==1} {
    set res [regexp {1\s+[AD]C\s+([\w\s]+)\s2} $buffer - val]
    if {$res==0} {
      set res [regexp {1\s+[\-\s]+([\w\s]+)\s2} $buffer - val]
    }
  } elseif {$ps==2} {
    set res [regexp {2\s+[AD]C\s+([\w\s]+)\sFAN} $buffer - val]
    if {$res==0} {
      set res [regexp {2\s+[\-\s]+([\w\s]+)\sFAN} $buffer - val]
    }
  }
  if {$res==0} {
    return -1
  } 
  set val [string trim $val]
  puts "ShowPS val:<$val>"
  if {[lindex [split $val " "] 0] == "HP"} {
    set val [lrange [split $val " "] 1 end] 
  }
  return $val
}
# ***************************************************************************
# Loopback
# ***************************************************************************
proc Loopback {mode} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  Status "Set Loopback to \'$mode\'"
  set gaSet(fail) "Loopback configuration fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "configure port ethernet 0/1\r" (0/1)]
  if {$ret!=0} {return $ret}
  if {$mode=="off"} {
    set ret [Send $com "no loopback\r" (0/1)]
  } elseif {$mode=="on"} {
    set ret [Send $com "loopback remote\r" (0/1)]
  }
  if {$ret!=0} {return $ret}
#   Send $com "exit\r" stam 0.25 
#   set ret [Send $com "ethernet 4/2\r" (4/2)]
#   if {$ret!=0} {return $ret}
#   if {$mode=="off"} {
#     set ret [Send $com "no loopback\r" (4/2)]
#   } elseif {$mode=="on"} {
#     set ret [Send $com "loopback remote\r" (4/2)]
#   }
#   if {$ret!=0} {return $ret}
  
  return $ret
}

# ***************************************************************************
# DateTime_Set
# ***************************************************************************
proc DateTime_Set {} {
  global gaSet buffer
#   OpenComUut
  Status "Set DateTime"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
  }
  if {$ret==0} {
    set gaSet(fail) "Logon fail"
    set com $gaSet(comDut)
    Send $com "exit all\r" stam 0.25 
    set ret [Send $com "configure system\r" >system]
  }
  if {$ret==0} {
    set gaSet(fail) "Set DateTime fail"
    set ret [Send $com "date-and-time\r" "date-time"]
  }
  if {$ret==0} {
    set pcDate [clock format [clock seconds] -format "%Y-%m-%d"]
    set ret [Send $com "date $pcDate\r" "date-time"]
  }
  if {$ret==0} {
    set pcTime [clock format [clock seconds] -format "%H:%M"]
    set ret [Send $com "time $pcTime\r" "date-time"]
  }
  return $ret
#   CloseComUut
#   RLSound::Play information
#   if {$ret==0} {
#     Status Done yellow
#   } else {
#     Status $gaSet(fail) red
#   } 
}
# ***************************************************************************
# LoadDefConf
# ***************************************************************************
proc LoadDefConf {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Load Default Configuration fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set cf $gaSet(defConfCF) 
  set cfTxt "DefaultConfiguration"
  set ret [DownloadConfFile $cf $cfTxt 1]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "file copy running-config user-default-config\r" "yes/no" ]
  if {$ret!=0} {return $ret}
  set ret [Send $com "y\r" "successfull" 30]
  
  return $ret
}
# ***************************************************************************
# DdrTest
# ***************************************************************************
proc DdrTest {attm} {
  global gaSet buffer
  Status "DDR Test (attempt $attm)"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
#   Send $com "exit all\r" stam 0.25 
#   Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  Status "Read MEA LOG (attempt $attm)"
  
  set gaSet(fail) "Read MEA LOG fail on attempt $attm"
  set ret [Send $com "debug mea\r\r" FPGA 11]
  if {$ret!=0} {
    set ret [Send $com "\r\r" FPGA ]
    if {$ret!=0} {return $ret}
  }
  set ret [Send $com "mea debug log show\r" FPGA>> 30]
  if {$ret!=0} {return $ret}
  
  if {$gaSet(dbrSW)== "6.7.1(0.53)" && [string match {*ENTU_ERROR l2cp entry was not deleted, HW failure*} $buffer]} {
    puts "for 6.7.1(0.53) thiis error allowed"
  } elseif {[string match {*ENTU_ERROR*} $buffer]} {
    set gaSet(fail) "\'ENTU_ERROR\' exists in the MEA log (attempt $attm)"
    return -1
  }
  if {[string match {*init DDR ..........................OK*} $buffer]==0} {
    set gaSet(fail) "\'init DDR ..OK\' doesn't exist in the MEA log (attempt $attm)"
    return -1
  }
  if {[string match {*DDR NOT OK*} $buffer]==1} {
    set gaSet(fail) "\'DDR NOT OK\' exists in the MEA log (attempt $attm)"
    return -1
  }
  
  set ret [Send $com "exit\r\r\r" ETX-2I 16]
  if {$ret!=0} {
    set ret [Send $com "exit\r\r\r" ETX-2I 16]
    if {$ret!=0} {return $ret}
  }
  return $ret
}  
# ***************************************************************************
# DryContactTest
# ***************************************************************************
proc DryContactTest {} {
  global gaSet buffer
  Status "Dry Contact Test"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
#  Send $com "exit all\r" stam 0.25 
#  Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  Status "Read MEA LOG"
  
  RLUsbPio::SetConfig $gaSet(idDrc) 11111000 ; # 3 first bits are OUT
  RLUsbPio::Set $gaSet(idDrc) xxxxx000 ; # 3 first bits are 0 
  
  set gaSet(fail) "Read MEA HW DRY fail"
  set ret [Send $com "debug mea\r" FPGA 11]
  if {$ret!=0} {return $ret}
  set ret [Send $com "mea hw dry\r" dry>>]
  if {$ret!=0} {return $ret}
  set ret [Send $com "read 0\r" dry>>]
  if {$ret!=0} {return $ret}
  
  set res [regexp {\[0x0\]\.+(\w+)} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "Read \'read 0\' fail"
    return -1
  }
  if {$val!="0xf7"} {
    set gaSet(fail) "The value of 0x0 is \'$val\'. Should be \'0xf7\'"
    return -1
  }
  
  set ret [Send $com "read 1\r" dry>>]
  if {$ret!=0} {return $ret}
  
  set res [regexp {\[0x1\]\.+(\w+)} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "Read \'read 1\' fail"
    return -1
  }
  if {$val!="0xff"} {
    set gaSet(fail) "The value of 0x1 is \'$val\'. Should be \'0xff\'"
    return -1
  }
  
  RLUsbPio::Set $gaSet(idDrc) xxxxx111 ; # 3 first bits are 1
  set ret [Send $com "read 0\r" dry>>]
  if {$ret!=0} {return $ret}
  
  set res [regexp {\[0x0\]\.+(\w+)} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "Read \'read 0\' fail"
    return -1
  }
  if {$val!="0xf0"} {
    set gaSet(fail) "The value of 0x0 is \'$val\'. Should be \'0xf0\'"
    return -1
  }
     
  set ret [Send $com "exit\r\r" ETX-2I 16]
  if {$ret!=0} {return $ret}
  return $ret
}  

# ***************************************************************************
# ShowArpTable
# ***************************************************************************
proc ShowArpTable {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Show ARP Table fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  set ret [Send $com "configure router 1\r" (1)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show arp-table\r" (1)]
  if {$ret!=0} {return $ret}
  
  set lin1 "1.1.1.1 00-00-00-00-00-01 Dynamic"
  set lin2 "2.2.2.1 00-00-00-00-00-02 Dynamic"
   
  foreach lin [list $lin1 $lin2] {
    if {[string match *$lin* $buffer]==0} {
      set gaSet(fail) "The \'$lin\' doesn't exist"
      return -1
    }
  }

  return 0
}
# ***************************************************************************
# BiosTest
# ***************************************************************************
proc BiosTest {testMode} {
  global gaSet buffer 
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="Xe"} {
    return [XeonBiosTest $testMode]
  }
  
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  puts "[MyTime] BiosTest $testMode"
  set gaSet(fail) "Enter to BIOS fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  Status "Enter to BIOS"
  set ret [Send $com "configure chassis ve-module reset-wake\r" 2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure chassis ve-module remote-terminal\r" 2I]
  if {$ret!=0} {return $ret}
  
  for {set attempt 1} {$attempt<=10} {incr attempt} {
    puts "BiosTest attempt:$attempt"
    if {$attempt>1} {
      RLSound::Play information
      set txt "Click \'OK\' and immediately push on Reset button of the DNFV"
      set res [DialogBox -type "OK Cancel" -icon /images/question \
          -title "Reset of DNFV" -message $txt -aspect 2000]
      update
      if {$res=="Cancel"} {
        return -2
      }
    }
    set ret [Send $com "\r" "to enter setup"]
    if {$ret=="-1"} {continue}
    
    set ret [Send $com "\33" "stam" 5]
    set ret 0
    
    if ![string match *Project* $buffer] {
      continue
    }
    
    set res [regexp {Project Version.*(Z.*) x64} $buffer - val]
    if {$res==0} {
      set ret -1
      set gaSet(fail) "Read \'Project Version\' fail"
      break
    }
    set val [string trim $val]
    set gaSet(dnfvProject) [string trim $gaSet(dnfvProject)]
    puts "gaSet(dnfvProject):<$gaSet(dnfvProject)> val:<$val>"
    if {$gaSet(dnfvProject) != $val} {
      set ret -1
      set gaSet(fail) "The \'Project Version\' is \'$val\'. Should be \'$gaSet(dnfvProject)\'"
      break
    }
    
    set res [regexp {EC Version\s+C ([\d\s]+)} $buffer - val]
    if {$res==0} {
      set ret -1
      set gaSet(fail) "Read \'EC Version\' fail"
      break
    }
    set val [string trim $val]
    set gaSet(dnfvEC) [string trim $gaSet(dnfvEC)]
    puts "gaSet(dnfvEC):<$gaSet(dnfvEC)> val:<$val>"
    if {$gaSet(dnfvEC) != $val} {
      set ret -1
      set gaSet(fail) "The \'EC Version\' is \'$val\'. Should be \'$gaSet(dnfvEC)\'"
      break
    }
    
    set res [regexp {Total Memory\s+(\d+)} $buffer - val]
    if {$res==0} {
      set ret -1
      set gaSet(fail) "Read \'Total Memory\' fail"
      break
    }
    foreach {b r p d ps} [split $gaSet(dutFam) .] {}
    puts "b:$b r:$r val:<$val>"
    if {$r != $val} {
      set ret -1
      set gaSet(fail) "The \'Total Memory\' is \'$val\'. Should be \'$r\'"
      break
    }
    
    Status "Checking the CPU Type"
    ## move right
    Send $com "\33\[C" stam 3
    ## move down
    Send $com "\33\[B" stam 3
    ## enter to CPU screen
    Send $com "\r"  stam 3
    
    set res [regexp {TM\) (i.*GHz)} $buffer - val]
    if {$res==0} {
      set ret -1
      set gaSet(fail) "Read \'CPU Type\' fail"
      break
    }
    set val [string trim $val]
    set gaSet(dnfvCPU) [string trim $gaSet(dnfvCPU)]
    puts "gaSet(dnfvCPU):<$gaSet(dnfvCPU)> val:<$val>"
    if {$gaSet(dnfvCPU) != $val} {
      set ret -1
      set gaSet(fail) "The \'CPU Type\' is \'$val\'. Should be \'$gaSet(dnfvCPU)\'"
      break
    }
    
    Status "Configuration Turbo Mode"
    Send $com "\33\[A" "Config TDP LOCK"
    Send $com "\33\[A" "Config TDP LOCK"
    Send $com "\33\[A" "Save & Exit"
    Send $com "\33\[A" "Save & Exit"
    
    if {$testMode=="check"} {
      if {![string match {*Turbo Mode \[Disabled\]*} $buffer]} {
        set gaSet(fail) "Configuration Turbo Mode to Disabled failed"
        set ret -1
        break
      }
    } elseif {$testMode=="set"} {
      if {[string match {*Turbo Mode \[Disabled\]*} $buffer]} {
        set ret 0
      } elseif {[string match {*Turbo Mode \[Enabled\]*} $buffer]} {
        Send $com \r stam 1
        ## move down
        Send $com "\33\[B" stam 1
        Send $com \r stam 3
        if {![string match {*Turbo Mode \[Disabled\]*} $buffer]} {
          set gaSet(fail) "Configuration Turbo Mode to Disabled failed"
          set ret -1
          break
        }
      }
    }
    #Send $com "\33\[A" "Previous Values"
#     for {set i 1} {$i <= 5} {incr i} {
#       ## move up
#       Send $com "\33\[A" stam 8
#       if {[string match {*Turbo Mode \[Disabled\]*} $buffer]} {
#         set ret 0
#         break
#       } 
#       if {[string match {*Turbo Mode \[Enabled\]*} $buffer]} {
#         Send $com \r stam 1
#         ## move down
#         Send $com "\33\[B" stam 1
#         Send $com \r stam 8
#         if {[string match {*Turbo Mode \[Disabled\]*} $buffer]} {
#           set ret 0
#           break
#         }
#       } 
#     }
    
    Status "Configuration Max. Freq. Ratio"
    for {set i 1} {$i <= 6} {incr i} {
      ## move up
      Send $com "\33\[A" stam 1 
    }  
    
    set maxFreqRat 22
    if {$testMode=="check"} {
      ##Max Freq Ratio   [1;37;44m22   ³   Supported 
      set res [regexp {m\s?(\d+)\s+} $buffer ma value]
      if {$res==0} {
        set gaSet(fail) "Read Max. Freq. Ratio fail"
        set ret -1
        break
      }
      if {$value!=$maxFreqRat} {
        set gaSet(fail) "Max. Freq. Ratio is $value. Should be $maxFreqRat"
        set ret -1
        break
      }
    } elseif {$testMode=="set"} {
      Send $com "$maxFreqRat" stam 1
    }   
    ## move down to see all changes
    Send $com "\33\[B" stam 3
    
    Send $com "\33" stam 2
    
    Status "Saving the changes"
    ## move left
    Send $com "\33\[D" stam 3
    Send $com "\33\[D" stam 2
    Send $com "\r" stam 2
    Send $com "\r" stam 2
    
    set ret 0
    break
    
  }
  puts "res of attempt-$attempt : <$ret>"
  return $ret
}
# ***************************************************************************
# BurnMacTest
# ***************************************************************************
proc BurnMacTest {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Enter to DNFV fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  if {[string match {*C:\\*} $buffer]} {
    ## it's already in the right place, do not entry into DNFV
  } else {
    set ret [Send $com "configure chassis ve-module remote-terminal\r" 2I]
    if {$ret!=0} {return $ret}
    set ret [Send $com "\r" "stam" 1]
    if {[string match {*login*} $buffer] || [string match {*Password*} $buffer]} {
      ## the DNFV is not new, so it's MACs are burned already
      set gaSet(dnfvMac1) rad
      set gaSet(dnfvMac2) rad
      return 0
    }
  }
  
  set secStart [clock seconds]
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set nowSec [clock seconds]
    set runSec [expr {$nowSec - $secStart}]
    $gaSet(runTime) configure -text $runSec
    update
    if {$runSec>45} {
      return -1
    }
    puts "runSec:$runSec" ; update
    Send $com "\r" "stam" 1
    if {[string match {*C:\\*} $buffer]} {
      set ret 0
      break
    }
    #RLSerial::Waitfor $com buffer stam 2
    #puts "$runSec <$buffer>" ; update
    #if {[string match {*new date*} $buffer]==1} {
    #  set ret 0
    #  break
    #}
    if {[string match {*login*} $buffer] || [string match {*Password*} $buffer]} {
      ## the DNFV is not new, so he MACs are burned already
      set gaSet(dnfvMac1) rad
      set gaSet(dnfvMac2) rad
      return 0
    }
  }
  puts "ret after while : <$ret>" ; update
  
  set ret [GetMac 1]
  puts "ret after getmac1 : <$ret>" ; update
  if {$ret=="-1"} {return $ret}
  set mac1 $ret
  
  set ret [GetMac 2]
  puts "ret after getmac2 : <$ret>" ; update
  if {$ret=="-1"} {return $ret}
  set mac2 $ret
  set ret 0
  set gaSet(dnfvMac1) $mac1
  set gaSet(dnfvMac2) $mac2
  
  
  if {$ret!=0} {return $ret}
  #set ret [Send $com "\r" "new time" 1]
  #if {$ret!=0} {return $ret}
  set ret [Send $com "\r" "C:"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "rad.bat\r" "1 MAC Address:"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "$mac1\r" "2 MAC Address:" 60]   
  if {$ret!=0} {return $ret}
  if ![string match {*updated successfully*} $buffer] {
    set gaSet(fail) "MAC1 updating fail"  
    return -1
  }
  if [string match {*No supported adapters were located*} $buffer] {
    set gaSet(fail) "MAC1 updating fail"  
    return -1
  }
  if {[regexp {Updating MAC Address.*Done.} $buffer -]==0} {
    set gaSet(fail) "MAC1 updating fail"  
    return -1
  }
#   AddToLog "MAC1 $mac1"
  AddToPairLog $gaSet(pair) "MAC1 $mac1"
  
  
  set ret [Send $com "$mac2\r" "complete the programming process" 30]
  if {$ret!=0} {return $ret}
  if ![string match {*updated successfully*} $buffer] {
    set gaSet(fail) "MACs updating fail"  
    return -1
  }
  if [string match {*No supported adapters were located*} $buffer] {
    set gaSet(fail) "MACs updating fail"  
    return -1
  }
  if {[regexp {Updating MAC Address.*Done.} $buffer -]==0} {
    set gaSet(fail) "MAC1 updating fail"  
    return -1
  }
#   AddToLog "MAC2 $mac2"
  AddToPairLog $gaSet(pair) "MAC2 $mac2"
  return 0 
}

# ***************************************************************************
# DnfvSoftwareDownloadTest
# ***************************************************************************
proc DnfvSoftwareDownloadTest {} {
  global gaSet buffer 
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Enter to DNFV fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
if 0 {
#   Status "Wait for DNFV booting"
# #   set ret [Send $com "configure chassis ve-module reset-wake\r" 2I]
# #   if {$ret!=0} {return $ret}
#   set ret [Send $com "configure chassis ve-module remote-terminal\r\r" "login:" 2]
#   
#   
#   set secStart [clock seconds]
#   while 1 {
#     if {$gaSet(act)==0} {return -2}
#     set nowSec [clock seconds]
#     set runSec [expr {$nowSec - $secStart}]
#     $gaSet(runTime) configure -text $runSec
#     update
#     if {$runSec>120} {
#       set ret -1
#       break
#     }
#     RLSerial::Waitfor $com buffer stam 2
#     puts "$runSec <$buffer>" ; update
#     if {[string match {*login:*} $buffer]==1} {
#       set ret 0
#       break
#     }
#     
#   }
} 
  set ret [DnfvBooting $com]
  if {$ret=="-2"} {return $ret}  
  
  if 1 {
  
  #if [string match {*login:*} $buffer] {}
  if {$ret==0 && [string match {*login:*} $buffer]} {
    ## the dnfv is not empty
    ## go to bios and at boot menu change the priority of DoK to first 
    for {set attempt 1} {$attempt<=10} {incr attempt} {
#       set gaSet(fail) "Change Boot priority fail"
#       RLSound::Play information
#       set txt "Click \'OK\' and immediately push on Reset button of the DNFV"
#       set res [DialogBox -type "OK Cancel" -icon /images/question \
#           -title "Reset of DNFV" -message $txt -aspect 2000]
#       update
#       if {$res=="Cancel"} {
#         return -2
#       }
      Status "Login into DNFV ($attempt)"
      set ret [Send $com "rad\r" "Password:"]
      if {$ret!=0} {return $ret}
      set ret [Send $com "rad123\r" ":~$"]
      if {$ret!=0} {return $ret}
      set ret [Send $com "sudo su\r" ":"]
      if {$ret!=0} {return $ret}
      set ret [Send $com "rad123\r" "#"]
      if {$ret!=0} {return $ret}
      set ret [Send $com "reboot\r" ":"]
      if {$ret!=0} {return $ret}
      set ret [RLSerial::Waitfor $com buffer "Version" 32]      
      #set ret [Send $com "\r" "to enter setup"]
      if {$ret=="-1"} {
        set ret [Wait "Wait for DNFV reseting" 70]
        if {$ret!=0} {return $ret}
        continue
      }
      
      for {set dok 1} {$dok<=4} {incr dok} {
        puts "[MyTime] Start of dok-$dok" ; update
        set ret [DnfvBiosDOK]
        puts "[MyTime] ret of dok-$dok : <$ret>" ; update
        if {$ret=="0"} {
          break
        } elseif {$ret=="-1"} {
          set ret [RLSerial::Waitfor $com buffer "BIOS Date" 3]
          puts "-1 dok-$dok <$buffer>" ; update
          set ret [Wait "Wait for DNFV reseting" 40]
          if {$ret!=0} {return $ret}
        } elseif {$ret=="1"} {  
          set ret [RLSerial::Waitfor $com buffer "BIOS Date" 3]
          puts "1 dok-$dok <$buffer>" ; update        
          continue
        }
      } 
      if {$ret=="0" || $ret=="-2"} {
        break
      }
    }  
  
  
    set gaSet(fail) "Software download fail"
    if {$ret!=0} {return $ret}
      
    
    #set ret [Send $com "y\r" "(y/n)" 15]
    #if {$ret!=0} {return $ret}
    #set ret [Send $com "y\r" "Start over" 1]
    
    
    set gaSet(fail) "Software download fail"
    Status "Wait for SW download"  
    set secStart [clock seconds]
    while 1 {
      if {$gaSet(act)==0} {return -2}
      set nowSec [clock seconds]
      set runSec [expr {$nowSec - $secStart}]
      $gaSet(runTime) configure -text $runSec
      update
      if {$runSec>220} {
        return -1
      }
      RLSerial::Waitfor $com buffer stam 2
      puts "sdt $runSec <$buffer>" ; update
      if {[string match {*Start over*} $buffer]==1} {
        set ret 0
        break
      }      
    }
  }
  }
  
  if {$ret!=0} {return $ret}
  
  ## move up
  after 1000
  Send $com "\33\[A" stam 1 
  set ret [Send $com "\r" "login:" 1]
  
  RLSound::Play information
  set txt "Remove the DiskOnKey"
  set res [DialogBox -type "OK Cancel" -icon /images/question \
      -title "DiskOnKey" -message $txt]
  update
  if {$res=="Cancel"} {
    return -2
  }
  
  set alreadyPowerOffOn 0
  Status "Wait DNFV up"
  #set ret [Send $com "\r" "login:" 1]
  set secStart [clock seconds]
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set nowSec [clock seconds]
    set runSec [expr {$nowSec - $secStart}]
    $gaSet(runTime) configure -text $runSec
    update
    if {$runSec>150} {
      return -1
    }
    Send $com "\r" "login:" 2
    #RLSerial::Waitfor $com buffer stam 2
    puts "$runSec <$buffer>" ; update
    
    if {[string match {*login:*} $buffer]==1} {
      set ret 0
      break
    }
    if {[string match {*user*} $buffer]==1} {
      set ret 0
      break
    }
    if {[string match {*Fixing recursive fault but reboot is needed*} $buffer]==1} {
      if {$alreadyPowerOffOn=="1"} {
        set gaSet(fail) "The DNFV already rebboted after app. download"
        set ret -1
        break
      }
      foreach {b r p d ps} [split $gaSet(dutFam) .] {}
      if {$b=="19V"} {
        set ret [DnfvPower off] 
        if {$ret!=0} {return $ret} 
      }  
      Power all off
      set secStart [clock seconds]
      after 2000
      Power all on
      set alreadyPowerOffOn 1
    }
    
  }
  
  if {$ret!=0} {return $ret}
  
  
  return $ret
}  
# ***************************************************************************
# DnfvBiosDOK
# ***************************************************************************
proc DnfvBiosDOK {} {
  global gaSet buffer
  Status "Change boot priority"
  set com $gaSet(comDut)
  set ret [Send $com "\33" "stam" 10]
  set ret 0
  
  if ![string match {*ME Firmware SKU*} $buffer] {
    return -1
  }
  ## move right 3 times
  Send $com "\33\[C" "Save & Exit" 2; #stam 2
  Send $com "\33\[C" " (SA) Configuration" 2; #stam 2
  Send $com "\33\[C" "CSM parameters" 2
  
  if {[string match {*Option #1 \[SATA*} $buffer]} {
    puts "boot from inside memory, we should change it to DoK"; update
    
    ## move down 4 times
    Send $com "\33\[B" "options." 2
    Send $com "\33\[B" "...\]" 2
    Send $com "\33\[B" stam 2
    Send $com "\33\[B" "BBS Priorities" 2
    
    Send $com "\r" "order" 2
    Send $com "\r" "stam" 2
    
    ## move down
    Send $com "\33\[B" "stam" 2
    
    Send $com "\r" "stam" 4
    Send $com "\33" "CSM parameters" 2
    
    set checkAgain 1
  } else {                        
    puts "boot from Dok" ; update
    set checkAgain 0
  } 
  
  ## move right 2 times
  Send $com "\33\[C" "User Password" 3
  Send $com "\33\[C" "Previous Values" 2
  
  Send $com "\r" "No" 2
  Send $com "\r"  stam 0.1
  
  return $checkAgain
}
# ***************************************************************************
# MacSwIDTest
# ***************************************************************************
proc MacSwIDTest {} {
  global gaSet buffer 
  puts "[MyTime] MacSwIDTest" ; update
  set com $gaSet(comDut)
  
  set gaSet(fail) "DNFV boot fail"
  set secStart [clock seconds]
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set secNow [clock seconds]
    set secUp [expr {$secNow - $secStart}] 
    $gaSet(runTime) configure -text $secUp
    puts "inloop secUp:$secUp" ; update
    update
    if {$secUp>125} {
      return -1  
    }
    if {$gaSet(act)==0} {return -2}
    set ret [Send $com \r "login:" 2]
    #set ret [RLSerial::Waitfor $com buffer "login:" 2]
    #puts "$secUp <$buffer>"
    
    if [string match *:~$* $buffer] {
      set ret 0
    }
    if [string match *rad#* $buffer] {
      set ret 0
    }
    if [string match *user>* $buffer] {
      set ret [Login]
      if {$ret!=0} {return $ret}
      Send $com "configure chassis ve-module remote-terminal\r\r" "stam" 1
      set ret 10
    }
    if [string match *boot\]* $buffer] {
      set ret [Send $com "run\r" "stam" 2]
      set ret [Login]
      if {$ret!=0} {return $ret}
      
      ## do not take Login time and start the counter from now
      set secStart [clock seconds]
      Send $com "configure chassis ve-module remote-terminal\r\r" "stam" 2
      set ret 11
    }
    puts "inloop secUp:$secUp ret:$ret\n" ; update
    if {$ret=="0"} {break}
  }
  puts "out of loop secUp:$secUp ret:$ret\n" ; update
  
  if [string match *login:* $buffer] {
    set gaSet(fail) "Enter to DNFV fail"
    set ret [Send $com "rad\r" "Password:"]
    if {$ret!=0} {return $ret}
    set ret [Send $com "rad123\r" ":~\$"]
    if {$ret!=0} {return $ret}
  }
  set ret [Send $com "ifconfig\r" ":~\$" 11]
  if {$ret!=0} {
    puts "ifconfig ret!=0 1"; update
    if ![string match *rad#* $buffer] {
      puts "ifconfig ret!=0 2"; update
      set ret -1
      return $ret
    }
  }
  
  if ![info exists gaSet(dnfvMac1)] {
    set gaSet(dnfvMac1) rad
    set mac1 $gaSet(dnfvMac1) 
  } else {
    #set mac1 [string tolower [join [SplitString2Paires  $gaSet(dnfvMac1)] :]]
    set mac1 [string tolower $gaSet(dnfvMac1)]  
  } 
  if ![info exists gaSet(dnfvMac2)] {
    set gaSet(dnfvMac2) rad
    set mac2 $gaSet(dnfvMac2) 
  } else {
    #set mac2 [string tolower [join [SplitString2Paires  $gaSet(dnfvMac2)] :]]
    set mac2 [string tolower $gaSet(dnfvMac2)]  
  }  
    
  set ret [regexp {\sp4p1\s+Link encap:Ethernet\s+HWaddr\s+([0-9a-f\:]+)} $buffer - val]
  if {$ret==0} {
    set gaSet(fail) "Get p4p1 fail"
    return -1
  }
  set val 0x[join [split $val :] ""]
  set radMin1 0x0020d2500000
  set radMax1 0x0020d2ffffff
  set radMin2 0x1806F5000000
  set radMax2 0x1806F5FFFFFF
  if {$mac1 =="rad"} {
    if {($val<$radMin1 || $val>$radMax1) && ($val<$radMin2 || $val>$radMax2)} {
      set gaSet(fail) "MAC at P4P1 is $val. Should be between $radMin1 and $radMax1 or $radMin2 and $radMax2"
      return -1  
    }
  } else {
    set mac1 0x$mac1
    if {$mac1 != $val} {
      set gaSet(fail) "MAC at P4P1 is <$val>. Should be <$mac1>"
      return -1  
    }
  }
  set ma [string toupper [string range $val 2 end]]
  set pair $::pair
  set gaSet(dnfvMac.$pair.P4P1) $ma
  set gaSet($pair.mac1) $ma
  puts "MAC at P4P1 is $ma"
#   AddToLog "MAC at P4P1 is $ma"
  AddToPairLog $gaSet(pair) "MAC at P4P1 is $ma"
  
  set ret [regexp {\sp4p2\s+Link encap:Ethernet\s+HWaddr\s+([0-9a-f\:]+)} $buffer - val]
  if {$ret==0} {
    set gaSet(fail) "Get p4p2 fail"
    return -1
  }
  set val 0x[join [split $val :] ""]
  if {$mac2=="rad"} {
    if {($val<$radMin1 || $val>$radMax1) && ($val<$radMin2 || $val>$radMax2)} {
      set gaSet(fail) "MAC at P4P2 is $val. Should be between $radMin1 and $radMax1 or $radMin2 and $radMax2"
      return -1  
    }
  } else {
    set mac2 0x$mac2
    if {$mac2 != $val} {
      set gaSet(fail) "MAC at P4P2 is <$val>. Should be <$mac2>"
      return -1  
    }
  }
  set ma [string toupper [string range $val 2 end]]
  set gaSet(dnfvMac.$pair.P4P2) $ma
  puts "MAC at P4P2 is $ma"
#   AddToLog "MAC at P4P2 is $ma"
  AddToPairLog $gaSet(pair) "MAC at P4P2 is $ma"
  
  set ret [Send $com "dnfv-ver\r" :~$]
  set res [regexp {dnfv-([\d\.]+)} $buffer - val]
  if {$ret!=0 || $res==0} {
    set gaSet(fail) "Read DNFV ver fail"
    return -1
  }
  if {$gaSet(dnfvVer) != $val} {}
  foreach {a b c d e f} [split $gaSet(dbrSW) \(\).] {}
  if {[string match *(* $gaSet(dbrSW)]} {
    ## don't take ( and ) from 1.1.0(0.016)
    append dbrSW $a.$b.$c.$e
  } else {
    ## take it as is from 1.2.0.024
    set dbrSW $gaSet(dbrSW)
  } 
  puts "gaSet(dbrSW):<$gaSet(dbrSW)> dbrSW:<$dbrSW> val:<$val>"; update
  if {$dbrSW != $val} {
    set gaSet(fail) "The DNFV ver is $val. Should be $gaSet(dbrSW)"
    return -1  
  }
    
  return 0 
}
# ***************************************************************************
# ForceMode
# ***************************************************************************
proc ForceMode {b mode ports} {
  global gaSet buffer
  Status "Force Mode $mode $ports"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
  #Send $com "exit all\r" stam 0.25 
  #Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Activation debug test fail"
  set ret [Send $com "debug test\r" test]
  if {$ret!=0} {return $ret}
  
  ## 13/07/2016 13:42:51 6 -> 8
  for {set port 1} {$port <= $ports} {incr port} {
    set gaSet(fail) "Force port $port to mode \'$mode\' fail"
    set ret [Send $com "forced-combo-mode $port $mode\r" "test"]
    if {$ret!=0} {return $ret}
    if {[string match {*cli error*} $buffer]==1} {
      return -1
    }
    if {$gaSet(act)=="0"} {return "-2"}
  }
  return $ret
}
# ***************************************************************************
# ReadEthPortStatus
# ***************************************************************************
proc ReadEthPortStatus {port} {
  global gaSet buffer bu
#   Status "Read EthPort Status of $port"
#   set ret [Login]
#   if {$ret!=0} {
#     set ret [Login]
#     if {$ret!=0} {return $ret}
#   }
  Status "Read EthPort Status of $port"
  set gaSet(fail) "Show status of port $port fail"
  set com $gaSet(comDut) 
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "config port ethernet $port\r" ($port)]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show status\r" ($port)]
  set bu $buffer
  if {$ret!=0} {
    after 2000
    set ret [Send $com "\r" ($port)]
    if {$ret!=0} {return $ret}   
    append bu $buffer
  }
  puts "ReadEthPortStatus bu:<$bu>"
  set res [regexp {([\w\d]+) Active} $bu - val]
  if {$res==0} {return -1}
  puts "ReadEthPortStatus val:<$val>"
  return $val
}
# ***************************************************************************
# DnfvCross
# ***************************************************************************
proc DnfvCross {mode} {
  global gaSet buffer
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="Xe"} {
    return 0
  }
  set com $gaSet(comDut)
  set ret [Login]
  set txt "Configure Dnfv-br-Cross to \'$mode\'" 
  set gaSet(fail) "$txt fail"
  if {$ret!=0} {return $ret}
  Status $txt
  Send $com "exit all\r" stam 0.5
  
  set ret [Send $com "configure chassis ve-module remote-terminal\r" "stam" 2]
  set ret [Send $com "\r" "login" 2] 
  #if {$ret!=0} {}
    for {set lo 1} {$lo<=8} {incr lo} {
      if {$gaSet(act)==0} {return -2}
      set ret [Send $com "\r" "$" 0.5]
      if {$ret==0} {break} 
      if {[string match {*login:*} $buffer]} {
        set ret 0; break
      }
      after 2000
    }
  #{}
  if {$ret!=0} {return $ret}
  if {[string match {*login:*} $buffer]} {
    set ret [Send $com "rad\r" Password:]
    if {$ret!=0} {return $ret}
    set ret [Send $com "rad123\r" :~$]
    if {$ret!=0} {return $ret}
  }  
  
  set ret [Send $com "dnfv-br-cross-off\r" :~$ 2]
  
  if {[string match {*password for rad*} $buffer]} {
    set ret [Send $com "rad123\r" :~$]
    if {$ret!=0} {return $ret}
  }  
  
  set ret [Send $com "dnfv-br-cross-$mode\r" :~$ 2]
  return $ret
}
# ***************************************************************************
# DnfvPower
# ***************************************************************************
proc DnfvPower {mode} {
  global gaSet buffer
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="Xe"} {
    return 0
  }
  set com $gaSet(comDut)
  set ret [Login]
  set txt "Configure Dnfv Power to \'$mode\'" 
  set gaSet(fail) "$txt fail"
  if {$ret!=0} {return $ret}
  Status $txt
  Send $com "exit all\r" stam 0.5
  
  set ret [Send $com "configure chassis ve-module remote-terminal\r" "stam" 2]
  set ret [Send $com "\r" "login" 2] 
  if {$ret!=0} {
    for {set lo 1} {$lo<=8} {incr lo} {
      if {$gaSet(act)==0} {return -2}
      set ret [Send $com "\r" "$" 0.5]
      if {$ret==0} {break} 
      if {[string match {*login:*} $buffer]} {
        set ret 0; break
      }
      after 2000
    }
  }
  if {$ret!=0} {return $ret}
  if {[string match {*login:*} $buffer]} {
    set ret [Send $com "rad\r" Password:]
    if {$ret!=0} {return $ret}
    set ret [Send $com "rad123\r" :~$]
    if {$ret!=0} {return $ret}
  }  
  
  set ret [Send $com "sudo su\r" :~$ 2]
  
  if {[string match {*password for rad*} $buffer]} {
    set ret [Send $com "rad123\r" :~$]
    if {$ret!=0} {
      if {![string match *rad#* $buffer]} {
        set ret -1
        return $ret 
      }
    }  
  }  
  
  set ret [Send $com "power$mode\r" "reboot: Power down" 30]
  if {$ret!=0} {return $ret}
  
  set ret [Send $gaSet(comDut) \x1F\r\r -2I]
  return $ret
}
# ***************************************************************************
# AdminSave
# ***************************************************************************
proc AdminSave {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret [Login]
  if {$ret!=0} {return $ret}
  Status "Admin Save"
  set ret [Send $com "exit all\r" "2I"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "admin save\r" "successfull" 60]
  return $ret
}

# ***************************************************************************
# ShutDown
# ***************************************************************************
proc ShutDown {port state} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret [Login]
  if {$ret!=0} {return $ret}
  set gaSet(fail) "$state of port $port fail"
  Status "ShutDown $port \'$state\'"
  set ret [Send $com "exit all\r" "2I"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure port ethernet $port\r $state" "($port)"]
  if {$ret!=0} {return $ret}
  
  return $ret
}

# ***************************************************************************
# SpeedEthPort
# ***************************************************************************
proc SpeedEthPort {port speed} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret [Login]
  if {$ret!=0} {return $ret}
  set gaSet(fail) "Configureation speed of port $port fail"
  Status "SpeedEthPort $port $speed"
  set ret [Send $com "exit all\r" "2I"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure port ethernet $port\r" "($port)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no auto-negotiation\r" "($port)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "speed-duplex 100-full-duplex rj45\r" "($port)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "auto-negotiation\r" "($port)"]
  if {$ret!=0} {return $ret}
  return $ret
}  
# ***************************************************************************
# ReadCPLD
# ***************************************************************************
proc ReadCPLD {} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Read CPLD"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
#  Send $com "exit all\r" stam 0.25 
#  Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  Status "Read CPLD"
  
  if ![info exists gaSet(cpld)] {
    set gaSet(cpld) ???
  } 
  set gaSet(fail) "Read CPLD fail"  
  set ret [Send $com "debug memory address c0100000 read char length 1\r" 2I]
  if {$ret!=0} {return $ret}
  set res [regexp {0xC0100000\s+(\d+)\s} $buffer - value]
  if {$res==0} {return -1}
  puts "\nReadCPLD value:<$value> gaSet(cpld):<$gaSet(cpld)>\n"; update
  if {$value!=$gaSet(cpld)} {
    set gaSet(fail) "CPLD is \'$value\'. Should be \'$gaSet(cpld)\'"  
    return -1
  }
  #set gaSet(cpld) ""
  return $ret
}

# ***************************************************************************
# DnfvShutdown
# ***************************************************************************
proc DnfvShutdown {mode} {
  global gaSet buffer
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="Xe"} { 
    return 0
  }
  set com $gaSet(comDut)
  set ret [Login]
  set txt "Configure DNFV to \'$mode\'" 
  set gaSet(fail) "$txt fail"
  if {$ret!=0} {return $ret}
  Status $txt
  Send $com "exit all\r" stam 0.5
  
  set ret [Send $com "configure cn $mode\r" "2I"]
  if {$ret!=0} {return $ret}
  
  if {$mode=="no shutdown"} {
    set ret [Wait "Wait for DNFV up" 40 white] ; # was 20   18/02/2018 09:40:41
    if {$ret!=0} {return $ret}
    set ret [DnfvBooting $com]
    if {$ret!=0} {return $ret}
  }
  return $ret
}
  
# ***************************************************************************
# DnfvBooting
# ***************************************************************************
proc DnfvBooting {com} {
  global gaSet  buffer
  puts "DnfvBooting $com"
  Status "Wait for DNFV booting"
  set ret [Send $com "configure chassis ve-module remote-terminal\r\r\r\r" "login:" 2]
  if {[string match {*etx2i-x86*} $buffer]==1} {
    return 0
  }
  set secStart [clock seconds]
  set ret -1
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set nowSec [clock seconds]
    set runSec [expr {$nowSec - $secStart}]
    $gaSet(runTime) configure -text $runSec
    update
    if {$runSec>220} {
      set ret -1
      break
    }
    RLSerial::Waitfor $com buffer stam 2
    puts "db $runSec <$buffer>" ; update
    if {[string match {*login:*} $buffer]==1 || [string match {*Start over*} $buffer]==1} {
      set ret 0
      break
    }
  }
  return $ret
}
# ***************************************************************************
# FansTemperatureSet
# ***************************************************************************
proc FansTemperatureSet {} {
  global gaSet buffer
  Status "FansTemperatureSet"
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set com $gaSet(comDut)
#   Send $com "exit all\r" stam 0.25 
#   Send $com "logon\r" stam 0.25 
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  Status "Set thermostat"    
  
  set gaSet(fail) "Write to thermostat fail"
  set ret [Send $com "debug thermostat\r" thermostat]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point upper 30\r" thermostat]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point lower 20\r" thermostat]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set-point upper 30\r" thermostat]
  if {$ret!=0} {return $ret}
  
  
  return $ret
}  

# ***************************************************************************
# LogonDebug
# ***************************************************************************
proc LogonDebug {com} {
  global gaSet buffer
  Send $com "exit all\r" stam 0.25 
  Send $com "logon debug\r" stam 0.25 
  Status "logon debug"
  if {[string match {*command not recognized*} $buffer]==0} {
#     set ret [Send $com "logon debug\r" password]
#     if {$ret!=0} {return $ret}
    regexp {Key code:\s+(\d+)\s} $buffer - kc
    catch {exec $::RadAppsPath/atedecryptor.exe $kc pass} password
    set ret [Send $com "$password\r" ETX-2I 1]
    if {$ret!=0} {return $ret}
  } else {
    set ret 0
  }
  return $ret  
}
# ***************************************************************************
# Boot_Download
# ***************************************************************************
proc Boot_Download {} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Empty unit prompt"
  Send $com "\r\r" "=>" 2
  set ret [Send $com "\r\r" "=>" 2]
  if {$ret!=0} {
    # no:
    puts "Skip Boot Download" ; update
    set ret 0
  } else {
    # yes:   
    Status "Setup in progress ..."
    
    #dec to Hex
    set x [format %.2x $::pair]
    
    # Config Setup:
    Send $com "env set ethaddr 00:20:01:02:03:$x\r" "=>"
    Send $com "env set netmask 255.255.255.0\r" "=>"
    Send $com "env set gatewayip 10.10.10.10\r" "=>"
    Send $com "env set ipaddr 10.10.10.1[set ::pair]\r" "=>"
    Send $com "env set serverip 10.10.10.10\r" "=>"
    
    # Download Comment: download command is: run download_vxboot
    # the download file name should be always: vxboot.bin
    # else it will not work !
    if [file exists c:/download/temp/vxboot.bin] {
      catch {file delete -force c:/download/temp/vxboot.bin}
    }
    if {[file exists $gaSet(BootCF)]!=1} {
      set gaSet(fail) "The BOOT file ($gaSet(BootCF)) doesn't exist"
      return -1
    }
    catch {file copy -force $gaSet(BootCF) c:/download/temp}              
    #regsub -all {\.[\w]*} $gaSet(BootCF) "" boot_file
    
    
        
    # Download:   
    Send $com "run download_vxboot\r" stam 1
    set ret [Wait "Download Boot in progress ..." 10]
    if {$ret!=0} {return $ret}
    
    catch {file delete -force c:/download/temp/vxboot.bin}
    
    
    Send $com "\r\r" "=>" 1
    Send $com "\r\r" "=>" 3
    
    set ret [regexp {Error} $buffer]
    if {$ret==1} {
      set gaSet(fail) "Boot download fail" 
      return -1
    }  
    
    Status "Reset the unit ..."
    Send $com "reset\r" "stam" 1
    set ret [Wait "Wait for Reboot ..." 40]
    if {$ret!=0} {return $ret}
    
  }      
  return $ret
}
# ***************************************************************************
# FormatFlashAfterBootDnl
# ***************************************************************************
proc FormatFlashAfterBootDnl {} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Format Flash after Boot Download"
  Send $com "\r\r" "Are you sure(y/n)?" 2
  set ret [Send $com "\r\r" "Are you sure(y/n)?" 2]
  if {$ret!=0} {
    puts "Skip Flash format" ; update
    set ret 0
  } else {
    Send $com "y\r" "\[boot\]:"
    puts "Format in progress ..." ; update
    set ret [MyWaitFor $com "boot]:" 5 900]
  }
  return $ret
}
# ***************************************************************************
# SetSWDownload
# ***************************************************************************
proc SetSWDownload {} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Set SW Download"
  
  set ret [EntryBootMenu]
  if {$ret!=0} {return $ret}
  
  set ret [DeleteBootFiles]
  if {$ret!=0} {return $ret}
  
  if {[file exists $gaSet(SWCF)]!=1} {
    set gaSet(fail) "The SW file ($gaSet(SWCF)) doesn't exist"
    return -1
  }
     
  ## C:/download/SW/6.0.1_0.32/etxa_6.0.1(0.32)_sw-pack_2iB_10x1G_sr.bin -->> \
  ## etxa_6.0.1(0.32)_sw-pack_2iB_10x1G_sr.bin
  set tail [file tail $gaSet(SWCF)]
  set rootTail [file rootname $tail]
  if [file exists c:/download/$tail] {
    catch {file delete -force c:/download/temp/$tail}
    after 1000
  }
    
  file copy -force $gaSet(SWCF) c:/download/temp 
  
  #gaInfo(TftpIp.$::ID) = 10.10.8.1 (device IP)
  #gaInfo(PcIp) = "10.10.10.254" (gateway IP/server IP)
  #gaInfo(mask) = "255.255.248.0"  (device mask)  
  #gaSet(Apl) = C:/Apl/4.01.10sw-pack_203n.bin

  
  # Config Setup:
  Send $com "\r\r" "\[boot\]:"
  set ret [Send $com "\r\r" "\[boot\]:"]  
  if {$ret!=0} {
    set gaSet(fail) "Boot Setup fail"
    return -1
  }
  Send $com "c\r" "file name" 
  Send $com "$tail\r" "device IP"
  #Send $com "c\r" "device IP"
  if {$gaSet(pair)==5} {
    Send $com "10.10.10.1[set ::pair]\r" "device mask"
  } else {
    Send $com "10.10.10.1[set gaSet(pair)]\r" "device mask"
  }
  Send $com "255.255.255.0\r" "server IP"
  Send $com "10.10.10.10\r" "gateway IP"
  Send $com "10.10.10.10\r" "user"
  Send $com "\r" "(pw)" ;# vxworks

  # device name: 8313
  set ret [Send $com "\r" "quick autoboot"]  
  if {$ret!=0} {  
    Send $com "\r" "quick autoboot"
  } 

  Send $com "n\r" "protocol" 
  #Send $com "tftp\12" "baud rate" ;# 9600
  Send $com "ftp\r" "baud rate" ;# 9600
  Send $com "\r" "\[boot\]:"
  
  # Reboot:
  Status "Reset the unit ..."
  Send $com "reset\r" "y/n"
  Send $com "y\r" "\[boot\]:" 10
                                                               
  set i 1
  set ret [Send $com "\r" "\[boot\]:" 2]  
  while {($ret!=0)&&($i<=4)} {
    incr i
    set ret [Send $com "\r" "\[boot\]:" 2]  
  }
  if {$ret!=0} {
    set gaSet(fail) "Boot Setup fail."
    return -1 
  }  
  
  return $ret  
}
# ***************************************************************************
# DeleteBootFiles
# ***************************************************************************
proc DeleteBootFiles {} {
  global  gaSet buffer
  set com $gaSet(comDut)
  
  Status "Delete Boot Files"
  Send $com "dir\r" "\[boot\]:"
  set ret0 [regexp -all {No files were found} $buffer]
  set ret1 [regexp -all {sw-pack-1} $buffer]
  set ret2 [regexp -all {sw-pack-2} $buffer]
  set ret3 [regexp -all {sw-pack-3} $buffer]
  set ret4 [regexp -all {sw-pack-4} $buffer]
  set ret5 [regexp -all {factory-default-config} $buffer]
  set ret6 [regexp -all {user-default-config} $buffer]
  set ret7 [regexp {Active SW-pack is:\s*(\d+)} $buffer var ActSw]
  set ret8 [regexp -all {startup-config} $buffer]
  
  
  if {$ret7==1} {set ActSw [string trim $ActSw]}
  
  # No files were found:
  if {$ret0!=0} {
    puts "No files were found to delete" ; update
    return 0
  }
  
  foreach SwPack "1 2 3 4" {
    # Del sw-pack-X:
    if {[set ret$SwPack]!=0} {
      if {([info exist ActSw]== 1) && ($ActSw==$SwPack)} {
        # exist:  (Active SW-pack is: 1)
        Send $com "delete sw-pack-[set SwPack]\r" ".?"
        set res [Send $com "y\r" "deleted successfully" 20]
        if {$res!=0} {
          set gaSet(fail) "sw-pack-[set SwPack] delete fail"
          return -1      
        }      
      } else {
        # not exist: ("Active SW-pack isn't: X"   or  "No active SW-pac")
        set res [Send $com "delete sw-pack-[set SwPack]\r" "deleted successfully" 20]
        if {$res!=0} {
          set gaSet(fail) "sw-pack-[set SwPack] delete fail"
          return -1      
        }       
      }
      puts "sw-pack-[set SwPack] Delete" ; update
    } else {
      puts "sw-pack-[set SwPack] not found" ; update
    }
  }

  # factory-default-config:
  if {$ret5!=0} {
    set res [Send $com "delete factory-default-config\r" "deleted successfully" 20]
    if {$res!=0} {
      set gaSet(fail) "fac-def-config delete fail"
      return -1      
    } 
    puts "factory-default-config Delete" ; update      
  } else {
    puts "factory-default-config not found" ; update
  }
  
  # user-default-config:
  if {$ret6!=0} {
    set res [Send $com "delete user-default-config\12" "deleted successfully" 20]
    if {$res!=0} {
      set gaSet(fail) "Use-def-config delete fail"
      return -1      
    } 
    puts "user-default-config Delete" ; update      
  } else {
    puts "user-default-config not found" ; update
  }
  
  # startup-config:
  if {$ret8!=0} {
    set res [Send $com "delete startup-config\12" "deleted successfully" 20]
    if {$res!=0} {
      set gaSet(fail) "Use-str-config delete fail
      return -1      
    } 
    puts "startup-config Delete" ; update      
  } else {
    puts "startup-config not found" ; update
  }  
    
  return 0
}
# ***************************************************************************
# SoftwareDownloadTest
# ***************************************************************************
proc SoftwareDownloadTest {} {
  global gaSet buffer 
  set com $gaSet(comDut)
  
  set tail [file tail $gaSet(SWCF)]
  set rootTail [file rootname $tail]
  # Download:   
  Status "Wait for download / writing to flash .."
  set gaSet(fail) "Application download fail"
  Send $com "download 1,[set tail]\r" "stam" 3
  if {[string match {*Are you sure(y/n)?*} $buffer]==1} {
    Send $com "y" "stam" 2
  }
  
  if {[string match {*Error*} $buffer]==1} {
    return -1
  }
   
  set ret [MyWaitFor $com "boot" 5 1200]
  if {$ret!=0} {return $ret}
 
  Status "Wait for set active 1 .."
  set ret [Send $com "set-active 1\r" "SW set active 1 completed successfully" 60] 
  if {$ret!=0} {
    set gaSet(fail) "Activate SW Pack1 fail"
    return -1
  }
  
  Status "Wait for loading start .."
  set ret [Send $com "run\r" "Loading" 60]
  return $ret
} 

# ***************************************************************************
# ClearLog
# ***************************************************************************
proc ClearLog {} {
  global gaSet
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
  }
  if {$ret==0} {
    set gaSet(fail) "Clear Log fail"
    set com $gaSet(comDut)
    Send $com "exit all\r" stam 0.25 
    set ret [Send $com "configure report\r" reporting]
  }
  if {$ret==0} {
    set ret [Send $com "clear-alarm-log all-logs\r" reporting]
  }
  return $ret
}
# ***************************************************************************
# ReadLog
# ***************************************************************************
proc ReadLog {{ev ""}} {
  global gaSet  buffer
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
  }
  if {$ret==0} {
    set gaSet(fail) "Read Log fail"
    set com $gaSet(comDut)
    Send $com "exit all\r" stam 0.25 
    set ret [Send $com "configure report\r" reporting]
  }
  if {$ret==0} {
    Send $com "show log\r" more 1
    set ret -1
    for {set page 1} {$page<=20} {incr page} {
      puts "page $page <$buffer>"
      
      if {$ev==""} {
        set ret 0
      } elseif {$ev!="" && [string match *$ev* $buffer]} {
        set ret 0
        Send $com "\03\r" reporting 1
        Send $com "\r" reporting 1
        break
      }
      if {[string match *reporting* $buffer]} {break}
      Send $com "\r" more 1
    }
  }
  return $ret
}

# ***************************************************************************
#  XeonBiosTest
# ***************************************************************************
proc XeonBiosTest {testMode} {
  global gaSet buffer
  ocu
  puts "[MyTime]  XeonBiosTest $testMode"
  set gaSet(fail) "Enter to BIOS fail"
  set com $gaSet(comDut)
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Enter to BIOS fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 
  
  Status "Enter to BIOS"
  set ret [Send $com "configure chassis ve-module reset-wake\r" 2I]
  if {$ret!=0} {return $ret}
  set ret [Send $com "configure chassis ve-module remote-terminal\r" 2I]
  if {$ret!=0} {return $ret}
  #ccu
  #package require RLCom
  #RLCom::Open $com 9600 8 NONE 1
  for {set i 1} {$i<=30} {incr i} {
    set ret [RLSerial::Waitfor $com buffer "F2" 0.1]
    #set ret [RLCom::Waitfor $com buffer "F2" 0.1]
    puts "i:$i buffer:<$buffer>" ; update
    if {$ret==0} {break}
  }
  if {$ret!="0"} {return $ret}
  #if {$ret!="0"} {RLCom::Close $com ; return $ret}
  
  set ret [Send $com "\33\[OQ" "Version 2.18.1260. Copyright" 10] ; ## send F2
  #Send $com "\x00\x06" stam 10  ; ## "\x00\x06"  "\x00\x3C"  "\x6C"  "\x00\x6C"  "\x00\x0f" "\x0f"   "\x06"
  #RLCom::Send $com "\x06" buffer tttt 10   ; ## "\x6C" "\x00\x6C" "\x00\x3C" "\x3C" "\x00\x06"  "\x06"
  #RLCom::Send $com "\x00\x60" buffer tttt 10 ; # "\x3C\xBC" "\x06\x0C" "\161"
  #RLCom::Send $com "\33\[OQ" buffer tttt 10 ; #
  #puts "buffer:<$buffer>"; update 
  #RLCom::Close $com 
  
  set ret 0
  set res [regexp {EC Version\s+\&\s+Build Da\s+(\w+)\s+\(\d} $buffer ma val]
  if {$res==0} {
    set gaSet(fail) "Read EC Version fail"
    set ret -1
  }
  if {$ret=="0"} {
    puts "XeonBiosTest EC ver val:<$val>"
    set val [string trim $val]
    set gaSet(dnfvEC) [string trim $gaSet(dnfvEC)]
    puts "gaSet(dnfvEC):<$gaSet(dnfvEC)> val:<$val>"
    if {$gaSet(dnfvEC) != $val} {
      set gaSet(fail) "The \'EC Version\' is \'$val\'. Should be \'$gaSet(dnfvEC)\'"          
      set ret -1
    }
  }  
  
  if {$ret=="0"} {
    set res [regexp {BIOS Version\s+\&\s+Build\s+(\w+)\s+\(\d} $buffer ma val]
    if {$res==0} {
      set gaSet(fail) "Read BIOS Version fail"
      set ret -1
    }
  }
  if {$ret=="0"} {
    puts "XeonBiosTest BIOS ver val:<$val>"
    set val [string trim $val]
    set gaSet(dnfvBIOS) [string trim $gaSet(dnfvBIOS)]
    puts "gaSet(dnfvBIOS):<$gaSet(dnfvBIOS)> val:<$val>"
    if {$gaSet(dnfvBIOS) != $val} {
      set gaSet(fail) "The \'BIOS Version\' is \'$val\'. Should be \'$gaSet(dnfvBIOS)\'"          
      set ret -1
    }
  }
  
  if {$ret=="0"} {
    set res [regexp {Total Memory\s+(\d+)\s+MB} $buffer ma val]
    if {$res==0} {
      set gaSet(fail) "Read Total Memory fail"
      set ret -1
    }
  }
  if {$ret=="0"} {
    puts "XeonBiosTest Total Memory val:<$val>"
    foreach {b r p d ps} [split $gaSet(dutFam) .] {}
    puts "b:$b r:$r val:<$val>"
    if {$r != $val} {
      set gaSet(fail) "The \'Total Memory\' is \'$val\'. Should be \'$r\'"
      set ret -1
    }
  }
  
  set res [XeonBootSaveExit]
  puts "XeonBiosTest res of XeonBootSaveExit: <$res>" 
  puts "XeonBiosTest ret: <$ret>" 
  return $ret
}

# ***************************************************************************
# XeonBootSaveExit
# ***************************************************************************
proc XeonBootSaveExit {} {
  global gaSet buffer
  set com $gaSet(comDut)
  set ret [Send $com "\33\[OS" stam 1] ; ## send F4
  set ret [Send $com "\r" "executed automatically" 20] ; ## send F4
  return $ret
}

# ***************************************************************************
# XeonSoftwareDownloadTest
# ***************************************************************************
proc XeonSoftwareDownloadTest {} {
  global gaSet buffer 
  set gaSet(act) 1
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Enter to DNFV fail"
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 0.25 

  set ret [XeonBooting]
  if {$ret=="-2"} {return $ret}  
  
  if {$ret==0} {
    Send $com "\33\[B" stam 1 ; # move down
    Send $com "\33\[B" stam 1 ; # move down
    Send $com "\33\[B" stam 1 ; # move down
    Send $com "\33\[B" stam 1 ; # move down
  
    if {$gaSet(act)=="0"} {return "-2"} 
    
    Send $com "\r" stam 0.25 
    
    set secStart [clock seconds]
    set ret -1
    set b1 ""
    set b2 ""
    while 1 {
      if {$gaSet(act)==0} {return -2}
      set nowSec [clock seconds]
      set runSec [expr {$nowSec - $secStart}]
      $gaSet(runTime) configure -text $runSec
      update
      if {$runSec>120} {
        set ret -1
        break
      }
      RLSerial::Waitfor $com buffer stam 2
      
      set b2 $buffer
      append b1 $b2
      set buffer $b1
      puts "XeonBooting $runSec <$buffer>" ; update
      if {[string match {*Choose the target disk*} $buffer]==1} {
        set ret 0
        break
      }
      set b1 $b2        
    }
  }
  
  if {$ret==0} {
    after 1000
    Send $com "\r" stam 0.25 
    Status "Wait for DNFV Software Download 1"
    set secStart [clock seconds]
    set ret -1
    set b1 ""
    set b2 ""
    while 1 {
      if {$gaSet(act)==0} {return -2}
      set nowSec [clock seconds]
      set runSec [expr {$nowSec - $secStart}]
      $gaSet(runTime) configure -text $runSec
      update
      if {$runSec>700} {
        set ret -1
        break
      }
      RLSerial::Waitfor $com buffer stam 2
      set b2 $buffer
      append b1 $b2
      set buffer $b1
      puts "XeonBooting $runSec <$buffer>" ; update
      if {[string match {*to continue*} $buffer]==1} {
        set ret 0
        break
      }
      set b1 $b2 
    }
  }
  
  if {$ret==0} {
    after 1000
    Send $com "\r" stam 0.25 
    Status "Wait for DNFV Software Download 2"
    set secStart [clock seconds]
    set ret -1
    set b1 ""
    set b2 ""
    while 1 {
      if {$gaSet(act)==0} {return -2}
      set nowSec [clock seconds]
      set runSec [expr {$nowSec - $secStart}]
      $gaSet(runTime) configure -text $runSec
      update
      if {$runSec>700} {
        set ret -1
        break
      }
      RLSerial::Waitfor $com buffer stam 2
      set b2 $buffer
      append b1 $b2
      set buffer $b1
      puts "XeonBooting $runSec <$buffer>" ; update
      if {[string match {*Start over*} $buffer]==1} {
        set ret 0
        break
      }
      set b1 $b2 
    }
  }
  
  if {$ret==0} {
    Send $com "\33\[A" stam 1 ; # move up
    ## we are on reboot line
    RLSound::Play information
    set txt "Remove the DiskOnKey"
    set res [DialogBox -type "OK Cancel" -icon /images/question \
        -title "DiskOnKey" -message $txt]
    update
    if {$res=="Cancel"} {
      return -2
    }
    
    Send $com "\r" stam 1
    Status "Wait for DNFV Up"
    set secStart [clock seconds]
    set ret -1
    set b1 ""
    set b2 ""
    while 1 {
      if {$gaSet(act)==0} {return -2}
      set nowSec [clock seconds]
      set runSec [expr {$nowSec - $secStart}]
      $gaSet(runTime) configure -text $runSec
      update
      if {$runSec>770} {
        set ret -1
        break
      }
      RLSerial::Waitfor $com buffer stam 2
      set b2 $buffer
      append b1 $b2
      set buffer $b1
      puts "XeonBooting $runSec <$buffer>" ; update
      if {[string match {*rad login:*} $buffer]==1} {
        set ret 0
        break
      }
      set b1 $b2 
    }
    
  }

  return $ret
}
# ***************************************************************************
# XeonBooting
# ***************************************************************************
proc XeonBooting {} {
  global gaSet  buffer
  set com $gaSet(comDut)
  puts "[MyTime] XeonBooting"; update
  Status "Wait for DNFV booting"
  set ret [Send $com "configure chassis ve-module remote-terminal\r\r\r\r" "login:" 2]
  if {[string match {*rad login*} $buffer]==1} {
    return 0
  }
  if {[string match {*syncope*} $buffer]==1} {
    return 0
  }
  set secStart [clock seconds]
  set ret -1
  set b1 ""
  set b2 ""
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set nowSec [clock seconds]
    set runSec [expr {$nowSec - $secStart}]
    $gaSet(runTime) configure -text $runSec
    update
    if {$runSec>220} {
      set ret -1
      break
    }
    RLSerial::Waitfor $com buffer stam 2
    set b2 $buffer
    append b1 $b2
    set buffer $b1
    puts "XeonBooting $runSec <$buffer>" ; update
    if {[string match {*if it's available*} $buffer]==1} {
      set ret 0
      break
    }
    if {[string match {*rad login*} $buffer]==1} {
      set ret 0
      break
    }
    if {[string match {*syncope*} $buffer]==1} {
      set ret 0
      break
    }
    set b1 $b2
  }
  return $ret
}

# ***************************************************************************
# XeonMacSwIDTest
# ***************************************************************************
proc XeonMacSwIDTest {} {
  global gaSet  buffer
  puts "[MyTime] XeonMacSwIDTest" ; update
  set com $gaSet(comDut)
  
  set secStart [clock seconds]
  while 1 {
    if {$gaSet(act)==0} {return -2}
    set secNow [clock seconds]
    set secUp [expr {$secNow - $secStart}] 
    $gaSet(runTime) configure -text $secUp
    puts "inloop secUp:$secUp" ; update
    update
    if {$secUp>125} {
      return -1  
    }
    if {$gaSet(act)==0} {return -2}
    set ret [Send $com \r "rad login:" 2]
    #set ret [RLSerial::Waitfor $com buffer "login:" 2]
    #puts "$secUp <$buffer>"
    
    if [string match *home/syncope* $buffer] {
      set ret 0
    }
    if [string match *:~$* $buffer] {
      set ret 0
    }
    if [string match {*rad login*} $buffer] {
      set ret 0
    }
    if [string match {*-2I*} $buffer] {
      set ret 0
    }
    if [string match *user>* $buffer] {
      set ret [Login]
      if {$ret!=0} {return $ret}
      Send $com "configure chassis ve-module remote-terminal\r\r" "stam" 1
      set ret 10
    }
    if [string match *boot\]* $buffer] {
      set ret [Send $com "run\r" "stam" 2]
      set ret [Login]
      if {$ret!=0} {return $ret}
      
      ## do not take Login time and start the counter from now
      set secStart [clock seconds]
      Send $com "configure chassis ve-module remote-terminal\r\r" "stam" 2
      set ret 11
    }
    puts "inloop secUp:$secUp ret:$ret\n" ; update
    if {$ret=="0"} {break}
  }
  puts "out of loop secUp:$secUp ret:$ret\n" ; update
  
  set ret [XeonLogin]
  if {$ret!=0} {return $ret}
   
  set ret [Send $com "ifconfig -a\r" "home/syncope" 20]
  if {$ret!=0} {return $ret}
  
  if ![info exists gaSet(dnfvMac1)] {
    set gaSet(dnfvMac1) rad
    set mac1 $gaSet(dnfvMac1) 
  } else {
    #set mac1 [string tolower [join [SplitString2Paires  $gaSet(dnfvMac1)] :]]
    set mac1 [string tolower $gaSet(dnfvMac1)]  
  } 
  if ![info exists gaSet(dnfvMac2)] {
    set gaSet(dnfvMac2) rad
    set mac2 $gaSet(dnfvMac2) 
  } else {
    #set mac2 [string tolower [join [SplitString2Paires  $gaSet(dnfvMac2)] :]]
    set mac2 [string tolower $gaSet(dnfvMac2)]  
  } 
  
  set res [regexp {vpp3(.+)vpp4} $buffer vpp3 val]
  if {$res==0} {
    set gaSet(fail) "Read VPP3 fail"
    return -1
  }
  set res [regexp {ether\s([\w\:]+)\s} $vpp3 ma val]
  set val 0x[join [split $val :] ""]
  set radMin1 0x0020d2500000
  set radMax1 0x0020d2ffffff
  set radMin2 0x1806F5000000
  set radMax2 0x1806F5FFFFFF
  if {$mac1 =="rad"} {
    if {($val<$radMin1 || $val>$radMax1) && ($val<$radMin2 || $val>$radMax2)} {
      set gaSet(fail) "MAC at VPP3 is $val. Should be between $radMin1 and $radMax1 or $radMin2 and $radMax2"
      return -1  
    }
  } else {
    set mac1 0x$mac1
    if {$mac1 != $val} {
      set gaSet(fail) "MAC at VPP3 is <$val>. Should be <$mac1>"
      return -1  
    }
  }
  set ma [string toupper [string range $val 2 end]]
  set pair $::pair
  set gaSet(dnfvMac.$pair.VPP3) $ma
  set gaSet($pair.mac1) $ma
  puts "MAC at VPP3 is $ma"
#   AddToLog "MAC at P4P1 is $ma"
  AddToPairLog $gaSet(pair) "MAC at VPP3 is $ma"
  
  set res [regexp {vpp4(.+)vpp3.2} $buffer vpp4 val]
  if {$res==0} {
    set gaSet(fail) "Read VPP4 fail"
    return -1
  }
  set res [regexp {ether\s([\w\:]+)\s} $vpp4 ma val] 
  set val 0x[join [split $val :] ""]
  if {$mac2=="rad"} {
    if {($val<$radMin1 || $val>$radMax1) && ($val<$radMin2 || $val>$radMax2)} {
      set gaSet(fail) "MAC at VPP4 is $val. Should be between $radMin1 and $radMax1 or $radMin2 and $radMax2"
      return -1  
    }
  } else {
    set mac2 0x$mac2
    if {$mac2 != $val} {
      set gaSet(fail) "MAC at VPP4 is <$val>. Should be <$mac2>"
      return -1  
    }
  }
  set ma [string toupper [string range $val 2 end]]
  set gaSet(dnfvMac.$pair.VPP4) $ma
  puts "MAC at VPP4 is $ma"
#   AddToLog "MAC at P4P2 is $ma"
  AddToPairLog $gaSet(pair) "MAC at VPP4 is $ma"
  

  return $ret
}

# ***************************************************************************
# XeonShortDataSetup
# ***************************************************************************
proc XeonShortDataSetup {} {
  global gaSet buffer
  set com $gaSet(comDut)
  
  set gaSet(fail) "DNFV-XEON boot fail" 
  set ret [XeonBooting] 
  if {$ret!=0} {return $ret}
    
  set ret [XeonLogin]
  if {$ret!=0} {return $ret}
    
  set gaSet(fail) "DNFV-XEON configuration fail" 
  set ret [Send $com "vppctl\r" "vpp\#"]
  if {$ret!=0} {return $ret}
  after 2000
  
  set ret [Send $com "create sub-interfaces GigabitEthernet7/0/0 200\r" "vpp\#"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "create sub-interfaces GigabitEthernet7/0/1 200\r" "vpp\#"]
  if {$ret!=0} {return $ret}
   after 1000
  set ret [Send $com "set interface state GigabitEthernet7/0/1 up\r" "vpp\#"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set interface state GigabitEthernet7/0/0 up\r" "vpp\#"]
  if {$ret!=0} {return $ret}
   after 1000
  set ret [Send $com "set interface state GigabitEthernet7/0/0.200 up\r" "vpp\#"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set interface state GigabitEthernet7/0/1.200 up\r" "vpp\#"]
  if {$ret!=0} {return $ret}
   after 1000
  set ret [Send $com "set interface l2 bridge GigabitEthernet7/0/0.200 1\r" "vpp\#"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "set interface l2 bridge GigabitEthernet7/0/1.200 1\r" "vpp\#"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "q\r" "home/syncope"]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Configuration fail" 
  set ret [Send $com \x1F\r\r -2I]
  if {$ret!=0} {return $ret}
  Send $com "exit all\r" stam 0.25
  set ret [Send $com "config port eth 0/2\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "shutdown\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "functional user\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit all\r" "-2I"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "conf flow\r" "flows"]
  if {$ret!=0} {return $ret}
   set ret [Send $com "classifier-profile \"all\" match-any\r" "(all)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "match all\r" "(all)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier-profile \"v200\" match-any\r" "(v200)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "match vlan 200\r" "(v200)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"1\"\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"all\"\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "policer profile \"Policer1\"\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "vlan-tag push vlan 200 p-bit fixed 0\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port ethernet 0/1\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port int-ethernet 0/8 queue 0 block 0/1\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"2\"\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"v200\"\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "policer profile \"Policer1\"\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "vlan-tag pop vlan\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port int-ethernet 0/8\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port ethernet 0/1 queue 0 block 0/1\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"5\"\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"all\"\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "policer profile \"Policer1\"\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "vlan-tag push vlan 200 p-bit fixed 0\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port ethernet 0/2\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port int-ethernet 0/7 queue 0 block 0/1\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"6\"\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"v200\"\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "policer profile \"Policer1\"\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "vlan-tag pop vlan\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port int-ethernet 0/7\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port ethernet 0/2 queue 0 block 0/1\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "exit all\r" "2I"]
  set ret [Send $com "admin save\r" "successfull" 60]
      
  return $ret
}
# ***************************************************************************
# XeonLongDataSetup
# ***************************************************************************
proc XeonLongDataSetup {} {
  global gaSet buffer
  set com $gaSet(comDut)
  
  Status "Xeon Long Data Setup"
  set ret [Send $com \x1F\r\r -2I 3]
  
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Logon fail"
  set ret [LogonDebug $com]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Configuration fail"
  set ret [Send $com "debug shell\r\r" "->" ]
  set ret [Send $com "\r\r" "->" ]
  if {$ret!=0} {
    set ret [Send $com "debug shell\r\r" "->" ]
    set ret [Send $com "\r\r" "->" ]
    if {$ret!=0} {return $ret}
  }
  
  set ret [Send $com "cmd\r" "vxWorks" ] 
  if {$ret!=0} {return $ret}  
  set ret [Send $com "ifconfig vlan11 down\r" "vxWorks" ] 
  if {$ret!=0} {return $ret} 
  
  set ret [Send $com "exit\r\r" "-2I" 3]
  if {$ret!=0} {
    set ret [Send $com "exit\r\r" "-2I" 3]
    set ret [Send $com "\r\r" "2I" 3 ]
    if {$ret!=0} {return $ret}
  }
  
  set gaSet(fail) "DNFV-XEON boot fail" 
  set ret [XeonBooting] 
  if {$ret!=0} {return $ret}
    
  set ret [XeonLogin]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "DNFV-XEON configuration fail" 
  
  set ret [Send $com "setenforce 0\r" "home/syncope"]
  if {$ret!=0} {return $ret}  
         
  set ret [Send $com "systemctl disable vpp\r" "home/syncope"]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Edit rc.local fail" 
  set ret [Send $com "nano /etc/rc.local\r" "stam" 2]
  set ret [Send $com "\27" "earch" 2] ; # ctrl+w, search
  set ret [Send $com "python\r" "stam" 2]
  ## python /root/vcpe/init_compute/compute_init_file.py
  ##set ret [Send $com "\x23" "stam" 2] ; # #
  if {[string match {*not found*} $buffer]} {
    ## do nothing,  "disable_ipv6 = 0" not found
    set ret [Send $com "\30" home/syncope] ; # Ctrl+x    
  } else {
    set ret [Send $com "\13" "stam" 2] ; # ctrl+k  , delete line
    set ret [Send $com "\30" "Cancel"] ; # Ctrl+x  , exit
    set ret [Send $com "y\r\r" "home/syncope" 3]
  }  
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Edit sysctl.conf fail" 
  set ret [Send $com "sysctl -p\r" "home/syncope" 3]
  if {$ret!=0} {return $ret}
  set ret [Send $com "nano /etc/sysctl.conf\r" stam 2]
  set ret [Send $com "\34" "(to replace)" 2] ; # ctrl+\  , search to replace
  set ret [Send $com "disable_ipv6 = 0\r" "Replace with" 2]
  set ret [Send $com "disable_ipv6 = 1\r" "Cancel" 2]
  if {[string match {*not found*} $buffer]} {
    ## do nothing,  "disable_ipv6 = 0" not found
    set ret [Send $com "\30" home/syncope] ; # Ctrl+x    
  } else {
    set ret [Send $com "a" "stam" 2]
    set ret [Send $com "\27" "earch" 2] ; # ctrl+w, search
    set ret [Send $com "disable_ipv6\r" "stam" 2]
    set ret [Send $com "\30" stam 2] ; # Ctrl+x
    set ret [Send $com "y\r\r" "home/syncope" 3]
  }  
  if {$ret!=0} {return $ret}  
  set ret [Send $com "sysctl -p\r" "home/syncope" 3]
  if {$ret!=0} {return $ret}    
  
  set ret [Send $com "reboot\r" "no running guest"]
  if {$ret!=0} {return $ret}    
  
  set gaSet(fail) "DNFV-XEON boot fail" 
  set ret [XeonBooting] 
  if {$ret!=0} {return $ret}
  
  set ret [XeonLogin]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "DNFV-XEON configuration fail" 
  
  set ret [Send $com "ifconfig eth1 up\r" "home/syncope"]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "ifconfig eth2 up\r" "home/syncope"]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "ethtool -G eth1 rx 4096 tx 4096\r" "home/syncope"]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "ethtool -G eth2 rx 4096 tx 4096\r" "home/syncope"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "brctl addbr br1\r" "home/syncope"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "brctl addif br1 eth1\r" "home/syncope"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "brctl addif br1 eth2\r" "home/syncope"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ifconfig br1 up\r" "home/syncope"]
  if {$ret!=0} {return $ret}  
  
  set gaSet(fail) "Configuration fail" 
  set ret [Send $com \x1F\r\r -2I]
  if {$ret!=0} {return $ret}
  Send $com "exit all\r" stam 0.25
  set ret [Send $com "config port eth 0/2\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "shutdown\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "functional user\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "0/2"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit all\r" "-2I"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "conf flow\r" "flows"]
  if {$ret!=0} {return $ret}
   set ret [Send $com "classifier-profile \"all\" match-any\r" "(all)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "match all\r" "(all)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"1\"\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"all\"\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port ethernet 0/1\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port int-ethernet 0/8 queue 0 block 0/1\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(1)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"2\"\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"all\"\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port int-ethernet 0/8\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port ethernet 0/1 queue 0 block 0/1\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(2)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"5\"\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"all\"\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port ethernet 0/2\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port int-ethernet 0/7 queue 0 block 0/1\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(5)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "flow \"6\"\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "classifier \"all\"\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "ingress-port int-ethernet 0/7\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "egress-port ethernet 0/2 queue 0 block 0/1\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "no shutdown\r" "(6)"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "exit\r" "flows"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "exit all\r" "2I"]
  set ret [Send $com "admin save\r" "successfull" 60]
      
  return $ret
}  
  
# ***************************************************************************
# XeonLogin
# ***************************************************************************
proc XeonLogin {} {
  global gaSet buffer
  set com $gaSet(comDut)  
  puts "[MyTime] XeonLogin"
  set gaSet(fail) "Logon to DNFV-XEON fail"
  Send $com "\r" stam 0.25
  if [string match *home/syncope* $buffer] {
    ## do nothing, you are inside
    set ret 0
  } else {
    set ret [Send $com "\r" "rad login:" 1]
    if {$ret!=0} {return $ret}
    
    set ret [Send $com "syncope\r" "Password:"]
    if {$ret!=0} {return $ret}
    
    set ret [Send $com "rWjpPm2Wgq4e\r" "syncope@rad:"]
    if {$ret!=0} {return $ret}
    
    set ret [Send $com "sudo su\r" "for syncope:"]
    if {$ret!=0} {return $ret}
    
    set ret [Send $com "rWjpPm2Wgq4e\r" "home/syncope"]
    if {$ret!=0} {return $ret}
  }
  return $ret 
}

# ***************************************************************************
# Connectivity_Test
# ***************************************************************************
proc Connectivity_Test {} {
  global gaSet buffer
  set com $gaSet(comDut)
  
  Status "Connectivity_Test"
  set ret [Send $com \x1F\r\r -2I 3]
  
  set ret [Login]
  if {$ret!=0} {
    #set ret [Login]
    if {$ret!=0} {return $ret}
  }
  
  set ret [XeonBooting]
  set gaSet(fail) "Login fail"
    
#   set ret [XeonLogin]
#   if {$ret!=0} {return $ret}
  
  set ret [Send $com \x1F\r\r -2I 3]
  if {$ret!=0} {
    set ret [Send $com \x1F\r\r -2I 3]
  }
  
  for {set i 1} {$i<=10} {incr i} {
    set ret [ConnectivityState $i]
    puts "ret of ConnectivityState $i: <$ret>"
    if {$ret==0 || $ret=="-2"} {
      break
    }
    Wait "Wait for Connectivity State" 10
  }
  if {$ret!=0} {return $ret}
  
  set ip 192.168.205.22
  Status "Ping to $ip"
  set ret [Send $com "ping $ip\r" "-2I" 20]
  if {$ret!=0} {return $ret}
  
  if [ string match {*5 packets transmitted. 5 packets received, 0% packet loss*} $buffer] {
    set ret 0
  } else {
    set gaSet(fail) "Ping to $ip fail"
    return -1
  }
  
  return $ret
}
# ***************************************************************************
# ConnectivityState
# ***************************************************************************
proc ConnectivityState {i} {
  global gaSet buffer
  set com $gaSet(comDut)
  Status "Connectivity State ($i)"
  set ret [Send $com "show configure virtualization system-detail\r" "-2I"]
  if {$ret!=0} {return $ret}
  set res [regexp {System status[\s\:]+(\w+)\s+Controller} $buffer ma val]
  if {$res==0} {
    set gaSet(fail) "Read Virtualization System-Detail fail"
    return -1
  }
  set val [string trim $val]
  puts "val:<$val>"
  if {$val!="Ready"} {
    set gaSet(fail) "System status is \'$val\'. Should be \'Ready\'"
    return -1
  }
  
  set res [regexp {Controller state[\s\:]+(\w+)\s+} $buffer ma val]
  set val [string trim $val]
  puts "val:<$val>"
  if {$val!="Ready"} {
    set gaSet(fail) "Controller state is \'$val\'. Should be \'Ready\'"
    return -1
  }
  return 0
}
# ***************************************************************************
# ReadEthPortOpStatus
# ***************************************************************************
proc ReadEthPortOpStatus {port} {
  global gaSet buffer bu
  Status "Read EthPort Op Status of $port"
  set gaSet(fail) "Show Op Status of port $port fail"
  set com $gaSet(comDut)
  Login 
  Send $com "exit all\r" stam 0.25 
  set ret [Send $com "config port\r" port]
  if {$ret!=0} {return $ret}
  set ret [Send $com "show summary\r" port]
  set res [string match "*ETH-$port Up Up*" $buffer]
  if {$res==1} {
    return Up
  }
  set res1 [string match "*ETH-$port Up Down*" $buffer]
  set res2 [string match "*ETH-$port Down Down*" $buffer]
  if {$res1==1 || $res2==1} {
    return Down
  }
  retutn -2
}  

