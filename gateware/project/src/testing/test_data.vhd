-- ----------------------------------------------------------------------------	
-- FILE: 	test_data.vhd
-- DESCRIPTION:	describe
-- DATE:	June 3, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity test_data is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
        en        : in std_logic;
        iq        : out std_logic_vector(11 downto 0);
        iq_sel    : out std_logic;
		  sw			: in std_logic

        --output ports 
        
        );
end test_data;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of test_data is
--declare signals,  components here
signal iq_sel_i : std_logic;
signal data   : unsigned(11 downto 0); 

  
begin

    	  process(reset_n, clk)
    begin
      if reset_n='0' then
        iq_sel_i<='0';
        data<=(others=>'0');
 	    elsif (clk'event and clk = '1') then
 	      if en='1' then 
            iq_sel_i<= not iq_sel_i;
            data<=data+1; 
        else
            iq_sel_i<= '0';
            data<=(others=>'0');
        end if;              
 	    end if;
    end process;
    
iq<=std_logic_vector(data);
iq_sel<=iq_sel_i when sw='0' else not iq_sel_i;    
  
end arch;   




