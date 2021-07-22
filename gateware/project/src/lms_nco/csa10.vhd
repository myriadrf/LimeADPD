-- ----------------------------------------------------------------------------	
-- FILE: 	csa10.vhd
-- DESCRIPTION:	10 bit Conditional Summ Adder (CSA)
-- DATE:	Dec 15, 1999
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
entity csa10 is
    port (
        a: in std_logic_vector (9 downto 0);
        b: in std_logic_vector (9 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (9 downto 0)
    );
end csa10;

-- ----------------------------------------------------------------------------
-- Architecture of csa10
-- ----------------------------------------------------------------------------
architecture csa10_arch of csa10 is
	signal s0: std_logic_vector(4 downto 0); -- Output from first BCLA5
	signal cout0: std_logic;
	signal s1: std_logic_vector(4 downto 0); -- Output from second BCLA5
	signal cout1: std_logic;
	signal sel: std_logic; -- Carry out from BCLA5
	signal zero, one: std_logic; -- Logic 0 and 1 signals

	-- Component declarations
	use work.components.bcla5;
	for all:bcla5 use entity work.bcla5(bcla5_arch);
begin

	-- Set logic 0 and 1 signals
	zero <= '0';
	one <= '1';
	
	-- Instantiate adders
	adder50: bcla5
		port map(a => a(9 downto 5), b => b(9 downto 5), 
			cin => zero, cout => cout0, s => s0);
			
	adder51: bcla5
		port map(a => a(9 downto 5), b => b(9 downto 5), 
			cin => one, cout => cout1, s => s1);

	adder5: bcla5
		port map(a => a(4 downto 0), b => b(4 downto 0), 
			cin => cin, cout => sel, s => s(4 downto 0));

	-- Select proper carry out and MSB of the result
	cout <= cout0 when sel = '0' else cout1;
	s(9 downto 5) <= s0 when sel = '0' else s1;
			  	
end csa10_arch;
