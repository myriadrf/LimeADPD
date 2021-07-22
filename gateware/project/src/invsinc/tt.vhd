-- ----------------------------------------------------------------------------	
-- FILE: 	tt.vhd
-- DESCRIPTION:	Tap terminating cell.
-- DATE:	Jul 24, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	July 27:	Datapath width changed to 26.
-- ----------------------------------------------------------------------------	

library work;
library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity tt is
    port (
    	x: in std_logic_vector(25 downto 0); 	-- Input signal
	clk: in std_logic;			-- Clock and reset
	en: in std_logic;			-- Enable
	reset: in std_logic;
	y: out std_logic_vector(24 downto 0) 	-- Output signal
    );
end tt;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture tt_arch of tt is
	-- Signals used in equalizing the delay at the input
	signal xd: std_logic_vector(23 downto 0);
	signal xdd: std_logic_vector(15 downto 0);
	signal xddd: std_logic_vector(7 downto 0);
	
	-- Equalized input
	signal xe: std_logic_vector(25 downto 0);
	
	-- Saturated signal
	signal xs: std_logic_vector(24 downto 0);
	
begin

	-- LATCH A
	latcha: process(clk, reset)
	begin
		if reset = '0' then
			xd <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xd <= x(23 downto 0);
			end if;
		end if;
	end process latcha;

	-- LATCH B
	latchb: process(clk, reset)
	begin
		if reset = '0' then
			xdd <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xdd <= xd(15 downto 0);
			end if;
		end if;
	end process latchb;

	-- LATCH C
	latchc: process(clk, reset)
	begin
		if reset = '0' then
			xddd <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xddd <= xdd(7 downto 0);
			end if;
		end if;
	end process latchc;
	
	-- LATCH D
	latchd: process(clk, reset)
	begin
		if reset = '0' then
			xe <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xe(25 downto 24) <= x(25 downto 24);
				xe(23 downto 16) <= xd(23 downto 16);
				xe(15 downto 8) <= xdd(15 downto 8);
				xe(7 downto 0) <= xddd(7 downto 0);
			end if;
		end if;
	end process latchd;
	
	-- Saturation logic
	xs <=	"0111111111111111111111111" when xe(25 downto 24) = "01" else
		"1000000000000000000000001" when xe(25 downto 24) = "10" else
		xe(24 downto 0);

	-- Print warning if overflow occured
	assert xe(25) = xe(24)
		report "Data overflow in some of the HB filters."
		severity warning;
	
	-- LATCH E
	latche: process(clk, reset)
	begin
		if reset = '0' then
			y <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				y <= xs;
			end if;
		end if;
	end process latche;

end tt_arch;
