-- ----------------------------------------------------------------------------	
-- FILE: 	phequfe.vhd
-- DESCRIPTION:	Filtering engine of the phase equaliser.
-- DATE:	Sep 04, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
ENTITY gfirhf16mod_bj IS
	PORT (
		-- Clock related inputs
		sleep : IN std_logic; -- Sleep signal
		clk : IN std_logic; -- Clock

		reset : IN std_logic; -- Reset
		
		reset_mem_n : IN std_logic;

		bypass : IN std_logic;
		odd, half : IN std_logic;

		-- Data input signals
		xi : IN std_logic_vector(15 DOWNTO 0);
		xq : IN std_logic_vector(15 DOWNTO 0);

		-- Filter configuration
		n : IN std_logic_vector(7 DOWNTO 0); 
		l : IN std_logic_vector(2 DOWNTO 0); 

		-- Coefficient memory interface
		maddressf0 : IN std_logic_vector(8 DOWNTO 0);
		maddressf1 : IN std_logic_vector(8 DOWNTO 0);

		mimo_en : IN std_logic;
		sdin : IN std_logic; -- Data in
		sclk : IN std_logic; -- Data clock
		sen : IN std_logic; -- Enable signal (active low)
		sdout : OUT std_logic; -- Data out
		oen : OUT std_logic;

		-- Filter output signals
		yi : OUT std_logic_vector(24 DOWNTO 0);
		yq : OUT std_logic_vector(24 DOWNTO 0);
		xen : OUT std_logic
	);
END gfirhf16mod_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
ARCHITECTURE gfirhf16_arch_bj OF gfirhf16mod_bj IS

	COMPONENT  phequfehf_bj4 IS
    PORT (
        x : IN std_logic_vector(24 DOWNTO 0); -- Input signal
        n : IN std_logic_vector(7 DOWNTO 0);

        -- Filter configuration
        h0, h1, h2, h3, h4 : IN std_logic_vector(15 DOWNTO 0);
        a : IN std_logic_vector(1 DOWNTO 0); 
        xen, ien, odd, half : IN std_logic;

        -- Clock related inputs
        sleep : IN std_logic; -- Sleep signal
        clk : IN std_logic; -- Clock
        reset : IN std_logic; -- Reset

        y : OUT std_logic_vector(24 DOWNTO 0); -- Filter output
        xo : OUT std_logic_vector(24 DOWNTO 0) -- DRAM output
    );
    END COMPONENT  phequfehf_bj4;

	SIGNAL ce0h0, ce0h1, ce0h2, ce0h3, ce0h4, ce0h5, ce0h6, ce0h7, ce0h8, ce0h9 : std_logic_vector(15 DOWNTO 0); -- Coefficients
	SIGNAL ce1h0, ce1h1, ce1h2, ce1h3, ce1h4, ce1h5, ce1h6, ce1h7, ce1h8, ce1h9 : std_logic_vector(15 DOWNTO 0); -- Coefficients

	SIGNAL ce0a : std_logic_vector(1 DOWNTO 0); -- Address to data memory
	SIGNAL ce1a : std_logic_vector(1 DOWNTO 0); -- Address to data memory

	SIGNAL ce0xen, ce0ien : std_logic; -- Control signals
	SIGNAL ce1xen, ce1ien : std_logic; -- Control signals

	SIGNAL xii : std_logic_vector(24 DOWNTO 0);
	SIGNAL xqi : std_logic_vector(24 DOWNTO 0);
	SIGNAL yii, yim : std_logic_vector(24 DOWNTO 0);
	SIGNAL yqi, yqm : std_logic_vector(24 DOWNTO 0);

	SIGNAL sdout0 : std_logic;
	SIGNAL oen0 : std_logic;
	SIGNAL sdout1 : std_logic;
	SIGNAL oen1 : std_logic;

	USE work.components.phequsce_bj;
	FOR ALL : phequsce_bj USE ENTITY work.phequsce_bj(phequsce_arch_bj);

BEGIN

	xen <= ce0xen;
	xii <= xi & "000000000";
	xqi <= xq & "000000000";

	-- Configuration engines
	ce0 : phequsce_bj PORT MAP(
		l => l, n => n,
		sleep => sleep, clk => clk, reset => reset,

		reset_mem_n => reset_mem_n, 

		maddress => maddressf0, mimo_en => mimo_en, sdin => sdin, sclk => sclk, sen => sen, sdout => sdout0, oen => oen0,
		h0 => ce0h0, h1 => ce0h1, h2 => ce0h2, h3 => ce0h3, h4 => ce0h4, h5 => ce0h5, h6 => ce0h6, h7 => ce0h7, h8 => ce0h8, h9 => ce0h9,
		a => ce0a, xen => ce0xen, ien => ce0ien
	);

	ce1 : phequsce_bj PORT MAP(
		l => l, n => n,
		sleep => sleep, clk => clk, reset => reset,

		reset_mem_n => reset_mem_n, 
		
		maddress => maddressf1, mimo_en => mimo_en, sdin => sdin, sclk => sclk, sen => sen, sdout => sdout1, oen => oen1,
		h0 => ce1h0, h1 => ce1h1, h2 => ce1h2, h3 => ce1h3, h4 => ce1h4, h5 => ce1h5, h6 => ce1h6, h7 => ce1h7, h8 => ce1h8, h9 => ce1h9,
		a => ce1a, xen => ce1xen, ien => ce1ien
	);

	sdout <= (sdout0 AND oen0) OR (sdout1 AND oen1);
	oen <= oen0 OR oen1;


	fei0 : phequfehf_bj4 PORT MAP(
		x => xii, n => n,
		h0 => ce0h0, h1 => ce0h1, h2 => ce0h2, h3 => ce0h3, h4 => ce0h4,
		a => ce0a, xen => ce0xen, ien => ce0ien,
		sleep => sleep, clk => clk, reset => reset,
		y => yii, xo => OPEN, odd => odd, half => '0'
	);

	feq0 : phequfehf_bj4 PORT MAP(
		x => xqi, n => n,
		h0 => ce1h0, h1 => ce1h1, h2 => ce1h2, h3 => ce1h3, h4 => ce1h4,
		a => ce1a, xen => ce1xen, ien => ce1ien,
		sleep => sleep, clk => clk, reset => reset,
		y => yqi, xo => OPEN, odd => odd, half => half
	);
	--	
	-- Bypass MUX'es and registers
	yim <= xii WHEN bypass = '1' ELSE
		yii;
	yqm <= xqi WHEN bypass = '1' ELSE
		yqi;

	dl : PROCESS (clk, reset)
	BEGIN
		IF reset = '0' THEN
			yi <= (OTHERS => '0');
			yq <= (OTHERS => '0');
		ELSIF clk'event AND clk = '1' THEN
			IF sleep = '0' THEN
				yi <= yim;
				yq <= yqm;
			END IF;
		END IF;
	END PROCESS dl;
END gfirhf16_arch_bj;