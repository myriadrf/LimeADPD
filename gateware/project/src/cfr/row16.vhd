-- ----------------------------------------------------------------------------	
-- FILE: 	row16.vhd
-- DESCRIPTION:	Single row of Booth multiplier
-- DATE:	Jan 02, 1999
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	Apr 19, 1999:	Adapted for VHDL version 87.
--		Apr 28, 1999:	Generic parameter 'msize' removed.
--		Aug 11, 2000:	Adapted for booth18x12.
--				Name changed back to 'row'.
--		Aug 06, 2001:	Sign extenstion implemented here in order
--				to simplify the connections at the
--				higher level.
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity row16 is
    port (
        x: in std_logic_vector (15 downto 0); -- Multiplicand
        y: in std_logic_vector (2 downto 0); -- Three bits of multiplier
	a: in std_logic_vector (16 downto 0); -- Input partial carries
        b: in std_logic_vector (16 downto 0); -- Input partial summs	
        c: buffer std_logic_vector (18 downto 0); -- Partial carries	
        s: buffer std_logic_vector (18 downto 0)  -- Partial summs
    );
end row16;

-- ----------------------------------------------------------------------------
-- Architecture of rowa
-- ----------------------------------------------------------------------------
architecture row16_arch of row16 is
	constant msize: integer := 16;	
	signal pp: std_logic_vector(msize downto 0); -- Partial product
	
	-- Component declaration
	use work.components.pproduct16;
	for all:pproduct16 use entity work.pproduct16(pproduct16_arch);
begin

	-- Calculate partial product x*y
	ppcalc: pproduct16
		port map(x => x, y => y, p => pp, cout => c(0));

	-- Adders 
	adders: for i in 0 to msize generate
		s(i) <= a(i) xor b(i) xor pp(i);
		c(i+1) <= (a(i) and b(i)) or (a(i) and pp(i)) or
			  (b(i) and pp(i));
	end generate adders;

	-- Sign extension
	s(msize+1) <= s(msize);
	s(msize+2) <= s(msize);
	c(msize+2) <= c(msize+1);
	
end row16_arch;
