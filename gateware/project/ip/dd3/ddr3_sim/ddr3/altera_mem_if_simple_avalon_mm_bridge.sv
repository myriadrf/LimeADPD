// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.




`timescale 1ps/1ps

module altera_mem_if_simple_avalon_mm_bridge (
	clk,
	reset_n,
	s0_address,
	s0_read,
	s0_readdata,
	s0_write,
	s0_writedata,
	s0_waitrequest,
	s0_waitrequest_n,
	s0_byteenable,
	s0_beginbursttransfer,
	s0_burstcount,
	s0_readdatavalid,
	m0_address,
	m0_read,
	m0_readdata,
	m0_write,
	m0_writedata,
	m0_waitrequest,
	m0_byteenable,
	m0_beginbursttransfer,
	m0_burstcount,
	m0_readdatavalid
);

    parameter DATA_WIDTH    = 32;
    parameter MASTER_DATA_WIDTH    = 32;
    parameter SLAVE_DATA_WIDTH    = 32;
    parameter SYMBOL_WIDTH  = 8;
	parameter ADDRESS_WIDTH = 10;
	parameter BURSTCOUNT_WIDTH = 1;
	parameter MASTER_ADDRESS_WIDTH = 10;
	parameter SLAVE_ADDRESS_WIDTH = 10;
	parameter WORKAROUND_HARD_PHY_ISSUE = 0;

	localparam USE_DIFFERENT_MASTER_SLAVE_ADDR = (MASTER_ADDRESS_WIDTH != SLAVE_ADDRESS_WIDTH ? 1 : 0);
	localparam S0_ADDR_WIDTH = (USE_DIFFERENT_MASTER_SLAVE_ADDR ? SLAVE_ADDRESS_WIDTH : ADDRESS_WIDTH);
	localparam M0_ADDR_WIDTH = (USE_DIFFERENT_MASTER_SLAVE_ADDR ? MASTER_ADDRESS_WIDTH : ADDRESS_WIDTH);
	localparam USE_DIFFERENT_MASTER_SLAVE_DATA = (MASTER_DATA_WIDTH != SLAVE_DATA_WIDTH ? 1 : 0);
	localparam S0_DATA_WIDTH = (USE_DIFFERENT_MASTER_SLAVE_DATA ? SLAVE_DATA_WIDTH : DATA_WIDTH);
	localparam M0_DATA_WIDTH = (USE_DIFFERENT_MASTER_SLAVE_DATA ? MASTER_DATA_WIDTH : DATA_WIDTH);
    localparam S0_BYTEEN_WIDTH = S0_DATA_WIDTH / SYMBOL_WIDTH;
    localparam M0_BYTEEN_WIDTH = M0_DATA_WIDTH / SYMBOL_WIDTH;

	input clk;
	input reset_n;

	input  [S0_ADDR_WIDTH-1:0]  s0_address;
	input                       s0_read;
	output [S0_DATA_WIDTH-1:0]     s0_readdata;
	input                       s0_write;
	input  [S0_DATA_WIDTH-1:0]     s0_writedata;
	output                      s0_waitrequest;
	output                      s0_waitrequest_n;
	input  [S0_BYTEEN_WIDTH-1:0]   s0_byteenable;
	output                      s0_readdatavalid;
	input [BURSTCOUNT_WIDTH-1:0] s0_burstcount;
	input 						 s0_beginbursttransfer;

	output [M0_ADDR_WIDTH-1:0]  m0_address;
	output                      m0_read;
	input  [M0_DATA_WIDTH-1:0]     m0_readdata;
	output                      m0_write;
	output [M0_DATA_WIDTH-1:0]     m0_writedata;
	input                       m0_waitrequest;
	output [M0_BYTEEN_WIDTH-1:0]   m0_byteenable;
	input                       m0_readdatavalid;
	output [BURSTCOUNT_WIDTH-1:0] m0_burstcount;
	output 					  m0_beginbursttransfer;

	generate
		if (WORKAROUND_HARD_PHY_ISSUE)
		begin
			reg waitrequest_r = 0;
			reg read_r = 0;

			always @(posedge clk)
			begin
				waitrequest_r <= s0_waitrequest;
				read_r <= s0_read;
			end

			assign m0_read = read_r & s0_read;
			assign s0_waitrequest = m0_waitrequest | (s0_read & ~waitrequest_r);
			assign s0_waitrequest_n = ~s0_waitrequest;
		end
		else
		begin
			assign m0_read = s0_read;
			assign s0_waitrequest = m0_waitrequest;
			assign s0_waitrequest_n = ~s0_waitrequest;
		end
	endgenerate

	assign m0_address = (M0_ADDR_WIDTH > S0_ADDR_WIDTH) ? { { (M0_ADDR_WIDTH - S0_ADDR_WIDTH) {1'b0} }, s0_address} : s0_address;
	assign s0_readdata = m0_readdata;
	assign m0_write = s0_write;
	assign m0_writedata = s0_writedata;
	assign m0_byteenable = s0_byteenable;
	assign s0_readdatavalid = m0_readdatavalid;
	assign m0_beginbursttransfer = s0_beginbursttransfer;
	assign m0_burstcount = s0_burstcount;

endmodule
