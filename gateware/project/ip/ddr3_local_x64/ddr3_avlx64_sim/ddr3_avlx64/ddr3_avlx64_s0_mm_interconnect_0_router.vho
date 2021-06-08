--IP Functional Simulation Model
--VERSION_BEGIN 15.0 cbx_mgl 2015:04:22:18:06:50:SJ cbx_simgen 2015:04:22:18:04:08:SJ  VERSION_END


-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Altera disclaims all warranties of any kind).


--synopsys translate_off

--synthesis_resources = mux21 14 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  ddr3_avlx64_s0_mm_interconnect_0_router IS 
	 PORT 
	 ( 
		 clk	:	IN  STD_LOGIC;
		 reset	:	IN  STD_LOGIC;
		 sink_data	:	IN  STD_LOGIC_VECTOR (93 DOWNTO 0);
		 sink_endofpacket	:	IN  STD_LOGIC;
		 sink_ready	:	OUT  STD_LOGIC;
		 sink_startofpacket	:	IN  STD_LOGIC;
		 sink_valid	:	IN  STD_LOGIC;
		 src_channel	:	OUT  STD_LOGIC_VECTOR (3 DOWNTO 0);
		 src_data	:	OUT  STD_LOGIC_VECTOR (93 DOWNTO 0);
		 src_endofpacket	:	OUT  STD_LOGIC;
		 src_ready	:	IN  STD_LOGIC;
		 src_startofpacket	:	OUT  STD_LOGIC;
		 src_valid	:	OUT  STD_LOGIC
	 ); 
 END ddr3_avlx64_s0_mm_interconnect_0_router;

 ARCHITECTURE RTL OF ddr3_avlx64_s0_mm_interconnect_0_router IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_12m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_13m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_18m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_19m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_20m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_24m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_25m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_26m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_27m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_15m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_21m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_22m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_28m_dataout	:	STD_LOGIC;
	 SIGNAL	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_29m_dataout	:	STD_LOGIC;
	 SIGNAL  wire_w1w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
	 SIGNAL  s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_0_258_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout :	STD_LOGIC;
	 SIGNAL  s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout :	STD_LOGIC;
 BEGIN

	wire_w1w(0) <= NOT s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_0_258_dataout;
	s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_0_258_dataout <= ((((((NOT sink_data(50)) AND (NOT sink_data(51))) AND sink_data(52)) AND (NOT sink_data(53))) AND (NOT sink_data(54))) AND (NOT sink_data(55)));
	s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout <= ((((sink_data(51) AND sink_data(52)) AND (NOT sink_data(53))) AND sink_data(54)) AND (NOT sink_data(55)));
	s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout <= ((((((((((((((NOT sink_data(42)) AND (NOT sink_data(43))) AND (NOT sink_data(44))) AND (NOT sink_data(45))) AND (NOT sink_data(46))) AND (NOT sink_data(47))) AND (NOT sink_data(48))) AND (NOT sink_data(49))) AND (NOT sink_data(50))) AND (NOT sink_data(51))) AND sink_data(52)) AND sink_data(53)) AND sink_data(54)) AND (NOT sink_data(55)));
	s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout <= ((NOT sink_data(54)) AND sink_data(55));
	sink_ready <= src_ready;
	src_channel <= ( wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_24m_dataout & wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_25m_dataout & wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_26m_dataout & wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_27m_dataout);
	src_data <= ( sink_data(93 DOWNTO 81) & wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_28m_dataout & wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_29m_dataout & sink_data(78 DOWNTO 0));
	src_endofpacket <= sink_endofpacket;
	src_startofpacket <= sink_startofpacket;
	src_valid <= sink_valid;
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_12m_dataout <= s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_0_258_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_13m_dataout <= wire_w1w(0) AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_18m_dataout <= s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_19m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_12m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_20m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_13m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_24m_dataout <= s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_25m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_18m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_26m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_19m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_27m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_20m_dataout OR s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout;
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_15m_dataout <= s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_0_258_dataout OR s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout;
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_21m_dataout <= s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_1_279_dataout OR s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout;
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_22m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_15m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_2_300_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_28m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_21m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout);
	wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_29m_dataout <= wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_data_22m_dataout AND NOT(s_wire_ddr3_avlx64_s0_mm_interconnect_0_router_src_channel_3_321_dataout);

 END RTL; --ddr3_avlx64_s0_mm_interconnect_0_router
--synopsys translate_on
--VALID FILE
