-- ----------------------------------------------------------------------------	
-- FILE:	dmem8x25.vhd
-- DESCRIPTION:	8 word by 16 bit data memory used in FIR filters implementation.
--		In fact, dmem8 is implemented as FILO with additional direct
--		acess (address/data) port.
-- DATE:	Sep 03, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee; 
use ieee.std_logic_1164.all ; 
use ieee.numeric_std.all ;
use work.mem_package.all ;

-- ----------------------------------------------------------------------------
entity dmem8x25 is 
	port (
		signal x: in std_logic_vector(24 downto 0); -- Data input
		signal clk, reset, en: in std_logic;
		signal a: in std_logic_vector(2 downto 0); -- Address
		signal d: out mword25 			   -- Data output
	);
end dmem8x25;

-- ----------------------------------------------------------------------------
architecture dmem8x25_arch of dmem8x25 is 
	signal mem: marray8x25;  -- RAM data 
begin 
			
	-- Reset and shift
	shift: process(clk, reset)
	begin
		if reset = '0' then
			for i in 0 to 7 loop
				mem(i) <= (others => '0');
			end loop;	      
		elsif clk'event and clk = '1' then
			if en = '1' then   
				for i in 7 downto 1 loop
					mem(i) <= mem(i-1);
				end loop;
				mem(0) <= x;
			end if;
		end if;
	end process shift;

	-- Construct data output
	d <= mem(to_integer(unsigned(a)));

end dmem8x25_arch; 
