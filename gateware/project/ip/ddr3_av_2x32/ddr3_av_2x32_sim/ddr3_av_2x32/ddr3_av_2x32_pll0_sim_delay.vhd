-- (C) 2001-2018 Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions and other 
-- software and tools, and its AMPP partner logic functions, and any output 
-- files from any of the foregoing (including device programming or simulation 
-- files), and any associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License Subscription 
-- Agreement, Intel FPGA IP License Agreement, or other applicable 
-- license agreement, including, without limitation, that your use is for the 
-- sole purpose of programming logic devices manufactured by Intel and sold by 
-- Intel or its authorized distributors.  Please refer to the applicable 
-- agreement for further details.



Library ieee;
use ieee.std_logic_1164.all;

entity ddr3_av_2x32_pll0_sim_delay is
   generic (
     delay     : natural := 1);

   port (
     o   : out std_logic;
     i   : in  std_logic);
end ddr3_av_2x32_pll0_sim_delay;

architecture behavior of ddr3_av_2x32_pll0_sim_delay is
begin
  o <= i after delay * 1 ps;
end behavior;

