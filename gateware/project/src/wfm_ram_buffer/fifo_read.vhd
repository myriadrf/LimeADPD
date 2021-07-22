-- ----------------------------------------------------------------------------	
-- FILE: 	fifo_read.vhd
-- DESCRIPTION:	constatly checks FIFO and if not empty, produces read signal 
-- DATE:	Nov 10, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo_read is
  generic( n_ch		: integer :=1
  
  );  
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  empty		: in std_logic;

        --output ports
        read_en        : out std_logic 
        
        );
end fifo_read;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo_read is
--declare signals,  components here
signal read_en_sig : std_logic;
signal read_en_sig2: std_logic;

  
begin

  process(reset_n, clk)
    begin
      if reset_n='0' then
				read_en_sig<='0';
				read_en_sig2<='0';
 	    elsif (clk'event and clk = '1') then
 	     if empty='0' then 
 	          read_en_sig<='1';
 	     else 
 	       read_en_sig<='0'; 
 	     end if;
			
			if read_en_sig='1' then
				read_en_sig2<= not read_en_sig2;
			else 
				read_en_sig2<=read_en_sig2;
			end if;
 	    end if;
    end process;
	 
	 
	read_en<= read_en_sig when n_ch=2 else	
				 read_en_sig2;
	 
  
end arch;