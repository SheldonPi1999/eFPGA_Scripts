# Create Block Design
if { $argc < 1 } { set bd_design "design_1"} else { set bd_design [lindex $argv 0] }

# Create Project in directory and name provided in args
create_bd_design $bd_design 
