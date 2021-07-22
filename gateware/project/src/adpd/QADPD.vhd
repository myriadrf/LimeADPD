-----------------------------------------------------------------------------	
-- FILE: 	QADPD.vhd
-- DESCRIPTION:	Quadrature predistorter model
-- DATE:          10:55 AM Friday, December 19, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

------------------------------------------------------------------------------	
--  coeff's range is [-16, 16],
--  signed two complement, 18 bits
--  aaaaa. bbbb bbbb bbbb b
--  one is  0x 0000 1000 0000 0000 0
------------------------------------------------------------------------------	
--  Clock frequency is 122.88 MHz
--  Sample rate 61.44 MSps

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_arith.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY QADPD IS
	GENERIC (
		n : NATURAL := 4; -- memory depth
		m : NATURAL := 3; -- nonlinearity
		mul_n : NATURAL := 18); -- precision
	PORT (
		clk, sclk : IN STD_LOGIC;
		reset_n : IN STD_LOGIC;
		reset_mem_n : IN STD_LOGIC;
		data_valid : IN STD_LOGIC;
		xpi : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		xpq : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		ypi : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		ypq : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		spi_ctrl : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		spi_data : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY QADPD;

ARCHITECTURE structure OF QADPD IS

	COMPONENT Multiplier2 IS
		PORT (
			dataa : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			datab : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			result : OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
		);
	END COMPONENT Multiplier2;

	COMPONENT adder IS
		GENERIC (
			res_n : NATURAL := 18;
			op_n : NATURAL := 18;
			addi : NATURAL := 1);
		PORT (
			dataa : IN STD_LOGIC_VECTOR (op_n - 1 DOWNTO 0);
			datab : IN STD_LOGIC_VECTOR (op_n - 1 DOWNTO 0);
			res : OUT STD_LOGIC_VECTOR (res_n - 1 DOWNTO 0));
	END COMPONENT Adder;

	TYPE cols IS ARRAY (M DOWNTO 0) OF STD_LOGIC_VECTOR(mul_n - 1 DOWNTO 0);
	TYPE matr IS ARRAY (N DOWNTO 0) OF cols;
	TYPE matr4 IS ARRAY (M DOWNTO 0) OF cols;

	TYPE cols2 IS ARRAY (M DOWNTO 0) OF STD_LOGIC_VECTOR(2 * mul_n - 1 DOWNTO 0);
	TYPE matr2 IS ARRAY (N DOWNTO 0) OF cols2;

	TYPE cols3 IS ARRAY (M DOWNTO 0) OF STD_LOGIC_VECTOR(mul_n + 12 DOWNTO 0);
	TYPE matr3 IS ARRAY (N DOWNTO 0) OF cols3;
	SIGNAL epprim : cols;

	CONSTANT extens : STD_LOGIC_VECTOR(mul_n - 18 DOWNTO 0) := (OTHERS => '0');
	SIGNAL XIp, XQp, XIpp, XQpp : STD_LOGIC_VECTOR(mul_n - 1 DOWNTO 0);
	SIGNAL sig1, sig2 : STD_LOGIC_VECTOR(2 * mul_n - 1 DOWNTO 0);
	SIGNAL sig3, sig4, ep, epp : STD_LOGIC_VECTOR(mul_n - 1 DOWNTO 0);

	SIGNAL xIep, xQep : matr;
	SIGNAL xIep_z, xQep_z : matr4;
	SIGNAL xIep_s, xQep_s : cols2;
	SIGNAL res1, res2, res3, res4 : matr2;
	SIGNAL res1_s, res2_s, res2_sprim, res3_s, res4_s, res4_sprim : matr3;
	SIGNAL ijYpI, ijYpQ, ijYpI_s, ijYpQ_s : matr2;

	TYPE row2 IS ARRAY (N DOWNTO 0) OF STD_LOGIC_VECTOR(2 * mul_n - 1 DOWNTO 0);

	SIGNAL iYpI, iYpQ : row2;
	SIGNAL YpI_s2, YpQ_s2 : STD_LOGIC_VECTOR(2 * mul_n - 1 DOWNTO 0);
	SIGNAL a, ap, b, bp, mul5a, mul5b, mul6a, mul6b : matr;
	CONSTANT zer : STD_LOGIC_VECTOR(mul_n - 17 DOWNTO 0) := (OTHERS => '0');
	CONSTANT all_zeros : STD_LOGIC_VECTOR(mul_n - 5 DOWNTO 0) := (OTHERS => '0');
	CONSTANT all_ones : STD_LOGIC_VECTOR(mul_n - 5 DOWNTO 0) := (OTHERS => '1');
	SIGNAL sigI, sigQ : STD_LOGIC_VECTOR(mul_n - 5 DOWNTO 0);
	SIGNAL ypi_s, ypq_s : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL address_i, address_j : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN

	address_i <= '0' & spi_ctrl(7 DOWNTO 4);
	address_j <= '0' & spi_ctrl(3 DOWNTO 0);

	PROCESS (reset_mem_n, sclk) IS
	BEGIN
		IF reset_mem_n = '0' THEN
			FOR i IN 0 TO n LOOP
				FOR j IN 0 TO m LOOP
					a(i)(j) <= (OTHERS => '0');
					ap(i)(j) <= (OTHERS => '0');
					b(i)(j) <= (OTHERS => '0');
					bp(i)(j) <= (OTHERS => '0');
				END LOOP;
			END LOOP;

			a(0)(0) <= x"0800" & zer;
			ap(0)(0) <= x"0800" & zer;

		ELSIF (sclk'event AND sclk = '1') THEN
			IF (spi_ctrl(15 DOWNTO 12) = "0001") THEN
				ap(CONV_INTEGER(address_i))(CONV_INTEGER(address_j)) <= spi_data & spi_ctrl(9 DOWNTO 8);
			ELSIF (spi_ctrl(15 DOWNTO 12) = "0010") THEN
				bp(CONV_INTEGER(address_i))(CONV_INTEGER(address_j)) <= spi_data & spi_ctrl(9 DOWNTO 8);
			ELSIF (spi_ctrl(15 DOWNTO 12) = "1111") THEN
				FOR i IN 0 TO n LOOP
					FOR j IN 0 TO m LOOP
						a(i)(j) <= ap(i)(j);
						b(i)(j) <= bp(i)(j);
					END LOOP;
				END LOOP;
			END IF;
		END IF;
	END PROCESS;

	lab4 : PROCESS (clk, reset_n) IS
	BEGIN
		IF reset_n = '0' THEN
			ypi <= (OTHERS => '0');
			ypq <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			IF (data_valid = '1') THEN
				ypi <= ypi_s;
				ypq <= ypq_s;
			END IF;
		END IF;
	END PROCESS;

	lab_IN : PROCESS (clk, reset_n) IS
	BEGIN
		IF reset_n = '0' THEN
			XIp <= (OTHERS => '0');
			XQp <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			IF data_valid = '1' THEN
				XIp <= xpi(13) & xpi(13) & xpi(13) & xpi & extens;
				XQp <= xpq(13) & xpq(13) & xpq(13) & xpq & extens;
			END IF;
		END IF;
	END PROCESS;

	Mult1 : multiplier2
	PORT MAP(dataa => XIp, datab => XIp, result => sig1);
	sig3(mul_n - 1 DOWNTO 0) <= sig1(2 * mul_n - 5 DOWNTO mul_n - 4);

	Mult2 : multiplier2
	PORT MAP(dataa => XQp, datab => XQp, result => sig2);
	sig4(mul_n - 1 DOWNTO 0) <= sig2(2 * mul_n - 5 DOWNTO mul_n - 4);

	Adder1 : adder GENERIC MAP(res_n => mul_n, op_n => mul_n, addi => 1)
	PORT MAP(dataa => sig3, datab => sig4, res => ep);

	labX0 : PROCESS (clk, reset_n) IS
	BEGIN
		IF reset_n = '0' THEN
			xIpp <= (OTHERS => '0');
			xQpp <= (OTHERS => '0');
			epp <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			IF (data_valid = '1') THEN
				xIpp <= xIp;
				xQpp <= xQp;
				epp <= ep;
			END IF;
		END IF;
	END PROCESS;

	xIep_z(0)(0) <= XIpp;
	xQep_z(0)(0) <= XQpp;
	epprim(0) <= epp;

	lab5 : FOR j IN 1 TO M GENERATE

		Mult3 : multiplier2
		PORT MAP(dataa => xIep_z(j - 1)(j - 1), datab => epprim(j - 1), result => xIep_s(j - 1));
		Mult4 : multiplier2
		PORT MAP(dataa => xQep_z(j - 1)(j - 1), datab => epprim(j - 1), result => xQep_s(j - 1));
		lab6 : PROCESS (clk, reset_n) IS
		BEGIN
			IF reset_n = '0' THEN
				xIep_z(j)(j) <= (OTHERS => '0');
				xQep_z(j)(j) <= (OTHERS => '0');
				epprim(j) <= (OTHERS => '0');
			ELSIF (clk'event AND clk = '1') THEN
				IF (data_valid = '1') THEN
					xIep_z(j)(j) <= xIep_s(j - 1)(2 * mul_n - 5 DOWNTO mul_n - 4);
					xQep_z(j)(j) <= xQep_s(j - 1)(2 * mul_n - 5 DOWNTO mul_n - 4);
					epprim(j) <= epprim(j - 1);
				END IF;
			END IF;
		END PROCESS;

		labX1 : FOR k IN 0 TO j - 1 GENERATE
			labX2 : PROCESS (clk, reset_n) IS
			BEGIN
				IF reset_n = '0' THEN
					xIep_z(j)(k) <= (OTHERS => '0');
					xQep_z(j)(k) <= (OTHERS => '0');
				ELSIF (clk'event AND clk = '1') THEN
					IF (data_valid = '1') THEN
						xIep_z(j)(k) <= xIep_z(j - 1)(k);
						xQep_z(j)(k) <= xQep_z(j - 1)(k);
					END IF;
				END IF;
			END PROCESS;
		END GENERATE;
	END GENERATE;

	labX3 : FOR j IN 0 TO M GENERATE
		xIep(0)(j) <= xIep_z(M)(j);
		xQep(0)(j) <= xQep_z(M)(j);
	END GENERATE;

	lab1 : FOR i IN N DOWNTO 1 GENERATE
		lab2 : FOR j IN 0 TO M GENERATE
			lab3 : PROCESS (clk, reset_n) IS
			BEGIN
				IF reset_n = '0' THEN
					xIep(i)(j) <= (OTHERS => '0');
					xQep(i)(j) <= (OTHERS => '0');
				ELSIF (clk'event AND clk = '1') THEN
					IF (data_valid = '1') THEN
						xIep(i)(j) <= xIep(i - 1)(j);
						xQep(i)(j) <= xQep(i - 1)(j);
					END IF;
				END IF;
			END PROCESS;
		END GENERATE;
	END GENERATE;

	lab7 : FOR i IN 0 TO N GENERATE
		lab8 : FOR j IN 0 TO M GENERATE

			mul5a(i)(j) <= a(i)(j) WHEN data_valid = '1' ELSE
			b(i)(j);
			mul5b(i)(j) <= xIep(i)(j) WHEN data_valid = '1' ELSE
			xQep(i)(j);

			Mult5 : multiplier2 PORT MAP(dataa => mul5a(i)(j), datab => mul5b(i)(j), result => res1(i)(j));
			lab14 : PROCESS (clk, reset_n) IS
			BEGIN
				IF reset_n = '0' THEN
					res1_s(i)(j) <= (OTHERS => '0');
					res2_s(i)(j) <= (OTHERS => '0');
					res2_sprim(i)(j) <= (OTHERS => '0');
				ELSIF (clk'event AND clk = '1') THEN
					IF (data_valid = '1') THEN
						res1_s(i)(j) <= res1(i)(j)(2 * mul_n - 1 - j DOWNTO mul_n - 13 - j);
						res2_sprim(i)(j) <= res2_s(i)(j);
					ELSE
						res2_s(i)(j) <= res1(i)(j)(2 * mul_n - 1 - j DOWNTO mul_n - 13 - j);
					END IF;
				END IF;
			END PROCESS;

			Adder2 : adder GENERIC MAP(res_n => 2 * mul_n, op_n => mul_n + 13, addi => 0)
			PORT MAP(dataa => res1_s(i)(j), datab => res2_sprim(i)(j), res => ijYpI(i)(j));

			mul6a(i)(j) <= a(i)(j) WHEN data_valid = '1' ELSE
			b(i)(j);
			mul6b(i)(j) <= xQep(i)(j) WHEN data_valid = '1' ELSE
			xIep(i)(j);
			Mult6 : multiplier2 PORT MAP(dataa => mul6a(i)(j), datab => mul6b(i)(j), result => res3(i)(j));

			lab15 : PROCESS (clk, reset_n) IS
			BEGIN
				IF reset_n = '0' THEN
					res3_s(i)(j) <= (OTHERS => '0');
					res4_s(i)(j) <= (OTHERS => '0');
					res4_sprim(i)(j) <= (OTHERS => '0');
				ELSIF (clk'event AND clk = '1') THEN
					IF (data_valid = '1') THEN
						res3_s(i)(j) <= res3(i)(j)(2 * mul_n - 1 - j DOWNTO mul_n - 13 - j);
						res4_sprim(i)(j) <= res4_s(i)(j);
					ELSE
						res4_s(i)(j) <= res3(i)(j)(2 * mul_n - 1 - j DOWNTO mul_n - 13 - j);
					END IF;
				END IF;
			END PROCESS;
			Adder3 : adder GENERIC MAP(res_n => 2 * mul_n, op_n => mul_n + 13, addi => 1) -- addition
			PORT MAP(dataa => res3_s(i)(j), datab => res4_sprim(i)(j), res => ijYpQ(i)(j));

			lab9 : PROCESS (clk, reset_n) IS
			BEGIN
				IF reset_n = '0' THEN
					ijYpI_s(i)(j) <= (OTHERS => '0');
					ijYpQ_s(i)(j) <= (OTHERS => '0');
				ELSIF (clk'event AND clk = '1') THEN
					IF (data_valid = '1') THEN
						ijYpI_s(i)(j) <= ijYpI(i)(j);
						ijYpQ_s(i)(j) <= ijYpQ(i)(j);
					END IF;
				END IF;
			END PROCESS;
		END GENERATE;

		lab10 : PROCESS (clk, reset_n) IS
			VARIABLE iYpI_s, iYpQ_s : STD_LOGIC_VECTOR(2 * mul_n - 1 DOWNTO 0);
		BEGIN
			IF reset_n = '0' THEN
				iYpI_s := (OTHERS => '0');
				iYpQ_s := (OTHERS => '0');
			ELSIF (clk'event AND clk = '1') THEN
				IF (data_valid = '1') THEN
					iYpI_s := (OTHERS => '0');
					iYpQ_s := (OTHERS => '0');
					FOR j IN 0 TO M LOOP
						iYpI_s := iYpI_s + ijYpI_s(i)(j);
						iYpQ_s := iYpQ_s + ijYpQ_s(i)(j);
					END LOOP;
				END IF;
			END IF;
			iYpI(i) <= iYpI_s;
			iYpQ(i) <= iYpQ_s;
		END PROCESS;
	END GENERATE;

	lab11 : PROCESS (clk, reset_n) IS
		VARIABLE YpI_s, YpQ_s : STD_LOGIC_VECTOR(2 * mul_n - 1 DOWNTO 0);
	BEGIN
		IF reset_n = '0' THEN
			YpI_s := (OTHERS => '0');
			YpQ_s := (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			IF (data_valid = '1') THEN
				YpI_s := (OTHERS => '0');
				YpQ_s := (OTHERS => '0');
				FOR i IN 0 TO N LOOP
					YpI_s := YpI_s + iYpI(i);
					YpQ_s := YpQ_s + iYpQ(i);
				END LOOP;
			END IF;
		END IF;
		YpI_s2 <= YpI_s;
		YpQ_s2 <= YpQ_s;
	END PROCESS;

	sigI <= YpI_s2(2 * mul_n - 1 DOWNTO mul_n + 4);
	sigQ <= YpQ_s2(2 * mul_n - 1 DOWNTO mul_n + 4);

	comp_I : PROCESS (YpI_s2, sigI)IS
	BEGIN
		IF (sigI = all_zeros) THEN
			ypi_s <= YpI_s2(mul_n + 4 DOWNTO mul_n - 13);
		ELSIF (sigI = all_ones) THEN
			ypi_s <= YpI_s2(mul_n + 4 DOWNTO mul_n - 13);
		ELSIF sigI(mul_n - 5) = '0' THEN
			ypi_s <= (17 => '0', OTHERS => '1');
		ELSE
			ypi_s <= (17 => '1', OTHERS => '0');
		END IF;
	END PROCESS;

	comp_Q : PROCESS (YpQ_s2, sigQ)IS
	BEGIN
		IF (sigQ = all_zeros) THEN
			ypq_s <= YpQ_s2(mul_n + 4 DOWNTO mul_n - 13);
		ELSIF (sigQ = all_ones) THEN
			ypq_s <= YpQ_s2(mul_n + 4 DOWNTO mul_n - 13);
		ELSIF sigQ(mul_n - 5) = '0' THEN
			ypq_s <= (17 => '0', OTHERS => '1');
		ELSE
			ypq_s <= (17 => '1', OTHERS => '0');
		END IF;
	END PROCESS;

END ARCHITECTURE structure;