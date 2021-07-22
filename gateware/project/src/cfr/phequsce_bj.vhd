-- ----------------------------------------------------------------------------	
-- FILE: 	phequce.vhd
-- DESCRIPTION:	Configuration engine for the phase equaliser, serial interface.
-- DATE:	Sep 04, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
--		Nov 23, 2001:	Sleep signal latched at the input. See dmuce.vhd
--				comments for details. REMOVED.
--		Nov 29, 2001:	Memory interface changed.
--		Aug 21, 2012: External memoty interface changed to SPI.
-- ----------------------------------------------------------------------------	

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------											
ENTITY phequsce_bj IS
	PORT (
		l : IN std_logic_vector(2 DOWNTO 0); -- Number of taps is 5*(l+1)
		n : IN std_logic_vector(7 DOWNTO 0); -- Clock division ratio = n+1
		sleep : IN std_logic; -- Sleep signal
		clk : IN std_logic; -- Clock
		reset : IN std_logic; -- Reset

		reset_mem_n: in std_logic; 	-- reset coefficients

		-- Memory interface
		maddress : IN std_logic_vector(8 DOWNTO 0);
		mimo_en : IN std_logic; --
		sdin : IN std_logic; -- Data in
		sclk : IN std_logic; -- Data clock
		sen : IN std_logic; -- Enable signal (active low)
		sdout : OUT std_logic; -- Data out
		oen : OUT std_logic;

		-- Outputs
		h0, h1, h2, h3, h4, h5, h6, h7, h8, h9 : OUT std_logic_vector(15 DOWNTO 0); -- Coefficients

		a : OUT std_logic_vector(1 DOWNTO 0); -- Address to data memory
		xen, ien : OUT std_logic -- Control signals
	);
END phequsce_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE phequsce_arch_bj OF phequsce_bj IS

	SIGNAL ai : std_logic_vector(7 DOWNTO 0);
	SIGNAL xeni, nsleep, ieni, covfl : std_logic;

	-- Logic constants
	SIGNAL zero, one : std_logic;
	SIGNAL zeroes : std_logic_vector(4 DOWNTO 0);

	-- Component declarations
	USE work.components.counter8;
	USE work.components.clkdiv;
	USE work.components.fircms_bj;
	FOR ALL : counter8 USE ENTITY work.counter8(counter8_arch);
	FOR ALL : clkdiv USE ENTITY work.clkdiv(clkdiv_arch);
	FOR ALL : fircms_bj USE ENTITY work.fircms_bj(fircms_arch_bj);

	SIGNAL nprim : std_logic_vector(2 DOWNTO 0);

BEGIN

	-- Logic constants
	zero <= '0';
	one <= '1';
	zeroes <= "00000";

	nsleep <= NOT sleep;

	a <= ai(1 DOWNTO 0); 
	xen <= xeni;
	ien <= ieni;

	nprim <= n(2 DOWNTO 0);

	-- Clock division
	clkd : clkdiv PORT MAP(
		n => n, sleep => sleep, clk => clk,
		reset => reset, en => xeni);
	-- Counter	
	countera : counter8 PORT MAP(
		n(7 DOWNTO 3) => zeroes, n(2 DOWNTO 0) => nprim, 
		updown => one, ssr => xeni, clk => clk,
		en => nsleep, reset => reset, q => ai, ovfl => covfl);

	-- Construct integrator enable signal
	ienl : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			ieni <= '0';
		ELSIF clk'event AND clk = '1' THEN
			IF xeni = '1' AND covfl = '1' THEN
				ieni <= '1';
			ELSIF xeni = '0' AND covfl = '1' THEN
				ieni <= '0';
			END IF;
		END IF;
	END PROCESS ienl;

	-- Coefficients memory 
	spic : fircms_bj PORT MAP(
		maddress => maddress, mimo_en => mimo_en, sdin => sdin, sclk => sclk,
		sen => sen, sdout => sdout, 
		hreset => reset_mem_n, 
		oen => oen,
		ai => ai(1 DOWNTO 0), di0 => h0, di1 => h1, di2 => h2, di3 => h3, di4 => h4,
		di5 => h5, di6 => h6, di7 => h7, di8 => h8, di9 => h9);

END phequsce_arch_bj;
