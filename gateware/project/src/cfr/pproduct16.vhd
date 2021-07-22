-- ----------------------------------------------------------------------------	
-- FILE: 	pproduct16.vhd
-- DESCRIPTION:	16 bit Partial product calculation in Booth multiplier
-- DATE:	Dec 06, 1998
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	Apr 28, 1999:	Generic parameter 'msize' converted to
--				constant because misunderstanding between 
--				us and synopsys:(
--		Aug 08, 2000:	Word lengths corrected for booth18x12.
--		Aug 06, 2001:	Sign extendtion implemented here to simplify
--				connections at the higher level.
-- ----------------------------------------------------------------------------	
library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity pproduct16 is
    port (
        x: in std_logic_vector (15 downto 0); -- Multiplicand
        y: in std_logic_vector (2 downto 0); -- Three bits of multiplier
        p: buffer std_logic_vector (16 downto 0); -- Partial product (x*y)
        cout: buffer std_logic -- Carry to correct 2's complement
    );
end pproduct16;

-- ----------------------------------------------------------------------------
-- Architecture of pproduct
-- ----------------------------------------------------------------------------
architecture pproduct16_arch of pproduct16 is
	constant msize: integer := 16; -- Multiplicand word size
begin
	-- Sign Bit
	p(msize) <= x(msize-1) when y = "001" or y = "010" or y = "011" else -- +CAND and +2CAND 
		not x(msize-1) when y = "100" or y = "101" or y = "110" else -- -CAND and -2CAND
		'0'; -- ZERO operation
	
	-- LSB is also constructed in a special way
	p(0) <= x(0) when y = "001" or y = "010" else -- +CAND
		'0' when y = "011" or y = "000" or y = "111"else -- +2CAND and ZERO
		not x(0) when y = "101" or y = "110" else -- -CAND
		'1' when y = "100" else -- -2CAND
		'0'; -- Just to make LEAPFROG more happy!
	
	-- Other partial products generation
	muxs: for i in 1 to msize-1 generate
		p(i) <= x(i) when y = "001" or y = "010" else -- +CAND
			x(i-1) when y = "011" else -- +2CAND
			not x(i) when y = "101" or y = "110" else -- -CAND
			not x(i-1) when y = "100" else -- -2CAND
			'0'; -- ZERO
	end generate muxs;
	
	-- Carry to correct 2's complement later on
	cout <= '1' when y = "100" or y = "101" or y = "110" else '0'; -- -CAND and -2CAND

end pproduct16_arch;
