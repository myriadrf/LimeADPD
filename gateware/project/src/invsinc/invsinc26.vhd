-- ----------------------------------------------------------------------------	
-- FILE: 	invsinc.vhd
-- DESCRIPTION:	5 tap FIR filter with positive symmetry
-- DATE:	Feb 06, 2001.
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library	ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------

entity invsinc26 is
	port (
		  clk: in std_logic; -- Clock
		  reset: in std_logic; -- Reset
		  en: in std_logic;			-- Sleep mode control
		  x1: in std_logic_vector(17 downto 0); -- Input
		  y1: out std_logic_vector(17 downto 0)  -- Output
		  
		  --x: in std_logic_vector(25 downto 0); -- Input
		  --y: out std_logic_vector(24 downto 0)  -- Output
		  );
end invsinc26;

-- ----------------------------------------------------------------------------
-- Architecture of invsinc
-- ----------------------------------------------------------------------------

architecture invsinc26_arch of invsinc26 is

--Component	declarations
	
--use work.components.csdm26x4;
--use work.components.ta26;
--use work.components.tt;

--for all:csdm26x4 use entity	work.csdm26x4(csdm26x4_arch);
--for all:ta26 use entity	work.ta26(ta26_arch);
--for all:tt use entity work.tt(tt_arch);

component csdm26x4 is
    port (
    	x0: in std_logic_vector(25 downto 0); -- Inputs
    	x1: in std_logic_vector(25 downto 0);
    	x2: in std_logic_vector(25 downto 0);
    	x3: in std_logic_vector(25 downto 0);
    	d1: in std_logic;			-- Sign bits for x1, ... x3
    	d2: in std_logic;
    	d3: in std_logic;
    	clk: in std_logic;			-- Clock signal
	en: in std_logic;			-- Enable
    	reset: in std_logic;			-- Reset signal
    	sout: out std_logic_vector(25 downto 0)
);
end component csdm26x4;


component tt is
    port (
   x: in std_logic_vector(25 downto 0); 	-- Input signal
	clk: in std_logic;			-- Clock and reset
	en: in std_logic;			-- Enable
	reset: in std_logic;
	y: out std_logic_vector(24 downto 0) 	-- Output signal
);
end component tt;

component ta26 is
    port (
    	a: in std_logic_vector(25 downto 0); -- Inputs
    	b: in std_logic_vector(25 downto 0);
	sign: in std_logic;	-- Sign bit for 'a'
	clk: in std_logic;	-- Clock and reset
	en: in std_logic;	-- Enable
	reset: in std_logic;
	s: buffer std_logic_vector(25 downto 0) -- Output signal
);
end component ta26;
	
--Internal signal declarations
-- ovako je bilo
signal x: std_logic_vector(25 downto 0); -- Input
signal y: std_logic_vector(24 downto 0);  -- Output

signal xh0, xh1, xh2: std_logic_vector(25 downto 0); --CSDM26x4 outputs
signal s0, s1, s2, s3: std_logic_vector(25 downto 0); --TA26 outputs
signal b0, b1, b2, b3: std_logic_vector(25 downto 0);--Latch outputs
signal zero, one: std_logic; --Logic zero and one signals 
signal zero_vec: std_logic_vector(25 downto 0); --Logic zero vector

begin
	
	
	x<=x1(17)&x1&"0000000";  -- input
	y1<=y(24 downto 7);  --output
	--Setting logic signals
	zero <= '0';
	one <= '1';
	zero_vec <= (others => '0');
	
	--Instantiation of CSDMs
	
	csdm1: csdm26x4 port map (

	-- +1/2^7
	x0(25) => x(25),
	x0(24) => x(25),
	x0(23) => x(25),
	x0(22) => x(25),
	x0(21) => x(25),
	x0(20) => x(25),
	x0(19) => x(25),
	x0(18 downto 0) => x(25 downto 7),
	
	-- +1/2^9
	x1(25) => x(25),
	x1(24) => x(25),
	x1(23) => x(25),
	x1(22) => x(25),
	x1(21) => x(25),
	x1(20) => x(25),
	x1(19) => x(25),
	x1(18) => x(25),
	x1(17) => x(25),
	x1(16 downto 0) => x(25 downto 9),
	
	-- +1/2^11
	x2(25) => x(25),
	x2(24) => x(25),
	x2(23) => x(25),
	x2(22) => x(25),
	x2(21) => x(25),
	x2(20) => x(25),
	x2(19) => x(25),
	x2(18) => x(25),
	x2(17) => x(25),
	x2(16) => x(25),
	x2(15) => x(25),
	x2(14 downto 0) => x(25 downto 11),
	
	-- -1/2^13
	x3(25) => x(25),
	x3(24) => x(25),
	x3(23) => x(25),
	x3(22) => x(25),
	x3(21) => x(25),
	x3(20) => x(25),
	x3(19) => x(25),
	x3(18) => x(25),
	x3(17) => x(25),
	x3(16) => x(25),
	x3(15) => x(25),
	x3(14) => x(25), 
	x3(13) => x(25),
	x3(12 downto 0) => x(25 downto 13), 
	
	d1 => zero, d2 => zero, d3 => one,
	clk => clk, en => en, reset => reset,
	sout => xh0
	); 
	
	csdm2: csdm26x4 port map (

	-- +1/2^10
	x0(25) => x(25),
	x0(24) => x(25),
	x0(23) => x(25),
	x0(22) => x(25),
	x0(21) => x(25),
	x0(20) => x(25),
	x0(19) => x(25),
	x0(18) => x(25),
	x0(17) => x(25),
	x0(16) => x(25), 
	x0(15 downto 0) => x(25 downto 10),
	
	-- -1/2^4
	x1(25) => x(25),
	x1(24) => x(25),
	x1(23) => x(25),
	x1(22) => x(25),
	x1(21 downto 0) => x(25 downto 4),
	
	-- -1/2^13
	x2(25) => x(25),
	x2(24) => x(25),
	x2(23) => x(25),
	x2(22) => x(25),
	x2(21) => x(25),
	x2(20) => x(25),
	x2(19) => x(25),
	x2(18) => x(25),
	x2(17) => x(25),
	x2(16) => x(25),
	x2(15) => x(25),
	x2(14) => x(25),
	x2(13) => x(25),
	x2(12 downto 0) => x(25 downto 13), 
	
	-- 0
	x3 => zero_vec,
	
	d1 => one, d2 => one, d3 => zero,
	clk => clk, en => en, reset => reset,
	sout => xh1
	);
	
	csdm3: csdm26x4 port map (

	-- +1/2^0
	x0 => x, 
	
	-- -1/2^3
	x1(25) => x(25),
	x1(24) => x(25),
	x1(23) => x(25),
	x1(22 downto 0) => x(25 downto 3),
	
	-- -1/2^6
	x2(25) => x(25),
	x2(24) => x(25),
	x2(23) => x(25),
	x2(22) => x(25),
	x2(21) => x(25),
	x2(20) => x(25),
	x2(19 downto 0) => x(25 downto 6),
	
	-- -1/2^8
	x3(25) => x(25),
	x3(24) => x(25),
	x3(23) => x(25),
	x3(22) => x(25),
	x3(21) => x(25),
	x3(20) => x(25),
	x3(19) => x(25),
	x3(18) => x(25),
	x3(17 downto 0) => x(25 downto 8),
	
	d1 => one, d2 => one, d3 => one,
	clk => clk, en => en, reset => reset,
	sout => xh2
	);
	
	--Instantiation of Tap Adders
	
	ta1: ta26 port map (a => xh0, b => b0, s => s0, sign => zero, 
	clk => clk, en => en, reset => reset);
	
	ta2: ta26 port map (a => xh1, b => b1, s => s1, sign => zero,
	clk => clk, en => en, reset => reset);
	
	ta3: ta26 port map (a => xh2, b => b2, s => s2, sign => zero,
	clk => clk, en => en, reset => reset);
	
	--Tap Adders for symetric coeficients
		
	ta4: ta26 port map (a => xh1, b => b3, s => s3, sign => zero,
	clk => clk, en => en, reset => reset);
					
	--Latches
	
	l1: process(clk, reset)
	begin
		if reset = '0' then 
			b0 <= (others => '0');
		elsif clk'event and clk='1' then
			if en = '1' then
				b0 <= s1;
			end if;
		end if;
	end process l1;	
	
	l2: process(clk, reset)
	begin
		if reset = '0' then 
			b1 <= (others => '0');
		elsif clk'event and clk='1' then
			if en = '1' then
				b1 <= s2;
			end if;
		end if;
	end process l2;
	
	l3: process(clk, reset)
	begin
		if reset = '0' then 
			b2 <= (others => '0');
		elsif clk'event and clk='1' then
			if en = '1' then	
				b2 <= s3;
			end if;
		end if;
	end process l3;		   
	
	l4: process(clk, reset)
	begin
		if reset = '0' then 
			b3 <= (others => '0');
		elsif clk'event and clk='1' then
			if en = '1' then
				b3 <= xh0;
			end if;
		end if;
	end process l4;
	
	--Tap Termination Cell
	
	tt1: tt port map (x => s0, y => y, clk => clk, en => en, reset => reset);
	
end invsinc26_arch;
	
	
	
	
	
	
	
		  
 