-- ----------------------------------------------------------------------------
-- FILE:          IC_74HC595_tb.vhd
-- DESCRIPTION:   
-- DATE:          Feb 13, 2014
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
entity IC_74HC595_tb is
end IC_74HC595_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of IC_74HC595_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic;
   
   --dut0
   signal dut0_en          : std_logic;
   signal dut0_data        : std_logic_vector(15 downto 0);
   signal dut0_busy        : std_logic;
  
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
   
   process is
   begin
      dut0_en <= '0'; wait for 20 ns;
      wait until rising_edge(clk0);
      dut0_en <= '1'; wait;
   end process;
   
   process is
   begin
      dut0_data <= x"0001";
      wait until reset_n = '1';
      wait until rising_edge(clk0);
      dut0_data <= x"0001";
      
      wait until dut0_busy = '0';
      wait until rising_edge(clk0);
      dut0_data <= x"8000";
      
      wait until rising_edge(clk0);
      wait until dut0_busy = '0';
      dut0_data <= x"AAAA";
      
      wait until rising_edge(clk0);
      wait until dut0_busy = '0';
      dut0_data <= x"5555";
      
      wait until rising_edge(clk0);
      wait until dut0_busy = '0';
      wait;     
   end process;
      -- design under test  

      
      
-- IC_74HC595_dut0 : entity work.IC_74HC595
   -- generic map(
      -- data_width   =>  16
   -- )
   -- port map(

      -- clk      => clk0,
      -- reset_n  => reset_n,
      -- en       => dut0_en,
      -- data     => dut0_data,
      -- busy     => open,

      -- SHCP     => open,
      -- STCP     => open,
      -- DS       => open
      
        -- );
        
IC_74HC595_top_dut0 : entity work.IC_74HC595_top
   port map(

      clk      => clk0,
      reset_n  => reset_n,
      data     => dut0_data,
      busy     => dut0_busy,

      SHCP     => open,
      STCP     => open,
      DS       => open
      
        );

end tb_behave;

