LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY division IS
	GENERIC (mul_n : NATURAL := 18);
	PORT (
		clk, reset_n, data_valid : IN std_logic;
		A_in : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		B_in : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		Z_out : OUT STD_LOGIC_VECTOR(17 DOWNTO 0));
END division;
ARCHITECTURE struct OF division IS

	COMPONENT adder IS
		GENERIC (
			res_n : NATURAL := 18; 
			op_n : NATURAL := 18; 
			addi : NATURAL := 1); 
		PORT (
			dataa : IN std_logic_vector (op_n - 1 DOWNTO 0);
			datab : IN std_logic_vector (op_n - 1 DOWNTO 0);
			res : OUT std_logic_vector (res_n - 1 DOWNTO 0));
	END COMPONENT Adder;

	TYPE new_type IS ARRAY (9 DOWNTO 0) OF std_logic_vector(19 DOWNTO 0);
	SIGNAL ax, bx, cx : new_type;

	TYPE new_type2 IS ARRAY (9 DOWNTO 0) OF std_logic_vector(17 DOWNTO 0);
	SIGNAL B, C : new_type2;

	TYPE new_type3 IS ARRAY (9 DOWNTO 0) OF std_logic_vector(39 DOWNTO 0);
	SIGNAL A : new_type3;
	SIGNAL data_valid_d : std_logic;

BEGIN
	PROCESS (clk, reset_n) IS
	BEGIN
		IF reset_n = '0' THEN
			data_valid_d <= '0';
			Z_out <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			data_valid_d <= data_valid;
			IF data_valid = '1' THEN
				Z_out <= C(9);
			END IF;
		END IF;
	END PROCESS;

	A(0) <= A_in(17) & A_in(17) & A_in(17) & A_in & x"0000" & "000";
	B(0) <= B_in;
	C(0) <= (OTHERS => '0');

	lab : FOR i IN 1 TO 9 GENERATE
		mux : PROCESS (A, B, data_valid) IS
		BEGIN
			IF data_valid = '1' THEN
				ax(i) <= A(i - 1)(39 DOWNTO 20);
				bx(i) <= B(i - 1)(17) & B(i - 1)(17) & B(i - 1);
			ELSE
				ax(i) <= A(i)(39 DOWNTO 20);
				bx(i) <= B(i)(17) & B(i)(17) & B(i);
			END IF;
		END PROCESS;

		Adder1 : adder GENERIC MAP(res_n => mul_n + 2, op_n => mul_n + 2, addi => 0)
		PORT MAP(dataa => ax(i), datab => bx(i), res => cx(i));

		PROCESS (clk, reset_n) IS
		BEGIN
			IF reset_n = '0' THEN
				A(i) <= (OTHERS => '0');
				B(i) <= (OTHERS => '0');
				C(i) <= (OTHERS => '0');

			ELSIF clk'event AND clk = '1' THEN
				IF data_valid = '1' THEN
					B(i) <= B(i - 1);

					IF cx(i)(19) = '0' THEN
						A(i) <= cx(i)(18 DOWNTO 0) & A(i - 1)(19 DOWNTO 0) & '0';
						C(i) <= C(i - 1)(16 DOWNTO 0) & '1';
					ELSE
						A(i) <= A(i - 1)(38 DOWNTO 0) & '0';
						C(i) <= C(i - 1)(16 DOWNTO 0) & '0';
					END IF;
				END IF;
				IF data_valid_d = '1' THEN
					IF cx(i)(19) = '0' THEN
						A(i) <= cx(i)(18 DOWNTO 0) & A(i)(19 DOWNTO 0) & '0';
						C(i) <= C(i)(16 DOWNTO 0) & '1';
					ELSE
						A(i) <= A(i)(38 DOWNTO 0) & '0';
						C(i) <= C(i)(16 DOWNTO 0) & '0';
					END IF;
				END IF;
			END IF;
		END PROCESS;
	END GENERATE;

END struct;