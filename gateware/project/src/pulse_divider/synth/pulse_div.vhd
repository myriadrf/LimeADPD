-- ----------------------------------------------------------------------------	
-- FILE: 	pulse_div.vhd
-- DESCRIPTION:	Divide pulses by 2. Pulses has to be one clk cycle long
-- DATE:	Feb 17, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pulse_div is
   port (
      clk      : in std_logic;
      reset_n  : in std_logic;
      pulse_in : in std_logic;
      pulse_div: out std_logic
      
        );
end pulse_div;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pulse_div is
--declare signals,  components here
signal sleep     : std_logic;

begin

sleep_sig : process(reset_n, clk)
    begin
      if reset_n='0' then
         sleep <= '0';
      elsif (clk'event and clk = '1') then
         if pulse_in = '1' then 
            sleep<= not sleep;
         else 
            sleep <= sleep;
         end if;
      end if;
end process;


 pulse_div_sig : process(reset_n, clk)
    begin
      if reset_n='0' then
         pulse_div <= '0';
      elsif (clk'event and clk = '1') then
         if sleep = '0' then 
            pulse_div <= pulse_in;
         else 
            pulse_div <= '0';
         end if;
      end if;
    end process;
    
end arch;   





