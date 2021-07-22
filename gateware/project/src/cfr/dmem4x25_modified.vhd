
-- ----------------------------------------------------------------------------	
-- FILE:	dmem8x25_modified.vhd
-- DESCRIPTION:	8 word by 16 bit data memory used in FIR filters implementation.
--		In fact, dmem8 is implemented as FILO with additional direct
--		acess (address/data) port.
-- DATE:	Sep 03, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mem_package.ALL;

-- ----------------------------------------------------------------------------
ENTITY dmem4x25_modified IS
	PORT (
		SIGNAL N: IN std_logic_vector(1 downto 0);
	    SIGNAL x : IN std_logic_vector(24 DOWNTO 0); -- Data input
		SIGNAL clk, reset, en, odd : IN std_logic;
		SIGNAL a1, a2 : IN std_logic_vector(1 DOWNTO 0); -- Address  --BJ
		SIGNAL d1, d2 : OUT mword25 -- Data output
	);
END dmem4x25_modified;

-- d1 for next 
-- d2 for calculation
-- ----------------------------------------------------------------------------
ARCHITECTURE dmem4x25_arch OF dmem4x25_modified IS
	SIGNAL mem : marray4x25; -- RAM data 
BEGIN

	-- Reset and shift
	shift : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			FOR i IN 0 TO 3 LOOP
				mem(i) <= (OTHERS => '0');
			END LOOP;
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				FOR i IN 3 DOWNTO 1 LOOP
					mem(i) <= mem(i - 1);
				END LOOP;

				IF odd = '1' THEN
					mem(1) <= x;					
					IF N = "00" THEN
					    mem(0) <= x;
					ELSE
					    mem(0) <= (OTHERS => '0');					    
					END IF;
				ELSE
					mem(0) <= x;
				END IF;
			END IF;
		END IF;
	END PROCESS shift;

	-- Construct data output
	d1 <= mem(to_integer(unsigned(a1)));
	d2 <= mem(to_integer(unsigned(a2)));

END dmem4x25_arch;