library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tff1 is 	

	 port(clk, reset_n: in std_logic;
		   q: out std_logic);
end entity tff1;

architecture beh of tff1 is
	signal sig : std_logic;	
begin

 process (clk, reset_n) is
 begin
		  
	if reset_n='0' then sig <= '0';			
			
   elsif clk'event and clk='1' then
				
			if sig='1' then sig<='0';
			else sig<='1';
			end if;
	
	 end if;	
 end process;
 
 q<=sig; 

end architecture beh;

		  