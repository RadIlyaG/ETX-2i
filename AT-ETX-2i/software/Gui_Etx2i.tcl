#***************************************************************************
#** GUI
#***************************************************************************
proc GUI {} {
  global gaSet gaGui glTests  
  
  wm title . "$gaSet(pair) : "
  #wm title . "$gaSet(pair) : $gaSet(DutFullName)"
  if {![info exists gaSet(eraseTitle)]} {
    set gaSet(eraseTitle) 1
  }
  set gaSet(eraseTitleGui) $gaSet(eraseTitle)
  if {$gaSet(eraseTitle)==1} {
    wm title . "$gaSet(pair) : "
  }
  
  wm protocol . WM_DELETE_WINDOW {Quit}
  wm geometry . $gaGui(xy)
  wm resizable . 0 0
  set descmenu {
    "&File" all file 0 {	 
      {command "Log File"  {} {} {} -command ShowLog}
	    {separator}     
      {cascad "&Console" {} console 0 {
        {checkbutton "console show" {} "Console Show" {} -command "console show" -variable gConsole}  
        {command "Capture Console" cc "Capture Console" {} -command CaptureConsole}
        {command "Find Console" console "Find Console" {} -command {GuiFindConsole}}          
      }
      }
      {separator}
      {command "Inform about new files" {} "Exit" {} -command {InformAboutNewFiles}}
      {separator}
      {command "History" History "" {} \
         -command {
           set command [list {*}[auto_execok start] {}]
           set url file:///[pwd]/history.html
           exec {*}$command $url &
           #set cmd [list exec "C:\\Program\ Files\\Internet\ Explorer\\iexplore.exe" [pwd]\\history.html &]
           #eval $cmd
         }
      }
      {separator}
      {command "E&xit" exit "Exit" {Alt x} -command {Quit}}
    }
    "&Tools" tools tools 0 {	  
      {command "Inventory" init {} {} -command {GuiInventory}}
      {command "Load Init File" init {} {} -command {GetInitFile}}
      {separator}  
      {command "Options" init {} {} -command {GuiOpts}}
      {separator}
      {command "Show Coms" init "" {} -command "ShowComs"}
      {separator}
      {radiobutton "Scan barcode each UUT" {} "" {} -command {ToogleEraseTitle 1} -variable gaSet(eraseTitleGui) -value 1}  
      {radiobutton "Scan barcode each batch" {} "" {} -command {ToogleEraseTitle 0} -variable gaSet(eraseTitleGui) -value 0}  
      {separator}   
      {cascad "Power" {} pwr 0 {
        {command "PS-1 & PS-2 ON" {} "" {} -command {GuiPower $gaSet(pair) 1}} 
        {command "PS-1 & PS-2 OFF" {} "" {} -command {GuiPower $gaSet(pair) 0}}  
        {command "PS-1 ON" {} "" {} -command {GuiPower $gaSet(pair).1 1}} 
        {command "PS-1 OFF" {} "" {} -command {GuiPower $gaSet(pair).1 0}} 
        {command "PS-2 ON" {} "" {} -command {GuiPower $gaSet(pair).2 1}} 
        {command "PS-2 OFF" {} "" {} -command {GuiPower $gaSet(pair).2 0}} 
        {command "PS-1 & PS-2 OFF and ON" {} "" {} \
            -command {
              GuiPower $gaSet(pair) 0
              after 1000
              GuiPower $gaSet(pair) 1
            }  
        }             
      }
      }  
      {separator}    
      {radiobutton "Don't perform Download steps" init {} {} -command {BuildTests} -variable gaSet(performDownloadSteps) -value 0}
      {radiobutton "Perform Download steps" init {} {} -command {BuildTests} -variable gaSet(performDownloadSteps) -value 1}                  
      {separator}    
      {radiobutton "Don't use exist Barcodes" init {} {} -command {} -variable gaSet(useExistBarcode) -value 0}
      {radiobutton "Use exist Barcodes" init {} {} -command {} -variable gaSet(useExistBarcode) -value 1}      
      {separator}
      {radiobutton "One test ON"  init {} {} -value 1 -variable gaSet(oneTest)}
      {radiobutton "One test OFF" init {} {} -value 0 -variable gaSet(oneTest)}      
      {separator}    
      {command "Release / Debug mode" {} "" {} -command {GuiReleaseDebugMode}}  
      {separator}   
      {command "Init ETX204" {} "" {} -command {ToolsEtxGen}} 
      {separator}    
      {cascad "Email" {} fs 0 {
        {command "E-mail Setting" gaGui(ToolAdd) {} {} -command {GuiEmail .mail}} 
  		  {command "E-mail Test" gaGui(ToolAdd) {} {} -command {TestEmail}}       
      }
      }  
      {separator}
      {radiobutton "Remove SFP"  manSfp {} {} -value 1 -variable gaSet(manSfp)}            
    }
    "&Terminal" terminal tterminal 0  {
      {command "UUT" "" "" {} -command {OpenTeraTerm gaSet(comDut)}}
      {command "GEN" "" "" {} -command {OpenTeraTerm gaSet(comGen1)}}      
    }
    "&About" all about 0 {
      {command "&About" about "" {} -command {About} 
      }
    }
  }
  if 0 {
    "&Short Tests" all shortTests 0 {
      {radiobutton "Perform Short Test" {} {} {} -command {UpdStatBarShortTest; BuildTests} -variable gaSet(performShortTest) -value 1}
      {radiobutton "Perform Full Test" {} {} {} -command {UpdStatBarShortTest; BuildTests} -variable gaSet(performShortTest) -value 0}       
    }
    {separator}    
      {radiobutton "Read Mac in UploadAppl" {} {} {} -command {} -variable gaSet(readMacUploadAppl) -value 1}
      {radiobutton "Don't read Mac in UploadAppl" {} {} {} -command {} -variable gaSet(readMacUploadAppl) -value 0}
      
    {radiobutton "Don't remove SFP" manSfp {} {} -value 0 -variable gaSet(manSfp)}  
  }
   #{command "SW init" init {} {} -command {GuiSwInit}}	
#    {radiobutton "Stop on Failure" {} "" {} -value 1 -variable gaSet(stopFail)}
#       {separator}

# {command "Update INIT files on all the Testers" {} "Exit" {} -command {UpdateInitsToTesters}}
      # {separator}
      

  set mainframe [MainFrame .mainframe -menu $descmenu]
  
  set gaSet(sstatus) [$mainframe addindicator]  
  $gaSet(sstatus) configure -width 64 
  
  set gaSet(statBarShortTest) [$mainframe addindicator]
  
  
  set gaSet(startTime) [$mainframe addindicator]
  
  set gaSet(runTime) [$mainframe addindicator]
  $gaSet(runTime) configure -width 5
  
  set tb0 [$mainframe addtoolbar]
  pack $tb0 -fill x
  set labstartFrom [Label $tb0.labSoft -text "Start From   "]
  set gaGui(startFrom) [ComboBox $tb0.cbstartFrom  -height 18 -width 35 -textvariable gaSet(startFrom) -justify center -editable 0]
  $gaGui(startFrom) bind <Button-1> {SaveInit}
  pack $labstartFrom $gaGui(startFrom) -padx 2 -side left
  set sepIntf [Separator $tb0.sepIntf -orient vertical]
  pack $sepIntf -side left -padx 6 -pady 2 -fill y -expand 0
	 
  set bb [ButtonBox $tb0.bbox0 -spacing 1 -padx 5 -pady 5]
    set gaGui(tbrun) [$bb add -image [Bitmap::get images/run1] \
        -takefocus 0 -command ButRun \
        -bd 1 -padx 5 -pady 5 -helptext "Run the Tester"]		 		 
    set gaGui(tbstop) [$bb add -image [Bitmap::get images/stop1] \
        -takefocus 0 -command ButStop \
        -bd 1 -padx 5 -pady 5 -helptext "Stop the Tester"]
    set gaGui(tbpaus) [$bb add -image [Bitmap::get images/pause] \
        -takefocus 0 -command ButPause \
        -bd 1 -padx 5 -pady 1 -helptext "Pause/Continue the Tester"]	    
  pack $bb -side left  -anchor w -padx 7 ;#-pady 3
  set bb [ButtonBox $tb0.bbox1 -spacing 1 -padx 5 -pady 5]
    set gaGui(noSet) [$bb add -image [Bitmap::get images/Set] \
        -takefocus 0 -command {PerfSet swap} \
        -bd 1 -padx 5 -pady 5 -helptext "Run with the UUTs Setup"]    
  pack $bb -side left  -anchor w -padx 7
  set bb [ButtonBox $tb0.bbox12 -spacing 1 -padx 5 -pady 5]
    set gaGui(email) [$bb add -image [image create photo -file  images/email16.ico] \
        -takefocus 0 -command {GuiEmail .mail} \
        -bd 1 -padx 5 -pady 5 -helptext "Email Setup"] 
    set gaGui(ramzor) [$bb add -image [image create photo -file  images/TRFFC09_1.ico] \
        -takefocus 0 -command {GuiIPRelay} \
        -bd 1 -padx 5 -pady 5 -helptext "IP-Relay Setup"]        
  pack $bb -side left  -anchor w -padx 7
  
  set sepIntf [Separator $tb0.sepFL -orient vertical]
  #pack $sepIntf -side left -padx 6 -pady 2 -fill y -expand 0 
  
  set bb [ButtonBox $tb0.bbox2]
    set gaGui(butShowLog) [$bb add -image [image create photo -file images/find1.1.ico] \
        -takefocus 0 -command {ShowLog} -bd 1 -helptext "View Log file"]     
  pack $bb -side left  -anchor w -padx 7
  
#   set lab1 [Label $tb0.lab1 -text "UUT Com:$gaSet(comDut)"]
#   set lab2 [Label $tb0.lab2 -text "GEN Com:$gaSet(comGen1)"]
#   pack $lab1 $lab2 -padx 2 -side left
    
    set frCommon [frame $mainframe.frCommon  -bd 2 -relief groove]
      set fr [frame $frCommon.fr -bd 0 -relief groove]
        set lab [Label $fr.lab -text "Tester mode"]
        set gaGui(cbTesterMode) [ComboBox $fr.cb -values [list "FTI" "Preparation for ESS"] \
            -textvariable gaSet(cbTesterMode) -width 19 -modifycmd {BuildTests} -justify center]
        pack $lab $gaGui(cbTesterMode) -side left -padx 2 -anchor n
      pack $fr -fill both -expand 1 -padx 2 -pady 2 -side left 
	 
    set frDUT [frame $mainframe.frDUT -bd 2 -relief groove] 
      set labDUT [Label $frDUT.labDUT -text "UUT's barcode" -width 15]
      set gaGui(entDUT) [Entry $frDUT.entDUT -bd 1 -justify center -width 50\
            -editable 1 -relief groove -textvariable gaSet(entDUT) -command {GetDbrName}\
            -helptext "Scan a barcode here"]
      set gaGui(clrDut) [Button $frDUT.clrDut -image [image create photo -file  images/clear1.ico] \
            -takefocus 1 \
            -command {
                global gaSet gaGui
                set gaSet(entDUT) ""
                focus -force $gaGui(entDUT)
            }]         
      pack $labDUT $gaGui(entDUT) $gaGui(clrDut) -side left -padx 2 
#     set frTestPerf [TitleFrame $mainframe.frTestPerf -bd 2 -relief groove \
#         -text "Test Performance"] 
#       set f [$frTestPerf getframe]      17/09/2014 16:26:46
    set frTestPerf [frame $mainframe.frTestPerf -bd 2 -relief groove]     
      set f $frTestPerf
      set frCur [frame $f.frCur]  
        set labCur [Label $frCur.labCur -text "Current Test  " -width 13]
        set gaGui(curTest) [Entry $frCur.curTest -bd 1 \
            -editable 0 -relief groove -textvariable gaSet(curTest) \
	       -justify center -width 50]
        pack $labCur $gaGui(curTest) -padx 7 -pady 1 -side left -fill x;# -expand 1 
      pack $frCur  -anchor w
      #set frStatus [frame $f.frStatus]
      #  set labStatus [Label $frStatus.labStatus -text "Status  " -width 12]
      #  set gaGui(labStatus) [Entry $frStatus.entStatus \
            -bd 1 -editable 0 -relief groove \
	   -textvariable gaSet(status) -justify center -width 58]
      #  pack $labStatus $gaGui(labStatus) -fill x -padx 7 -pady 3 -side left;# -expand 1 	 
      #pack $frStatus -anchor w
      set frFail [frame $f.frFail]
      set gaGui(frFailStatus) $frFail
        set labFail [Label $frFail.labFail -text "Fail Reason  " -width 12]
        set labFailStatus [Entry $frFail.labFailStatus \
            -bd 1 -editable 1 -relief groove \
            -textvariable gaSet(fail) -justify center -width 58]
      pack $labFail $labFailStatus -fill x -padx 7 -pady 3 -side left; # -expand 1	
      #pack $gaGui(frFailStatus) -anchor w
  
    pack $frCommon -side left -fill both -expand 1   -padx 2 -pady 2
    pack $frDUT $frTestPerf -fill both -expand yes -padx 2 -pady 2 -anchor nw	 
  pack $mainframe -fill both -expand yes

  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled  

  console eval {.console config -height 14 -width 92}
  console eval {set ::tk::console::maxLines 10000}
  console eval {.console config -font {Verdana 10}}
  focus -force .
  bind . <F1> {console show}
  bind . <Alt-i> {GuiInventory}
  bind . <Alt-r> {ButRun}
  bind . <Alt-s> {ButStop}
  bind . <Alt-b> {set gaSet(useExistBarcode) 1}
  bind . <Control-p> {ToolsPower on}
  bind . <Control-i> {GuiInventory}
  bind . <Control-o> {GuiOpts}

  .menubar.tterminal entryconfigure 0 -label "UUT: COM $gaSet(comDut)"
  .menubar.tterminal entryconfigure 2 -label "GEN: COM $gaSet(comGen1)"
  
  RLStatus::Show -msg atp
#   RLStatus::Show -msg fti
   set gaSet(entDUT) ""
  focus -force $gaGui(entDUT)
  
  if ![info exists ::RadAppsPath] {
    set ::RadAppsPath c:/RadApps
  }
  
  set gaSet(GuiUpTime) [clock seconds]
}
# ***************************************************************************
# About
# ***************************************************************************
proc About {} {
  if [file exists history.html] {
    set id [open history.html r]
    set hist [read $id]
    close $id
#     regsub -all -- {[<>]} $hist " " a
#     regexp {div ([\d\.]+) \/div} $a m date
    regsub -all -- {<[\w\=\#\d\s\"\/]+>} $hist "" a
    regexp {<!---->\s(.+)\s<!---->} $a m date
  } else {
    set date 14.11.2016 
  }
  DialogBox -title "About the Tester" -icon info -type ok -font {{Lucida Console} 9} -message "ATE software upgrade\n$date"
  #DialogBox -title "About the Tester" -icon info -type ok\
          -message "The software upgrated at 14.11.2016"
}
#***************************************************************************
#** ButRun
#***************************************************************************
proc ButRun {} {
  global gaSet gaGui glTests gRelayState
  Ramzor green on
  puts "\r[MyTime] ButRun"; update
  pack forget $gaGui(frFailStatus)
  Status ""
  set gaSet(runStatus) ""
  set gaSet(1.barcode1.IdMacLink) ""
  set ::wastedSecs 0
  set gaSet(ButRunTime) [clock seconds]
  
  set gaSet(act) 1
  console eval {.console delete 1.0 end}
  console eval {set ::tk::console::maxLines 100000}
  LoadBootErrorsFile
#   if {$gaSet(pair)!="1"} {
#     $gaGui(labPairPerf1) configure -bg $gaSet(toTestClr)
#   }
  set ret 0
  puts "[wm title .]"
  if {[wm title .]=="$gaSet(pair) : "} {
    set ret -1
    set gaSet(fail) "Please scan the UUT's barcode"
  }

  if ![file exists c:/logs] {
    file mkdir c:/logs
  }
#   if {[catch {glob *logFile.txt} lTxt]==0} {
#     ## if there is no logFile, the [glob] rises error. therefor i use catch]
#     foreach fil [glob *logFile.txt] {
#       file copy -force $fil c:/logs/$fil
#     } 
#     foreach fil [glob *logFile.txt] {
#       file delete -force $fil
#     }
#   }
  
  set ti [clock format [clock seconds] -format  "%Y.%m.%d-%H.%M"]
  set gaSet(logFile.$gaSet(pair)) c:/logs/$ti.$gaSet(pair).logFile.txt
  set gaSet(logTime) [clock format [clock seconds] -format  "%Y.%m.%d-%H.%M.%S"]
  
  set gRelayState red
  IPRelay-LoopRed
  
  Ramzor red on
  set ret [GuiReadOperator]
  Ramzor green on
  parray gaSet *arco*
  parray gaSet *rato*
  if {$ret!=0} {
    set ret -3
  } elseif {$ret==0} {
    set ret [ReadBarcode]
    parray gaSet *arco*
    parray gaSet *rato*
    if {$ret=="-1"} {
#       ## SKIP is pressed, we can continue
#       set ret 0
#       set gaSet(1.barcode1) "skipped" 
    }
  
  
    if {![file exists uutInits/$gaSet(DutInitName)]} {
      set txt "Init file for \'$gaSet(DutFullName)\' is absent"
      Status  $txt
      set gaSet(fail) $txt
      set gaSet(curTest) $gaSet(startFrom)
      set ret -1
  #     AddToLog $gaSet(fail)
      AddToPairLog $gaSet(pair) $gaSet(fail)
    }
  
  
    if {$gaSet(performShortTest)=="1"} {
      #RLSound::Play beep
      RLSound::Play fail
      set txt "Be aware!\r\rYou are about to perform the short test.\r\r\
      If you are not sure, click the GUI's \'Short Tests\'->\'Perform Full Test\'"
      set res [DialogBoxRamzor -icon images/info -type "Continue Abort" -text $txt -default 1 -aspect 2000 -title ASMi53]
      if {$res=="Abort"} {
        set ret -2
        set gaSet(fail) "Short test abort"
        Status "Short test abort"
  #       AddToLog $gaSet(fail)
        AddToPairLog $gaSet(pair) $gaSet(fail)
      } else {
        set ret 0
      }
    }
  
    if {$gaSet(relDebMode)=="Debug"} {
      #RLSound::Play beep
      RLSound::Play information
      set txt "Be aware!\r\rYou are about to perform tests in Debug mode.\r\r\
      If you are not sure, in the GUI's \'Tools\'->\'Release / Debug mode\' choose \"Release Mode\""
      set res [DialogBoxRamzor -icon images/info -type "Continue Abort" -text $txt -default 1 -aspect 2000 -title "ETX-2i-10G"]
      if {$res=="Abort"} {
        set ret -2
        set gaSet(fail) "Debug mode abort"
        Status "Debug mode abort"
  #       AddToLog $gaSet(fail)
        AddToPairLog $gaSet(pair) $gaSet(fail)
      } else {
        AddToPairLog $gaSet(pair) "\n!!! DEBUG MODE !!!\n"
        set ret 0
      }
    }
  
    foreach v {sw} {
      if {$gaSet($v)=="??"} {
        puts "ButRun v:$v gaSet($v):$gaSet($v)"
        set txt "Init file for \'$gaSet(DutFullName)\' is wrong"
        Status  $txt
        set gaSet(fail) $txt
        set gaSet(curTest) $gaSet(startFrom)
        set ret -1
  #       AddToLog $gaSet(fail)
        AddToPairLog $gaSet(pair) $gaSet(fail)
        break
      }
    }
  }
#   puts "[MyTime] source Lib_Put_RicEth.tcl" ; update
#   source Lib_Put_RicEth.tcl
#   puts "[MyTime] source Lib_Put_RicEth_$gaSet(dutFam).tcl" ; update
#   source Lib_Put_RicEth_$gaSet(dutFam).tcl
#   
  if {$ret==0} {
    AddToPairLog $gaSet(pair) " $gaSet(operatorID) $gaSet(operator)"
    
    IPRelay-Green
    Status ""
    set gaSet(curTest) [$gaGui(startFrom) cget -text]
    console eval {.console delete 1.0 "end-1001 lines"}
    pack forget $gaGui(frFailStatus)
    $gaSet(startTime) configure -text " Start: [MyTime] "
    $gaGui(tbrun) configure -relief sunken -state disabled
    $gaGui(tbstop) configure -relief raised -state normal
    $gaGui(tbpaus) configure -relief raised -state normal
    set gaSet(fail) ""
    foreach wid {startFrom} {
      $gaGui($wid) configure -state disabled
    }
    #.mainframe setmenustate tools disabled
    update
#     catch {exec taskkill.exe /im hypertrm.exe /f /t}
#     catch {exec taskkill.exe /im mb.exe /f /t}
    RLTime::Delay 1
    catch {unset gaSet(1.mac1)}
    catch {unset gaSet(dnfvMac1)}
    catch {unset gaSet(dnfvMac2)}
    
    set ret 0
    GuiPower all 1 ; ## power ON before scan barcodes and OpenRL
    set gaSet(plEn) 0
    if {$ret==0} {
    
      
      
      if {$ret==0} {
        IPRelay-Green
        set ret [OpenRL]
        if {$ret==0} {
          set ret [Testing]
        }
      }
    }
    puts "ret of Testing: $ret"  ; update
    foreach wid {startFrom } {
      $gaGui($wid) configure -state normal
    }
    .mainframe setmenustate tools normal
    puts "end of normal widgets"  ; update
    update
    set retC [CloseRL]
    puts "ret of CloseRL: $retC"  ; update
    
    set gaSet(oneTest) 0
    set gaSet(rerunTesterMulti) conf
    set gaSet(nextPair) begin
    set gaSet(readMacUploadAppl) 1
    
    set gRelayState red
    IPRelay-LoopRed
  }
  
  if {$ret==0} {
    RLSound::Play pass
    Status "Done"  #00ff00 ; #green
    if  {[info exists gaSet(pair)] && [info exists gaSet(log.$gaSet(pair))] && [file exists $gaSet(log.$gaSet(pair))]} {
      file rename -force $gaSet(log.$gaSet(pair)) [file rootname $gaSet(log.$gaSet(pair))]-Pass.txt
    }
    set gaSet(runStatus) Pass
	  
	  set gaSet(curTest) ""
	  set gaSet(startFrom) [lindex $glTests 0]
  } elseif {$ret==1} {
    RLSound::Play information
    Status "The test has been perform"  yellow
  } else {
    set gaSet(runStatus) Fail  
    if {$ret=="-2"} {
	    set gaSet(fail) "User stop"
      
      ## do not include UserStop in statistics
      set gaSet(runStatus) ""  
	  }
    if {$gaSet(runStatus)!=""} {
      UnregIdBarcode $gaSet(1.barcode1)
    }
    if {$ret=="-3"} {
	    ## do not include No Operator fail in statistics
      set gaSet(runStatus) ""  
	  }
	  pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
	  RLSound::Play fail
	  Status "Test FAIL"  red
    if {[info exists gaSet(pair)] && [info exists gaSet(log.$gaSet(pair))] && [file exists $gaSet(log.$gaSet(pair))]} {
	    file rename -force $gaSet(log.$gaSet(pair)) [file rootname $gaSet(log.$gaSet(pair))]-Fail.txt       
    }
    ##27/11/2015 14:32:38   
#     if {$gaSet(failAnd)=="stay"} {   
#       set gaSet(startFrom) $gaSet(curTest)
#     } elseif {$gaSet(failAnd)=="jump2Start"} {   
#       set gaSet(startFrom) [lindex $glTests 0]
#     }
    set gaSet(startFrom) $gaSet(curTest)
    update
  }
  if {$gaSet(runStatus)!=""} {
    SQliteAddLine
  }
  SendEmail "ETX-2i" [$gaSet(sstatus) cget -text]
  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled
  $gaGui(tbpaus) configure -relief sunken -state disabled
  
  if {$gaSet(eraseTitle)==1} {
    wm title . "$gaSet(pair) : "
  }
  
  set res [DialogBox -type "OK" -icon /images/info -title "Finish" -message "The test is done" ]
  update
  Ramzor all off
  
  update
}


#***************************************************************************
#** ButStop
#***************************************************************************
proc ButStop {} {
  global gaGui gaSet
  set gaSet(act) 0
  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled
  $gaGui(tbpaus) configure -relief sunken -state disabled
  foreach wid {startFrom } {
    $gaGui($wid) configure -state normal
  }
  .mainframe setmenustate tools normal
  CloseRL
  update
}
# ***************************************************************************
# ButPause
# ***************************************************************************
proc ButPause {} {
  global gaGui gaSet
  if { [$gaGui(tbpaus) cget -relief] == "raised" } {
    $gaGui(tbpaus) configure -relief "sunken"     
    #CloseRL
  } else {
    $gaGui(tbpaus) configure -relief "raised" 
    #OpenRL   
  }
        
  while { [$gaGui(tbpaus) cget -relief] != "raised" } {
    RLTime::Delay 1
  }  
}

#***************************************************************************
#** GuiSwInit
#***************************************************************************
proc GuiSwInit {} {  
  global gaSet tmpSw tmpCsl
  set tmpSw  $gaSet(soft)
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base +200+200
  wm resizable $base 1 1 
  wm title $base "SW init"
  pack [LabelEntry $base.entHW -label "UUT's SW:  " \
      -justify center -textvariable tmpSw] -pady 1 -padx 3  
  pack [Separator $base.sep1 -orient horizontal] -fill x -padx 2 -pady 3
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [Button $base.frBut.butCanc -text Cancel -command ButCanc -width 7] -side right -padx 6
    pack [Button $base.frBut.butOk -text Ok -command ButOk -width 7]  -side right -padx 6
  
  focus -force $base
  grab $base
  return {}  
}


#***************************************************************************
#** ButOk
#***************************************************************************
proc ButOk {} {
  global gaSet lp
  #set lp [PasswdDlg .topHwInit.passwd -parent .topHwInit]
  set login 1 ; #[lindex $lp 0]
  set pw    1 ; #[lindex $lp 1]
  if {$login!="1" || $pw!="1"} {
    #exec c:\\rlfiles\\Tools\\btl\\beep.exe &
    RLSound::Play information
    tk_messageBox -icon error -title "Access denied" -message "The Login or Password isn't correct" \
       -type ok
  } else {
    set sw  [.topHwInit.entHW cget -text]
    puts "$sw"
    set gaSet(soft) $sw
    SaveInit
  }
  ButCanc
}


#***************************************************************************
#** ButCanc -- 
#***************************************************************************
proc ButCanc {} {
  grab release .topHwInit
  focus .
  destroy .topHwInit
}


#***************************************************************************
#** GuiInventory
#***************************************************************************
proc GuiInventory {} {  
  global gaSet gaTmpSet gaGui
  
  if [winfo exists .topHwInit] {
    wm deiconify .topHwInit
    wm deiconify .
    wm deiconify .topHwInit
    return {}
  }
  
  if {![info exists gaSet(DutFullName)] || $gaSet(DutFullName)==""} {
    #exec C:\\RLFiles\\Tools\\Btl\\failbeep.exe &
    RLSound::Play fail    
    set txt "Define the UUT first"
    DialogBoxRamzor -title "Wrong UUT" -message $txt -type OK -icon images/error
    focus -force $gaGui(entDUT)
    return -1
  }
  
  array unset gaTmpSet
  
  set parL [list sw dnfvProject dnfvEC dnfvCPU licDir dnfvVer dbrSW swPack \
      dnfvdbrSW dbrBVerSw dbrBVer cpld dnfvBIOS]
  foreach par $parL {
    if ![info exists gaSet($par)] {set gaSet($par) ??}
    set gaTmpSet($par) $gaSet($par)
  }
  foreach indx {19V 19 M DGasp ExtClk RTR DNFV Boot SW Default Half19 Half19_loop Half19_4ports} { 
    if ![info exists gaSet([set indx]CF)] {set gaSet([set indx]CF) c:/aa}
    set gaTmpSet([set indx]CF)  $gaSet([set indx]CF)
  }

  
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 1 1 
  wm title $base "Inventory of $gaSet(DutFullName)"
  
  set indx 0
  if {$gaSet(dutBox)=="19" || $gaSet(dutBox)=="19V" || $gaSet(dutBox)=="M" || $gaSet(dutBox)=="Half19"} {
    set fr [frame $base.frSwVer -bd 0 -relief groove]
      pack [Label $fr.labSW  -text "SW Ver" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbSW -justify center -width 45 -state disabled -editable 0 -textvariable gaTmpSet(dbrSW)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
    set fr [frame $base.frSwPack -bd 0 -relief groove]
      pack [Label $fr.labSW  -text "SW Pack" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbSW -justify center -editable 1 -textvariable gaTmpSet(swPack)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
    set fr [frame $base.frBVer -bd 0 -relief groove]
      pack [Label $fr.labBVer  -text "Boot Ver" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbBVer -justify center -width 45 -state disabled -editable 0 -textvariable gaTmpSet(dbrBVer)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
    set fr [frame $base.frBVerSw -bd 0 -relief groove]
      pack [Label $fr.labBVerSw  -text "Boot SW Pack" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbBVerSw -justify center -editable 1 -textvariable gaTmpSet(dbrBVerSw)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
    set fr [frame $base.frCpld -bd 0 -relief groove]
      pack [Label $fr.labCpld  -text "CPLD" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbCpld -justify center -editable 1 -textvariable gaTmpSet(cpld)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
  } elseif {$gaSet(dutBox)=="DNFV"} {
    foreach indx {Project EC CPU BIOS} {
      set fr [frame $base.fr$indx -bd 0 -relief groove]
        pack [Label $fr.lab$indx  -text "$indx" -width 15] -pady 1 -padx 2 -anchor w -side left
        pack [Entry $fr.cb$indx -justify center -width 45 -editable 1 -textvariable gaTmpSet(dnfv$indx)] -pady 1 -padx 2 -anchor w -side left
      pack $fr  -fill x -pady 3
    }
    set fr [frame $base.frSwVer -bd 0 -relief groove]
      pack [Label $fr.labSW  -text "SW Ver" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbSW -justify center -width 45 -state disabled -editable 0 -textvariable gaTmpSet(dbrSW)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
    set fr [frame $base.frSwPack -bd 0 -relief groove]
      pack [Label $fr.labSW  -text "SW Pack" -width 15] -pady 1 -padx 2 -anchor w -side left
      pack [Entry $fr.cbSW -justify center -width 45 -editable 1 -textvariable gaTmpSet(swPack)] -pady 1 -padx 2 -anchor w -side left
    pack $fr  -anchor w
  }
  
  pack [Separator $base.sep[incr inx] -orient horizontal] -fill x -padx 2 -pady 3
  
  set txtWidth 40
  if {$gaSet(dutBox)!="DNFV"} {
    ## no need configuration files for DNFV    
    foreach indx {Boot SW 19V 19 M Half19_loop Half19_4ports DGasp ExtClk RTR} {
      if {$indx==$gaSet(dutBox) || $indx=="DGasp" || $indx=="ExtClk" || $indx=="RTR" || \
        $indx=="Boot" || $indx=="SW" || $indx=="Half19_loop"  || $indx=="Half19_4ports"} {
        set fr [frame $base.fr$indx -bd 0 -relief groove]
          if {$indx=="Boot" || $indx=="SW"} {
            set txt "Browse to \'[set indx]\' bin file..."
          } else {
            set txt "Browse to \'[set indx]\' configuration file..."
          }
          set f [set indx]CF
          pack [Button $fr.brw -text $txt -width $txtWidth -command [list BrowseCF $txt $f]] -side left -pady 1 -padx 3 -anchor w
          pack [Label $fr.lab  -textvariable gaTmpSet($f)] -pady 1 -padx 3 -anchor w
        pack $fr  -fill x -pady 3
      }
    } 
    set fr  [frame $base.frUcf -bd 2 -relief groove]
      set gaGui(chbUcf) [ttk::checkbutton $fr.chbUcf -text "User Default Configuration File" -variable ::chbUcf -command {ToggleUCF}]
      pack $gaGui(chbUcf)  -pady 1 -padx 3 -anchor w 
    pack $fr -fill x -pady 3
  } elseif {$gaSet(dutBox)=="DNFV"} {
    foreach indx {DNFV} {      
      set fr [frame $base.fr$indx -bd 0 -relief groove]
        set txt "Browse to \'[set indx]\' Conf File..."
        set f [set indx]CF
        pack [Button $fr.brw -text $txt -width $txtWidth -command [list BrowseCF $txt $f]] -side left -pady 1 -padx 3 -anchor w
        pack [Label $fr.lab  -textvariable gaTmpSet($f)] -pady 1 -padx 3 -anchor w
      pack $fr  -fill x -pady 3      
    }
  }
  #pack [Separator $base.sep3 -orient horizontal] -fill x -padx 2 -pady 3
  
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [Button $base.frBut.butImp -text Import -command ButImportInventory -width 7] -side right -padx 6
    pack [Button $base.frBut.butCanc -text Cancel -command ButCancInventory -width 7] -side right -padx 6
    pack [Button $base.frBut.butOk -text Ok -command ButOkInventory -width 7]  -side right -padx 6
  
  focus -force $base
  grab $base
  return {}  
}
# ***************************************************************************
# BrowseCF
# ***************************************************************************
proc BrowseCF {txt f} {
  global gaTmpSet
  set gaTmpSet($f) [tk_getOpenFile -title $txt -initialdir "[pwd]/ConfFiles"]
  focus -force .topHwInit
}
# ***************************************************************************
# BrowseLic
# ***************************************************************************
proc BrowseLic {} {
  global gaTmpSet
  set gaTmpSet(licDir) [tk_chooseDirectory -title "Choose Licence file location" -initialdir "c:\\Download"]
  focus -force .topHwInit
}
# ***************************************************************************
# ButImportInventory
# ***************************************************************************
proc ButImportInventory {} {
  global gaSet gaTmpSet
  set fil [tk_getOpenFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
  if {$fil!=""} {  
    set gaTmpSet(DutFullName) $gaSet(DutFullName)
    set gaTmpSet(DutInitName) $gaSet(DutInitName)
    set DutInitName $gaSet(DutInitName)
    
    source $fil
    set parL [list sw licDir]
    foreach par $parL {
      set gaTmpSet($par) $gaSet($par)
    }
    
    set gaSet(DutFullName) $gaTmpSet(DutFullName)
    set gaSet(DutInitName) $DutInitName ; #xcxc ; #gaTmpSet(DutInitName)    
  }    
  focus -force .topHwInit
}
#***************************************************************************
#** ButOk
#***************************************************************************
proc ButOkInventory {} {
  global gaSet gaTmpSet
  
#   set saveInitFile 0
#   foreach nam [array names gaTmpSet] {
#     if {$gaTmpSet($nam)!=$gaSet($nam)} {
#       puts "ButOkInventory1 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
#       #set gaSet($nam) $gaTmpSet($nam)      
#       set saveInitFile 1 
#       break
#     }  
#   }
  
  set saveInitFile 1  
  if {$saveInitFile=="1"} {
    set res Save
    if {[file exists uutInits/$gaSet(DutInitName)]} {
      set txt "Init file for \'$gaSet(DutFullName)\' exists.\n\nAre you sure you want overwright the file?"
      set res [DialogBox -title "Save init file" -message  $txt -icon images/question \
          -type [list Save "Save As" Cancel] -default 2]
      if {$res=="Cancel"} {array unset gaTmpSet ; return -1}
    }
    if ![file exists uutInits] {
      file mkdir uutInits
    }
    if {$res=="Save"} {
      #SaveUutInit uutInits/$gaSet(DutInitName)
      set fil "uutInits/$gaSet(DutInitName)"
    } elseif {$res=="Save As"} {
      set fil [tk_getSaveFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
      if {$fil!=""} {        
        set fil1 [file tail [file rootname $fil]]
        puts fil1:$fil1
        set gaSet(DutInitName) $fil1.tcl
        set gaSet(DutFullName) $fil1
        #set gaSet(entDUT) $fil1
        wm title . "$gaSet(pair) : $gaSet(DutFullName)"
        #SaveUutInit $fil
        update
      }
    } 
    puts "ButOkInventory fil:<$fil>"
    if {$fil!=""} {
      foreach nam [array names gaTmpSet] {
        if {$gaTmpSet($nam)!=$gaSet($nam)} {
          puts "ButOkInventory2 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
          set gaSet($nam) $gaTmpSet($nam)      
        }  
      }
      #mparray gaTmpSet
      #mparray gaSet
      SaveUutInit $fil
    } 
  }
  #mparray gaSet dnf*
  array unset gaTmpSet
  SaveInit
  BuildTests
  ButCancInventory
}


#***************************************************************************
#** ButCancInventory
#***************************************************************************
proc ButCancInventory {} {
  grab release .topHwInit
  focus .
  destroy .topHwInit
}


#***************************************************************************
#** Quit
#***************************************************************************
proc Quit {} {
  global gaSet
  SaveInit
  RLSound::Play information
  set ret [DialogBox -title "Confirm exit"\
      -type "yes no" -icon images/question -aspect 2000\
      -text "Are you sure you want to close the application?"]
  if {$ret=="yes"} {CloseRL; IPRelay-Green; exit}
}

#***************************************************************************
#** CaptureConsole
#***************************************************************************
proc CaptureConsole {} {
  console eval { 
    set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"]
    if ![file exists c:/temp] {
      file mkdir c:/temp
      after 1000
    }
    set fi c:\\temp\\ConsoleCapt_[set ti].txt
    if [file exists $fi] {
      set res [tk_messageBox -title "Save Console Content" \
        -icon info -type yesno \
        -message "File $fi already exist.\n\
               Do you want overwrite it?"]      
      if {$res=="no"} {
         set types { {{Text Files} {.txt}} }
         set new [tk_getSaveFile -defaultextension txt \
                 -initialdir c:\\ -initialfile [file rootname $fi]  \
                 -filetypes $types]
         if {$new==""} {return {}}
      }
    }
    set aa [.console get 1.0 end]
    set id [open $fi w]
    puts $id $aa
    close $id
  }
}

# ***************************************************************************
# UpdStatBarShortTest
# ***************************************************************************
proc UpdStatBarShortTest {} {
  global gaSet
  
  if {$gaSet(performShortTest)==1} {
    set txt " SHORT TEST! " 
    set bg red
    set fg SystemButtonText  
  } else {
    set txt ""
    set bg SystemButtonFace
    set fg SystemButtonText
  }
  $gaSet(statBarShortTest) configure -text $txt -bg $bg -fg $fg
}

# ***************************************************************************
# ToogleEraseTitle
# ***************************************************************************
proc ToogleEraseTitle {changeTo} {
  global gaSet
  if {![info exists gaSet(eraseTitle)]} {
    set gaSet(eraseTitle) 1
  }
  if {$gaSet(eraseTitle)==1 && $changeTo==0} {
    set gaSet(eraseTitle) 0
#     set log ""
#     while 1 {
#       set p [PasswdDlg .p -parent . -type okcancel]
#       if {[llength $p]==0} {
#         ## cancel button
#         return {}
#       } else {
#         foreach {log pass} $p {}
#       }
#       if {$log=="rad" && $pass=="123"} {set gaSet(eraseTitle) 0; break}
#     }
  }
  if {$changeTo==1} {
    set gaSet(eraseTitle) 1
    wm title . "$gaSet(pair) : "
  }  
}

# ***************************************************************************
# GuiOpts
# ***************************************************************************
proc GuiOpts {} {  
  global gaSet gaTmpSet gaGui
  
  if [winfo exists .topOpts] {
    wm deiconify .topOpts
    wm deiconify .
    wm deiconify .topOpts
    return {}
  }
  
  array unset gaTmpSet
  
  set parL [list ddrMultyQty DGTestQty DGTestLoopBreak]
  foreach par $parL {
    if ![info exists gaSet($par)] {set gaSet($par) ??}
    set gaTmpSet($par) $gaSet($par)
  }
  
  set base .topOpts
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 1 1 
  wm title $base "Options"
  set labelWidth 25
  
  set indx 0
  set subIndx 0
  set fr [frame $base.fr$indx -bd 0 -relief groove]
    pack [Label $fr.lab$indx  -text "DDR multi Quantity" -width $labelWidth] -pady 1 -padx 2 -anchor w -side left
    pack [Entry $fr.cb$indx -justify center -width 15 -state normal -editable 1 -textvariable gaTmpSet(ddrMultyQty)] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w  

  incr indx 
  set fr [frame $base.fr$indx -bd 2 -relief groove]
    set fr1 [frame $fr.fr1 -bd 0 -relief groove]
    pack [Label $fr1.lab$indx  -text "Dying Gasp Test Quantity" -width $labelWidth] -pady 1 -padx 2 -anchor w -side left
    pack [Entry $fr1.cb$indx -justify center -width 15 -state normal -editable 1 -textvariable gaTmpSet(DGTestQty)] -pady 1 -padx 2 -anchor w -side left
    set fr2 [frame $fr.fr2 -bd 0 -relief groove]
    pack [checkbutton $fr2.chb$indx  -text "Exit from DG loop if test pass" -variable gaTmpSet(DGTestLoopBreak)] -pady 1 -padx 2 -anchor w -side left
    pack $fr1 $fr2 -anchor w
  pack $fr  -anchor w  -padx 2 -pady 2 
  
  #pack [Separator $base.sep[incr inx] -orient horizontal] -fill x -padx 2 -pady 3
  
  
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [Button $base.frBut.butCanc -text Cancel -command ButCancOpts -width 7] -side right -padx 6
    pack [Button $base.frBut.butOk -text Ok -command ButOkOpts -width 7]  -side right -padx 6
  
  focus -force $base
  grab $base
  return {}  
}
#***************************************************************************
#** ButOkOpts
#***************************************************************************
proc ButOkOpts {} {
  global gaSet gaTmpSet
  
  foreach nam [array names gaTmpSet] {
    if {$gaTmpSet($nam)!=$gaSet($nam)} {
      puts "ButOkOpts $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
      set gaSet($nam) $gaTmpSet($nam)      
    }  
  }

  array unset gaTmpSet
  SaveInit
  ButCancOpts
}


#***************************************************************************
#** ButCancOpts
#***************************************************************************
proc ButCancOpts {} {
  grab release .topOpts
  focus .
  destroy .topOpts
}

# ***************************************************************************
# ShowComs
# ***************************************************************************
proc ShowComs {} {                                                                        
  global gaSet gaGui
  set txt  ""
  append txt "UUT Com: $gaSet(comDut)\n"  
  append txt "GEN Com: $gaSet(comGen1)\n"
  
  DialogBox -title "COMs definitions" -type OK -message "$txt"
  return {}
}
# ***************************************************************************
# GuiReleaseDebugMode
# ***************************************************************************
proc GuiReleaseDebugMode {} {
  global gaSet gaGui gaTmpSet glTests 
  
  set base .topReleaseDebugMode
  if [winfo exists $base] {
    wm deiconify $base
    return {}
  }
    
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 1 1 
  wm title $base "Release/Debug Mode"
  
   array unset gaTmpSet
   
  if ![info exists gaSet(relDebMode)] {
    set gaSet(relDebMode) Release  
  }
  foreach par {relDebMode} {
    set gaTmpSet($par) $gaSet($par) 
  }
    
  set fr1 [ttk::frame $base.fr1 -relief groove]
    set fr11 [ttk::frame $fr1.fr11]
      set gaGui(rbRelMode) [ttk::radiobutton $fr11.rbRelMode -text "Release Mode" -variable gaTmpSet(relDebMode) -value Release -command ToggleRelDeb]
      set gaGui(rbDebMode) [ttk::radiobutton $fr11.rbDebMode -text "Debug Mode" -variable gaTmpSet(relDebMode) -value Debug -command ToggleRelDeb]
      set gaGui(butBuildTest) [ttk::button $fr11.butBuildTest -text "Refresh Tests" \
           -command {
               BuildTests
               after 200
               ButCancReleaseDebugMode
               after 100
               update
               GuiReleaseDebugMode
           }]      
      pack $gaGui(rbRelMode) $gaGui(rbDebMode) $gaGui(butBuildTest) -anchor nw
      
    set fr12 [ttk::frame $fr1.fr12]
      set fr121 [ttk::frame $fr12.fr121]
        set l2 [ttk::label $fr121.l2 -text "Available Tests"]
        pack $l2 -anchor w
        scrollbar $fr121.yscroll -command {$gaGui(lbAllTests) yview} -orient vertical
        pack $fr121.yscroll -side right -fill y
        set gaGui(lbAllTests) [ListBox $fr121.lb1  -selectmode multiple \
            -yscrollcommand "$fr121.yscroll set" -height 25 -width 33 \
            -dragenabled 1 -dragevent 1 -dropenabled 1 -dropcmd DropRemTest]
        pack $gaGui(lbAllTests) -side left -fill both -expand 1
        
      set fr122 [frame $fr12.fr122 -bd 0 -relief groove]
        grid [button $fr122.b0 -text ""   -command {} -state disabled -relief flat] -sticky ew
        $fr122.b0 configure -background [ttk::style lookup . -background disabled]
        grid [set gaGui(addOne) [ttk::button $fr122.b3 -text ">"  -command {AddTest sel}]] -sticky ew
        grid [set gaGui(addAll) [ttk::button $fr122.b4 -text ">>" -command {AddTest all}]] -sticky ew
        grid [set gaGui(remOne) [ttk::button $fr122.b5 -text "<"  -command {RemTest sel}]] -sticky ew
        grid [set gaGui(remAll) [ttk::button $fr122.b6 -text "<<" -command {RemTest all}]] -sticky ew
            
      set fr123 [frame $fr12.fr123 -bd 0 -relief groove]  
        set l3 [Label $fr123.l3 -text "Tests to run"]
        pack $l3 -anchor w  
        scrollbar $fr123.yscroll -command {$gaGui(lbTests) yview} -orient vertical  
        pack $fr123.yscroll -side right -fill y
        set gaGui(lbTests) [ListBox $fr123.lb2  -selectmode multiple \
            -yscrollcommand "$fr123.yscroll set" -height 25 -width 33 \
            -dragenabled 1 -dragevent 1 -dropenabled 1 -dropcmd DropAddTest] 
        pack $gaGui(lbTests) -side left -fill both -expand 1  
      
      grid $fr121 $fr122 $fr123 -sticky news  
          
    pack $fr11 -side left -padx 14 -anchor n -pady 2
    pack $fr12 -side left -padx 2 -anchor n -pady 2
  pack $fr1  -padx 2 -pady 2
  pack [ttk::frame $base.frBut] -pady 4 -anchor e    -padx 2 
    #pack [Button $base.frBut.butImp -text Import -command ButImportInventory -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butCanc -text Cancel -command ButCancReleaseDebugMode -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butOk -text Ok -command ButOkReleaseDebugMode -width 7]  -side right -padx 6
  
  #BuildTests
  ##ToggleTestMode  ; just in ASMi54
  foreach te $glTests {
    $gaGui(lbAllTests) insert end $te -text $te
  }
  
  ToggleRelDeb
  
  focus -force $base
  grab $base
  return {}  
}
# ***************************************************************************
# ButCancReleaseDebugMode
# ***************************************************************************
proc ButCancReleaseDebugMode {} {
  grab release .topReleaseDebugMode
  focus .
  destroy .topReleaseDebugMode
}
# ***************************************************************************
# ButOkReleaseDebugMode
# ***************************************************************************
proc ButOkReleaseDebugMode {} {
  global gaGui gaSet gaTmpSet glTests
  
  if {[llength [$gaGui(lbTests) items]]==0} {
    return 0
  }
  
  set gaSet(relDebMode) $gaTmpSet(relDebMode) 
  
  set glTests [$gaGui(lbTests) items]
  set gaSet(startFrom) [lindex $glTests 0]
  
  $gaGui(startFrom) configure -values $glTests
  if {$gaSet(relDebMode)=="Debug"} {
    set gaSet(debugTests) $glTests
  }
  
  if {[llength [$gaGui(lbAllTests) items]] != [llength [$gaGui(lbTests) items]]} {
    Status "Debug Mode" red
  }
  array unset gaTmpSet
  #SaveInit
  #BuildTests
  ButCancReleaseDebugMode
}  
# ***************************************************************************
# AddTest
# ***************************************************************************
proc AddTest {mode} {
   global gaSet gaGui
   if {$mode=="sel"} {
     set ftL [$gaGui(lbAllTests) selection get]
   } elseif {$mode=="all"} {
     set ftL [$gaGui(lbAllTests) items]
   }
   foreach ft $ftL {
     if {[lsearch [$gaGui(lbTests) items] $ft]=="-1"} {
       $gaGui(lbTests) insert end $ft -text $ft
     }
   }
   $gaGui(lbAllTests) selection clear
   $gaGui(lbTests) reorder [lsort -dict [$gaGui(lbTests) items]]
}
# ***************************************************************************
# RemTest
# ***************************************************************************
proc RemTest {mode} {
   global gaSet gaGui
   if {$mode=="sel"} {
     set ftL [$gaGui(lbTests) selection get]
   } elseif {$mode=="all"} {
     set ftL [$gaGui(lbTests) items]
     eval $gaGui(lbTests) selection set $ftL
#      RLSound::Play beep
#      set res [DialogBox -title "Remove all tests" -type [list Cancel Yes] \
#        -text "Are you sure you want to remove ALL the tests?" -icon images/info]
#      if {$res=="Cancel"} {
#        $gaGui(lbTests) selection clear
#        return {}
#      }
   }
   foreach ft $ftL {
     $gaGui(lbTests) delete $ftL
   }
}
# ***************************************************************************
# DropAddTest
# ***************************************************************************
proc DropAddTest {listbox dragsource itemList operation datatype data} {
  puts [list $listbox $dragsource $itemList $operation $datatype $data]
  global gaSet gaGui
  if {$dragsource=="$gaGui(lbAllTests).c"} {
    set ft $data
    if {[lsearch [$gaGui(lbTests) items] $ft]=="-1"} {
      $gaGui(lbTests) insert end $ft -text $ft
    }
    $gaGui(lbTests) reorder [lsort -dict [$gaGui(lbTests) items]]
  } elseif {$dragsource=="$gaGui(lbTests).c"} {
    set destIndx [$gaGui(lbTests) index [lindex $itemList 1]]
    $gaGui(lbTests) move $data $destIndx
    $gaGui(lbTests) selection clear
    
  }
}
# ***************************************************************************
# DropRemTest
# ***************************************************************************
proc DropRemTest {listbox dragsource itemList operation datatype data} {
  puts [list $listbox $dragsource $itemList $operation $datatype $data]
  global gaSet gaGui gaTmpSet
  if {$gaTmpSet(relDebMode)=="Debug"} {
    if {$dragsource=="$gaGui(lbTests).c"} {
      set ft $data
      $gaGui(lbTests) delete $ft
    }
  }
}
# ***************************************************************************
# ToggleRelDeb
# ***************************************************************************
proc ToggleRelDeb {} {
  global gaGui gaTmpSet
  if {$gaTmpSet(relDebMode)=="Release"} {
    puts "ToggleRelDeb Release"
    #BuildTests
    after 100
    AddTest all
    set state disabled
  } elseif {$gaTmpSet(relDebMode)=="Debug"} {
    puts "ToggleRelDeb Debug"
    RemTest all
    after 100 ; update
    set state normal
    if {[info exists gaSet(debugTests)] && [llength $gaSet(debugTests)]>0} {
      foreach ft $gaSet(debugTests) {
        if {[lsearch [$gaGui(lbTests) items] $ft]=="-1"} {
          $gaGui(lbTests) insert end $ft -text $ft
        }
      }
    }
  }
  foreach b [list $gaGui(addOne) $gaGui(addAll) $gaGui(remOne) $gaGui(remAll)] {
    $b configure -state $state
  }
}
# ***************************************************************************
# ToggleTestMode
# ***************************************************************************
proc ToggleTestMode {} {
  global gaGui gaSet
  
  foreach {b r p d ps} [split $gaSet(dutFam) .] {}
  puts "[MyTime] ToggleTestMode b:<$b> p:<$p>" ; update 
  if {$b!="DNFV"} {  
    set gaSet(cbTesterMode) "FTI"
    $gaGui(cbTesterMode) configure -state disabled
  } else {
    if {$p=="I7"} {
      set gaSet(cbTesterMode) "FTI"
      $gaGui(cbTesterMode) configure -state disabled
    } elseif {$p=="Xe"} {
      #set gaSet(cbTesterMode) "FTI"
      $gaGui(cbTesterMode) configure -state normal
    } 
  }
}
# ***************************************************************************
# GuiReadOperator
# ***************************************************************************
proc GuiReadOperator {} {
  global gaSet gaGui gaDBox gaGetOpDBox
  catch {array unset gaDBox} 
  catch {array unset gaGetOpDBox} 
  #set ret [GetOperator -i pause.gif -ti "title Get Operator" -te "text Operator's Name "]
  set sn [clock seconds]
  set ret [GetOperator -i images/oper32.ico -gn $::RadAppsPath]
  incr ::wastedSecs [expr {[clock seconds]-$sn}]
  if {$ret=="-1"} {
    set gaSet(fail) "No Operator Name"
    return $ret
  } else {
    set gaSet(operator) $ret
    return 0
  }

}   
# ***************************************************************************
# ToggleUCF
# ***************************************************************************
proc ToggleUCF {} {
  global gaTmpSet
  puts "ToggleUCF ::chbUcf:<$::chbUcf>"
  if {$::chbUcf && ($gaTmpSet(DefaultCF)=="" || $gaTmpSet(DefaultCF)=="c:/aa")} {  
    set gaTmpSet(DefaultCF) "UserDefConf_exists"
  } else {
    set gaTmpSet(DefaultCF) ""
  }
}