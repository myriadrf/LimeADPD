LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY regis IS
	GENERIC (n : NATURAL := 16);
	PORT (
		clk, reset_n, data_valid : IN STD_LOGIC;
		D : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		Q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END regis;

ARCHITECTURE beh OF regis IS

BEGIN
	aa : PROCESS (clk, reset_n) IS
	BEGIN
		IF reset_n = '0' THEN
			Q <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF data_valid = '1' THEN
				Q <= D;
			END IF;
		END IF;
	END PROCESS aa;
END ARCHITECTURE beh;