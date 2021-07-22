// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// ******************************************************************************************************************************** 
// This file instantiates the PLL.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME common; -name IP_TOOL_VERSION 18.0; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)


module ddr3_av_2x32_pll0 (
	global_reset_n,
	pll_ref_clk,
	pll_mem_clk,
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
	pll_addr_cmd_clk,
	pll_avl_clk,
	pll_config_clk,
	pll_locked,
	afi_half_clk,
	pll_mem_phy_clk,
	afi_phy_clk,
	pll_avl_phy_clk,
	afi_clk
);


// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver. 
parameter DEVICE_FAMILY = "Cyclone V";

// choose between abstract (fast) and regular model
`ifndef ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL
  `define ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL 0
`endif

parameter ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL = `ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;

localparam FAST_SIM_MODEL = ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;


// Clock settings
parameter REF_CLK_FREQ = "125.0 MHz";
parameter REF_CLK_PERIOD_PS = 8000;

parameter PLL_AFI_CLK_FREQ_STR = "333.333333 MHz";
parameter PLL_MEM_CLK_FREQ_STR = "333.333333 MHz";
parameter PLL_WRITE_CLK_FREQ_STR = "333.333333 MHz";
parameter PLL_ADDR_CMD_CLK_FREQ_STR = "333.333333 MHz";
parameter PLL_AFI_HALF_CLK_FREQ_STR = "166.666666 MHz";
parameter PLL_NIOS_CLK_FREQ_STR = "66.666666 MHz";
parameter PLL_CONFIG_CLK_FREQ_STR = "22.222222 MHz";
parameter PLL_P2C_READ_CLK_FREQ_STR = "";
parameter PLL_C2P_WRITE_CLK_FREQ_STR = "";
parameter PLL_HR_CLK_FREQ_STR = "";
parameter PLL_DR_CLK_FREQ_STR = "";

parameter PLL_AFI_CLK_FREQ_SIM_STR = "3004 ps";
parameter PLL_MEM_CLK_FREQ_SIM_STR = "3004 ps";
parameter PLL_WRITE_CLK_FREQ_SIM_STR = "3004 ps";
parameter PLL_ADDR_CMD_CLK_FREQ_SIM_STR = "3004 ps";
parameter PLL_AFI_HALF_CLK_FREQ_SIM_STR = "6008 ps";
parameter PLL_NIOS_CLK_FREQ_SIM_STR = "15020 ps";
parameter PLL_CONFIG_CLK_FREQ_SIM_STR = "45060 ps";
parameter PLL_P2C_READ_CLK_FREQ_SIM_STR = "0 ps";
parameter PLL_C2P_WRITE_CLK_FREQ_SIM_STR = "0 ps";
parameter PLL_HR_CLK_FREQ_SIM_STR = "0 ps";
parameter PLL_DR_CLK_FREQ_SIM_STR = "0 ps";

parameter AFI_CLK_PHASE      = "0 ps";
parameter AFI_PHY_CLK_PHASE  = "0 ps";
parameter MEM_CLK_PHASE      = "0 ps";
parameter WRITE_CLK_PHASE    = "2250 ps";
parameter ADDR_CMD_CLK_PHASE = "2250 ps";
parameter AFI_HALF_CLK_PHASE = "0 ps";
parameter AVL_CLK_PHASE      = "375 ps";
parameter CONFIG_CLK_PHASE   = "0 ps";

parameter MEM_CLK_PHASE_SIM       = "0 ps";
parameter WRITE_CLK_PHASE_SIM     = "2252 ps";
parameter ADDR_CMD_CLK_PHASE_SIM  = "2252 ps";


parameter ABSTRACT_REAL_COMPARE_TEST = "false";

localparam SIM_FILESET = ("false" == "true");

localparam AFI_CLK_FREQ       = SIM_FILESET ? PLL_AFI_CLK_FREQ_SIM_STR : PLL_AFI_CLK_FREQ_STR;
localparam MEM_CLK_FREQ       = SIM_FILESET ? PLL_MEM_CLK_FREQ_SIM_STR : PLL_MEM_CLK_FREQ_STR;
localparam WRITE_CLK_FREQ     = SIM_FILESET ? PLL_WRITE_CLK_FREQ_SIM_STR : PLL_WRITE_CLK_FREQ_STR;
localparam ADDR_CMD_CLK_FREQ  = SIM_FILESET ? PLL_ADDR_CMD_CLK_FREQ_SIM_STR : PLL_ADDR_CMD_CLK_FREQ_STR;
localparam AFI_HALF_CLK_FREQ  = SIM_FILESET ? PLL_AFI_HALF_CLK_FREQ_SIM_STR : PLL_AFI_HALF_CLK_FREQ_STR;
localparam AVL_CLK_FREQ       = SIM_FILESET ? PLL_NIOS_CLK_FREQ_SIM_STR : PLL_NIOS_CLK_FREQ_STR;
localparam CONFIG_CLK_FREQ    = SIM_FILESET ? PLL_CONFIG_CLK_FREQ_SIM_STR : PLL_CONFIG_CLK_FREQ_STR;
localparam P2C_READ_CLK_FREQ  = SIM_FILESET ? PLL_P2C_READ_CLK_FREQ_SIM_STR : PLL_P2C_READ_CLK_FREQ_STR;
localparam C2P_WRITE_CLK_FREQ = SIM_FILESET ? PLL_C2P_WRITE_CLK_FREQ_SIM_STR : PLL_C2P_WRITE_CLK_FREQ_STR;
localparam HR_CLK_FREQ        = SIM_FILESET ? PLL_HR_CLK_FREQ_SIM_STR : PLL_HR_CLK_FREQ_STR;
localparam DR_CLK_FREQ        = SIM_FILESET ? PLL_DR_CLK_FREQ_SIM_STR : PLL_DR_CLK_FREQ_STR;


// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION


input	pll_ref_clk;		// PLL reference clock

// When the PHY is selected to be a PLL/DLL MASTER, the PLL and DLL are instantied on this top level
wire	pll_afi_clk /* synthesis keep */;		// See pll_memphy instantiation below for detailed description of each clock

output	pll_mem_clk;
output	pll_write_clk;
output	pll_write_clk_pre_phy_clk;
output	pll_addr_cmd_clk;
output	pll_avl_clk;
output	pll_config_clk;
output	pll_locked;    // When 0, PLL is out of lock
                       // should be used to reset system level afi_clk domain logic



// Reset Interface, AFI 2.0
input   global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)



// PLL Interface
output	afi_clk;
output	afi_half_clk;

wire	pll_afi_half_clk;

output	pll_mem_phy_clk;
output	afi_phy_clk;
output	pll_avl_phy_clk;



// END PARAMETER SECTION
// ******************************************************************************************************************************** 

initial $display("Using %0s pll emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


	wire fbout;
	

	generic_pll pll1 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_afi_clk),
		.fboutclk(fbout),
		.locked(pll_locked),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll1.reference_clock_frequency = REF_CLK_FREQ,
		pll1.output_clock_frequency = AFI_CLK_FREQ,
		pll1.phase_shift = AFI_CLK_PHASE,
		pll1.duty_cycle = 50;
		
	generic_pll pll1_phy (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(afi_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								

	);	
	defparam pll1_phy.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll1_phy.output_clock_frequency = AFI_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll1_phy.phase_shift = AFI_CLK_PHASE;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll1_phy.phase_shift = AFI_CLK_PHASE;
`else
	// defparam pll1_phy.phase_shift = AFI_PHY_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll1_phy.duty_cycle = 50;
	
	generic_pll pll2 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								

	);	
	defparam pll2.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll2.output_clock_frequency = MEM_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll2.phase_shift = MEM_CLK_PHASE_SIM;
`else
	// defparam pll2.phase_shift = MEM_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll2.duty_cycle = 50;
			
	generic_pll pll2_phy (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_mem_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll2_phy.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll2_phy.output_clock_frequency = MEM_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll2_phy.phase_shift = MEM_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll2_phy.phase_shift = MEM_CLK_PHASE_SIM;
`else
	// defparam pll2_phy.phase_shift = MEM_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll2_phy.duty_cycle = 50;

	generic_pll pll3 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_write_clk_pre_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll3.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll3.output_clock_frequency = WRITE_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll3.phase_shift = WRITE_CLK_PHASE_SIM;
`else
	// defparam pll3.phase_shift = WRITE_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll3.duty_cycle = 50;

	generic_pll pll4 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_addr_cmd_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll4.reference_clock_frequency = REF_CLK_FREQ;
	defparam pll4.output_clock_frequency = ADDR_CMD_CLK_FREQ;
	// The following is evaluated for RTL simulation
	// synthesis translate_off
	defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE_SIM;
	// synthesis translate_on
	// The following is evaluated for physical realization 	
	// synthesis read_comments_as_HDL on
`ifdef SYNTH_FOR_SIM
	// defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE_SIM;
`else
	// defparam pll4.phase_shift = ADDR_CMD_CLK_PHASE;
`endif
	// synthesis read_comments_as_HDL off
	defparam pll4.duty_cycle = 50;

	generic_pll pll5 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_afi_half_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll5.reference_clock_frequency = REF_CLK_FREQ,
		pll5.output_clock_frequency = AFI_HALF_CLK_FREQ,
		pll5.phase_shift = AFI_HALF_CLK_PHASE,
		pll5.duty_cycle = 50;
	 
	generic_pll pll6 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_avl_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll6.reference_clock_frequency = REF_CLK_FREQ,
		pll6.output_clock_frequency = AVL_CLK_FREQ,
		pll6.phase_shift = AVL_CLK_PHASE,
		pll6.duty_cycle = 50;
		
	generic_pll pll6_phy (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_avl_phy_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll6_phy.reference_clock_frequency = REF_CLK_FREQ,
		pll6_phy.output_clock_frequency = AVL_CLK_FREQ,
		pll6_phy.phase_shift = AVL_CLK_PHASE,
		pll6_phy.duty_cycle = 50;

	generic_pll pll7 (
		.refclk({pll_ref_clk}),
		.rst(~global_reset_n),
		.fbclk(fbout),
		.outclk(pll_config_clk),
		.fboutclk(),
		.locked(),
		.writerefclkdata(),
    .writeoutclkdata(),
    .writephaseshiftdata(), 
		.writedutycycledata(),
		.readrefclkdata(),
    .readoutclkdata(),
    .readphaseshiftdata(),
    .readdutycycledata()								
	);	
	defparam pll7.reference_clock_frequency = REF_CLK_FREQ,
		pll7.output_clock_frequency = CONFIG_CLK_FREQ,
		pll7.phase_shift = CONFIG_CLK_PHASE,
		pll7.duty_cycle = 50;
		
		


`ifndef SIMGEN		
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
`else 
	assign pll_write_clk = pll_write_clk_pre_phy_clk;
`endif 




	// Clock descriptions
	// pll_afi_clk: full-rate clock, 0 degree phase shift, clock for AFI interface logic
	// pll_mem_clk: full-rate clock, 0 degree phase shift, clock output to memory
	// pll_write_clk: full-rate clock, -90 degree phase shift, clocks write data out to memory
	// pll_addr_cmd_clk: full-rate clock, inverted version (180 degree phase shift) of pll_afi_clk, clocks address/command out to memory
	//					 In the special case of QDRII, BL2, address/command is double data rate (same as write data)
	//					 pll_addr_cmd_clk will have -90 degree phase shift (same as write clock)
	// pll_afi_half_clk: half-rate clock, 0 degree phase shift
	// the purpose of these clock settings is so that address/command/write data are centred aligned with the output clock(s) to memory 

	assign afi_clk = pll_afi_clk;

	assign afi_half_clk = pll_afi_half_clk;


endmodule

