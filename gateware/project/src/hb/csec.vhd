-- ----------------------------------------------------------------------------	
-- FILE:	csec.vhd
-- DESCRIPTION:	Common sub-expressions calculation block.
-- DATE:	July 24, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:	July 27:	Datapath width changed to 26.
--				Input inverted and latched not to produce
--				short gleches at the filter start up.
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity csec is
    port (
	x: in std_logic_vector(24 downto 0);
	clk: in std_logic;			-- Clock and reset
	en: in std_logic;			-- Enable
	reset: in std_logic;
	xp: out std_logic_vector(25 downto 0); 	-- x*(1+1/4)
	xo: out std_logic_vector(25 downto 0);	-- just delayed x
	xm: out std_logic_vector(25 downto 0)	-- x*(1-1/4)
    );
end csec;

-- ----------------------------------------------------------------------------
-- Architecture of csec
-- ----------------------------------------------------------------------------
architecture csec_arch of csec is
	-- Delayed versions of the input signal
	signal xl: std_logic_vector(24 downto 0);
	signal xll, xlll: std_logic_vector(25 downto 0);

	-- Inverted and delayed input
	signal xi, xil: std_logic_vector(24 downto 0);
	signal xill, xilll: std_logic_vector(25 downto 0);

	-- Carry in signals
	signal c1m, c1ml, c2m, c2ml, c3m, c3ml: std_logic;
	signal c1p, c1pl, c2p, c2pl, c3p, c3pl: std_logic;

	-- Signals to align the results in time
	signal sm: std_logic_vector(25 downto 0);
	signal sml: std_logic_vector(23 downto 0);
	signal smll: std_logic_vector(15 downto 0);
	signal smlll: std_logic_vector(7 downto 0);

	signal sp: std_logic_vector(25 downto 0);
	signal spl: std_logic_vector(23 downto 0);
	signal spll: std_logic_vector(15 downto 0);
	signal splll: std_logic_vector(7 downto 0);

	-- Logic constants
	signal one, zero: std_logic;

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
	-- Set logic constants
	one <= '1';
	zero <= '0';

	-- Delay input signal
	latchx: process(clk, reset)
	begin
		if reset = '0' then
			xl <= (others => '0');
			xll <= (others => '0');
			xlll <= (others => '0');
			xo <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xl <= x;
				xll(24 downto 0) <= xl;
				xll(25) <= xl(24);
				xlll <= xll;
				xo <= xlll;
			end if;
		end if;
	end process latchx;

	-- Invert input and delay it
	xi <= not x;
	latchxi: process(clk, reset)
	begin
		if reset = '0' then
			xil <= (others => '0');
			xill <= (others => '0');
			xilll <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xil <= xi;
				xill(24 downto 0) <= xil;
				xill(25) <= xil(24);
				xilll <= xill;
			end if;
		end if;
	end process latchxi;
	
	-- Delay carry in signals
	latchc: process(clk, reset)
	begin
		if reset = '0' then
			c1ml <= '0';
			c2ml <= '0';
			c3ml <= '0';
			c1pl <= '0';
			c2pl <= '0';
			c3pl <= '0';
		elsif clk'event and clk = '1' then
			if en = '1' then
				c1ml <= c1m;
				c2ml <= c2m;
				c3ml <= c3m;
				c1pl <= c1p;
				c2pl <= c2p;
				c3pl <= c3p;
			end if;
		end if;
	end process latchc;

	-- BCLA adders to calculate xm
	adderlm: bcla8
		port map(a => x(7 downto 0), b => xi(9 downto 2), cin => one, 
			cout => c1m, s => sm(7 downto 0));

	addermm: bcla8
		port map(a => xl(15 downto 8), b => xil(17 downto 10), cin => c1ml, 
			cout => c2m, s => sm(15 downto 8));

	adderhm: bcla8
		port map(a => xll(23 downto 16), b => xill(25 downto 18), cin => c2ml, 
			cout => c3m, s => sm(23 downto 16));

	adderem: bcla2
		port map(a => xlll(25 downto 24), b(1) => xilll(25), b(0) => xilll(25),
			cin => c3ml, cout => open, s => sm(25 downto 24));

	-- BCLA adders to calculate xp
	adderlp: bcla8
		port map(a => x(7 downto 0), b => x(9 downto 2), cin => zero, 
			cout => c1p, s => sp(7 downto 0));

	addermp: bcla8
		port map(a => xl(15 downto 8), b => xl(17 downto 10), cin => c1pl, 
			cout => c2p, s => sp(15 downto 8));

	adderhp: bcla8
		port map(a => xll(23 downto 16), b => xll(25 downto 18), cin => c2pl, 
			cout => c3p, s => sp(23 downto 16));

	adderep: bcla2
		port map(a => xlll(25 downto 24), b(1) => xlll(25), b(0) => xlll(25),
			cin => c3pl, cout => open, s => sp(25 downto 24));

	-- Align in time xm output
	latchm: process(clk, reset)
	begin
		if reset = '0' then
			xm <= (others => '0');
			sml <= (others => '0');
			smll <= (others => '0');
			smlll <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xm(25 downto 24) <= sm(25 downto 24);
				xm(23 downto 16) <= sml(23 downto 16);
				xm(15 downto 8) <= smll(15 downto 8);
				xm(7 downto 0) <= smlll(7 downto 0);

				sml <= sm(23 downto 0);
				smll <= sml(15 downto 0);
				smlll <= smll(7 downto 0);
			end if;
		end if;
	end process latchm;

	-- Align in time xp output
	latchp: process(clk, reset)
	begin
		if reset = '0' then
			xp <= (others => '0');
			spl <= (others => '0');
			spll <= (others => '0');
			splll <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xp(25 downto 24) <= sp(25 downto 24);
				xp(23 downto 16) <= spl(23 downto 16);
				xp(15 downto 8) <= spll(15 downto 8);
				xp(7 downto 0) <= splll(7 downto 0);

				spl <= sp(23 downto 0);
				spll <= spl(15 downto 0);
				splll <= spll(7 downto 0);
			end if;
		end if;
	end process latchp;

end csec_arch;
