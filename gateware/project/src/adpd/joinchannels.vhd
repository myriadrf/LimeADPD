LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY joinchannels IS
	GENERIC (N : NATURAL := 14);
	PORT (
		clk : IN STD_LOGIC;
		reset_n : IN STD_LOGIC;
		sel_chA : IN STD_LOGIC;
		xAi : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		xAq : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		xBi : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		xBq : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		yi : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		yq : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
	);

END ENTITY joinchannels;

ARCHITECTURE beh OF joinchannels IS

BEGIN

	WRITE_OUTPUT : PROCESS (clk, reset_n) IS
	BEGIN
		IF reset_n = '0' THEN
			yi <= (OTHERS => '0');
			yq <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN

			IF (sel_chA = '1') THEN
				yi <= xAi;
				yq <= xAq;
			ELSE
				yi <= xBi;
				yq <= xBq;
			END IF;

		END IF;
	END PROCESS WRITE_OUTPUT;

END ARCHITECTURE beh;