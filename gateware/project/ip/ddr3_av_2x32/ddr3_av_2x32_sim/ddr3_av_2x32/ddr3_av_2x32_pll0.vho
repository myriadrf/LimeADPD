--IP Functional Simulation Model
--VERSION_BEGIN 18.0 cbx_mgl 2018:04:24:18:08:49:SJ cbx_simgen 2018:04:24:18:04:18:SJ  VERSION_END


-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- You may only use these simulation model output files for simulation
-- purposes and expressly not for synthesis or any other purposes (in which
-- event Intel disclaims all warranties of any kind).


--synopsys translate_off

 LIBRARY altera_lnsim;
 USE altera_lnsim.altera_lnsim_components.all;

--synthesis_resources = generic_pll 10 
 LIBRARY ieee;
 USE ieee.std_logic_1164.all;

 ENTITY  ddr3_av_2x32_pll0 IS 
	 PORT 
	 ( 
		 afi_clk	:	OUT  STD_LOGIC;
		 afi_half_clk	:	OUT  STD_LOGIC;
		 afi_phy_clk	:	OUT  STD_LOGIC;
		 global_reset_n	:	IN  STD_LOGIC;
		 pll_addr_cmd_clk	:	OUT  STD_LOGIC;
		 pll_avl_clk	:	OUT  STD_LOGIC;
		 pll_avl_phy_clk	:	OUT  STD_LOGIC;
		 pll_config_clk	:	OUT  STD_LOGIC;
		 pll_locked	:	OUT  STD_LOGIC;
		 pll_mem_clk	:	OUT  STD_LOGIC;
		 pll_mem_phy_clk	:	OUT  STD_LOGIC;
		 pll_ref_clk	:	IN  STD_LOGIC;
		 pll_write_clk	:	OUT  STD_LOGIC;
		 pll_write_clk_pre_phy_clk	:	OUT  STD_LOGIC
	 ); 
 END ddr3_av_2x32_pll0;

 ARCHITECTURE RTL OF ddr3_av_2x32_pll0 IS

	 ATTRIBUTE synthesis_clearbox : natural;
	 ATTRIBUTE synthesis_clearbox OF RTL : ARCHITECTURE IS 1;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_locked	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll1_phy_62_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll1_phy_62_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll2_64_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll2_64_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll2_phy_66_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll2_phy_66_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll4_70_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll4_70_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll5_72_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll5_72_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll6_74_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll6_74_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll6_phy_76_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll6_phy_76_rst	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll7_78_outclk	:	STD_LOGIC;
	 SIGNAL  wire_ddr3_av_2x32_pll0_generic_pll_pll7_78_rst	:	STD_LOGIC;
	 SIGNAL  wire_w_lg_global_reset_n1w	:	STD_LOGIC_VECTOR (0 DOWNTO 0);
 BEGIN

	wire_w_lg_global_reset_n1w(0) <= NOT global_reset_n;
	afi_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_outclk;
	afi_half_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll5_72_outclk;
	afi_phy_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll1_phy_62_outclk;
	pll_addr_cmd_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll4_70_outclk;
	pll_avl_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll6_74_outclk;
	pll_avl_phy_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll6_phy_76_outclk;
	pll_config_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll7_78_outclk;
	pll_locked <= wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_locked;
	pll_mem_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll2_64_outclk;
	pll_mem_phy_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll2_phy_66_outclk;
	pll_write_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_outclk;
	pll_write_clk_pre_phy_clk <= wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_outclk;
	wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll1_60 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "3004 ps",
		phase_shift => "0 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		fboutclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		locked => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_locked,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll1_phy_62_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll1_phy_62 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "3004 ps",
		phase_shift => "0 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_phy_62_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll1_phy_62_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll2_64_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll2_64 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "3004 ps",
		phase_shift => "0 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll2_64_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll2_64_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll2_phy_66_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll2_phy_66 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "3004 ps",
		phase_shift => "0 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll2_phy_66_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll2_phy_66_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll3_68 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "3004 ps",
		phase_shift => "2252 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll3_68_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll4_70_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll4_70 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "3004 ps",
		phase_shift => "2252 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll4_70_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll4_70_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll5_72_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll5_72 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "6008 ps",
		phase_shift => "0 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll5_72_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll5_72_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll6_74_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll6_74 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "15020 ps",
		phase_shift => "375 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll6_74_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll6_74_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll6_phy_76_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll6_phy_76 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "15020 ps",
		phase_shift => "375 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll6_phy_76_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll6_phy_76_rst
	  );
	wire_ddr3_av_2x32_pll0_generic_pll_pll7_78_rst <= wire_w_lg_global_reset_n1w(0);
	ddr3_av_2x32_pll0_generic_pll_pll7_78 :  generic_pll
	  GENERIC MAP (
		duty_cycle => 50,
		output_clock_frequency => "45060 ps",
		phase_shift => "0 ps",
		reference_clock_frequency => "125.0 MHz"
	  )
	  PORT MAP ( 
		fbclk => wire_ddr3_av_2x32_pll0_generic_pll_pll1_60_fboutclk,
		outclk => wire_ddr3_av_2x32_pll0_generic_pll_pll7_78_outclk,
		refclk => pll_ref_clk,
		rst => wire_ddr3_av_2x32_pll0_generic_pll_pll7_78_rst
	  );

 END RTL; --ddr3_av_2x32_pll0
--synopsys translate_on
--VALID FILE
