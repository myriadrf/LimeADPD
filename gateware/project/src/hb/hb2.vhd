-- ----------------------------------------------------------------------------	
-- FILE: 	hb2.vhd
-- DESCRIPTION:	HB2 implemented as interleaved polyphase filter
--		with programmable clock rate.
-- DATE:	July 25, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- TO DO:	Change enable signal generation circuitry by clkdev module.
-- REVISIONS:	Sep 12, 2001:	Clock division circuitry substituted by
--				clkdiv module.
-- ----------------------------------------------------------------------------	

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY hb2 IS
	PORT (
		xi1 : IN std_logic_vector(17 DOWNTO 0); -- I input signal
		xq1 : IN std_logic_vector(17 DOWNTO 0); -- Q input signal
		n : IN std_logic_vector(7 DOWNTO 0); -- Clock division ratio is 2^n
		sleep : IN std_logic; -- Sleep mode control
		clk : IN std_logic; -- Clock and reset
		reset : IN std_logic;
		xen : OUT std_logic;
		yi1 : OUT std_logic_vector(17 DOWNTO 0); -- I output signal
		yq1 : OUT std_logic_vector(17 DOWNTO 0) -- Q output signal
	);
END hb2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE hb2_arch OF hb2 IS

	SIGNAL xi : std_logic_vector(24 DOWNTO 0); -- I input signal
	SIGNAL xq : std_logic_vector(24 DOWNTO 0); -- Q input signal

	SIGNAL yi : std_logic_vector(24 DOWNTO 0); -- I output signal
	SIGNAL yq : std_logic_vector(24 DOWNTO 0); -- Q output signal

	SIGNAL x : std_logic_vector(24 DOWNTO 0); -- Multiplexed xi and xq
	SIGNAL xe : std_logic_vector(24 DOWNTO 0); -- Even input
	SIGNAL xo : std_logic_vector(24 DOWNTO 0); -- Odd input
	SIGNAL ye : std_logic_vector(24 DOWNTO 0); -- Even output
	SIGNAL yo : std_logic_vector(24 DOWNTO 0); -- Odd output
	SIGNAL yia : std_logic_vector(24 DOWNTO 0); -- Advanced yi

	-- Enable and MUX select signal
	SIGNAL en, sel : std_logic;

	-- Component declarations
	USE work.components.hb2e;
	USE work.components.hb2o;
	FOR ALL : hb2e USE ENTITY work.hb2e(hb2e_arch);
	FOR ALL : hb2o USE ENTITY work.hb2o(hb2o_arch);

	USE work.components.clkdiv;
	FOR ALL : clkdiv USE ENTITY work.clkdiv(clkdiv_arch);
	
	-- Borko
	signal  yqprim,  yqsec,  yqter, yqquad: std_logic_vector(17 downto 0);
	constant delay: std_logic:='1';

BEGIN

	xi <= xi1(17 DOWNTO 0) & "0000000";
	xq <= xq1(17 DOWNTO 0) & "0000000";
	-- Clock division
	clkd : clkdiv PORT MAP(
		n => n, clk => clk, reset => reset,
		sleep => sleep, en => en);

	-- MUX select signal
	dff : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			--sel <= '0';
			sel <= '1';
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				sel <= NOT sel;
			END IF;
		END IF;
	END PROCESS dff;

	xen <= sel;

	-- Multiplex xi and xq
	x <= xi WHEN sel = '1' ELSE
		xq;

	-- Latch La
	la : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			xe <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				xe <= x;
			END IF;
		END IF;
	END PROCESS la;

	-- Latch Lb
	lb : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			xo <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				xo <= xe;
			END IF;
		END IF;
	END PROCESS lb;

	-- Even HB2 filter
	even : hb2e
	PORT MAP(x => xe, clk => clk, en => en, reset => reset, y => ye);

	-- Odd HB2 filter
	odd : hb2o
	PORT MAP(x => xo, clk => clk, en => en, reset => reset, y => yo);

	-- Multiplex ye and yo to construct yia and yq
	yia <= ye WHEN sel = '1' ELSE
		yo;
	yq <= ye WHEN sel = '0' ELSE
		yo;

	-- Delay yia one clock cycle to align it with ya
	le : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			yi <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				yi <= yia;
			END IF;
		END IF;
	END PROCESS le;
	
	--- Borko
   delayl: process(clk)
	begin
		if clk'event and clk = '1' then
		
		  yqprim<=yq(24 downto 7);
		  yqsec<=yqprim;
		  yqter<=yqsec;
		  yqquad<=yqter;
		
		end if;
	end process delayl;

	-- Delay  both
	latch : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			yi1 <= (OTHERS => '0');
			yq1 <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF en = '1' THEN
				
				yi1 <= yi(24 DOWNTO 7);
				--yq1 <= yq(24 DOWNTO 7);
				
				if delay='0' then yq1<=yq(24 downto 7);
				else	yq1<= yqprim;
				end if;
				
			END IF;
		END IF;
	END PROCESS latch;

END hb2_arch;