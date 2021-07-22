-- ----------------------------------------------------------------------------	
-- FILE: 	reset_n_synch.vhd
-- DESCRIPTION:	reset_n synchronization
-- DATE:	August 23, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity reset_n_synch is
   port (
      --input ports 
      clk             : in std_logic;
      reset_n         : in std_logic;
      reset_n_sinch   : out std_logic
   );
end reset_n_synch;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of reset_n_synch is
--declare signals,  components here
signal high_lvl   : std_logic;
signal signal_d0  : std_logic; 
signal signal_d1  : std_logic; 
  
begin
   
high_lvl <= '1';

process(reset_n, clk)
begin
   if reset_n='0' then
      signal_d0 <='0';
      signal_d1 <='0';
   elsif (clk'event and clk = '1') then
      signal_d0<=high_lvl;
      signal_d1<=signal_d0;
   end if;
end process;
   
reset_n_sinch <= signal_d1; 
  
end arch;   




