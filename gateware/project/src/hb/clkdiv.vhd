-- ----------------------------------------------------------------------------	
-- FILE:	clkdiv.vhd
-- DESCRIPTION:	Programmable clock divider. Division can be in the range 1-256.
-- DATE:	Sep 05, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	March 01, 2001:	Clich in 'en' signal eliminated.
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity clkdiv is
    port (
	n: in std_logic_vector(7 downto 0);	-- Clock division ratio is n+1
	sleep: in std_logic;			-- Sleep signal
	clk: in std_logic;			-- Clock and reset
	reset: in std_logic;
	en: out std_logic			-- Output enable signal
    );
end clkdiv;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture clkdiv_arch of clkdiv is

	-- Internal signals
	signal a, s: std_logic_vector(7 downto 0);
	signal ovfl: std_logic;

	-- Constant signals
	signal one: std_logic_vector(7 downto 0);
	signal zero: std_logic;
		
	-- Component declaration
	--use work.components.bcla8;
	--for all:bcla8 use entity work.bcla8(bcla8_arch);
	
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
	-- Set constant signals
	one <= "00000001";
	zero <= '0';

	-- 8 bit adder
	adder: bcla8 port map(a => a, b => one, cin => zero, cout => open, s => s);
								   
	-- Latch
	latch: process(clk, reset)
	begin
		if reset = '0' then
			a <= (others => '0');
		elsif clk'event and clk = '1' then
			if ovfl = '1' and sleep = '0' then
				a <= (others => '0');
			elsif ovfl = '0' and sleep = '0' then
				a <= s;
			end if;
		end if;
	end process latch;

	-- Comparator
	ovfl <= '1' when a = n else '0';

	-- Construct output enable signal
	enl: process(clk, reset)
	begin
		if reset = '0' then
			en <= '0';
		elsif clk'event and clk = '1' then
			en <= (not sleep) and ovfl;
		end if;
	end process enl;

end clkdiv_arch;
