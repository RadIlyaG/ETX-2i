wm iconify . ; update
## delete barcode files TO3001483079.txt
foreach fi [glob -nocomplain -type f *.txt] {
  if [regexp {\w{2}\d{9,}} $fi] {
    file delete -force $fi
  }
}
if [file exists c:/TEMP_FOLDER] {
  file delete -force c:/TEMP_FOLDER
}
source lib_DeleteOldApp.tcl
DeleteOldApp

after 1000
set ::RadAppsPath c:/RadApps

if 1 {
  set gaSet(radNet) 0
  foreach {jj ip} [regexp -all -inline {v4 Address[\.\s\:]+([\d\.]+)} [exec ipconfig]] {
    if {[string match {*192.115.243.*} $ip] || [string match {*172.18.9*} $ip]} {
      set gaSet(radNet) 1
    }  
  }
  if {$gaSet(radNet)} {
    set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/autosyncapp/rlautosync.tcl]
    set mTimeRL  [file mtime c:/tcl/lib/rl/rlautosync.tcl]
    puts "mTimeTds:$mTimeTds mTimeRL:$mTimeRL"
    if {$mTimeTds>$mTimeRL} {
      puts "$mTimeTds>$mTimeRL"
      file copy -force //prod-svm1/tds/install/ateinstall/jate_team/autosyncapp/rlautosync.tcl c:/tcl/lib/rl
      after 2000
    }
    set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/autoupdate/rlautoupdate.tcl]
    set mTimeRL  [file mtime c:/tcl/lib/rl/rlautoupdate.tcl]
    puts "mTimeTds:$mTimeTds mTimeRL:$mTimeRL"
    if {$mTimeTds>$mTimeRL} {
      puts "$mTimeTds>$mTimeRL"
      file copy -force //prod-svm1/tds/install/ateinstall/jate_team/autoupdate/rlautoupdate.tcl c:/tcl/lib/rl
      after 2000
    }
    if 1 {
      set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/LibUrl_WS/LibUrl.tcl]
      set mTimePwd  [file mtime [pwd]/LibUrl.tcl]
      puts "mTimeTds:$mTimeTds mTimePwd:$mTimePwd"
      if {$mTimeTds>$mTimePwd} {
        puts "$mTimeTds>$mTimePwd"
        file copy -force //prod-svm1/tds/install/ateinstall/jate_team/LibUrl_WS/LibUrl.tcl ./
        after 2000
      }
    }
    update
  }
  
  package require RLAutoSync
  
  #set s1 [file normalize //prod-svm1/tds/Temp/ilya/shared/ETX-2i/AT-ETX-2i/AT-ETX-2i_v1]
  set s1 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/ETX-2i/AT-ETX-2i]
  set d1 [file normalize  C:/AT-ETX-2i]
  set s2 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/ETX-2i/download]
  set d2 [file normalize  C:/download]
  
  if {$gaSet(radNet)} {
    set emailL {{yulia_s@rad.com} {} {}}
  } else {
    set emailL [list]
  }
  
  set ret [RLAutoSync::AutoSync "$s1 $d1 $s2 $d2" -noCheckFiles {init*.tcl skipped.txt  *.db} \
  -noCheckDirs {temp OLD old} -jarLocation $::RadAppsPath -javaLocation $gaSet(javaLocation) \
  -emailL $emailL -putsCmd 1  -radNet $gaSet(radNet)]
  #console show
  puts "ret:<$ret>"
  set gsm $gMessage
  foreach gmess $gMessage {
    puts "$gmess"
  }
  update
  if {$ret=="-1"} {
    set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
    -message "The AutoSync process did not perform successfully.\n\n\
    Do you want to continue? "]
    if {$res=="no"} {
      SQliteClose
      exit
    }
  }
  
  if {$gaSet(radNet)} {
    package require RLAutoUpdate
    set s2 [file normalize W:/winprog/ATE]
    set d2 [file normalize $::RadAppsPath]
    set ret [RLAutoUpdate::AutoUpdate "$s2 $d2" \
        -noCopyGlobL {Get_Li* Macreg.2* Macreg-i* DP* *.prd}]
    #console show
    puts "ret:<$ret>"
    set gsm $gMessage
    foreach gmess $gMessage {
      puts "$gmess"
    }
    update
    if {$ret=="-1"} {
      set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
      -message "The AutoSync process did not perform successfully.\n\n\
      Do you want to continue? "]
      if {$res=="no"} {
        #SQliteClose
        exit
      }
    }
  }
}

package require BWidget
package require img::ico
package require RLSerial
package require RLEH
package require RLTime
package require RLStatus
package require RLEtxGen
package require RLUsbPio
package require RLUsbMmux
package require RLSound
package require RLCom
RLSound::Open ; # [list failbeep fail.wav passbeep pass.wav beep warning.wav]
#package require RLScotty ; #RLTcp
package require ezsmtp
package require http
package require RLAutoUpdate
package require registry
set gaSet(hostDescription) [registry get "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" srvcomment ]
package require sqlite3
package require twapi

source Gui_Etx2i.tcl
source Main_Etx2i.tcl
source Lib_Put_Etx2i.tcl
source Lib_Gen_Etx2i.tcl
source [info host]/init$gaSet(pair).tcl
source lib_bc.tcl
source Lib_DialogBox.tcl
source Lib_FindConsole.tcl
source LibEmail.tcl
source LibIPRelay.tcl
source Lib_Etx204.tcl
source Lib_Ds280e01_Etx2i.tcl
source lib_DeleteOldApp.tcl
DeleteOldApp
source lib_SQlite.tcl
source LibUrl.tcl
source Lib_GetOperator.tcl
#console show
if [file exists uutInits/$gaSet(DutInitName)] {
  source uutInits/$gaSet(DutInitName)
} else {
  source [lindex [glob uutInits/ETX*.tcl] 0]
}
source Lib_Ramzor.tcl
source lib_EcoCheck.tcl

set gaSet(act) 1
set gaSet(initUut) 1
set gaSet(oneTest)    0
set gaSet(puts) 1
set gaSet(noSet) 0

set gaSet(toTestClr)    #aad5ff
set gaSet(toNotTestClr) SystemButtonFace
set gaSet(halfPassClr)  #ccffcc

set gaSet(useExistBarcode) 0

set gaSet(DGTestQty) 3
# if {![info exists gaSet(DGTestQty)]} {
#   set gaSet(DGTestQty) 1
# }
set gaSet(DGTestLoopBreak) 1

if {![info exists gaSet(performDownloadSteps)]} {
  set gaSet(performDownloadSteps) 1
}


set gaSet(relDebMode) Release
set gaSet(cbTesterMode) "FTI"

# if {![info exists gaSet(DGTestLoopBreak)]} {
#   set gaSet(DGTestLoopBreak) 1
# }
#set gaSet(1.barcode1) CE100025622

set gaSet(manSfp) 1


GUI
#ToggleTestMode
# BuildTests
update

wm deiconify .
wm geometry . $gaGui(xy)
update

Status "Ready"
#set ret [SQliteOpen]