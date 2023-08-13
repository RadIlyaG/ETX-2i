# ***************************************************************************
# DeleteOldApp
# ***************************************************************************
proc DeleteOldApp {} {
  foreach fol [glob -nocomplain -type d c:/download/*] {
    if {[string match -nocase {6.5.1(0.15)} [file tail $fol]]} {
      catch {file delete -force $fol}
    } 
    if {[string match -nocase {6.5.1(0.27)_FT} [file tail $fol]]} {
      catch {file delete -force $fol}
    }
    if {[string match -nocase {6.5.1(1.33)_FT} [file tail $fol]]} {
      catch {file delete -force $fol}
    }
  }
}

