-- ----------------------------------------------------------------------------	
-- FILE: 	rowfirstt12.vhd
-- DESCRIPTION:	Truncated version of the first row in Booth multiplier array.
-- DATE:	Aug 24, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity rowfirstt12 is
    port (
        x: in std_logic_vector (11 downto 0); -- Multiplicand
        y: in std_logic_vector (3 downto 0); -- Four LSB bits of multiplier
        sbit: in std_logic; -- Y's sign bit used for 1's complement multiplication
        s: buffer std_logic_vector (14 downto 0); -- Partial carries
        c: buffer std_logic_vector (14 downto 0)  -- Partial summs
    );
end rowfirstt12;

-- ----------------------------------------------------------------------------
-- Architecture of rowfirsta
-- ----------------------------------------------------------------------------
architecture rowfirstt12_arch of rowfirstt12 is

	constant msize: integer := 12;
	
	signal ppa: std_logic_vector(msize-2 downto 0); -- Partial product A
	signal ppb: std_logic_vector(msize downto 0); -- Partial product B
	signal carry: std_logic;
	
	-- Component declaration
	use work.components.pproduct10;
	for all:pproduct10 use entity work.pproduct10(pproduct10_arch);
	use work.components.pproduct12;
	for all:pproduct12 use entity work.pproduct12(pproduct12_arch);
begin

	-- Calculate partial product ppa=x*(y1 y0 sbit)
	ppcalca: pproduct10
		port map(x => x(msize-1 downto 2), y(2 downto 1) => y(1 downto 0), y(0) => sbit, 
				p => ppa, cout => carry );
	
	-- Calculate partial product ppb=x*(y3 y2 y1)
	ppcalcb: pproduct12
		port map(x => x, y => y(3 downto 1), 
				p => ppb, cout => c(0));

	-- LSB adder
	s(0) <= ppa(0) xor ppb(0) xor carry;
	c(1) <= (ppa(0) and ppb(0)) or (ppa(0) and carry) or (ppb(0) and carry);

	-- Adders without two MSB ones
	adders: for i in 1 to msize-2 generate
		s(i)   <= ppa(i) xor ppb(i);
		c(i+1) <= ppa(i) and ppb(i);
	end generate adders;
	
	-- Two MSB adders
	s(msize-1) <= ppa(msize-2) xor ppb(msize-1);
	c(msize)   <= ppa(msize-2) and ppb(msize-1);
	
	s(msize)   <= ppa(msize-2) xor ppb(msize);
	c(msize+1) <= ppa(msize-2) and ppb(msize);

	-- Sign extension
	s(msize+1) <= s(msize);
	s(msize+2) <= s(msize);
	c(msize+2) <= c(msize+1);
	
end rowfirstt12_arch;
