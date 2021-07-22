
# (C) 2001-2018 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 18.0 614 win32 2018.11.02.10:23:49
# ----------------------------------------
# Auto-generated simulation script rivierapro_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     ddr3_av_2x32
# 
# Altera recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Altera simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "aldec.do", and modify the text as directed.
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# set QSYS_SIMDIR <script generation output directory>
# #
# # Source the generated IP simulation script.
# source $QSYS_SIMDIR/aldec/rivierapro_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# set USER_DEFINED_VHDL_COMPILE_OPTIONS <compilation options for VHDL>
# set USER_DEFINED_VERILOG_COMPILE_OPTIONS <compilation options for Verilog>
# #
# # Call command to compile the Quartus EDA simulation library.
# dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
# com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #
# vlog -sv2k5 <your compilation options> <design and testbench files>
# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
# #
# set TOP_LEVEL_NAME <simulation top>
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
# elab
# #
# # Run the simulation.
# run
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If ddr3_av_2x32 is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Altera IP
# within the Quartus project, and generate a unified
# script which supports all the Altera IP within the design.
# ----------------------------------------

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "ddr3_av_2x32"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "C:/intelfpga_lite/18.0/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_VHDL_COMPILE_OPTIONS] { 
  set USER_DEFINED_VHDL_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_VERILOG_COMPILE_OPTIONS] { 
  set USER_DEFINED_VERILOG_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

set Aldec "Riviera"
if { [ string match "*Active-HDL*" [ vsim -version ] ] } {
  set Aldec "Active"
}

if { [ string match "Active" $Aldec ] } {
  scripterconf -tcl
  createdesign "$TOP_LEVEL_NAME"  "."
  opendesign "$TOP_LEVEL_NAME"
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
  file copy -force $QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_AC_ROM.hex ./
  file copy -force $QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_inst_ROM.hex ./
  file copy -force $QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_sequencer_mem.hex ./
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries     
ensure_lib      ./libraries/work
vmap       work ./libraries/work
ensure_lib                       ./libraries/altera_ver           
vmap       altera_ver            ./libraries/altera_ver           
ensure_lib                       ./libraries/lpm_ver              
vmap       lpm_ver               ./libraries/lpm_ver              
ensure_lib                       ./libraries/sgate_ver            
vmap       sgate_ver             ./libraries/sgate_ver            
ensure_lib                       ./libraries/altera_mf_ver        
vmap       altera_mf_ver         ./libraries/altera_mf_ver        
ensure_lib                       ./libraries/altera_lnsim_ver     
vmap       altera_lnsim_ver      ./libraries/altera_lnsim_ver     
ensure_lib                       ./libraries/cyclonev_ver         
vmap       cyclonev_ver          ./libraries/cyclonev_ver         
ensure_lib                       ./libraries/cyclonev_hssi_ver    
vmap       cyclonev_hssi_ver     ./libraries/cyclonev_hssi_ver    
ensure_lib                       ./libraries/cyclonev_pcie_hip_ver
vmap       cyclonev_pcie_hip_ver ./libraries/cyclonev_pcie_hip_ver
ensure_lib                       ./libraries/altera               
vmap       altera                ./libraries/altera               
ensure_lib                       ./libraries/lpm                  
vmap       lpm                   ./libraries/lpm                  
ensure_lib                       ./libraries/sgate                
vmap       sgate                 ./libraries/sgate                
ensure_lib                       ./libraries/altera_mf            
vmap       altera_mf             ./libraries/altera_mf            
ensure_lib                       ./libraries/altera_lnsim         
vmap       altera_lnsim          ./libraries/altera_lnsim         
ensure_lib                       ./libraries/cyclonev             
vmap       cyclonev              ./libraries/cyclonev             
ensure_lib              ./libraries/dll0        
vmap       dll0         ./libraries/dll0        
ensure_lib              ./libraries/oct0        
vmap       oct0         ./libraries/oct0        
ensure_lib              ./libraries/c0          
vmap       c0           ./libraries/c0          
ensure_lib              ./libraries/s0          
vmap       s0           ./libraries/s0          
ensure_lib              ./libraries/p0          
vmap       p0           ./libraries/p0          
ensure_lib              ./libraries/pll0        
vmap       pll0         ./libraries/pll0        
ensure_lib              ./libraries/ddr3_av_2x32
vmap       ddr3_av_2x32 ./libraries/ddr3_av_2x32

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  eval vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                    -work altera_ver           
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                             -work lpm_ver              
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                -work sgate_ver            
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                            -work altera_mf_ver        
  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                        -work altera_lnsim_ver     
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_atoms_ncrypt.v"          -work cyclonev_ver         
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_hmi_atoms_ncrypt.v"      -work cyclonev_ver         
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_atoms.v"                       -work cyclonev_ver         
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_hssi_atoms_ncrypt.v"     -work cyclonev_hssi_ver    
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_hssi_atoms.v"                  -work cyclonev_hssi_ver    
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_pcie_hip_atoms_ncrypt.v" -work cyclonev_pcie_hip_ver
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_pcie_hip_atoms.v"              -work cyclonev_pcie_hip_ver
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_syn_attributes.vhd"              -work altera               
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_standard_functions.vhd"          -work altera               
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/alt_dspbuilder_package.vhd"             -work altera               
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_europa_support_lib.vhd"          -work altera               
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives_components.vhd"       -work altera               
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.vhd"                  -work altera               
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/220pack.vhd"                            -work lpm                  
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.vhd"                           -work lpm                  
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate_pack.vhd"                         -work sgate                
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.vhd"                              -work sgate                
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf_components.vhd"               -work altera_mf            
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.vhd"                          -work altera_mf            
  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                        -work altera_lnsim         
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim_components.vhd"            -work altera_lnsim         
  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/cyclonev_atoms_ncrypt.v"          -work cyclonev             
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_atoms.vhd"                     -work cyclonev             
  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QUARTUS_INSTALL_DIR/eda/sim_lib/cyclonev_components.vhd"                -work cyclonev             
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_dll_cyclonev.sv"                                                -work dll0        
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_oct_cyclonev.sv"                                                -work oct0        
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_hard_memory_controller_top_cyclonev.sv"                         -work c0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0.vhd"                                                          -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/altera_avalon_sc_fifo.v"                                                      -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst.v"                                -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst_test_bench.v"                     -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_sequencer_mem_no_ifdef_params.sv"                               -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_sequencer_rst.sv"                                               -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_mem_if_simple_avalon_mm_bridge.sv"                                     -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_merlin_arbitrator.sv"                                                  -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altera_merlin_master_translator.sv"                                           -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_irq_mapper.sv"                                                -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0.vhd"                                        -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_avalon_st_adapter.vhd"                      -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv"       -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_cmd_demux.sv"                               -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_cmd_demux_001.sv"                           -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_cmd_mux.sv"                                 -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_cmd_mux_001.sv"                             -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_cpu_inst_data_master_translator.vhd"        -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_cpu_inst_instruction_master_translator.vhd" -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_hphy_bridge_s0_translator.vhd"              -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_router.sv"                                  -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_router_001.sv"                              -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_router_002.sv"                              -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_router_003.sv"                              -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_rsp_demux_001.sv"                           -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_rsp_mux.sv"                                 -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_rsp_mux_001.sv"                             -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_sequencer_mem_s1_translator.vhd"            -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_sequencer_reg_file_inst_avl_translator.vhd" -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_s0_mm_interconnect_0_sequencer_scc_mgr_inst_avl_translator.vhd"  -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_reg_file.sv"                                                        -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_acv_phase_decode.v"                                             -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_acv_wrapper.sv"                                                 -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_mgr.sv"                                                         -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_reg_file.v"                                                     -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_siii_phase_decode.v"                                            -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_siii_wrapper.sv"                                                -work s0          
  eval  vlog -v2k5 $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_sv_phase_decode.v"                                              -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/sequencer_scc_sv_wrapper.sv"                                                  -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/aldec/altera_merlin_burst_uncompressor.sv"                                    -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/aldec/altera_merlin_master_agent.sv"                                          -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/aldec/altera_merlin_slave_agent.sv"                                           -work s0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/aldec/altera_merlin_slave_translator.sv"                                      -work s0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_p0.vho"                                                          -work p0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_p0_altdqdqs.vhd"                                                 -work p0          
  eval  vlog  $USER_DEFINED_VERILOG_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS      "$QSYS_SIMDIR/ddr3_av_2x32/altdq_dqs2_acv_connect_to_hard_phy_cyclonev.sv"                               -work p0          
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_pll0.vho"                                                        -work pll0        
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_pll0_sim_delay.vhd"                                              -work pll0        
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32/ddr3_av_2x32_0002.vhd"                                                        -work ddr3_av_2x32
  eval  vcom $USER_DEFINED_VHDL_COMPILE_OPTIONS $USER_DEFINED_COMPILE_OPTIONS          "$QSYS_SIMDIR/ddr3_av_2x32.vhd"                                                                                            
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim +access +r -t ps $ELAB_OPTIONS -L work -L dll0 -L oct0 -L c0 -L s0 -L p0 -L pll0 -L ddr3_av_2x32 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with -dbg -O2 option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -dbg -O2 +access +r -t ps $ELAB_OPTIONS -L work -L dll0 -L oct0 -L c0 -L s0 -L p0 -L pll0 -L ddr3_av_2x32 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -dbg -O2
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                                         -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                                           -- Compile device library files"
  echo
  echo "com                                               -- Compile the design files in correct order"
  echo
  echo "elab                                              -- Elaborate top level design"
  echo
  echo "elab_debug                                        -- Elaborate the top level design with -dbg -O2 option"
  echo
  echo "ld                                                -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                                          -- Compile all the design files and elaborate the top level design with -dbg -O2"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                                    -- Top level module name."
  echo "                                                     For most designs, this should be overridden"
  echo "                                                     to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME                              -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                                       -- Platform Designer base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR                               -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS                      -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS                         -- User-defined elaboration options, added to elab/elab_debug aliases."
  echo
  echo "USER_DEFINED_VHDL_COMPILE_OPTIONS                 -- User-defined vhdl compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_VERILOG_COMPILE_OPTIONS              -- User-defined verilog compile options, added to com/dev_com aliases."
}
file_copy
h
