-- ----------------------------------------------------------------------------	
-- FILE: 	ddr_ch_sel.vhd
-- DESCRIPTION:	generates mux signal for channel select in ddr mode
-- DATE:	July 13, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ddr_ch_sel is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  gen_en		: in std_logic;
		  i_sel		: in std_logic;
		  q_sel		: in std_logic;
		         --output ports 
		  ch_sel		: out std_logic
		  
        );
end ddr_ch_sel;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ddr_ch_sel is
--declare signals,  components here
signal sel : std_logic; 

component lpm_mux1 IS
	PORT
	(
		data0		: IN STD_LOGIC ;
		data1		: IN STD_LOGIC ;
		sel		: IN STD_LOGIC ;
		result		: OUT STD_LOGIC 
	);
END component;

  
begin


mux_inst	: lpm_mux1
port map (
			data0 => i_sel,
			data1 => q_sel,
			sel	=> sel,
			result => ch_sel
			);

  process(reset_n, clk)
    begin
      if reset_n='0' then
			sel<='0';  
 	    elsif (clk'event and clk = '1') then
 	      if gen_en='1' then 
				sel<= not sel;
			else 
				sel<=sel;
			end if;
 	    end if;
    end process;
  
end arch;   




