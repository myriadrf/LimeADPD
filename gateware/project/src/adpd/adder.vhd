library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is		
	generic ( 
		res_n: natural:=18;  -- broj bitova rezultata
		op_n: natural:=18;   -- broj bitova operanda
		addi: natural:=1);  -- sabiranje ako je addi==1
	port(
		dataa		: in std_logic_vector (op_n-1 downto 0);
		datab		: in std_logic_vector (op_n-1 downto 0);
		res		: out std_logic_vector (res_n-1 downto 0));
end adder;

architecture adder of adder is	
	signal exta, extb: std_logic_vector(res_n-op_n-1 downto 0);
begin 
	
	exta<=(others=>dataa(op_n-1)); 
	extb<=(others=>datab(op_n-1)); 
	
	process (dataa, datab,exta, extb) is
	begin		
		if addi=1 then
			res<=(exta&dataa)+(extb&datab);
		else 
			res<=(exta&dataa)-(extb&datab);
		end if;			
	end process;	
	
end adder;
