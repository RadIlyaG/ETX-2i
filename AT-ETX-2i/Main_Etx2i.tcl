proc BuildTests {} {
  global gaSet gaGui glTests
  
  if {![info exists gaSet(DutInitName)] || $gaSet(DutInitName)==""} {
    puts "\n[MyTime] BuildTests DutInitName doesn't exists or empty. Return -1\n"
    return -1
  }
  puts "\n[MyTime] BuildTests DutInitName:$gaSet(DutInitName)\n"
  
  RetriveDutFam 
  ToggleTestMode
    
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b!="DNFV"} {  
  
    ## 29/09/2016 14:35:54
    ## 6.0.1 reads the USB port without a special app
    ## USBportConf  
    
    ## 29/09/2016 14:36:01
    ## since DG mechanism  is located not on the PSs but on the board,
    ## we should check it only one time
    ## DyingGaspTest_2
    set lTestNames [list]
    if {$gaSet(performDownloadSteps)} {
      lappend lTestNames BootDownload SetDownload Pages SoftwareDownload ; # Set_DateTime Test_DateTime
    }
    lappend lTestNames DDR_single SetToDefault PS_ID 
    
    # from 2020.09.17 USB port did not checked
    #lappend USBportTest
    lappend lTestNames FansTemperature DyingGaspConf DyingGaspTest  \
        DataTransmissionConf DataTransmissionUTP DataTransmissionSFP
    if {$p=="P"} {
      lappend lTestNames ExtClk 
    }    
    lappend lTestNames DDR_multi
    if {$d=="D"} {
      lappend lTestNames DryContact 
    }
    lappend lTestNames RtrConf RtrArp RtrData Leds
    if {$b=="19V"} {
       lappend lTestNames DnfvOK
    } 
    lappend lTestNames Mac_BarCode SetToDefaultAll
  } elseif {$b=="DNFV"} {    
    if {$p=="I7"} {
      set lTestNames [list BIOS BurnMAC DnfvSoftwareDownload MacSwID VerifyBIOS\
          DnfvDataTransmissionConf DnfvDataTransmission DnfvMac_BarCode DnfvLed]
    } elseif {$p=="Xe"} {
      if {$gaSet(cbTesterMode)=="FTI"} {
        set lTestNames [list VerifyBIOS BurnMAC DnfvSoftwareDownload MacSwID\
            DnfvDataTransmissionConf DnfvDataTransmission Connectivity DnfvMac_BarCode DnfvLed]
      } else {
        set lTestNames [list DnfvDataTransmissionConf]
      }    
    }    
  }    

  set lTestsAllTests $lTestNames
  ## next lines remove DataTransmissionConf and DataTransmissionTest
  foreach t $lTestNames {
    if ![string match DataTr* $t] {
     lappend lTestsTestsWithoutDataRun $t
    }
  }
    
  set glTests ""
  set gaSet(TestMode) AllTests
  set lTests [set lTests$gaSet(TestMode)]
  
  for {set i 0; set k 1} {$i<[llength $lTests]} {incr i; incr k} {
    lappend glTests "$k..[lindex $lTests $i]"
  }
  
  set gaSet(startFrom) [lindex $glTests 0]
  $gaGui(startFrom) configure -values $glTests
  
}
# ***************************************************************************
# Testing
# ***************************************************************************
proc Testing {} {
  global gaSet glTests

  set startTime [$gaSet(startTime) cget -text]
  set stTestIndx [lsearch $glTests $gaSet(startFrom)]
  set lRunTests [lrange $glTests $stTestIndx end]
  
  if ![file exists c:/logs] {
    file mkdir c:/logs
    after 1000
  }
  set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M"]
  set gaSet(logFile) c:/logs/logFile_[set ti]_$gaSet(pair).txt
#   if {[string match {*Leds*} $gaSet(startFrom)] || [string match {*Mac_BarCode*} $gaSet(startFrom)]} {
#     set ret 0
#   }
  
  set pair 1
  if {$gaSet(act)==0} {return -2}
    
  set ::pair $pair
  puts "\n\n ********* DUT start *********..[MyTime].."
  Status "DUT start"
  set gaSet(curTest) ""
  update
    
#   AddToLog "********* DUT start *********"
  AddToPairLog $gaSet(pair) "********* DUT start *********"
#   if {$gaSet(dutBox)!="DNFV"} {
#     AddToLog "$gaSet(1.barcode1)"
#   }     
  puts "RunTests1 gaSet(startFrom):$gaSet(startFrom)"

  foreach numberedTest $lRunTests {
    set gaSet(curTest) $numberedTest
    puts "\n **** Test $numberedTest start; [MyTime] "
    update
    
    MuxMngIO ioToGenMngToPc
      
    set testName [lindex [split $numberedTest ..] end]
    $gaSet(startTime) configure -text "$startTime ."
#     AddToLog "Test \'$testName\' started"
    AddToPairLog $gaSet(pair) "Test \'$testName\' started"
    set ret [$testName 1]
    if {$ret!=0 && $ret!="-2" && $testName!="Mac_BarCode" && $testName!="ID" && $testName!="Leds"} {
#     set logFileID [open tmpFiles/logFile-$gaSet(pair).txt a+]
#     puts $logFileID "**** Test $numberedTest fail and rechecked. Reason: $gaSet(fail); [MyTime]"
#     close $logFileID
#     puts "\n **** Rerun - Test $numberedTest finish;  ret of $numberedTest is: $ret;  [MyTime]\n"
#     $gaSet(startTime) configure -text "$startTime .."
      
#     set ret [$testName 2]
    }
    
    if {$ret==0} {
      set retTxt "PASS."
    } else {
      set retTxt "FAIL. Reason: $gaSet(fail)"
    }
#     AddToLog "Test \'$testName\' $retTxt"
    AddToPairLog $gaSet(pair) "Test \'$testName\' $retTxt"
       
    puts "\n **** Test $numberedTest finish;  ret of $numberedTest is: $ret;  [MyTime]\n" 
    update
    if {$ret!=0} {
      break
    }
    if {$gaSet(oneTest)==1} {
      set ret 1
      set gaSet(oneTest) 0
      break
    }
  }

  AddToPairLog $gaSet(pair) "WS: $::wastedSecs"
  
  puts "RunTests4 ret:$ret gaSet(startFrom):$gaSet(startFrom)"   
  return $ret
}

# ***************************************************************************
# USBportConf
# ***************************************************************************
proc USBportConf {run} {
  global gaSet
  set ret 0
   ### 13/07/2016 15:06:43 6.0.1 reads the USB port without a special app
  set ret [EntryBootMenu]
  if {$ret=="-1"} {
    set ret [EntryBootMenu]
  }
  if {$ret!=0} {return $ret}
  
  set ret [DownloadUsbPortApp]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# USBportTest
# ***************************************************************************
proc USBportTest {run} {
  global gaSet
  set ret 0
   ### 13/07/2016 15:06:43 6.0.1 reads the USB port without a special app
  
  set ret [CheckUsbPort]
  if {$ret!=0} {return $ret}
  
#   set ret [EntryBootMenu]
#   if {$ret!=0} {return $ret}
#   
#   set ret [DeleteUsbPortApp]
#   if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# FansTemperature
# ***************************************************************************
proc FansTemperature {run} {
  global gaSet
  Power all on
  set ret [FansTemperatureTest]
  return $ret
}





# ***************************************************************************
# PS_ID
# ***************************************************************************
proc PS_ID {run} {
  global gaSet
  Power all on
  set ret [PS_IDTest]
  return $ret
}

# ***************************************************************************
# SK_ID
# ***************************************************************************
proc SK_ID {run} {
  global gaSet
  Power all on
  set ret [SK_IDTest]
  return $ret
}

# ***************************************************************************
# DyingGaspConf
# ***************************************************************************
proc DyingGaspConf {run} {
  global gaSet
  Power all on
  set ret [DyingGaspSetup]
  return $ret
}
# ***************************************************************************
# DyingGaspTest
# ***************************************************************************
proc DyingGaspTest {run} {
  global gaSet  buffer
  for {set dgt 1} {$dgt<=$gaSet(DGTestQty)} {incr dgt} {
    Status "Dying Gasp Test No.$dgt"
    set ret [DyingGaspTest_1 $run]
    puts "\r ret of Dying Gasp Test No.$dgt : <$ret>"
    AddToPairLog $gaSet(pair) "Test \'DyingGaspTest\' $dgt: $ret"
    if {($ret==0 && $gaSet(DGTestLoopBreak)==1) || $ret=="-2"} {
      break
    } 
  }
  if {$ret==0} {
    set ret [FactDefault std]
    if {$ret!=0} {return $ret}    
    MuxMngIO ioToGenMngToPc
  }
  return $ret
}  
# ***************************************************************************
# DyingGaspTest_1
# ***************************************************************************
proc DyingGaspTest_1 {run} {
  global gaSet  buffer
  Power all on
#   set gRelayState red
#   IPRelay-LoopRed
#   SendEmail "ETX-2I" "Manual Test"
#   RLSound::Play information
#   set txt "1. Remove the SFP from I/O 0/1\n\
#   2. Remove the data cable \'0/1\' from the I/O UTP\n\
#   3. Connect cable \'MNG\' to I/O 0/1 UTP"
#   set res [DialogBox -type "OK Cancel" -icon /images/question -title "Dying Gasp Test" -message $txt]
#   update
#   if {$res!="OK"} {
#     return -2
#   } else {
#     set ret 0
#   }
#   
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  MuxMngIO ioToPc
  set ret [ForceMode $b rj45 1]
  if {$ret!=0} {return $ret}
  Wait "Wait for RJ45 mode" 15
  set ret [ReadEthPortStatus 0/1]
  if {$ret=="-1" || $ret=="-2"} {return $ret}
  if {$ret!="RJ45"} {
    set gaSet(fail) "The $ret in port 0/1 is active instead of RJ45"
    return -1
  }
 
  set ret [SpeedEthPort 0/1 100]
  if {$ret!=0} {return $ret}
  
  for {set op 1} {$op <= 5} {incr op} { 
    set ret [ReadEthPortStatus 0/1]
    set res [regexp {Operational Status[\s\:]+(\w+)\s} $buffer m opStat]
    if {$res==0} {
      set gaSet(fail) "Read Op State of eth 0/1 fail"
      return -1
    }
    puts "ret of ReadEthPortStatus $op: <$ret> opStat:<$opStat>"
    if {$opStat=="Up"} {
      break
    }
  }
  if {$opStat=="Down"} {
    set gaSet(fail) "Op State of eth 0/1 is Down"
    return -1
  } 
  
  set ret [Wait "Wait for management" 145]
  if {$ret!=0} {return $ret}
  set ret [DyingGaspPerf 1 2]
  if {$ret!=0} {return $ret}
  
  Power all on
  
## 24/10/2017 11:26:03 performed in DyingGaspTest_loop
#   set ret [FactDefault std]
#   if {$ret!=0} {return $ret}
#   
#   MuxMngIO ioToGenMngToPc

#   set gRelayState red
#   IPRelay-LoopRed
#   SendEmail "ETX-2I" "Manual Test"
#   RLSound::Play information
#   set txt "1. Connect cable \'MNG\' to the \'MNG-ETH\' port\n\
#   2. Connect the data cable \'0/1\' to the I/O UTP\n\
#   3. Insert the SFP into I/O 0/1"
#   set res [DialogBox -type "OK Cancel" -icon /images/question -title "Dying Gasp Test" -message $txt]
#   update
#   if {$res!="OK"} {
#     return -2
#   } else {
#     set ret 0
#   }
  
  return $ret
}
# ***************************************************************************
# DyingGaspTest_2
# ***************************************************************************
proc DyingGaspTest_2 {run} {
  global gaSet gRelayState
  Power all on
  set ret [DyingGaspPerf 2 1]
  if {$ret!=0} {return $ret}
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$ps=="DC"} {
    Power all off
    set gRelayState red
    IPRelay-LoopRed
    SendEmail "ETX-2I" "Manual Test"
    RLSound::Play information
    set txt "Remove the AC PSs and insert DC PSs"
    set res [DialogBox -type "OK Cancel" -icon /images/question -title "Change PS" -message $txt]
    update
    if {$res!="OK"} {
      return -2
    } else {
      set ret 0
    }
    Power all on
    set gRelayState green
    IPRelay-Green
  }
  return $ret
}

# ***************************************************************************
# XFP_ID
# ***************************************************************************
proc XFP_ID {run} {
  global gaSet
  Power all on
  set ret [XFP_ID_Test]
  return $ret
}  

# ***************************************************************************
# SfpUtp_ID
# ***************************************************************************
proc SfpUtp_ID {run} {
  global gaSet
  Power all on
  set ret [SfpUtp_ID_Test]
  return $ret
} 
# ***************************************************************************
# DateTime
# ***************************************************************************
proc DateTime {run} {
  global gaSet
  Power all on
  set ret [DateTime_Test]
  return $ret
} 

# ***************************************************************************
# DataTransmissionConf
# ***************************************************************************
proc DataTransmissionConf {run} {
  global gaSet
  Power all on
     
  #ConfigEtxGen
#   Status "EtxGen::GenConfig"
#   foreach {b r p d ps} [split $gaSet(dutFam) .] {}
#   if {$b=="19V"} {
#     set packRate 50000
#   } else {
#     set packRate 1200000
#   }
#   RLEtxGen::GenConfig $gaSet(idGen1) -updGen all -packRate $packRate
#   after 2000
#   set ret [ShutDown 0/1 "shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   for {set i 1} {$i<=10} {incr i} {
#     set res1 [ReadEthPortOpStatus 0/1]
#     set res2 [ReadEthPortOpStatus 0/2]
#     puts "[MyTime] res1:<$res1> res2:<$res2>"
#     if {$res1=="Down" && $res2=="Down"} {
#       set ret 0
#       break
#     } else {
#       set ret [Wait "Wait for 0/1 & 0/2 down" 10]
#       if {$ret!=0} {return $ret}
#     }
#   }
#   if {$ret!=0} {return $ret}
  puts "[MyTime] RLEtxGen::PortsConfig -admStatus down"; update
  RLEtxGen::PortsConfig $gaSet(idGen1) -updGen all -admStatus down
  after 2000
      
  set ret [DataTransmissionSetup]
  if {$ret!=0} {return $ret}
  
#   after 2000
#   set ret [ShutDown 0/1 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   for {set i 1} {$i<=10} {incr i} {
#     set res1 [ReadEthPortOpStatus 0/1]
#     set res2 [ReadEthPortOpStatus 0/2]
#     puts "[MyTime] res1:<$res1> res2:<$res2>"
#     if {$res1=="Up" && $res2=="Up"} {
#       set ret 0
#       break
#     } else {
#       set ret [Wait "Wait for 0/1 & 0/2 up" 10]
#       if {$ret!=0} {return $ret}
#     }
#   }
  
  return $ret
} 
# ***************************************************************************
# DataTransmissionTest
# ***************************************************************************
proc DataTransmissionUTP {run} {
  global gaSet
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  after 2000
  puts "[MyTime] RLEtxGen::PortsConfig -admStatus down"; update
  RLEtxGen::PortsConfig $gaSet(idGen1) -updGen all -admStatus down
#   set ret [ShutDown 0/1 "shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   for {set i 1} {$i<=10} {incr i} {
#     set res1 [ReadEthPortOpStatus 0/1]
#     if {$res1=="-1" || $res1=="-2"} {return $res1}
#     set res2 [ReadEthPortOpStatus 0/2]
#     if {$res2=="-1" || $res2=="-2"} {return $res2}
#     puts "[MyTime] res1:<$res1> res2:<$res2>"
#     if {$res1=="Down" && $res2=="Down"} {
#       set ret 0
#       break
#     } else {
#       set ret [Wait "Wait for 0/1 & 0/2 down" 10]
#       if {$ret!=0} {return $ret}
#     }
#   }
#   if {$ret!=0} {return $ret}
  
  if {$b!="19"} {}
    set ret [ForceMode $b rj45 8]
    if {$ret!=0} {return $ret}
    Wait "Wait for RJ45 mode" 15
    ## 13/07/2016 13:43:05 1/3 and 1/4 have been added
    if {$b=="19"} {
      if {[string match *19M* $gaSet(DutInitName)]==1} {
        set portsL [list 0/1 0/2 0/3 0/4 1/1 1/2]
      } else {
        set portsL [list 0/1 0/2 0/3 0/4 0/5 0/6 0/7 0/8]
      }
    } elseif {$b=="19V"} {
      set portsL [list 0/1 0/2 0/3 0/4 1/1 1/2]
    } else {
      set portsL [list 0/1 0/2 0/3 0/4 1/1 1/2]
    }
    foreach port $portsL {
      set ret [ReadEthPortStatus $port]
      if {$ret=="-1" || $ret=="-2"} {return $ret}
      if {$ret!="RJ45"} {
        set gaSet(fail) "The $ret in port $port is active instead of RJ45"
        return -1
      }
    }
  #{}
#   set ret [AdminSave]
#   if {$ret!=0} {return $ret}
#   Power all off
#   after 1000
#   Power all on
    
  if {$b=="19V"} {
    set packRate 50000
    set stream 8
  } else {
    set packRate 1200000
    set stream 1
  }  
  InitEtxGen 1 
  Status "EtxGen::GenConfig -packRate $packRate"
  RLEtxGen::GenConfig $gaSet(idGen1) -updGen all -packRate $packRate -stream $stream
  
  if {$b=="19V"} {
    set ret [DnfvCross on] 
    if {$ret!=0} {return $ret}  
  }  
  
#   set ret [ShutDown 0/1 "shutdown"]
#   if {$ret!=0} {return $ret}
#   
#   after 2000
#   
#   set ret [ShutDown 0/1 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   
#   set ret [ShutDown 0/1 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   set ret [ShutDown 0/1 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   for {set i 1} {$i<=10} {incr i} {
#     set res1 [ReadEthPortOpStatus 0/1]
#     set res2 [ReadEthPortOpStatus 0/2]
#     puts "[MyTime] res1:<$res1> res2:<$res2>"
#     if {$res1=="Up" && $res2=="Up"} {
#       set ret 0
#       break
#     } else {
#       set ret [Wait "Wait for 0/1 & 0/2 up" 10]
#       if {$ret!=0} {return $ret}
#     }
#   }
#   if {$ret!=0} {return $ret}
  
  set ret [DataTransmissionTestPerf [list 1 2] $packRate]
  if {$ret==0} {
    DnfvCross off
  }  
  return $ret
}
# ***************************************************************************
# DataTransmissionSFP
# ***************************************************************************
proc DataTransmissionSFP {run} {
  global gaSet gRelayState
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b!="19"} {
#     set ret [ForceMode $b sfp 8]
#     if {$ret!=0} {return $ret}
#     foreach port [list 0/1 0/2 0/3 0/4 1/1 1/2] {
#       set ret [ReadEthPortStatus $port]
#       if {$ret=="-1" || $ret=="-2"} {return $ret}
#       if {$ret!="SFP"} {
#         set gaSet(fail) "The $ret in port $port is active instead of SFP"
#         return -1
#       }
#     }
#     set ret [AdminSave]
#     if {$ret!=0} {return $ret}

    if {$b=="19V"} {
      set ret [DnfvCross off]
      if {$ret!=0} {return $ret}
      set ret [DnfvPower off] 
      if {$ret!=0} {return $ret} 
    }
    
    Power all off
    after 1000
    Power all on 
    set ret [Login]
    if {$ret!=0} {return $ret}
    set ret [Wait "Wait for ETX up" 60]
    if {$ret!=0} {return $ret}
  } elseif {$b=="19"} {
#     set gRelayState red
#     IPRelay-LoopRed
#     set txt "Connect the SFP ports instead of the RJ ports"
#     SendEmail "ETX-2i" $txt
#     RLSound::Play information
#     set res [DialogBox -title "DataTransmission SFP" -icon /images/info\
#         -message $txt -aspect 2000 -type "Ok Cancel"]
#     if {$res=="Cancel"} {return -2}
#     IPRelay-Green
    
    
    #26/04/2017 15:22:59 Power off-on instead of force sfp
#     set ret [ForceMode $b sfp 8]
#     if {$ret!=0} {return $ret}
#     Wait "Wait for SFP mode" 15
#     foreach port [list 0/1 0/2 0/3 0/4 0/5 0/6 0/7 0/8] {
#       set ret [ReadEthPortStatus $port]
#       if {$ret=="-1" || $ret=="-2"} {return $ret}
#       if {$ret!="SFP"} {
#         set gaSet(fail) "The $ret in port $port is active instead of SFP"
#         return -1
#       }
#     }
#     set ret [AdminSave]
#     if {$ret!=0} {return $ret}

    Power all off
    after 1000
    Power all on 
    set ret [Login]
    if {$ret!=0} {return $ret}
    set ret [Wait "Wait for ETX up" 30]
    if {$ret!=0} {return $ret}
    
    if {[string match *19M* $gaSet(DutInitName)]==1} {
      set portsL [list 0/1 0/2 0/3 0/4 1/1 1/2]
    } else {
      set portsL [list 0/1 0/2 0/3 0/4 0/5 0/6 0/7 0/8]
    }
    foreach port $portsL {
      set ret [ReadEthPortStatus $port]
      if {$ret=="-1" || $ret=="-2"} {return $ret}
      if {$ret!="SFP"} {
        set gaSet(fail) "The $ret in port $port is active instead of SFP"
        return -1
      }
    }
  }
  after 2000
  puts "[MyTime] RLEtxGen::PortsConfig -admStatus down"; update
  RLEtxGen::PortsConfig $gaSet(idGen1) -updGen all -admStatus down
#   set ret [ShutDown 0/1 "shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   for {set i 1} {$i<=10} {incr i} {
#     set res1 [ReadEthPortOpStatus 0/1]
#     set res2 [ReadEthPortOpStatus 0/2]
#     puts "[MyTime] res1:<$res1> res2:<$res2>"
#     if {$res1=="Down" && $res2=="Down"} {
#       set ret 0
#       break
#     } else {
#       set ret [Wait "Wait for 0/1 & 0/2 down" 10]
#       if {$ret!=0} {return $ret}
#     }
#   }
#   if {$ret!=0} {return $ret}
  
  if {$b=="19V"} {
    set packRate 50000
    set stream 8
  } else {
    set packRate 1200000
    set stream 1
  }
  InitEtxGen 1 
  Status "EtxGen::GenConfig -packRate $packRate"
  RLEtxGen::GenConfig $gaSet(idGen1) -updGen all -packRate $packRate -stream $stream
  
  if {$b=="19V"} {
    set ret [DnfvCross on] 
    if {$ret!=0} {return $ret}
  }  
  
#   after 2000
#   RLEtxGen::PortsConfig $gaSet(idGen1) -updGen all -admStatus up
#   set ret [ShutDown 0/1 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
#   for {set i 1} {$i<=10} {incr i} {
#     set res1 [ReadEthPortOpStatus 0/1]
#     set res2 [ReadEthPortOpStatus 0/2]
#     puts "[MyTime] res1:<$res1> res2:<$res2>"
#     if {$res1=="Up" && $res2=="Up"} {
#       set ret 0
#       break
#     } else {
#       set ret [Wait "Wait for 0/1 & 0/2 up" 10]
#       if {$ret!=0} {return $ret}
#     }
#   }
#   if {$ret!=0} {return $ret}
  
  set ret [DataTransmissionTestPerf [list 3 4] $packRate]   
  if {$ret==0 && $b=="19V"} {
    set ret [DnfvCross off]
  } 
  return $ret
}
# ***************************************************************************
# DataTransmissionTestPerf
# ***************************************************************************
proc DataTransmissionTestPerf {lGens packRate} {
  global gaSet
  Power all on 
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
#   if {$b=="19V"} {
#     set packRate 50000
#   } else {
#     set packRate 1200000
#   }
  set ret [Wait "Waiting for stabilization" 10 white]
  if {$ret!=0} {return $ret}
  
  Etx204Start
  set ret [Wait "Data is running" 10 white]
  if {$ret!=0} {return $ret}
  set ret [Etx204Check $lGens $packRate]
  if {$ret!=0} {return $ret}
  
  set ret [Wait "Data is running" 120 white]
  if {$ret!=0} {return $ret}
  
  set ret [Etx204Check $lGens $packRate]
  if {$ret!=0} {return $ret}
 
  return $ret
}  
# ***************************************************************************
# ExtClkUnlocked
# ***************************************************************************
proc ExtClkUnlocked {run} {
  global gaSet
  Power all on
  set ret [ExtClkTest Unlocked]
  return $ret
}
# ***************************************************************************
# ExtClkLocked
# ***************************************************************************
proc ExtClkLocked {run} {
  global gaSet
  Power all on
  set ret [ExtClkTest Locked]
  return $ret
}
# ***************************************************************************
# ExtClk
# ***************************************************************************
proc ExtClk {run} {
  global gaSet
  Power all on
  set ret [ExtClkTest Unlocked]
  if {$ret!=0} {return $ret}
  set ret [ExtClkTest Locked]
  return $ret
}
# ***************************************************************************
# Leds
# ***************************************************************************
proc Leds {run} {
  global gaSet gaGui gRelayState
  Status ""
  Power all on
  
  set ret [Login]
  if {$ret!=0} {return $ret}
  set ret [FactDefault std]
  if {$ret!=0} {return $ret}  
    
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$b=="19V"} {
    set ret [Login]
    if {$ret!=0} {return $ret}
    
    foreach {b r p d ps} [split $gaSet(dutFam) .] {}
    if {$p=="I7"} { 
      set ret [Send $gaSet(comDut) "exit all\r" "2I"]
      if {$ret!=0} {return $ret}
      set ret [Send $gaSet(comDut) "configure cn no shutdown\r" "2I"]
      if {$ret!=0} {return $ret} 
    }
    
    RLSound::Play information
    set txt "Verify that the DNFV is working"
    set res [DialogBox -type "OK Fail" -icon /images/question -title "Lock Knob Test" -message $txt]
    update
    if {$res!="OK"} {
      set gaSet(fail) "Lock Knob Test failed"
      return -1
    } else {
      set ret 0
    }
    
    RLSound::Play information
    set txt "Open the lock knob and verify that the DNFV is not working"
    set res [DialogBox -type "OK Fail" -icon /images/question -title "Lock Knob Test" -message $txt]
    update
    if {$res!="OK"} {
      set gaSet(fail) "Lock Knob Test failed"
      return -1
    } else {
      set ret 0
    }
    
    RLSound::Play information
    ## 25/12/2019 13:50:41 Ronen: 19V ie tested with DNFV I7 Reference
    set p I7
    if {$p=="I7"} { 
      set txt "Extract the DNFV module out of the cage\n\
      Wait 5 Sec\n\
      Insert the DNFV module back to cage\n\
      Move the lock knob into lock position and secure it tightly with the lock screw"
    } elseif {$p=="Xe"} {
      set txt "Move the lock knob into lock position and secure it tightly with the lock screw\n\
      After few seconds verify that fans rotate noisy for about 30 seconds and then rotate silently"
    }
    set res [DialogBox -type "OK Fail" -icon /images/question -title "Lock Knob Test" -message $txt]
    update
    if {$res!="OK"} {
      set gaSet(fail) "Lock Knob Test failed"
      return -1
    } else {
      set ret 0
    }
  }  
  if {$p=="I7"} { 
    set ret [Loopback on]
    if {$ret!=0} {return $ret}
  }  
  
  ## 13:24 18/02/2024
  set ret [FansTemperatureSet]
  if {$ret!=0} {return $ret}
  
  
  set ret [Login]
  if {$ret!=0} {return $ret}
  set ret [Send $gaSet(comDut) "exit all\r" "2I"]
  if {$ret!=0} {return $ret} 
  

  ## DyingGasp for pings
  set cf C:/AT-ETX-2i/ConfFiles/Dying\ Gasp.txt
  set cfTxt "Dying Gasp"
  set ret [DownloadConfFile $cf $cfTxt 1]  
  if {$ret!=0} {return $ret}
  
  set gRelayState red
  IPRelay-LoopRed
  SendEmail "ETX-2I" "Manual Test"
  
  catch {set pingId [exec ping.exe 10.10.10.1[set gaSet(pair)] -t &]}
  
  set txt ""
  RLSound::Play information
  set txt1 "Verify that:\n\
  GREEN \'PWR\' led is ON\n\
  RED \'TST/ALM\' led is blinking\n\
  GREEN \'LINK\' led of \'MNG-ETH\' is ON\n\
  ORANGE \'ACT\' led of \'MNG-ETH\' is blinking\n"
  
  set txt2 "On each PS GREEN \'PWR\' led is ON\n"
  
  set txt3 "GREEN \'LINK/ACT\' leds of I/O ports 0/1 and 0/2 are blinking\n\
  GREEN \'LINK/ACT\' leds of rest of ports are ON\n\
  EXT CLK's GREEN \'SD\' led is ON (if exists)"
  
  append txt $txt1
  if {$b!="M"} {
    append txt $txt2
  } 
  append txt $txt3
  
  set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
  update
  
  catch {exec pskill.exe -t $pingId}
  
  if {$res!="OK"} {
    set gaSet(fail) "LED Test failed"
    return -1
  } else {
    set ret 0
  }
  set ret [Loopback off]
  if {$ret!=0} {return $ret} 
    
  if {$b!="M"} {
    foreach ps {2 1} {
      Power $ps off
      #after 10000
      set ret [Wait "Wait for PS-$ps is OFF" 12 white]
      if {$ret!=0} {return $ret}
      set val [ShowPS $ps]
      puts "val:<$val>"
      if {$val=="-1"} {return -1}
      if {$val!="Failed"} {
        set gaSet(fail) "Status of PS-$ps is \"$val\". Expected \"Failed\""
  #       AddToLog $gaSet(fail)
        return -1
      }
      RLSound::Play information
      set txt "Verify on PS-$ps that GREEN led is OFF"
      set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
      update
      if {$res!="OK"} {
        set gaSet(fail) "LED Test failed"
        return -1
      } else {
        set ret 0
      }
      
      RLSound::Play information
      set txt "Remove PS-$ps and verify that led is OFF"
      set res [DialogBox -type "OK Cancel" -icon /images/info -title "LED Test" -message $txt]
      update
      if {$res!="OK"} {
        set gaSet(fail) "PS_ID Test failed"
        return -1
      } else {
        set ret 0
      }
      
      set val [ShowPS $ps]
      puts "val:<$val>"
      if {$val=="-1"} {return -1}
      if {$val!="Not exist"} {
        set gaSet(fail) "Status of PS-$ps is \"$val\". Expected \"Not exist\""
  #       AddToLog $gaSet(fail)
        return -1
      }
      
      RLSound::Play information
      set txt "Assemble PS-$ps"
      set res [DialogBox -type "OK Cancel" -icon /images/info -title "LED Test" -message $txt]
      update
      if {$res!="OK"} {
        set gaSet(fail) "PS_ID Test failed"
        return -1
      } else {
        set ret 0
      }
      Power $ps on
      after 2000
    }
  }
  
  if {$p=="P"} {
    RLSound::Play information
    set txt "Remove the EXT CLK cable and verify the SD led is OFF"
    set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
    update
    if {$res!="OK"} {
      set gaSet(fail) "LED Test failed"
      return -1
    } else {
      set ret 0
    }
  }
 
  set ret [TstAlm off]
  if {$ret!=0} {return $ret} 
  RLSound::Play information
  set txt "Verify the TST/ALM led is OFF"
  set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
  update
  if {$res!="OK"} {
    set gaSet(fail) "LED Test failed"
    return -1
  } else {
    set ret 0
  }
  
  RLSound::Play information
  set txt "Disconnect all cables (except POWER and CONTROL) and optic fibers and verify GREEN leds are OFF"
  set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
  update
  if {$res!="OK"} {
    set gaSet(fail) "LED Test failed"
    return -1
  } else {
    set ret 0
  }
  
  RLSound::Play information
  set txt "Verify FAN is rotating"
  set res [DialogBox -type "OK Fail" -icon /images/question -title "FAN Test" -message $txt]
  update
  if {$res!="OK"} {
    set gaSet(fail) "FAN Test failed"
    return -1
  } else {
    set ret 0
  }
  
  set res [regexp {\.[AD]{1,2}C\.} $gaSet(DutInitName)]
  puts "Leds $gaSet(DutInitName) res:<$res>"
  if {$res==0} {
    # if two PSs - no message
    set ret 0
  } else {    
    Power 2 off
    RLSound::Play information
    set txt "Remove PS-2"
    set res [DialogBox -type "OK Cancel" -icon /images/info -title "LED Test" \
      -message $txt -bg yellow -font {TkDefaultFont 11}]
    update
    
    if {$res!="OK"} {
      set gaSet(fail) "Remove PS-2 fail"
      set ret -1
    } else {
      set ret 0
    }    
  }
  
  return $ret
}
# ***************************************************************************
# DnfvOK
# ***************************************************************************
proc DnfvOK {run} {
  global gaSet buffer
  set com $gaSet(comDut)
  Send $com "exit all\r" stam 1 
  Send $com "\r" stam 1
  set ret [DnfvBooting $com]
  puts "ret of DnfvBooting: $ret"
  if {$ret!=0} {
    set gaSet(fail) "Login to DNFV fail"
    return $ret
  }
  return $ret
}
# ***************************************************************************
# SetToDefault
# ***************************************************************************
proc SetToDefault {run} {
  global gaSet gaGui
  Power all on
  set ret [FactDefault std]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# SetToDefaultAll
# ***************************************************************************
proc SetToDefaultAll {run} {
  global gaSet gaGui
  Power all on
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  
  if {$b=="19V"} {
  #   ##25/09/2017 11:40:33
#  ## no need power off since "cn no shutdown" was not performed yet  
#     set ret [DnfvPower off] 
#     if {$ret!=0} {return $ret} 

  }  
  set ret [FactDefault stda]
  if {$ret!=0} {return $ret}
  
  return $ret
}

# ***************************************************************************
# Mac_BarCode
# ***************************************************************************
proc Mac_BarCode {run} {
  global gaSet  
  set pair $::pair 
  puts "Mac_BarCode \"$pair\" "
  mparray gaSet *mac* ; update
  mparray gaSet *barcode* ; update
  set badL [list]
  set ret -1
  foreach unit {1} {
    if ![info exists gaSet($pair.mac$unit)] {
      set ret [ReadMac]
      if {$ret!=0} {return $ret}
    }  
  } 
  foreach unit {1} {
    if {![info exists gaSet($pair.barcode$unit)] || $gaSet($pair.barcode$unit)=="skipped"} {
      set ret [ReadBarcode]
      if {$ret!=0} {return $ret}
    }  
  }
  #set ret [ReadBarcode [PairsToTest]]
#   set ret [ReadBarcode]
#   if {$ret!=0} {return $ret}
  set ret [RegBC]
      
  return $ret
}
# ***************************************************************************
# DnfvMac_BarCode
# ***************************************************************************
proc DnfvMac_BarCode {run} {
  global gaSet  
  set pair $::pair 
  puts "DnfvMac_BarCode \"$pair\" "
  mparray gaSet *mac* ; update
  mparray gaSet *barcode* ; update
  set badL [list]
  set ret -1
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  
  foreach unit {1} {
    if ![info exists gaSet($pair.mac$unit))] {
      if {$p=="I7"} {
        set ret [MacSwIDTest]
      } elseif {$p=="Xe"} {
        set ret [XeonBooting]
        set gaSet(fail) "Login fail"
        set ret [XeonMacSwIDTest]
      }  
      if {$ret!=0} {return $ret}
    }  
  } 
  foreach unit {1} {
    if ![info exists gaSet($pair.barcode$unit)] {
      set ret [ReadBarcode]
      if {$ret!=0} {return $ret}
    }  
  }
  #set ret [ReadBarcode [PairsToTest]]
#   set ret [ReadBarcode]
#   if {$ret!=0} {return $ret}
  set ret [RegBC]
               
  if {$ret==0} {
    set ret [DnfvPower off] 
    if {$ret!=0} {return $ret} 
  }    
  return $ret
}


# ***************************************************************************
# LoadDefaultConfiguration
# ***************************************************************************
proc LoadDefaultConfiguration {run} {
  global gaSet  
  Power all on
  set ret [LoadDefConf]
  return $ret
}
# ***************************************************************************
# DDR_single
# ***************************************************************************
proc DDR_single {run} {
  global gaSet
  Power all on
  set ret [DdrTest 1]
  return $ret
}
# ***************************************************************************
# DDR_multi
# ***************************************************************************
proc DDR_multi {run} {
  global gaSet
  Power all on
  for {set i 1} {$i<=$gaSet(ddrMultyQty)} {incr i} {
    set ret [DdrTest $i]
    if {$ret!=0} {break}
    Power all off
    after 2000
    Power all on
  }  
  return $ret
}
# ***************************************************************************
# DDR
# ***************************************************************************
proc DDR {run} {
  global gaSet
  Power all on
  set ret [DdrTest 1]
  return $ret
}
# ***************************************************************************
# DryContact
# ***************************************************************************
proc DryContact {run} {
  global gaSet
  Power all on
  set ret [DryContactTest]
  return $ret
}
# ***************************************************************************
# RtrConf
# ***************************************************************************
proc RtrConf {run} {
  global gaSet
  Power all on
  puts "[MyTime] RLEtxGen::PortsConfig -admStatus down"; update
  RLEtxGen::PortsConfig $gaSet(idGen1) -updGen all -admStatus down
  set ret [FactDefault stda]
  if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/1 "shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "shutdown"]
#   if {$ret!=0} {return $ret}
  set ret [RtrSetup]
  if {$ret!=0} {return $ret}
#   after 2000
#   puts "[MyTime] RLEtxGen::PortsConfig -admStatus up"; update
#   RLEtxGen::PortsConfig $gaSet(idGen1) -updGen all -admStatus up
#   set ret [ShutDown 0/1 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   set ret [ShutDown 0/2 "no shutdown"]
#   if {$ret!=0} {return $ret}
#   after 2000
  
  return $ret
} 
# ***************************************************************************
# DataTransmissionSFP
# ***************************************************************************
proc RtrArp {run} {
  global gaSet
  #ConfigEtxGen                   
  Status "EtxGen::GenConfig"
  InitEtxGen 1 
  set id $gaSet(idGen1) 
  RLEtxGen::GenConfig $id -updGen all -packRate 10
  ## -payload should have digits and low case letters!
  RLEtxGen::PacketConfig $id MAC -updGen 3 -SA 000000000001 -DA FFFFFFFFFFFF \
      -payload 0001080006040001000000000001010101010000000000000101010a \
      -ethType 0806 
  RLEtxGen::PacketConfig $id MAC -updGen 4 -SA 000000000002 -DA FFFFFFFFFFFF \
      -payload 0001080006040001000000000002020202010000000000000202020a \
      -ethType 0806  
      
  return [ShowArpTable]   
}
# ***************************************************************************
# RtrData
# ***************************************************************************
proc RtrData {run} {
  global gaSet
  #ConfigEtxGen
  Status "EtxGen::GenConfig"
  InitEtxGen 1 
  set id $gaSet(idGen1) 
  RLEtxGen::GenConfig $id -updGen all -packRate 20000
  
  set da1 [ReadPortMac 0/1]
  puts "RtrData da1:<$da1>"; update
  if {$da1=="-1" || $da1=="-2"} {
    return $da1
  }
  set da2 [ReadPortMac 0/2]
  puts "RtrData da2:<$da2>"; update
  if {$da2=="-1" || $da2=="-2"} {
    return $da2
  }
  ## -payload should have digits and low case letters!
  RLEtxGen::PacketConfig $id MAC -updGen 3 -SA 000000000001 -DA $da1 \
      -payload [string tolower 4500001400000000FFFDB4E801010101020202010000000000000000] \
      -ethType 0800 
  RLEtxGen::PacketConfig $id MAC -updGen 4 -SA 000000000002 -DA $da2 \
      -payload [string tolower 4500001400000000FFFDB4E802020201010101010000000000000000] \
      -ethType 0800  
      
  return [DataTransmissionTestPerf [list 3 4] 20000] 
}      
 
# ***************************************************************************
# BIOS
# ***************************************************************************
proc BIOS {run} {
  global gaSet
  Power all off
  
  RLSound::Play information
  set txt "Insert DiskOnKey with rad.bat program (MAC) and press OK"
  set res [DialogBox -type "OK Cancel" -icon /images/question \
      -title "Burn MAC" -message $txt -aspect 2000]
  update
  if {$res=="Cancel"} {
    return -2
  }
  
  Power all on
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="I7"} {
    return [BiosTest set]
  } elseif {$p=="Xe"} {
    return [BiosTest check]
  } 
}
# ***************************************************************************
# VerifyBIOS
# ***************************************************************************
proc VerifyBIOS {run} {
  
  return [BiosTest check]
}
# ***************************************************************************
# BurnMAC
# ***************************************************************************
proc BurnMAC {run} {
  set ret [BurnMacTest]
  return $ret
}

# ***************************************************************************
# DnfvSoftwareDownload
# ***************************************************************************
proc DnfvSoftwareDownload {run} {
  global gaSet
  Power all off
  
  RLSound::Play information
  set txt "Insert DiskOnKey with application and press OK"
  set res [DialogBox -type "OK Cancel" -icon /images/question \
      -title "Burn MAC" -message $txt -aspect 2000]
  update
  if {$res=="Cancel"} {
    return -2
  }
  
  Power all on
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="I7"} {
    set ret [DnfvSoftwareDownloadTest]
  } elseif {$p=="Xe"} {
    set ret [XeonSoftwareDownloadTest]
  }
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# MacSwID
# ***************************************************************************
proc MacSwID {run} {
  global gaSet
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  if {$p=="I7"} {
    set ret [MacSwIDTest]
    if {$ret!=0} {
      set ret [MacSwIDTest]
      if {$ret!=0} {return $ret}
    }
  } elseif {$p=="Xe"} {
    set ret [XeonMacSwIDTest]
    if {$ret!=0} {
      set ret [XeonMacSwIDTest]
      if {$ret!=0} {return $ret}
    }
  }
  return $ret
}
# ***************************************************************************
# DnfvDataTransmissionConf
# ***************************************************************************
proc DnfvDataTransmissionConf {run} {
  global gaSet
  Power all on
  
  set com $gaSet(comDut)
  Send $com \x1F\r\r -2I 3  
  #ConfigEtxGen
  
  set ret [FactDefault stda]
  if {$ret!=0} {return $ret}   
  set ret [DataTransmissionSetup]
  if {$ret!=0} {return $ret} 
  
  return $ret
} 
# ***************************************************************************
# DnfvDataTransmission
# ***************************************************************************
proc DnfvDataTransmission {run} {
  global gaSet
  
  Status "EtxGen::GenConfig"
  InitEtxGen 1
  RLEtxGen::GenConfig $gaSet(idGen1) -updGen all -packRate 50000 -stream 8
  
  set ret [DnfvCross on] 
  if {$ret!=0} {return $ret}  
  
  set ret [DataTransmissionTestPerf [list 1 2] 50000]  
  if {$ret!=0} {return $ret}
  
  set ret [DnfvCross off] 
  if {$ret!=0} {return $ret}  
  
#   set ret [DnfvPower off] 
#   if {$ret!=0} {return $ret} 
  return $ret
}
# ***************************************************************************
# DnfvLeds
# ***************************************************************************
proc DnfvLed {run} {
  global gaSet gaGui gRelayState
  Status ""
  Power all on
  
  set gRelayState red
  IPRelay-LoopRed
  SendEmail "ETX-2I" "Manual Test"
  
  #catch {set pingId [exec ping.exe 10.10.10.1[set gaSet(pair)] -t &]}
  
  RLSound::Play information
  set txt "Verify that the DNFV is working and its GREEN \'PWR\' led is ON"
  set res [DialogBox -type "OK Fail" -icon /images/question -title "Lock Knob Test" -message $txt]
  update
  if {$res!="OK"} {
    set gaSet(fail) "Lock Knob Test failed"
    return -1
  } else {
    set ret 0
  }
  
  RLSound::Play information
  set txt "Open the lock knob and verify that the DNFV is not working"
  set res [DialogBox -type "OK Fail" -icon /images/question -title "Lock Knob Test" -message $txt]
  update
  if {$res!="OK"} {
    set gaSet(fail) "Lock Knob Test failed"
    return -1
  } else {
    set ret 0
  }
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  
  RLSound::Play information
  if {$p=="I7"} { 
    set txt "Extract the DNFV module out of the cage\n\
    Wait 5 Sec\n\
    Insert the DNFV module back to cage\n\
    Move the lock knob into lock position and secure it tightly with the lock screw"
  } elseif {$p=="Xe"} {
    set txt "Move the lock knob into lock position and secure it tightly with the lock screw\n\
    After few seconds verify that fans rotate noisy for about 30 seconds and then rotate silently"
  }
  set res [DialogBox -type "OK Fail" -icon /images/question -title "Lock Knob Test" -message $txt]
  update
  if {$res!="OK"} {
    set gaSet(fail) "Lock Knob Test failed"
    return -1
  } else {
    set ret 0
  }
  
#   RLSound::Play information
#   set txt "Verify that:\n\
#   GREEN \'PWR\' led is ON"
#   set res [DialogBox -type "OK Fail" -icon /images/question -title "LED Test" -message $txt]
#   update
#   
#   #catch {exec pskill.exe -t $pingId}
#   
#   if {$res!="OK"} {
#     set gaSet(fail) "LED Test failed"
#     return -1
#   } else {
#     set ret 0
#   }
  
  
  return $ret
}
# ***************************************************************************
# BootDownload
# ***************************************************************************
proc BootDownload {run} {
  set ret [Boot_Download]
  if {$ret!=0} {return $ret}
  
  set ret [FormatFlashAfterBootDnl]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# SetDownload
# ***************************************************************************
proc SetDownload {run} {
  set ret [SetSWDownload]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# Pages
# ***************************************************************************
proc Pages {run} {
  global gaSet buffer
  set ret [GetPageFile $gaSet($::pair.barcode1)]
  if {$ret!=0} {return $ret}
  
  set ret [WritePages]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# SoftwareDownload
# ***************************************************************************
proc SoftwareDownload {run} {
  MuxMngIO mngToPc
  set ret [EntryBootMenu]
  if {$ret!=0} {return $ret}
  
  set ret [SoftwareDownloadTest]
  if {$ret!=0} {return $ret}
  
  return $ret
}
# ***************************************************************************
# Set_DateTime
# ***************************************************************************
proc Set_DateTime {run} {
  return [DateTime_Set]
}
# ***************************************************************************
# Test_DateTime
# ***************************************************************************
proc Test_DateTime {run} {
  Power all off
  after 2000
  Power all on
  set ret [Wait "Wait for UUT up" 45 white]
  if {$ret!=0} {return $ret}
  return [DateTime_Test]
}

# ***************************************************************************
# Connectivity
# ***************************************************************************
proc Connectivity {run} {
  global gaSet buffer
  set ret [FactDefault std]
  if {$ret!=0} {return $ret}
  return [Connectivity_Test]
}