LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE IEEE.math_real.ALL;
USE ieee.std_logic_arith.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
ENTITY cfir_bj IS
	GENERIC (nd : NATURAL := 20);
	PORT (
		-- Clock related inputs
		sleep : IN STD_LOGIC; -- Sleep signal
		clk : IN STD_LOGIC; -- Clock
		reset : IN STD_LOGIC; -- Reset

		reset_mem_n : IN STD_LOGIC;

		bypass : IN STD_LOGIC; --  Bypass
		odd : IN STD_LOGIC;

		-- Data input signals
		xi : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		xq : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

		threshold : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

		n : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Clock division ratio = n+1
		l : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Number of taps is 5*(l+1)

		-- Coefficient memory interface
		maddressf0 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		maddressf1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);

		mimo_en : IN STD_LOGIC; --
		sdin : IN STD_LOGIC; -- Data in
		sclk : IN STD_LOGIC; -- Data clock
		sen : IN STD_LOGIC; -- Enable signal (active low)
		sdout : OUT STD_LOGIC; -- Data out
		oen : OUT STD_LOGIC;

		-- Filter output signals
		yi : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		yq : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		xen : OUT STD_LOGIC
	);
END cfir_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE struct OF cfir_bj IS

	COMPONENT gfirhf16mod_bj IS
		PORT (
			-- Clock related inputs
			sleep : IN STD_LOGIC; -- Sleep signal
			clk : IN STD_LOGIC; -- Clock
			reset : IN STD_LOGIC; -- Reset

			reset_mem_n : IN STD_LOGIC;

			bypass : IN STD_LOGIC; --  Bypass
			odd, half : IN STD_LOGIC; 

			-- Data input signals
			xi : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			xq : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

			-- Filter configuration
			n : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- Clock division ratio = n+1
			l : IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- Number of taps is 5*(l+1)

			-- Coeffitient memory interface
			maddressf0 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			maddressf1 : IN STD_LOGIC_VECTOR(8 DOWNTO 0);

			mimo_en : IN STD_LOGIC; --
			sdin : IN STD_LOGIC; -- Data in
			sclk : IN STD_LOGIC; -- Data clock
			sen : IN STD_LOGIC; -- Enable signal (active low)
			sdout : OUT STD_LOGIC; -- Data out
			oen : OUT STD_LOGIC;

			-- Filter output signals
			yi : OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
			yq : OUT STD_LOGIC_VECTOR(24 DOWNTO 0);
			xen : OUT STD_LOGIC
		);
	END COMPONENT gfirhf16mod_bj;

	COMPONENT multiplier2 IS
		PORT (
			dataa : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			datab : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			result : OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
		);
	END COMPONENT multiplier2;

	COMPONENT adder IS
		GENERIC (
			res_n : NATURAL := 18;
			op_n : NATURAL := 18;
			addi : NATURAL := 1);
		PORT (
			dataa : IN STD_LOGIC_VECTOR (op_n - 1 DOWNTO 0);
			datab : IN STD_LOGIC_VECTOR (op_n - 1 DOWNTO 0);
			res : OUT STD_LOGIC_VECTOR (res_n - 1 DOWNTO 0)
		);
	END COMPONENT Adder;

	COMPONENT sqroot IS
		GENERIC (
			mul_n : NATURAL := 18;
			root : BOOLEAN);
		PORT (
			clk, reset_n, data_valid : IN STD_LOGIC;
			A_in : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
			B_out : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
		);
	END COMPONENT sqroot;

	COMPONENT division IS
		GENERIC (mul_n : NATURAL := 18);
		PORT (
			clk, reset_n, data_valid : IN STD_LOGIC;
			A_in : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
			B_in : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
			Z_out : OUT STD_LOGIC_VECTOR(17 DOWNTO 0));
	END COMPONENT division;

	SIGNAL xi1, xq1, one, zero, threshold1, sig7, sig8, e, c, sig9, sig10, f, y, o, b, b1, b2, xq2, xi2 : STD_LOGIC_VECTOR (17 DOWNTO 0);
	SIGNAL sig1, sig2, sig3, sig4, sig5, sig6, sig11, sig12 : STD_LOGIC_VECTOR (35 DOWNTO 0);

	TYPE array1 IS ARRAY (0 TO 10) OF STD_LOGIC;
	SIGNAL sign, sleep1 : array1;

	TYPE array2 IS ARRAY (0 TO nd + 32) OF STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL xi_reg, xq_reg : array2;

	SIGNAL xen1, data_valid : STD_LOGIC;
	SIGNAL o1, f1 : STD_LOGIC_VECTOR (24 DOWNTO 0);
	SIGNAL selsig : STD_LOGIC_VECTOR(7 DOWNTO 0);

	TYPE array3 IS ARRAY (0 TO 5) OF STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL cpom, cpom2 : array3;
	SIGNAL max, min, cprim, cprim2 : STD_LOGIC_VECTOR(17 DOWNTO 0);

	SIGNAL yitemp, yqtemp : STD_LOGIC_VECTOR(15 DOWNTO 0);
	CONSTANT LE : INTEGER := 1;

BEGIN
	threshold1 <= "00" & threshold;
	data_valid <= xen1;
	xen <= xen1;

	one <= "01" & x"0000";
	zero <= (OTHERS => '0');

	PROCESS (reset, clk) IS
	BEGIN
		IF reset = '0' THEN
			xi1 <= (OTHERS => '0');
			xq1 <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF (data_valid = '1') THEN
				xi1 <= xi(15) & xi & '0';
				xq1 <= xq(15) & xq & '0';
			END IF;
		END IF;
	END PROCESS;

	MultI2 : multiplier2 PORT MAP(dataa => xi1, datab => xi1, result => sig1);
	MultQ2 : multiplier2 PORT MAP(dataa => xq1, datab => xq1, result => sig2);

	sig3(35 DOWNTO 0) <= sig1(33 DOWNTO 0) & "00";
	sig4(35 DOWNTO 0) <= sig2(33 DOWNTO 0) & "00";

	Adder1 : adder GENERIC MAP(res_n => 36, op_n => 36, addi => 1) PORT MAP(dataa => sig3, datab => sig4, res => sig5);

	PROCESS (reset, clk) IS
	BEGIN
		IF reset = '0' THEN
			sig6 <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF (data_valid = '1') THEN
				sig6 <= sig5;
			END IF;
		END IF;
	END PROCESS;

	Sqroot1 : sqroot GENERIC MAP(mul_n => 18, root => true) 
	PORT MAP(clk => clk, reset_n => reset, data_valid => data_valid, A_in => sig6, B_out => e);

	Adder2 : adder GENERIC MAP(res_n => 18, op_n => 18, addi => 0) 
	PORT MAP(dataa => e, datab => threshold1, res => sig7);

	sign(0) <= sig7(17);

	Div1 : division GENERIC MAP(mul_n => 18) 
	PORT MAP(clk => clk, reset_n => reset, data_valid => data_valid, A_in => threshold1, B_in => e, Z_out => sig8);
	
	sleep1(0) <= sleep;
	
	lab0 : FOR i IN 1 TO 10 GENERATE
		PROCESS (reset, clk) IS
		BEGIN
			IF reset = '0' THEN
				sign(i) <= '0';
				sleep1(i) <= '1';
			ELSIF clk'event AND clk = '1' THEN 
				IF (data_valid = '1') THEN
					sign(i) <= sign(i - 1);
					sleep1(i) <= sleep1(i - 1);
				END IF;
			END IF;
		END PROCESS;
	END GENERATE;

	c <= sig8 WHEN (sign(10) = '0' AND sleep1(10) = '0') ELSE
		one;

	PROCESS (clk) IS
		VARIABLE pommin : STD_LOGIC_VECTOR(17 DOWNTO 0);
	BEGIN
		IF clk'event AND clk = '1' THEN
			IF (data_valid = '1') THEN

				IF (min = cpom(LE)) THEN
					cprim <= cpom(LE);
				ELSE
					cprim <= one;
				END IF;

				cpom(0) <= c;
				pommin := c;
				FOR i IN 0 TO LE - 1 LOOP
					cpom(i + 1) <= cpom(i);
					IF (pommin > cpom(i)) THEN
						pommin := cpom(i);
					END IF;
				END LOOP;
			END IF;
		END IF;
		min <= pommin;
	END PROCESS;

	PROCESS (clk) IS
		VARIABLE pommax : STD_LOGIC_VECTOR(17 DOWNTO 0);
	BEGIN
		IF clk'event AND clk = '1' THEN
			IF (data_valid = '1') THEN

				IF (max = cpom2(0)) THEN
					cprim2 <= cpom2(0);
				ELSE
					cprim2 <= one;
				END IF;

				cpom2(0) <= cprim;
				pommax := cprim;
				FOR i IN 0 TO LE - 1 LOOP
					cpom2(i + 1) <= cpom2(i);
					IF (pommax > cpom2(i)) THEN
						pommax := cpom2(i);
					END IF;
				END LOOP;
			END IF;
		END IF;
		max <= pommax;
	END PROCESS;

	Adder3 : adder GENERIC MAP(res_n => 18, op_n => 18, addi => 0) 
	PORT MAP(dataa => one, datab => cprim2, res => sig9);

	Adder4 : adder GENERIC MAP(res_n => 18, op_n => 18, addi => 0) 
	PORT MAP(dataa => sig9, datab => f, res => sig10);
	
	PROCESS (sig10) IS
	BEGIN
		IF (sig10(17) = '0') THEN
			y <= sig10;
		ELSE
			y <= zero;
		END IF;
	END PROCESS;
	
	gfir : gfirhf16mod_bj PORT MAP(
		sleep => sleep,
		clk => clk,
		reset => reset,
		reset_mem_n => reset_mem_n,
		bypass => '0',
		xi => y(17 DOWNTO 2),
		xq => y(17 DOWNTO 2),
		n => n,
		l => l,
		maddressf0 => maddressf0,
		maddressf1 => maddressf1,
		mimo_en => mimo_en,
		sdin => sdin,
		sclk => sclk,
		sen => sen,
		sdout => sdout,
		oen => oen,
		yi => o1,
		yq => f1,
		xen => xen1,
		odd => odd,
		half => '1');

	o <= o1(23 DOWNTO 6);
	f <= f1(24 DOWNTO 7);

	Adder5 : adder GENERIC MAP(res_n => 18, op_n => 18, addi => 0) 
	PORT MAP(dataa => one, datab => o, res => b);
	
	xi_reg(0) <= xi1;
	xq_reg(0) <= xq1;

	lab1 : FOR i IN 1 TO nd + 32 GENERATE
		PROCESS (reset, clk) IS
		BEGIN
			IF reset = '0' THEN
				xi_reg(i) <= (OTHERS => '0');
				xq_reg(i) <= (OTHERS => '0');
			ELSIF clk'event AND clk = '1' THEN
				IF (data_valid = '1') THEN
					xi_reg(i) <= xi_reg(i - 1);
					xq_reg(i) <= xq_reg(i - 1);
				END IF;
			END IF;
		END PROCESS;
	END GENERATE;

	selsig <= "00110000" WHEN (n = x"03") ELSE 
		"00100111" WHEN (n = x"01") ELSE 
		"00100101"; 

	mux : PROCESS (xi_reg, xq_reg, selsig) IS
	BEGIN
		xi2 <= xi_reg(conv_integer(selsig));
		xq2 <= xq_reg(conv_integer(selsig));
	END PROCESS mux;
	
	MultIb : multiplier2 PORT MAP(dataa => xi2, datab => b, result => sig11);
	MultQb : multiplier2 PORT MAP(dataa => xq2, datab => b, result => sig12);

	PROCESS (reset, clk) IS
	BEGIN
		IF reset = '0' THEN
			yi <= (OTHERS => '0');
			yq <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF (data_valid = '1') THEN
				IF bypass = '0' THEN
					yi <= sig11(32 DOWNTO 17);
					yq <= sig12(32 DOWNTO 17);
				ELSE
					yi <= xi2(16 DOWNTO 1);
					yq <= xq2(16 DOWNTO 1);
				END IF;
			END IF;
		END IF;
	END PROCESS;

END ARCHITECTURE struct;