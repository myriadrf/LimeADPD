-- ----------------------------------------------------------------------------	
-- FILE: 	bcla4.vhd
-- DESCRIPTION:	4 bit Binary Carry Look Ahead (BCLA) adder
-- DATE:	Jan 29, 1999
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity bcla4 is
    port (
        a: in std_logic_vector (3 downto 0);
        b: in std_logic_vector (3 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (3 downto 0)
    );
end bcla4;

-- ----------------------------------------------------------------------------
-- Architecture of bcla4
-- ----------------------------------------------------------------------------
architecture bcla4_arch of bcla4 is
	signal ga, pa: std_logic_vector(3 downto 0); -- First level GP signals
	signal gb, pb: std_logic_vector(1 downto 0); -- Second level GP signals
	signal gc, pc: std_logic; -- Third level GP signals
	signal c: std_logic_vector(3 downto 1); -- Internal carry signals
begin

-- Full adders
	s(0) <= a(0) xor b(0) xor cin;
	ga(0) <= a(0) and b(0);
	pa(0) <= a(0) or b(0);

	fadders: for i in 1 to 3 generate 
		s(i) <= a(i) xor b(i) xor c(i);
		ga(i) <= a(i) and b(i);
		pa(i) <= a(i) or b(i);
	end generate fadders;	

-- First layer of BCLA modules
	c(1) <= ga(0) or (pa(0) and cin);
	gb(0) <= ga(1) or (pa(1) and ga(0));
	pb(0) <= pa(1) and pa(0);
	
	c(3) <= ga(2) or (pa(2) and c(2));
	gb(1) <= ga(3) or (pa(3) and ga(2));
	pb(1) <= pa(3) and pa(2);
	
-- Last BCLA module
	c(2) <= gb(0) or (pb(0) and cin);
	gc <= gb(1) or (pb(1) and gb(0));
	pc <= pb(1) and pb(0);

-- Carry out calculation
	cout <= gc or (pc and cin);
	
end bcla4_arch;
