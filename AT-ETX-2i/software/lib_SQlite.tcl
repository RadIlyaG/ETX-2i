# ***************************************************************************
# SQliteOpen
# ***************************************************************************
proc SQliteOpen {} {
  global gaSet
  puts "[MyTime] SQliteOpen" ; update 
  if {$gaSet(radNet)} {  
    set dbFile \\\\prod-svm1\\tds\\temp\\SQLiteDB\\JerAteStats.db
    if ![file exists $dbFile] {
      set gaSet(fail) "No DataBase file or it's not reachable"
      return -1
    }
    sqlite3 gaSet(dataBase) $dbFile 
    gaSet(dataBase) timeout 5000
    
    set res [gaSet(dataBase) eval {SELECT name FROM sqlite_master WHERE type='table' AND name='tbl'}]
    if {$res==""} {
      gaSet(dataBase) eval {CREATE TABLE tbl(Barcode, UutName, HostDescription, Date, Time, Status, FailTestsList, FailDescription, DealtByServer)}
    }
    puts "[MyTime] DataBase is open well!"  
  } else {
    puts "[MyTime] DataBase is not open - out of RadNet"
    return -1
  }  
  return 0
}
# ***************************************************************************
# SQliteClose
# ***************************************************************************
proc SQliteClose {} {
  global gaSet
  puts "[MyTime] SQliteClose" ; update
  catch {gaSet(dataBase) close}
}
# ***************************************************************************
# SQliteAddLine
# ***************************************************************************
proc SQliteAddLine {} {
  global gaSet
  if $::repairMode {return 0}
  
  set barcode $gaSet(1.barcode1)
  puts "[MyTime] SQliteAddLine $barcode"
  if {[string match *skip* $barcode]} {
    ## do not include skipped in stats
    return 0
  }
  if {$gaSet(1.barcode1.IdMacLink)=="link"} {
    ## do not report about passed unit
    ## 10:10 04/10/2023 return 0
  }
  set uut $gaSet(DutFullName)
  set hostDescription $gaSet(hostDescription)
  set stopTime [clock seconds]
  if ![info exist gaSet(ButRunTime)] {
    set gaSet(ButRunTime) [expr {$stopTime - 600}]
  }
  foreach {date tim} [split [clock format $stopTime -format "%Y.%m.%d %H:%M:%S"] " "] {break}
  #foreach {date tim} [split [clock format [clock seconds] -format "%Y.%m.%d %H.%M.%S"] " "] {break}
  set status $gaSet(runStatus)
  if {$status=="Pass"} {
    set failTestsList ""
    set failReason ""
  } else {
    set failTestsList [lindex [split $gaSet(curTest) ..] end]
    set failReason $gaSet(fail)
  }   
  
  if [info exists gaSet(operator)] {
    set operator $gaSet(operator) 
  } else {
    set operator 0
  }
  
  # set poNumber ""
  # set traceID ""
  # foreach {ret resTxt} [::RLWS::Get_TraceId $barcode] {}
  # if {[info exists gaSet(1.traceId)] && $gaSet(1.traceId)!=""} {
    # set traceID $gaSet(1.traceId)
  # } elseif {$ret==0} {
    # set traceID $resTxt
  # }
  # if {$traceID!=""} {
    # foreach {ret resTxt} [::RLWS::Get_PcbTraceIdData $traceID  {"po number"}] {}
    # if {$ret!="0"} {
      # set poNumber ""
    # } else {
      # set poNumber $resTxt
    # }  
  # }
  
  if {$gaSet(1.traceId)==""} {    
    set poNumber ""
    set traceID ""
  } else {
    set traceID $gaSet(1.traceId)
    foreach {ret resTxt} [::RLWS::Get_PcbTraceIdData $gaSet(1.traceId) {"po number"}] {}
    if {$ret!="0"} {
      set poNumber ""
    } else {
      set poNumber $resTxt
    }
  } 

  for {set tr 1} {$tr <= 6} {incr tr} {
    #if [catch {UpdateDB $barcode $uut $hostDescription $date $tim-$gaSet(ButRunTime) $status $failTestsList $failReason $operator} res] {}
    #if [catch {::RLWS::UpdateDB2 $barcode $uut $hostDescription $date $tim-$gaSet(ButRunTime) $status $failTestsList $failReason $operator $traceID $poNumber "" "" ""} res] {}
    foreach {ret resTxt} [::RLWS::UpdateDB2  $barcode $uut $hostDescription \
            $date $tim-$gaSet(ButRunTime) $status $failTestsList $failReason $operator\
            $traceID $poNumber [info host] "" ""] {}
    if {$ret!=0} {
      set res "Try${tr}_fail.$resTxt"
      puts "[MyTime] Web DataBase is not updated. Try:<$tr>. Res:<$resTxt>" ; update
      after [expr {int(rand()*3000+60)}] 
    } else {
      puts "[MyTime] Web DataBase is updated well!"
      set res "Try $tr passed"
      break
    }
  }
  
  #03/01/2021 07:47:55
#   set ret [SQliteOpen]
#   if {$ret!=0} {return $ret}
#   for {set tr 1} {$tr <= 6} {incr tr} {
#     if [catch {gaSet(dataBase) eval {INSERT INTO tbl VALUES($barcode,$uut,$hostDescription,$date,$tim,$status,$failTestsList,$failReason,$operator)}} res] {
#       set res "Try${tr}_fail.$res"
#       puts "[MyTime] DataBase is not updated. Try:<$tr>. Res:<$res>" ; update
# #       if {$tr==4} {
# #         SQliteClose
# #         after 1000
# #         SQliteOpen        
# #       }
#       after [expr {int(rand()*3000+60)}]  
#     } else {
#       puts "[MyTime] DataBase is updated well!"
#       set res "Try $tr passed"
#       break
#     }
#   }
#   SQliteClose

  set id [open c:/logs/logsStatus.txt a+]
    puts $id "$barcode,$uut,$hostDescription,$date,$tim,$status,$failTestsList,$failReason,$operator  res:<$res>"
  close $id  
  
  if ![string match *passed* $res] {
    if [catch {open //prod-svm1/tds/temp/DbLocked/[regsub \/ $hostDescription .]_$gaSet(pair).txt a+} id] {
      puts "[MyTime] $id"
    } else {
      puts $id "$barcode,$uut,$hostDescription,$date,$tim,$status,$failTestsList,$failReason,$operator  res:<$res>"   
      close $id
    }
  }
  
  
  return 0 
}
# ***************************************************************************
# AddLine
# ***************************************************************************
proc AddLine {} {
  global gaSet
  set gaSet(radNet) 1
  set barcode DE1005790454
  set gaSet(1.barcode1.IdMacLink) "noLink"
  set uut IlyaGinzburg
  set hostDescription $gaSet(hostDescription)
  set status Pass
  set gaSet(pair) wert
  set failTestsList sdfsdf
  set failReason sadas
  foreach {date tim} [split [clock format [clock seconds] -format "%Y.%m.%d %H:%M:%S"] " "] {break}
  set operator "ILYA GINZBURG"
  
  for {set tr 1} {$tr <= 6} {incr tr} {
    if [catch {UpdateDB $barcode $uut $hostDescription $date $tim $status $failTestsList $failReason $operator} res] {
      set res "Try${tr}_fail.$res"
      puts "[MyTime] Web DataBase is not updated. Try:<$tr>. Res:<$res>" ; update
      after [expr {int(rand()*3000+60)}] 
    } else {
      puts "[MyTime] Web DataBase is updated well!"
      set res "Try $tr passed"
      break
    }
  }
  
  if ![string match *passed* $res] {
    if [catch {open //prod-svm1/tds/temp/DbLocked/[regsub \/ $hostDescription .]_$gaSet(pair).txt a+} id] {
      puts "[MyTime] $id"
    } else {
      puts $id "$barcode,$uut,$hostDescription,$date,$tim,$status,$failTestsList,$failReason,0  res:<$res>"   
      close $id
    }
  }
}
# ***************************************************************************
# MyTime
# ***************************************************************************
proc MyTime {} {
  return [clock format [clock seconds] -format "%T   %d/%m/%Y"]
}
