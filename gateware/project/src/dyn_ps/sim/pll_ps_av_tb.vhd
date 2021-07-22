-- ----------------------------------------------------------------------------
-- FILE:          pll_ps_av_tb.vhd
-- DESCRIPTION:   Phase shift module with avalon MM interface
-- DATE:          4:33 PM Wednesday, February 7, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_ps_av_tb is
end pll_ps_av_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of pll_ps_av_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1              : std_logic;
   signal reset_n                : std_logic;
   signal reset                  : std_logic;
   signal dut0_mgmt_waitrequest  : std_logic;
   signal dut0_mgmt_write        : std_logic;
   signal dut0_mgmt_read         : std_logic;
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   reset <= not reset_n;
   
   process is
   begin
      dut0_mgmt_waitrequest <= '1';
      wait until (rising_edge(dut0_mgmt_write) OR rising_edge(dut0_mgmt_read));
      wait until rising_edge(clk0);
      dut0_mgmt_waitrequest <= '0';
      wait until rising_edge(clk0);
   end process;
   
   
      -- design under test  

phsft_dut0 : entity work.pll_ps_av 
port map(
   clk               => clk0,
   reset_n           => reset_n,
   busy              => open,
   en                => '1', 
   phase             => "0000000000000011", 
   cnt               => "00001",
   updown            => '1',
   mgmt_readdata     => x"00000001",
   mgmt_waitrequest  => dut0_mgmt_waitrequest,
   mgmt_read         => dut0_mgmt_read,
   mgmt_write        => dut0_mgmt_write,
   mgmt_address      => open,
   mgmt_writedata    => open
   );

end tb_behave;

