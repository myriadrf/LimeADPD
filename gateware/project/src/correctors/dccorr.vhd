-- ----------------------------------------------------------------------------	
-- FILE: 	dccorr.vhd
-- DESCRIPTION:	Dc corrector (Tx).
-- DATE:	Nov 25, 2012
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity dccorr is
port
	(
		clk	: in std_logic;
		nrst	: in std_logic;
		en		: in std_logic;
		byp	: in std_logic;
		x		: in signed (13 downto 0);
		dc		: in signed (7 downto 0);
		y		: out signed (13 downto 0)
	);
end dccorr;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture dccorr_arch of dccorr is

	signal mux	: signed (13 downto 0);
	signal s		: signed (13 downto 0);
	signal r		: signed (13 downto 0);
	
	
begin
	
	
	s <= x + dc;
	mux <= s(13 downto 0) when byp = '0' else x;

	reg: process(clk, nrst)
	begin
		if(nrst = '0') then
			r <= (others => '0');
		elsif rising_edge(clk) then
			if en = '1' then
				r <= mux;
			end if;
		end if;
		
	end process reg;

	-- Output	
	y <= r;

end dccorr_arch;