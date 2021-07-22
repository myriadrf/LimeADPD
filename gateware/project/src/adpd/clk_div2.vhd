LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY clk_div2 IS
	PORT (
		clk : IN STD_LOGIC; -- Clock and reset
		rst_n : IN STD_LOGIC;
		en : OUT STD_LOGIC -- Output enable signal
	);
END clk_div2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE clk_div2 OF clk_div2 IS

	SIGNAL q : STD_LOGIC;

BEGIN

	labX : PROCESS (clk, rst_n) IS
	BEGIN
		IF rst_n = '0' THEN
			q <= '0';
		ELSIF (clk'event AND clk = '1') THEN
			q <= NOT q;
		END IF;
	END PROCESS;

	en <= q;

END ARCHITECTURE clk_div2;