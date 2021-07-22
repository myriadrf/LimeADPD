LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY adder IS
	GENERIC (
		res_n : NATURAL := 18;
		op_n : NATURAL := 18;
		addi : NATURAL := 1);
	PORT (
		dataa : IN STD_LOGIC_VECTOR (op_n - 1 DOWNTO 0);
		datab : IN STD_LOGIC_VECTOR (op_n - 1 DOWNTO 0);
		res : OUT STD_LOGIC_VECTOR (res_n - 1 DOWNTO 0));
END adder;

ARCHITECTURE adder OF adder IS
	SIGNAL exta, extb : STD_LOGIC_VECTOR(res_n - op_n - 1 DOWNTO 0);
BEGIN

	exta <= (OTHERS => dataa(op_n - 1));
	extb <= (OTHERS => datab(op_n - 1));

	PROCESS (dataa, datab, exta, extb) IS
	BEGIN
		IF addi = 1 THEN
			res <= (exta & dataa) + (extb & datab);
		ELSE
			res <= (exta & dataa) - (extb & datab);
		END IF;
	END PROCESS;

END adder;