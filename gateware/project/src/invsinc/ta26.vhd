-- ----------------------------------------------------------------------------	
-- FILE: 	ta26.vhd
-- DESCRIPTION:	26 bit tap adder.
-- DATE:	Jul 24, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	July 27:	Datapath width changed to 26.
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity ta26 is
    port (
    	a: in std_logic_vector(25 downto 0); -- Inputs
    	b: in std_logic_vector(25 downto 0);
	sign: in std_logic;	-- Sign bit for 'a'
	clk: in std_logic;	-- Clock and reset
	en: in std_logic;	-- Enable
	reset: in std_logic;
	s: buffer std_logic_vector(25 downto 0) -- Output signal
    );
end ta26;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture ta26_arch of ta26 is
	-- Carry signals
	signal c1, c1l, c2, c2l, c3, c3l: std_logic;
	
	-- Delayed versions of sign bit
	signal signl, signll, signlll: std_logic;
	
	-- Inverted version of 'a' input signal
	signal a1: std_logic_vector(7 downto 0);
	signal a2: std_logic_vector(7 downto 0);
	signal a3: std_logic_vector(7 downto 0);
	signal a4: std_logic_vector(1 downto 0);
	
	-- Component declarations
	--use work.components.bcla2;
	--use work.components.bcla8;
	--for all:bcla2 use entity work.bcla2(bcla2_arch);
	--for all:bcla8 use entity work.bcla8(bcla8_arch);
	
	
	component bcla2 is
  port (
    a:    in     std_logic_vector (1 downto 0);
    b:    in     std_logic_vector (1 downto 0);
    cin:  in     std_logic;
	
    s:    buffer std_logic_vector (1 downto 0);
    cout: buffer std_logic
  );
  end component bcla2;
  
  
  component bcla8 is
    port (
        a: in std_logic_vector (7 downto 0);
        b: in std_logic_vector (7 downto 0);
        cin: in std_logic;
        cout: buffer std_logic;
        s: buffer std_logic_vector (7 downto 0)
    );
    end component bcla8;
	
begin

	-- LATCHES
	latches: process(clk, reset)
	begin
		if reset = '0' then
			c1l <= '0';
			c2l <= '0';
			c3l <= '0';
			signl <= '0';
			signll <= '0';
			signlll <= '0';
		elsif clk'event and clk = '1' then
			if en = '1' then
				c1l <= c1;
				c2l <= c2;
				c3l <= c3;
				signl <= sign;
				signll <= signl;
				signlll <= signll;
			end if;
		end if;
	end process latches;
	
	-- Invert 'a' input if sign = 1
	a1 <= a(7 downto 0) when sign = '0' else not a(7 downto 0);
	a2 <= a(15 downto 8) when signl = '0' else not a(15 downto 8);
	a3 <= a(23 downto 16) when signll = '0' else not a(23 downto 16);
	a4 <= a(25 downto 24) when signlll = '0' else not a(25 downto 24);
	
	-- Low significant bits adder
	addera: bcla8
		port map(a => a1, b => b(7 downto 0), cin => sign, 
			cout => c1, s => s(7 downto 0));

	-- Medium significant bits adder
	adderb: bcla8
		port map(a => a2, b => b(15 downto 8), cin => c1l, 
			cout => c2, s => s(15 downto 8));

	-- High significant bits adder
	adderc: bcla8
		port map(a => a3, b => b(23 downto 16), cin => c2l, 
			cout => c3, s => s(23 downto 16));
	-- Additional 2 bit adder
	adderd: bcla2
		port map(a => a4, b => b(25 downto 24), cin => c3l, 
			cout => open, s => s(25 downto 24));

end ta26_arch;
