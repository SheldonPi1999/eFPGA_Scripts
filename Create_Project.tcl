# 0 - Set Direction and Project Name
# Command: vivado -mode batch -nolog -nojournal -notrace -source Create_Project.tcl -tclargs NAME DIR

set jobs 8

if { $argc < 2 } {
  if { $argc == 1 } {
    puts "Generating with set project name."
    set project_name [lindex $argv 0]
    set outputDir "C:/eFPGA/"
  } else {
    puts "Generating Generic project ..."
    set project_name "Generic"
    set outputDir "C:/eFPGA/"
  }
} else {
  puts "Generating project ..."
  set project_name [lindex $argv 0]
  set outputDir [lindex $argv 1]
}

append outputDir $project_name

file mkdir $outputDir

cd $outputDir

#---------------------------------------------------------------------------

## 1 - Configure Project settings
puts "Configuring the setttings... \n"
create_project $project_name -part xc7z007sclg225-1
set_property board_part em.avnet.com:minized:part0:1.2 [current_project]
set_property target_language VHDL [current_project]

#---------------------------------------------------------------------------

## 2 - Create Block design
puts "\nCreating block design..."
create_bd_design "design_1"

#---------------------------------------------------------------------------

## 3 - Add Zynq Processing system on block design and run Block automation
puts "\nCreating Zynq Processing system ..."
update_compile_order -fileset sources_1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

puts "\nRunning Block Automation ..."
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } [get_bd_cells processing_system7_0]

#---------------------------------------------------------------------------

## 4 - Create VHDL Wrapper file
puts "\nCreating VHDL Wrapper..."
set wrapperDir ""
set addDir ""

append wrapperDir $outputDir
append wrapperDir "/"
append wrapperDir $project_name
append wrapperDir ".srcs/sources_1/bd/design_1"
set addFiles $wrapperDir
append wrapperDir "/design_1.bd"
append addFiles "/hdl/design_1_wrapper.vhd"

make_wrapper -files [get_files $wrapperDir] -top 
add_files -norecurse $addFiles

#---------------------------------------------------------------------------

# !!!!!!!!!!!!!!!!!!!!!!!!!! NOT WORKING !!!!!!!!!!!!!!!!!!!!!!!!!!
## 5 - Configure Zynq System GPIO WIDTH (8) AND PS/PL
# puts "\n Configuring GPIO WIDTH (8) AND PS/PL ..."
# startgroup
# set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1} CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} CONFIG.PCW_GPIO_EMIO_GPIO_IO {8}] [get_bd_cells processing_system7_0]
# endgroup

#---------------------------------------------------------------------------

## 5 - Generate Bitstream
puts "\n Generating bitstream ..."
launch_runs impl_1 -to_step write_bitstream -jobs $jobs

#---------------------------------------------------------------------------

## 6 - Run implementation


#---------------------------------------------------------------------------

## 7 - Generate .XSA file
puts "\nGenerating XSA File ..."
set XSADir ""

append XSADir $outputDir
append XSADir "/design_1_wrapper.xsa"

puts "\nExporting Hardware ..."
puts $XSADir

update_compile_order -fileset sources_1
write_hw_platform -fixed -force -include_bit -file $XSADir
# write_hw_platform -fixed -force  -include_bit -file C:/eFPGA/TEST_Oefening8/design_1_wrapper.xsa
#--------------------------------------------------------------------------- NE VETTIGE LAG HUAHAHAHA ---------



#vivado -gui






































































