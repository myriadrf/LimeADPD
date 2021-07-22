-- ----------------------------------------------------------------------------
-- FILE:          clock_div_tb.vhd
-- DESCRIPTION:   
-- DATE:          2020/04/03
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
entity clock_div_tb is
end clock_div_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of clock_div_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
  
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
   
      -- design under test  

   dut0 : entity work.clock_div 
   generic map(
      ndiv => 1000000
   )
   port map(

      clk      => clk0,
      reset_n  => reset_n,
      divout   => open

    );

end tb_behave;

