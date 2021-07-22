-- ----------------------------------------------------------------------------	
-- FILE:	nco.vhd
-- DESCRIPTION: Direct Digital Frequency Synthesiser with:
--			32 bit phase accumulator
--			19 bit phase precision
--			14 bit quadrature outputs
-- DATE:	Aug 02, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
--		Nov 27, 2001:	Enable signal for the sine/cosine
--				look tables removed. Putting 
--				look up table in sleep mode is
--				implemented by just stopping the phase
--				accumulator.
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nco is
    port (
    	fcw: in std_logic_vector (31 downto 0); -- Frequency control word
--    	fmi: in std_logic_vector (31 downto 0); -- FM input
--	fmcin: in std_logic;			-- FM carry in
--	pho: in std_logic_vector (15 downto 0); -- Phase offset
    	ofc: in std_logic; -- Output format control signal
			spc: in std_logic; -- Sine phase control signal
			sleep: in std_logic; -- Sleep signal
    	clk: in std_logic; -- Clock
    	nrst: in std_logic; -- Reset
    	sin: out std_logic_vector (13 downto 0); -- Sine ouput
			cos: out std_logic_vector (13 downto 0) -- Cosine ouput
    );
end nco;

-- ----------------------------------------------------------------------------
-- Architecture of nco
-- ----------------------------------------------------------------------------
architecture nco_arch of nco is
	signal phase: std_logic_vector (18 downto 0);
	signal en: std_logic;
	
	-- Component declarations
	use work.components.phaccu;
	use work.components.qpsmc19x14;
	for all:phaccu use entity work.phaccu(phaccu_arch);
	for all:qpsmc19x14 use entity work.qpsmc19x14(qpsmc19x14_arch);

begin
	-- Enable signals is inverted sleep
	en <= not sleep;

	-- Phase accumulator

	pha: phaccu
		port map
		(
		fcw => fcw, 
		clk => clk,
		en => en,
		nrst => nrst,
		phase => phase
		);	 
	-- Phase to Sine Magnitude Converter
	qpsmc:  qpsmc19x14
		port map(phase => phase, sin => sin, cos => cos, ofc => ofc, 
			clk => clk, reset => nrst, spc => spc);

end nco_arch;
