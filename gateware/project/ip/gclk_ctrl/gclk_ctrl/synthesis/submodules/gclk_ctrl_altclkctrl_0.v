//altclkctrl CBX_SINGLE_OUTPUT_FILE="ON" CLOCK_TYPE="Global Clock" DEVICE_FAMILY="Cyclone V" USE_GLITCH_FREE_SWITCH_OVER_IMPLEMENTATION="OFF" ena inclk outclk
//VERSION_BEGIN 16.1 cbx_altclkbuf 2016:11:30:18:10:07:SJ cbx_cycloneii 2016:11:30:18:10:07:SJ cbx_lpm_add_sub 2016:11:30:18:10:07:SJ cbx_lpm_compare 2016:11:30:18:10:07:SJ cbx_lpm_decode 2016:11:30:18:10:07:SJ cbx_lpm_mux 2016:11:30:18:10:07:SJ cbx_mgl 2016:11:30:18:11:28:SJ cbx_nadder 2016:11:30:18:10:07:SJ cbx_stratix 2016:11:30:18:10:07:SJ cbx_stratixii 2016:11:30:18:10:07:SJ cbx_stratixiii 2016:11:30:18:10:07:SJ cbx_stratixv 2016:11:30:18:10:07:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2016  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Intel and sold by Intel or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.



//synthesis_resources = cyclonev_clkena 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  gclk_ctrl_altclkctrl_0_sub
	( 
	ena,
	inclk,
	outclk) /* synthesis synthesis_clearbox=1 */;
	input   ena;
	input   [3:0]  inclk;
	output   outclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1   ena;
	tri0   [3:0]  inclk;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire  wire_sd1_outclk;
	wire [1:0]  clkselect;

	cyclonev_clkena   sd1
	( 
	.ena(ena),
	.enaout(),
	.inclk(inclk[0]),
	.outclk(wire_sd1_outclk));
	defparam
		sd1.clock_type = "Global Clock",
		sd1.ena_register_mode = "always enabled",
		sd1.lpm_type = "cyclonev_clkena";
	assign
		clkselect = {2{1'b0}},
		outclk = wire_sd1_outclk;
endmodule //gclk_ctrl_altclkctrl_0_sub
//VALID FILE // (C) 2001-2016 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  gclk_ctrl_altclkctrl_0  (
    inclk,
    outclk);

    input    inclk;
    output   outclk;

    wire  sub_wire0;
    wire  outclk;
    wire  sub_wire1;
    wire  sub_wire2;
    wire [3:0] sub_wire3;
    wire [2:0] sub_wire4;

    assign  outclk = sub_wire0;
    assign  sub_wire1 = 1'h1;
    assign  sub_wire2 = inclk;
    assign sub_wire3[3:0] = {sub_wire4, sub_wire2};
    assign sub_wire4[2:0] = 3'h0;

    gclk_ctrl_altclkctrl_0_sub  gclk_ctrl_altclkctrl_0_sub_component (
                .ena (sub_wire1),
                .inclk (sub_wire3),
                .outclk (sub_wire0));

endmodule