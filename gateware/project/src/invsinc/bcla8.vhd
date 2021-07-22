-- ----------------------------------------------------------------------------	
-- FILE: 	bcla8.vhd
-- DESCRIPTION:	8 bit Binary Carry Look Ahead (BCLA) adder
-- DATE:	Dec 05, 1998
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
entity bcla8 is
    port (
        a: in std_logic_vector (7 downto 0);
        b: in std_logic_vector (7 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (7 downto 0)
    );
end bcla8;

-- ----------------------------------------------------------------------------
-- Architecture of bcla8
-- ----------------------------------------------------------------------------
architecture bcla8_arch of bcla8 is
	signal ga, pa: std_logic_vector(7 downto 0); -- First level GP signals
	signal gb, pb: std_logic_vector(3 downto 0); -- Second level GP signals
	signal gc, pc: std_logic_vector(1 downto 0); -- Third level GP signals
	signal gd, pd: std_logic; -- Last GP signals
	signal c: std_logic_vector(7 downto 1); -- Internal carry signals
begin

-- Full adders
	s(0) <= a(0) xor b(0) xor cin;
	ga(0) <= a(0) and b(0);
	pa(0) <= a(0) or b(0);

	fadders: for i in 1 to 7 generate 
		s(i) <= a(i) xor b(i) xor c(i);
		ga(i) <= a(i) and b(i);
		pa(i) <= a(i) or b(i);
	end generate fadders;	

-- First layer of BCLA modules
	c(1) <= ga(0) or (pa(0) and cin);
	gb(0) <= ga(1) or (pa(1) and ga(0));
	pb(0) <= pa(1) and pa(0);
	
	bclas: for i in 1 to 3 generate
		c(2*i+1) <= ga(2*i) or (pa(2*i) and c(2*i));
		gb(i) <= ga(2*i+1) or (pa(2*i+1) and ga(2*i));
		pb(i) <= pa(2*i+1) and pa(2*i);
	end generate bclas;
	
-- Last three BCLA modules
	c(2) <= gb(0) or (pb(0) and cin);
	gc(0) <= gb(1) or (pb(1) and gb(0));
	pc(0) <= pb(1) and pb(0);
	
	c(6) <= gb(2) or (pb(2) and c(4));
	gc(1) <= gb(3) or (pb(3) and gb(2));
	pc(1) <= pb(3) and pb(2);
	
	c(4) <= gc(0) or (pc(0) and cin);
	gd <= gc(1) or (pc(1) and gc(0));
	pd <= pc(1) and pc(0);
	
-- Carry out calculation
	cout <= gd or (pd and cin);
	
end bcla8_arch;
