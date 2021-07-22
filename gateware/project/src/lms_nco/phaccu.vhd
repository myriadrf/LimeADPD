-- ----------------------------------------------------------------------------	
-- FILE:	phaccu.vhd
-- DESCRIPTION:	32 bit Phase Accumulator with frequency modulation and
--		phase offset inputs.
-- DATE:	July 31, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	Nov 02, 2001:	Toggling removed.
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity phaccu is
	port
	(
		fcw: in	std_logic_vector (31 downto 0); -- Frequency Control Word
		clk: in std_logic; -- Clock signal
		en: in std_logic;  -- Enable signal
		nrst: in std_logic; -- Reset signal
		phase: buffer std_logic_vector (18 downto 0) -- Phase signal
	);
end phaccu;

-- ----------------------------------------------------------------------------
-- Architecture of phaccu
-- ----------------------------------------------------------------------------
architecture phaccu_arch of phaccu is

	signal s: signed (31 downto 0);
	signal r: signed (31 downto 0);
	
begin

	s <= signed(fcw) + r;
	
	reg: process(clk, nrst)
	begin
		if(nrst = '0') then
			r <= (others => '0');
		elsif rising_edge(clk) then
			if en = '1' then
				r <= s;
			end if;
		end if;
	end process reg;
	
	phase <= std_logic_vector (r(31 downto 13));
	
end phaccu_arch;
