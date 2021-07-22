-- ----------------------------------------------------------------------------	
-- FILE: 	accu10x26.vhd
-- DESCRIPTION: This file implements digital integrator with 10 inputs
--		each 26 bit wide. Accumulator is used in MAC based FIR 
--		filters implementation.
-- DATE:	Sep 04, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	Sep 11, 2001:	Signal xen changed to more logical 
--				oen (Output Enable).
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity accu10x26mac is
    port (
	x1: in std_logic_vector(25 downto 0); -- First input
	x2: in std_logic_vector(25 downto 0);
	x3: in std_logic_vector(25 downto 0);
	x4: in std_logic_vector(25 downto 0);
	x5: in std_logic_vector(25 downto 0);
	x6: in std_logic_vector(25 downto 0);
	x7: in std_logic_vector(25 downto 0);
	x8: in std_logic_vector(25 downto 0);
	x9: in std_logic_vector(25 downto 0);
	x10: in std_logic_vector(25 downto 0);	-- Last input
	ien, oen, en: in std_logic;		-- Enable control signals
	clk, reset: in std_logic;
	y: out std_logic_vector(24 downto 0)
    );
end accu10x26mac;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture accu10x26mac_arch of accu10x26mac is
	constant WIDTH: integer := 26;	-- Adder width
	signal s1: std_logic_vector(WIDTH-1 downto 0); -- Internal sums	
	signal s1d: std_logic_vector(WIDTH-1 downto 0); -- Internal sums	
	signal s2: std_logic_vector(WIDTH-1 downto 0); 
	signal s3: std_logic_vector(WIDTH-1 downto 0);
	signal s4: std_logic_vector(WIDTH-1 downto 0);
	signal s4d: std_logic_vector(WIDTH-1 downto 0);
	signal s5: std_logic_vector(WIDTH-1 downto 0);
	signal s6: std_logic_vector(WIDTH-1 downto 0);
	signal s7: std_logic_vector(WIDTH-1 downto 0);
	signal s7d: std_logic_vector(WIDTH-1 downto 0);
	signal s8: std_logic_vector(WIDTH-1 downto 0);
	signal s9: std_logic_vector(WIDTH-1 downto 0);

	signal c1: std_logic_vector(WIDTH-1 downto 1);	-- Internal carries
	signal c1d: std_logic_vector(WIDTH-1 downto 1);	-- Internal carries
	signal c2: std_logic_vector(WIDTH-1 downto 1);
	signal c3: std_logic_vector(WIDTH-1 downto 1);
	signal c4: std_logic_vector(WIDTH-1 downto 1);
	signal c4d: std_logic_vector(WIDTH-1 downto 1);
	signal c5: std_logic_vector(WIDTH-1 downto 1);
	signal c6: std_logic_vector(WIDTH-1 downto 1);
	signal c7: std_logic_vector(WIDTH-1 downto 1);
	signal c7d: std_logic_vector(WIDTH-1 downto 1);
	signal c8: std_logic_vector(WIDTH-1 downto 1);
	signal c9: std_logic_vector(WIDTH-1 downto 1);

	signal s, c, sa, ca, saa, caa: std_logic_vector(WIDTH-1 downto 0);
	signal oenz1, oenz2, oenz3, oenz4, oenz5, oenz6, oenz7, oenz8: std_logic;
	signal ienz1, ienz2, ienz3, ienz4, ienz5, ienz6, ienz7: std_logic;

	signal	x4d,
					x5d,
					x6d, 
					x7d, x7dd,
					x8d, x8dd, 
					x9d, x9dd,
					x10d, x10dd, x10ddd,
					x11, x12, yi: std_logic_vector(WIDTH-1 downto 0);

	signal zero: std_logic;
		
	use work.components.add26;
	for all:add26 use entity work.add26(add26_arch);

begin				  
	zero <= '0';

	-- Construct delayed versions of oen and ien signals
	delay: process(clk, reset)
	begin
		if reset = '0' then
			oenz1 <= '0';
			oenz2 <= '0';
			oenz3 <= '0';
			oenz4 <= '0';
			oenz5 <= '0';
			oenz6 <= '0';
			oenz7 <= '0';
			oenz8 <= '0';
			ienz1 <= '0';
			ienz2 <= '0';
			ienz3 <= '0';
			ienz4 <= '0';
			ienz5 <= '0';
			ienz6 <= '0';
			ienz7 <= '0';
		elsif clk'event and clk = '1' then
			if en = '1' then
				oenz1 <= oen;
				oenz2 <= oenz1;
				oenz3 <= oenz2;
				oenz4 <= oenz3;
				oenz5 <= oenz4;
				oenz6 <= oenz5;
				oenz7 <= oenz6;
				oenz8 <= oenz7;
				ienz1 <= ien;
				ienz2 <= ienz1;
				ienz3 <= ienz2;
				ienz4 <= ienz3;
				ienz5 <= ienz4;
				ienz6 <= ienz5;
				ienz7 <= ienz6;
			end if;
		end if;
	end process delay;

		    
	-- Row 1
	-- -------------------------------------------------------------
	row1: for i in 0 to WIDTH-2 generate
		s1(i) <= x1(i) xor x2(i) xor x3(i);
		c1(i+1) <= (x1(i) and x2(i)) or (x1(i) and x3(i)) or
			  (x2(i) and x3(i));
	end generate row1;
	s1(WIDTH-1) <= x1(WIDTH-1) xor x2(WIDTH-1) xor x3(WIDTH-1);
	
	-- Latch
	-- -------------------------------------------------------------
	latcha: process(clk, reset)
	begin
		if reset = '0' then
			s1d <= (others => '0');
			c1d <= (others => '0');
			x4d <= (others => '0');
			x5d <= (others => '0');
			x6d <= (others => '0');
			x7d <= (others => '0');
			x8d <= (others => '0');
			x9d <= (others => '0');
			x10d <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' and ienz4 = '1' then
				s1d <= s1;
				c1d <= c1;
				x4d <= x4;
				x5d <= x5;
				x6d <= x6;
				x7d <= x7;
				x8d <= x8;
				x9d <= x9;
				x10d <= x10;
			end if;
		end if;
	end process latcha;

	-- Row 2
	-- -------------------------------------------------------------
	s2(0) <= s1d(0) xor x4d(0);
	c2(1) <= s1d(0) and x4d(0);
	row2: for i in 1 to WIDTH-2 generate
		s2(i) <= x4d(i) xor s1d(i) xor c1d(i);
		c2(i+1) <= (x4d(i) and s1d(i)) or (x4d(i) and c1d(i)) or
			  (s1d(i) and c1d(i));
	end generate row2;
	s2(WIDTH-1) <= x4d(WIDTH-1) xor s1d(WIDTH-1) xor c1d(WIDTH-1);

	-- Row 3
	-- -------------------------------------------------------------
	s3(0) <= s2(0) xor x5d(0);
	c3(1) <= s2(0) and x5d(0);
	row3: for i in 1 to WIDTH-2 generate
		s3(i) <= x5d(i) xor s2(i) xor c2(i);
		c3(i+1) <= (x5d(i) and s2(i)) or (x5d(i) and c2(i)) or
			  (s2(i) and c2(i));
	end generate row3;
	s3(WIDTH-1) <= x5d(WIDTH-1) xor s2(WIDTH-1) xor c2(WIDTH-1);
	
	-- Row 4
	-- -------------------------------------------------------------
	s4(0) <= s3(0) xor x6d(0);
	c4(1) <= s3(0) and x6d(0);
	row4: for i in 1 to WIDTH-2 generate
		s4(i) <= x6d(i) xor s3(i) xor c3(i);
		c4(i+1) <= (x6d(i) and s3(i)) or (x6d(i) and c3(i)) or
			  (s3(i) and c3(i));
	end generate row4;
	s4(WIDTH-1) <= x6d(WIDTH-1) xor s3(WIDTH-1) xor c3(WIDTH-1);
	
	
	
	-- Latch
	-- -------------------------------------------------------------
	latchb: process(clk, reset)
	begin
		if reset = '0' then
			s4d <= (others => '0');
			c4d <= (others => '0');
			x9dd <= (others => '0');
			x8dd <= (others => '0');
			x7dd <= (others => '0');
			x10dd <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' and ienz5 = '1' then
				s4d <= s4;
				c4d <= c4;
				x7dd <= x7d;
				x8dd <= x8d;
				x9dd <= x9d;
				x10dd <= x10d;
			end if;
		end if;
	end process latchb;
	

	-- Row 5
	-- -------------------------------------------------------------
	s5(0) <= s4d(0) xor x7dd(0);
	c5(1) <= s4d(0) and x7dd(0);
	row5: for i in 1 to WIDTH-2 generate
		s5(i) <= x7dd(i) xor s4d(i) xor c4d(i);
		c5(i+1) <= (x7dd(i) and s4d(i)) or (x7dd(i) and c4d(i)) or
			  (s4d(i) and c4d(i));
	end generate row5;
	s5(WIDTH-1) <= x7dd(WIDTH-1) xor s4d(WIDTH-1) xor c4d(WIDTH-1);

	-- Row 6
	-- -------------------------------------------------------------
	s6(0) <= s5(0) xor x8dd(0);
	c6(1) <= s5(0) and x8dd(0);
	row6: for i in 1 to WIDTH-2 generate
		s6(i) <= x8dd(i) xor s5(i) xor c5(i);
		c6(i+1) <= (x8dd(i) and s5(i)) or (x8dd(i) and c5(i)) or
			  (s5(i) and c5(i));
	end generate row6;
	s6(WIDTH-1) <= x8dd(WIDTH-1) xor s5(WIDTH-1) xor c5(WIDTH-1);

	-- Row 7
	-- -------------------------------------------------------------
	s7(0) <= s6(0) xor x9dd(0);
	c7(1) <= s6(0) and x9dd(0);
	row7: for i in 1 to WIDTH-2 generate
		s7(i) <= x9dd(i) xor s6(i) xor c6(i);
		c7(i+1) <= (x9dd(i) and s6(i)) or (x9dd(i) and c6(i)) or
			  (s6(i) and c6(i));
	end generate row7;
	s7(WIDTH-1) <= x9dd(WIDTH-1) xor s6(WIDTH-1) xor c6(WIDTH-1);
	   
--	-- Latch
--	-- -------------------------------------------------------------
	latchc: process(clk, reset)
	begin
		if reset = '0' then
			s7d <= (others => '0');
			c7d <= (others => '0');
			x10ddd <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' and ienz6 = '1' then
				s7d <= s7;
				c7d <= c7;
				x10ddd <= x10dd;
			end if;
		end if;
	end process latchc;

	-- Row 8
	-- -------------------------------------------------------------
	s8(0) <= s7d(0) xor x10ddd(0);
	c8(1) <= s7d(0) and x10ddd(0);
	row8: for i in 1 to WIDTH-2 generate
		s8(i) <= x10ddd(i) xor s7d(i) xor c7d(i);
		c8(i+1) <= (x10ddd(i) and s7d(i)) or (x10ddd(i) and c7d(i)) or
			  (s7d(i) and c7d(i));
	end generate row8;
	s8(WIDTH-1) <= x10ddd(WIDTH-1) xor s7d(WIDTH-1) xor c7d(WIDTH-1);

	-- Multiplexters
	x11 <= (others => '0') when oenz8 = '1' else sa;
	x12 <= (others => '0') when oenz8 = '1' else ca;

	-- Row 9
	-- -------------------------------------------------------------
	s9(0) <= s8(0) xor x11(0);
	c9(1) <= s8(0) and x11(0);
	row9: for i in 1 to WIDTH-2 generate
		s9(i) <= x11(i) xor s8(i) xor c8(i);
		c9(i+1) <= (x11(i) and s8(i)) or (x11(i) and c8(i)) or
			  (s8(i) and c8(i));
	end generate row9;
	s9(WIDTH-1) <= x11(WIDTH-1) xor s8(WIDTH-1) xor c8(WIDTH-1);

	-- Row 10
	-- -------------------------------------------------------------
	saa(0) <= s9(0) xor x12(0);
	caa(1) <= s9(0) and x12(0);
	row10: for i in 1 to WIDTH-2 generate
		saa(i) <= x12(i) xor s9(i) xor c9(i);
		caa(i+1) <= (x12(i) and s9(i)) or (x12(i) and c9(i)) or
			  (s9(i) and c9(i));
	end generate row10;
	saa(WIDTH-1) <= x12(WIDTH-1) xor s9(WIDTH-1) xor c9(WIDTH-1);
	caa(0) <= '0';

	-- Latch
	-- -------------------------------------------------------------
	latchd: process(clk, reset)
	begin
		if reset = '0' then
			sa <= (others => '0');
			ca <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' and ienz7 = '1' then
				sa <= saa;
				ca <= caa;
			end if;
		end if;
	end process latchd;

	-- Provides s and c when calculation is finished
	-- -------------------------------------------------------------
	latche: process(clk, reset)
	begin
		if reset = '0' then
			s <= (others => '0');
			c <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' and oenz8 = '1' then
				s <= sa;
				c <= ca;
			end if;
		end if;
	end process latche;

	-- Adder
	adder: add26 port map(a => s, b => c, cin => zero, 
				clk => clk, en => oen, reset => reset,
				s => yi, cout => open);

	-- Saturation logic
	y <=	"0111111111111111111111111" when yi(25 downto 24) = "01" else
		"1000000000000000000000001" when yi(25 downto 24) = "10" else
		yi(24 downto 0);

	-- Print warning if overflow occured
	assert yi(25) = yi(24)
		report "Data overflow in some of PSF filters."
		severity warning;

end accu10x26mac_arch;
