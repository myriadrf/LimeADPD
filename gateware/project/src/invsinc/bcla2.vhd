-- ----------------------------------------------------------------------------	
-- FILE:        bcla2.vhd
-- DESCRIPTION:	2 bit Binary Carry Look Ahead (BCLA) adder
-- DATE:        Feb 26, 2001
-- AUTHOR(s):   Microelectronic Centre Design Team
--              MUMEC
--              Bounds Green Road
--              N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration:
-- ------------------------------------ ---------------------------------------
entity bcla2 is
  port (
    a:    in     std_logic_vector (1 downto 0);
    b:    in     std_logic_vector (1 downto 0);
    cin:  in     std_logic;
	
    s:    buffer std_logic_vector (1 downto 0);
    cout: buffer std_logic
  );
end bcla2;

-- ----------------------------------------------------------------------------
-- Architecture definition:
-- ----------------------------------------------------------------------------
architecture bcla2_arch of bcla2 is
  signal g0, p0, g1, p1: std_logic;
  signal g10, p10: std_logic;
  signal c1: std_logic;
	
begin

  -- Blocks fadder1b_gp: 
  s(0) <= a(0) xor b(0) xor cin;
  g0   <= a(0) and b(0);
  p0   <= a(0) or  b(0);

  s(1) <= a(1) xor b(1) xor c1;
  g1   <= a(1) and b(1);
  p1   <= a(1) or  b(1);

  -- BCLA block:
  c1  <= g0 or  (p0 and cin);
  g10 <= g1 or  (p1 and g0);
  p10 <= p1 and p0;
	
  -- Carry out block:
  cout <= g10 or (p10 and cin);
	
end bcla2_arch;
