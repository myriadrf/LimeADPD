-- ----------------------------------------------------------------------------	
-- FILE: edge_pulse.vhd
-- DESCRIPTION: generates one clock cycle positive pulse when edge is detected
-- DATE: August 17, 2017
-- AUTHOR(s): Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- TODO:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity edge_pulse is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic; 
      sig_in      : in std_logic;
      pulse_out   : out std_logic 
   );
end edge_pulse;

-- ----------------------------------------------------------------------------
-- Architecture of rising edge detection
-- ----------------------------------------------------------------------------
architecture arch_rising of edge_pulse is
--Declare signals,  components here

signal sig_in_reg0      : std_logic;
signal sig_in_reg1      : std_logic;
signal sig_in_risign    : std_logic;

begin

-- ----------------------------------------------------------------------------
-- Register process
-- ----------------------------------------------------------------------------
sig_in_regs : process(clk, reset_n)
   begin
   if reset_n = '0' then 
      sig_in_reg0 <= '0';
      sig_in_reg1 <= '0';
   elsif (clk'event AND clk='1') then 
      sig_in_reg0 <= sig_in;
      sig_in_reg1 <= sig_in_reg0;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Edge detect process
-- ----------------------------------------------------------------------------
edge_proc : process(clk, reset_n)
   begin
   if reset_n = '0' then 
      sig_in_risign <= '0';
   elsif (clk'event AND clk='1') then
      if (sig_in_reg0 = '1' AND sig_in_reg1 = '0') then 
         sig_in_risign <= '1';
      else
         sig_in_risign <= '0';
      end if;
   end if;
end process;

pulse_out <= sig_in_risign;

end arch_rising;  

-- ----------------------------------------------------------------------------
-- Architecture of falling edge detection
-- ----------------------------------------------------------------------------
architecture arch_falling of edge_pulse is
--Declare signals,  components here

signal sig_in_reg0      : std_logic;
signal sig_in_reg1      : std_logic;
signal sig_in_falling   : std_logic;

begin

-- ----------------------------------------------------------------------------
-- Register process
-- ----------------------------------------------------------------------------
sig_in_regs : process(clk, reset_n)
   begin
   if reset_n = '0' then 
      sig_in_reg0 <= '0';
      sig_in_reg1 <= '0';
   elsif (clk'event AND clk='1') then 
      sig_in_reg0 <= sig_in;
      sig_in_reg1 <= sig_in_reg0;
   end if;
end process;

-- ----------------------------------------------------------------------------
-- Edge detect process
-- ----------------------------------------------------------------------------
edge_proc : process(clk, reset_n)
   begin
   if reset_n = '0' then 
      sig_in_falling <= '0';
   elsif (clk'event AND clk='1') then
      if (sig_in_reg0 = '0' AND sig_in_reg1 = '1') then 
         sig_in_falling <= '1';
      else
         sig_in_falling <= '0';
      end if;
   end if;
end process;

pulse_out <= sig_in_falling;

end arch_falling; 



