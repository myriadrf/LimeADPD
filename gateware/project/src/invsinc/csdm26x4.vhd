-- ----------------------------------------------------------------------------	
-- FILE: 	csdm26x4.vhd
-- DESCRIPTION:	26 bit by 4 nonzero digits CSD multiplier.
-- DATE:	July 24, 2001
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
entity csdm26x4 is
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
end csdm26x4;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture csdm26x4_arch of csdm26x4 is
	-- Internal versions of x1, x2 and x3
	signal x1i: std_logic_vector(25 downto 0);
	signal x2i: std_logic_vector(25 downto 0);
	signal x3i: std_logic_vector(25 downto 0);
	
	signal s0: std_logic_vector(25 downto 0); -- Internal sums	
	signal s1: std_logic_vector(25 downto 0);
	signal c0: std_logic_vector(25 downto 0); -- Internal carries
	signal c1: std_logic_vector(25 downto 0);
	
	-- Signals inside second pipeline stage
	signal al, bl: std_logic_vector(7 downto 0);
	signal am, bm: std_logic_vector(7 downto 0);
	signal ah, bh: std_logic_vector(7 downto 0);
	signal ae, be: std_logic_vector(1 downto 0);
	signal sl: std_logic_vector(7 downto 0);
	signal c2, cin: std_logic;
	
	-- Signals for the third pipeline stage
	signal aml, bml: std_logic_vector(7 downto 0);
	signal ahl, bhl: std_logic_vector(7 downto 0);
	signal ael, bel: std_logic_vector(1 downto 0);
	signal sm: std_logic_vector(7 downto 0);
	signal c2l, c3: std_logic;
	
	-- Signals for the fourth pipeline stage
	signal ahll, bhll: std_logic_vector(7 downto 0);
	signal aell, bell: std_logic_vector(1 downto 0);
	signal sh: std_logic_vector(7 downto 0);
	signal c3l, c4: std_logic;

	-- Signals inside the fifth stage
	signal aelll, belll: std_logic_vector(1 downto 0);
	signal se: std_logic_vector(1 downto 0);
	signal c4l: std_logic;

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

	-- Invert x1, x2 and x3 according to their sign bits
	x1i <= x1 when d1 = '0' else not x1;
	x2i <= x2 when d2 = '0' else not x2;
	x3i <= x3 when d3 = '0' else not x3;
	
	-- First row of full adders
	-- -------------------------------------------------------------
	row1: for i in 0 to 24 generate
		s0(i) <= x0(i) xor x1i(i) xor x2i(i);
		c0(i+1) <= (x0(i) and x1i(i)) or (x0(i) and x2i(i)) or
			  (x1i(i) and x2i(i));
	end generate row1;
	s0(25) <= x0(25) xor x1i(25) xor x2i(25);
	c0(0) <= d1;

	-- Second row of full adders
	-- -------------------------------------------------------------
	row2: for i in 0 to 24 generate
		s1(i) <= x3i(i) xor s0(i) xor c0(i);
		c1(i+1) <= (x3i(i) and s0(i)) or (x3i(i) and c0(i)) or
			  (s0(i) and c0(i));
	end generate row2;
	s1(25) <= x3i(25) xor s0(25) xor c0(25);
	c1(0) <= d2;

	-- LATCH A
	latcha: process(clk, reset)
	begin
		if reset = '0' then
			cin <= '0';
			al <= (others => '0');
			bl <= (others => '0');
			am <= (others => '0');
			bm <= (others => '0');
			ah <= (others => '0');
			bh <= (others => '0');
			ae <= (others => '0');
			be <= (others => '0');
		elsif clk'event and clk = '1' then
		 	if en = '1' then
				cin <= d3;
				al <= s1(7 downto 0);
				bl <= c1(7 downto 0);
				am <= s1(15 downto 8);
				bm <= c1(15 downto 8);
				ah <= s1(23 downto 16);
				bh <= c1(23 downto 16);
				ae <= s1(25 downto 24);
				be <= c1(25 downto 24);
			end if;
		end if;
	end process latcha;

	-- First bcla8 adder
	addera: bcla8
		port map(a => al, b => bl, cin => cin, cout => c2, s => sl);

	-- LATCH B
	latchb: process(clk, reset)
	begin
		if reset = '0' then
			c2l <= '0';
			aml <= (others => '0');
			bml <= (others => '0');
			ahl <= (others => '0');
			bhl <= (others => '0');
			ael <= (others => '0');
			bel <= (others => '0');
			sout(7 downto 0) <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				c2l <= c2;
				aml <= am;
				bml <= bm;
				ahl <= ah;
				bhl <= bh;
				ael <= ae;
				bel <= be;
				sout(7 downto 0) <= sl;
			end if;
		end if;
	end process latchb;

	-- Second bcla8 adder
	adderb: bcla8
		port map(a => aml, b => bml, cin => c2l, cout => c3, s => sm);

	-- LATCH C
	latchc: process(clk, reset)
	begin
		if reset = '0' then
			c3l <= '0';
			ahll <= (others => '0');
			bhll <= (others => '0');
			aell <= (others => '0');
			bell <= (others => '0');
			sout(15 downto 8) <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				c3l <= c3;
				ahll <= ahl;
				bhll <= bhl;
				aell <= ael;
				bell <= bel;
				sout(15 downto 8) <= sm;
			end if;
		end if;
	end process latchc;

	-- Third bcla8 adder
	adderc: bcla8
		port map(a => ahll, b => bhll, cin => c3l, cout => c4, s => sh);

	-- LATCH D
	latchd: process(clk, reset)
	begin
		if reset = '0' then
			aelll <= (others => '0');
			belll <= (others => '0');
			c4l <= '0';
			sout(23 downto 16) <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				aelll <= aell;
				belll <= bell;
				c4l <= c4;
				sout(23 downto 16) <= sh;
			end if;
		end if;
	end process latchd;

	-- Last bcla2 adder
	adderd: bcla2
		port map(a => aelll, b => belll, cin => c4l, cout => open, s => se);

	-- LATCH E
	latche: process(clk, reset)
	begin
		if reset = '0' then
			sout(25 downto 24) <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				sout(25 downto 24) <= se;
			end if;
		end if;
	end process latche;

end csdm26x4_arch;
