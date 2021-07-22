-- ----------------------------------------------------------------------------	
-- FILE:	counter8.vhd
-- DESCRIPTION:	8 bit up/down counter.
-- DATE:	Aug 17, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity counter8 is
    port (
	n: in std_logic_vector (7 downto 0);	-- To count (0-to-n) or (n-to-0)
	updown: in std_logic;			-- To count up or down
	ssr: in std_logic;			-- Synchronious set or reset
	clk: in std_logic;			-- Clock
	en: in std_logic; 			-- Enable signal
	reset: in std_logic;			-- Asynchronious reset
	q: buffer std_logic_vector(7 downto 0);	-- Output
	ovfl: buffer std_logic			-- Overflow flag
    );
end counter8;

-- ----------------------------------------------------------------------------
-- Architecture of phaccu
-- ----------------------------------------------------------------------------
architecture counter8_arch of counter8 is

	-- Internal signals
	signal b, c, s: std_logic_vector(7 downto 0);

	-- Constant signals
	signal zero, one, minus_one: std_logic_vector(7 downto 0);
		
	-- Component declaration
	use work.components.bcla8;
	for all:bcla8 use entity work.bcla8(bcla8_arch);
begin
	-- Set constant signals
	zero      <= "00000000";
	one       <= "00000001";
	minus_one <= "11111111";

	-- 8 bit adder
	adder: bcla8 port map(a => q, b => b, cin => zero(0), cout => open, s => s);
								   
	-- Increment or decrement each clock cycle
	b <= one when updown = '1' else minus_one;

	-- Latch
	latch: process(clk, reset)
	begin
		if reset = '0' then
			q <= (others => '0');
		elsif clk'event and clk = '1' then
			if updown = '1' and ssr = '1' and en = '1' then
				q <= (others => '0');
			elsif updown = '0' and ssr = '1' and en = '1' then
				q <= n;
			elsif en = '1' and ovfl = '0' then
				q <= s;
			end if;
		end if;
	end process latch;

	-- Comparator
	c <= n when updown = '1' else zero;
	ovfl <= '1' when q = c else '0';

end counter8_arch;
