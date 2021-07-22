-- ----------------------------------------------------------------------------	
-- FILE: 	ddr2rxiq.vhd
-- DESCRIPTION: Take data from ddri and convert to RXIQ
-- DATE:	Mar 31, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ddr2rxiq is
	port(
		reset_n 	: in std_logic;                                ---input reset active low
		clk				: in std_logic;
		
		dil				: in std_logic_vector(12 downto 0);
		dih				: in std_logic_vector(12 downto 0);

		rxiqsel		: out std_logic;
		rxdA			: out std_logic_vector(11 downto 0);
		rxdB			: out std_logic_vector(11 downto 0);
		
		AI			: out std_logic_vector(11 downto 0);
		AQ			: out std_logic_vector(11 downto 0);
		BI			: out std_logic_vector(11 downto 0);
		BQ			: out std_logic_vector(11 downto 0)

	);

end entity ddr2rxiq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture ddr2rxiq_arch of ddr2rxiq is

	signal rai, raid1 : std_logic_vector(11 downto 0);
	signal raq : std_logic_vector(11 downto 0);
	signal rbi : std_logic_vector(11 downto 0);
	signal rbq : std_logic_vector(11 downto 0);

begin

	-- A channel
	process(clk, reset_n)
	begin
		if(reset_n = '0') then
			rai <= (others => '0');
			raq <= (others => '0');
			raid1 <= (others => '0');
		elsif (clk'event and clk = '1') then
			if dih(12) = '0' then
				rai <= dih(11 downto 0);
				raq <= dil(11 downto 0);
				raid1 <= rai;
			end if;
		end if;	 
	end process;
	
	-- B channel
	process(clk, reset_n)
	begin
		if(reset_n = '0') then
			rbi <= (others => '0');
			rbq <= (others => '0');
		elsif (clk'event and clk = '1') then
			if dih(12) = '1' then
				rbi <= dih(11 downto 0);
				rbq <= dil(11 downto 0);
			end if;
		end if;	 
	end process;

	rxiqsel <= dih(12);
	
	rxdA <= raid1 when dih(12) = '1' else raq;
	rxdB <= rbi when dih(12) = '1' else rbq;
	
	AI <= rai;
	AQ <= raq;
	BI <= rbi;
	BQ <= rbq;

end architecture;

