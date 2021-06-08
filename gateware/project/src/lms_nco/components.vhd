-- ----------------------------------------------------------------------------	
-- FILE:	components.vhd
-- DESCRIPTION:	This package contains all components declarations.
-- DATE:	July 24, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.mem_package.all ;

-- ----------------------------------------------------------------------------
-- Package declaration
-- ----------------------------------------------------------------------------
package components is

-- ------------------------------------ ---------------------------------------
component bcla8
	port (
		a: in std_logic_vector (7 downto 0);
		b: in std_logic_vector (7 downto 0);
		cin: in std_logic;
		cout: buffer std_logic;
		s: buffer std_logic_vector (7 downto 0)
    );
end component;
-- ----------------------------------------------------------------------------
component hb2e 
	port
	(
		clk	: in std_logic;
		en	: in std_logic;
		nrst	: in std_logic;
		x		: in signed (17 downto 0);
		y		: out signed (17 downto 0)
	);
end component;
-- ----------------------------------------------------------------------------
component hb2o
	port 
	(
		x: in signed(17 downto 0); 	-- Input signal
		clk: in std_logic;			-- Clock and reset
		en: in std_logic;
		nrst: in std_logic;
		y: out signed(17 downto 0) 	-- Output signal
   );
end component;
-- ----------------------------------------------------------------------------
component clkdiv
    port (
	n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
	sleep: in std_logic;			-- Sleep signal
	clk: in std_logic;			-- Clock and reset
	nrst: in std_logic;
	en: out std_logic			-- Output enable signal
    );
end component;
-- ----------------------------------------------------------------------------
component tsp
	port(
		fcw1: in std_logic_vector(17 downto 0);
		fcw2: in std_logic_vector(17 downto 0);
		fcw3: in std_logic_vector(17 downto 0);
		fcw4: in std_logic_vector(17 downto 0);
		clk: in std_logic;
		reset: in std_logic;
		en: in std_logic; -- Enable
		sines: out std_logic_vector(17 downto 0);
		cosines: out std_logic_vector(17 downto 0)
	);
end component;
-- ----------------------------------------------------------------------------
component coarse19x16
   port (
       a: in        std_logic_vector (10 downto 0);
       o: buffer    std_logic_vector (12 downto 0)
   );
end component;
-- ----------------------------------------------------------------------------
component ddfs19x19x16
    port (
    	fcw: in std_logic_vector (17 downto 0); -- Frequency control word
    	clk: in std_logic; -- Clock
    	reset: in std_logic; -- Reset
	en: in std_logic; -- Enable
    	toggle: in std_logic; -- Carry in toggling control signal
    	sin: buffer std_logic_vector (15 downto 0); --Sinus output signal
	cos: buffer std_logic_vector (15 downto 0)  --Cosinus output signal 
    );
end component;
-- ----------------------------------------------------------------------------
component fine19x16
   port (
       a: in        std_logic_vector (10 downto 0);
       o: buffer    std_logic_vector (4 downto 0)
   );
end component;
-- ----------------------------------------------------------------------------
component iqrgen
	generic (
		size: positive; 
		crest: natural;
		yi0: std_logic_vector(32 downto 0);
		yq0: std_logic_vector(32 downto 0)
	);
	port (
		clk: in std_logic;
		reset: in std_logic;
		en: in std_logic;
		yi: buffer std_logic_vector(size-1 downto 0);
		yq: buffer std_logic_vector(size-1 downto 0)
	);
end component;
-- ----------------------------------------------------------------------------
component lut19x16
    port (
    	phase: in	std_logic_vector (18 downto 0);
    	sine:  buffer	std_logic_vector (15 downto 0)
    );
end component;
-- ----------------------------------------------------------------------------
component prsgen1
	generic(y0: std_logic_vector(32 downto 0));
	port (
		clk: in std_logic;
		reset: in std_logic;
		en: in std_logic;
		y: buffer std_logic_vector(32 downto 0)
	);
end component;
-- ----------------------------------------------------------------------------
component prsgen2
	generic(y0: std_logic_vector(32 downto 0));
	port (
		clk: in std_logic;
		reset: in std_logic;		    
		en: in std_logic;
		y: buffer std_logic_vector(32 downto 0)
	);
end component;
-- ----------------------------------------------------------------------------
component hb2
	port (
		xi: in signed(17 downto 0); 	-- I input signal
		xq: in signed(17 downto 0); 	-- Q input signal
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio is 2^n
		sleep: in std_logic;			-- Sleep mode control
		clk: in std_logic;			-- Clock and reset
		nrst: in std_logic;
		xen: out std_logic;
		yi: out signed(17 downto 0); 	-- I output signal
		yq: out signed(17 downto 0) 	-- Q output signal
    );
end component;
-- ----------------------------------------------------------------------------
component hb1
		port 
		(
		xi: in signed(17 downto 0); 	-- I input signal
		xq: in signed(17 downto 0); 	-- Q input signal
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
		sleep: in std_logic;			-- Sleep mode control
		clk: in std_logic;			-- Clock and reset
		nrst: in std_logic;
		xen: out std_logic;			-- HBI input enable
		yi: out signed(17 downto 0); 	-- I output signal
		yq: out signed(17 downto 0) 	-- Q output signal
    );
end component;
-- ----------------------------------------------------------------------------
component hb1o
	port 
	(
		x: in signed (17 downto 0); 	-- Input signal
		clk: in std_logic;			-- Clock and reset
		en: in std_logic;
		nrst: in std_logic;
		y: out signed (17 downto 0) 	-- Output signal
   );
end component;
-- ----------------------------------------------------------------------------
component hb1e
	port
	(
		clk	: in std_logic;
		en	: in std_logic;
		nrst	: in std_logic;
		x		: in signed (17 downto 0);
		y		: out signed (17 downto 0)
	);
end component;
-- ----------------------------------------------------------------------------
component hbi
	port 
	(
		xi: in std_logic_vector(17 downto 0); 	-- I input signal
		xq: in std_logic_vector(17 downto 0); 	-- Q input signal
		n: in std_logic_vector(1 downto 0);	-- Interpolation ratio is 2^n
		nd: in std_logic_vector(7 downto 0);	-- Clock division is nd+1
		sleep: in std_logic;			-- Sleep mode control
		clk: in std_logic;			-- Clock and reset
		nrst: in std_logic;
		byp: in std_logic;
		xen: out std_logic;			-- HBI input enable
		yi: out std_logic_vector(17 downto 0); 	-- I output signal
		yq: out std_logic_vector(17 downto 0) 	-- Q output signal
    );
end component;
-- ----------------------------------------------------------------------------
component hb1d
	port
	(
		xi: in std_logic_vector(17 downto 0); 	-- I input signal
		xq: in std_logic_vector(17 downto 0); 	-- Q input signal
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
		sleep: in std_logic;			-- Sleep mode control
		clk: in std_logic;			-- Clock and reset
		nrst: in std_logic;
		yen: out std_logic;			-- HBI output enable
		yi: out std_logic_vector(17 downto 0); 	-- I output signal
		yq: out std_logic_vector(17 downto 0) 	-- Q output signal
		);
end component;
-- ----------------------------------------------------------------------------
component hb2d
	port
	(
		xi: in std_logic_vector(17 downto 0); 	-- I input signal
		xq: in std_logic_vector(17 downto 0); 	-- Q input signal
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
		sleep: in std_logic;			-- Sleep mode control
		clk: in std_logic;			-- Clock and reset
		nrst: in std_logic;
		yen: out std_logic;			-- HBI input enable
		yi: out std_logic_vector(17 downto 0); 	-- I output signal
		yq: out std_logic_vector(17 downto 0) 	-- Q output signal
		);
end component;
-- ----------------------------------------------------------------------------
component hbd
port (
	xi: in std_logic_vector(17 downto 0); 	-- I input signal
	xq: in std_logic_vector(17 downto 0); 	-- Q input signal
	n: in std_logic_vector(1 downto 0);	-- Interpolation ratio is 2^n
	nd: in std_logic_vector(7 downto 0);	-- Clock division is n+1
	sleep: in std_logic;			-- Sleep mode control
	clk: in std_logic;			-- Clock and reset
	nrst: in std_logic;
	byp: in std_logic;
	yen: out std_logic;			-- HBD data ready
	yi: out std_logic_vector(17 downto 0); 	-- I output signal
	yq: out std_logic_vector(17 downto 0) 	-- Q output signal
    );
end component;
-- ----------------------------------------------------------------------------
component phaccu
	port
	(
		fcw: in	std_logic_vector (31 downto 0); -- Frequency Control Word
		clk: in std_logic; -- Clock signal
		en: in std_logic;  -- Enable signal
		nrst: in std_logic; -- Reset signal
		phase: buffer std_logic_vector (18 downto 0) -- Phase signal
	);
end component;
-- ----------------------------------------------------------------------------
component qpsmc19x14
    port (
	phase: in std_logic_vector(18 downto 0); -- Input phase
	sin: out std_logic_vector(13 downto 0); -- In phase output signal
	cos: out std_logic_vector(13 downto 0); -- Quadrature output signal 
	ofc: in std_logic; 	-- Output Format Control 
	clk: in std_logic;	-- Clock, enable and reset
	reset: in std_logic;
	spc: in std_logic	-- Sine Phase Control signal
    );
end component;
-- ----------------------------------------------------------------------------
component csava7x6
    port (
	in1: in std_logic_vector(6 downto 0); -- First input
	in2: in std_logic_vector(6 downto 0);
	in3: in std_logic_vector(6 downto 0);
	in4: in std_logic_vector(6 downto 0);
	in5: in std_logic_vector(6 downto 0);
	in6: in std_logic_vector(6 downto 0);	-- Last input
	s: out std_logic_vector(6 downto 0);	-- Sum output
	c: out std_logic_vector(6 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component bcla4
    port (
        a: in std_logic_vector (3 downto 0);
        b: in std_logic_vector (3 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (3 downto 0)
    );
end component;
-- ----------------------------------------------------------------------------
component csava9x6
    port (
	in1: in std_logic_vector(8 downto 0); -- First input
	in2: in std_logic_vector(8 downto 0);
	in3: in std_logic_vector(8 downto 0);
	in4: in std_logic_vector(8 downto 0);
	in5: in std_logic_vector(8 downto 0);
	in6: in std_logic_vector(8 downto 0);	-- Last input
	s: out std_logic_vector(8 downto 0);	-- Sum output
	c: out std_logic_vector(8 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava11x6
    port (
	in1: in std_logic_vector(10 downto 0); -- First input
	in2: in std_logic_vector(10 downto 0);
	in3: in std_logic_vector(10 downto 0);
	in4: in std_logic_vector(10 downto 0);
	in5: in std_logic_vector(10 downto 0);
	in6: in std_logic_vector(10 downto 0);	-- Last input
	s: out std_logic_vector(10 downto 0);	-- Sum output
	c: out std_logic_vector(10 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava12x8
    port (
	in1: in std_logic_vector(11 downto 0); -- First input
	in2: in std_logic_vector(11 downto 0);
	in3: in std_logic_vector(11 downto 0);
	in4: in std_logic_vector(11 downto 0);
	in5: in std_logic_vector(11 downto 0);
	in6: in std_logic_vector(11 downto 0);
	in7: in std_logic_vector(11 downto 0);
	in8: in std_logic_vector(11 downto 0);	-- Last input
	s: out std_logic_vector(11 downto 0);	-- Sum output
	c: out std_logic_vector(11 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava14x6
    port (
	in1: in std_logic_vector(13 downto 0); -- First input
	in2: in std_logic_vector(13 downto 0);
	in3: in std_logic_vector(13 downto 0);
	in4: in std_logic_vector(13 downto 0);
	in5: in std_logic_vector(13 downto 0);
	in6: in std_logic_vector(13 downto 0);	-- Last input
	s: out std_logic_vector(13 downto 0);	-- Sum output
	c: out std_logic_vector(13 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava15x6 
    port (
	in1: in std_logic_vector(14 downto 0); -- First input
	in2: in std_logic_vector(14 downto 0);
	in3: in std_logic_vector(14 downto 0);
	in4: in std_logic_vector(14 downto 0);
	in5: in std_logic_vector(14 downto 0);
	in6: in std_logic_vector(14 downto 0);	-- Last input
	s: out std_logic_vector(14 downto 0);	-- Sum output
	c: out std_logic_vector(14 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava17x6
    port (
	in1: in std_logic_vector(16 downto 0); -- First input
	in2: in std_logic_vector(16 downto 0);
	in3: in std_logic_vector(16 downto 0);
	in4: in std_logic_vector(16 downto 0);
	in5: in std_logic_vector(16 downto 0);
	in6: in std_logic_vector(16 downto 0);	-- Last input
	s: out std_logic_vector(16 downto 0);	-- Sum output
	c: out std_logic_vector(16 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava18x6
    port (
	in1: in std_logic_vector(17 downto 0); -- First input
	in2: in std_logic_vector(17 downto 0);
	in3: in std_logic_vector(17 downto 0);
	in4: in std_logic_vector(17 downto 0);
	in5: in std_logic_vector(17 downto 0);
	in6: in std_logic_vector(17 downto 0);	-- Last input
	s: out std_logic_vector(17 downto 0);	-- Sum output
	c: out std_logic_vector(17 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava20x6
    port (
	in1: in std_logic_vector(19 downto 0); -- First input
	in2: in std_logic_vector(19 downto 0);
	in3: in std_logic_vector(19 downto 0);
	in4: in std_logic_vector(19 downto 0);
	in5: in std_logic_vector(19 downto 0);
	in6: in std_logic_vector(19 downto 0);	-- Last input
	s: out std_logic_vector(19 downto 0);	-- Sum output
	c: out std_logic_vector(19 downto 0)	-- Carry output
    );
end component;

-- ----------------------------------------------------------------------------
component csava20x9
    port (
	in1: in std_logic_vector(19 downto 0); -- First input
	in2: in std_logic_vector(19 downto 0);
	in3: in std_logic_vector(19 downto 0);
	in4: in std_logic_vector(19 downto 0);
	in5: in std_logic_vector(19 downto 0);
	in6: in std_logic_vector(19 downto 0);
	in7: in std_logic_vector(19 downto 0);
	in8: in std_logic_vector(19 downto 0);
	in9: in std_logic_vector(19 downto 0);	-- Last input
	s: out std_logic_vector(19 downto 0);	-- Sum output
	c: out std_logic_vector(19 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csa10
    port (
        a: in std_logic_vector (9 downto 0);
        b: in std_logic_vector (9 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (9 downto 0)
    );
end component;
-- ----------------------------------------------------------------------------
component csava8x6
    port (
	in1: in std_logic_vector(7 downto 0); -- First input
	in2: in std_logic_vector(7 downto 0);
	in3: in std_logic_vector(7 downto 0);
	in4: in std_logic_vector(7 downto 0);
	in5: in std_logic_vector(7 downto 0);
	in6: in std_logic_vector(7 downto 0);	-- Last input
	s: out std_logic_vector(7 downto 0);	-- Sum output
	c: out std_logic_vector(7 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava10x6
    port (
	in1: in std_logic_vector(9 downto 0); -- First input
	in2: in std_logic_vector(9 downto 0);
	in3: in std_logic_vector(9 downto 0);
	in4: in std_logic_vector(9 downto 0);
	in5: in std_logic_vector(9 downto 0);
	in6: in std_logic_vector(9 downto 0);	-- Last input
	s: out std_logic_vector(9 downto 0);	-- Sum output
	c: out std_logic_vector(9 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava12x6
    port (
	in1: in std_logic_vector(11 downto 0); -- First input
	in2: in std_logic_vector(11 downto 0);
	in3: in std_logic_vector(11 downto 0);
	in4: in std_logic_vector(11 downto 0);
	in5: in std_logic_vector(11 downto 0);
	in6: in std_logic_vector(11 downto 0);	-- Last input
	s: out std_logic_vector(11 downto 0);	-- Sum output
	c: out std_logic_vector(11 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava13x6
    port (
	in1: in std_logic_vector(12 downto 0); -- First input
	in2: in std_logic_vector(12 downto 0);
	in3: in std_logic_vector(12 downto 0);
	in4: in std_logic_vector(12 downto 0);
	in5: in std_logic_vector(12 downto 0);
	in6: in std_logic_vector(12 downto 0);	-- Last input
	s: out std_logic_vector(12 downto 0);	-- Sum output
	c: out std_logic_vector(12 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava14x8
    port (
	in1: in std_logic_vector(13 downto 0); -- First input
	in2: in std_logic_vector(13 downto 0);
	in3: in std_logic_vector(13 downto 0);
	in4: in std_logic_vector(13 downto 0);
	in5: in std_logic_vector(13 downto 0);
	in6: in std_logic_vector(13 downto 0);
	in7: in std_logic_vector(13 downto 0);
	in8: in std_logic_vector(13 downto 0);	-- Last input
	s: out std_logic_vector(13 downto 0);	-- Sum output
	c: out std_logic_vector(13 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava16x6
    port (
	in1: in std_logic_vector(15 downto 0); -- First input
	in2: in std_logic_vector(15 downto 0);
	in3: in std_logic_vector(15 downto 0);
	in4: in std_logic_vector(15 downto 0);
	in5: in std_logic_vector(15 downto 0);
	in6: in std_logic_vector(15 downto 0);	-- Last input
	s: out std_logic_vector(15 downto 0);	-- Sum output
	c: out std_logic_vector(15 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava17x8
    port (
	in1: in std_logic_vector(16 downto 0); -- First input
	in2: in std_logic_vector(16 downto 0);
	in3: in std_logic_vector(16 downto 0);
	in4: in std_logic_vector(16 downto 0);
	in5: in std_logic_vector(16 downto 0);
	in6: in std_logic_vector(16 downto 0);
	in7: in std_logic_vector(16 downto 0);
	in8: in std_logic_vector(16 downto 0);	-- Last input
	s: out std_logic_vector(16 downto 0);	-- Sum output
	c: out std_logic_vector(16 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava18x8
    port (
	in1: in std_logic_vector(17 downto 0); -- First input
	in2: in std_logic_vector(17 downto 0);
	in3: in std_logic_vector(17 downto 0);
	in4: in std_logic_vector(17 downto 0);
	in5: in std_logic_vector(17 downto 0);
	in6: in std_logic_vector(17 downto 0);
	in7: in std_logic_vector(17 downto 0);
	in8: in std_logic_vector(17 downto 0);	-- Last input
	s: out std_logic_vector(17 downto 0);	-- Sum output
	c: out std_logic_vector(17 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component csava20x8
    port (
	in1: in std_logic_vector(19 downto 0); -- First input
	in2: in std_logic_vector(19 downto 0);
	in3: in std_logic_vector(19 downto 0);
	in4: in std_logic_vector(19 downto 0);
	in5: in std_logic_vector(19 downto 0);
	in6: in std_logic_vector(19 downto 0);
	in7: in std_logic_vector(19 downto 0);
	in8: in std_logic_vector(19 downto 0);	-- Last input
	s: out std_logic_vector(19 downto 0);	-- Sum output
	c: out std_logic_vector(19 downto 0)	-- Carry output
    );
end component;
-- ----------------------------------------------------------------------------
component bcla5
    port (
        a: in std_logic_vector (4 downto 0);
        b: in std_logic_vector (4 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (4 downto 0)
    );
end component;
-- ----------------------------------------------------------------------------
component nco
    port (
    	fcw: in std_logic_vector (31 downto 0); -- Frequency control word
    	ofc: in std_logic; -- Output format control signal
			spc: in std_logic; -- Sine phase control signal
			sleep: in std_logic; -- Sleep signal
    	clk: in std_logic; -- Clock
    	nrst: in std_logic; -- Reset
    	sin: out std_logic_vector (13 downto 0); -- Sine ouput
			cos: out std_logic_vector (13 downto 0) -- Cosine ouput
    );
end component;

-- ----------------------------------------------------------------------------
component dcram
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0)
	);
END component;
-- ----------------------------------------------------------------------------
--component cnt_5
--	generic 
--	( 
--		N : integer := 0
--		--l : integer := 0
--	);
--	port
--	(
--		clk	: in std_logic;
--		nrst	: in std_logic;
--		en 		:  in std_logic;
--		--N 		: in integer; --(7 downto 0);
--		l			: in integer;
--		y			: out std_logic_vector (7 downto 0)
--	);
--end component;
-- ----------------------------------------------------------------------------
component cnt_5
	generic 
	( 
		N : integer := 0
		--l : integer := 0
	);
	port
	(
		clk		: in std_logic;
		nrst	: in std_logic;
		en 		:  in std_logic;
		enB 		:  in std_logic;
		sc			: in std_logic_vector (7 downto 0);
		--N 		: in integer; --(7 downto 0);
		l			: in integer;
		y			: out std_logic_vector (7 downto 0)
	);
end component;

component clkdiviq
    port (
	n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
	sleep: in std_logic;			-- Sleep signal
	clk: in std_logic;			-- Clock and reset
	nrst: in std_logic;
	en: out std_logic			-- Output enable signal
    );
end component;


end components;
