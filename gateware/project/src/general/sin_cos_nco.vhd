-- ----------------------------------------------------------------------------	
-- FILE: 	file_name.vhd
-- DESCRIPTION:	describe
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity sin_cos_nco is
  port (
        --input ports 
        clk       : in std_logic;
        reset_n   : in std_logic;
		  fsin		: out std_logic_vector(13 downto 0);
		  fcos		: out std_logic_vector(13 downto 0)

        --output ports 
        
        );
end sin_cos_nco;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of sin_cos_nco is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0); 
signal fsin_std	 : std_logic_vector(13 downto 0);
signal fcos_std	 : std_logic_vector(13 downto 0);
signal fsin_sign	 : signed(13 downto 0);
signal fcos_sign	 : signed(13 downto 0);

 component sincos is
	port (
		clk       : in  std_logic                     := '0';             -- clk.clk
		clken     : in  std_logic                     := '0';             --  in.clken
		phi_inc_i : in  std_logic_vector(31 downto 0) := (others => '0'); --    .phi_inc_i
		fsin_o    : out std_logic_vector(13 downto 0);                    -- out.fsin_o
		fcos_o    : out std_logic_vector(13 downto 0);                    --    .fcos_o
		out_valid : out std_logic;                                        --    .out_valid
		reset_n   : in  std_logic                     := '0'              -- rst.reset_n
	);
end component; 


begin


--nco : sincos
--	port map(
--		clk      	=> clk, 
--		clken     	=> '1', 
--		phi_inc_i 	=> x"042AAAAB", 
--		fsin_o    	=> fsin_std, 
--		fcos_o    	=> fcos_std, 
--		out_valid 	=> open,                                        
--		reset_n   	=> reset_n
--	);

fsin_sign<=signed(fsin_std)+8192;
fcos_sign<=signed(fcos_std)+8192;

fsin<=std_logic_vector(fsin_sign);
fcos<=std_logic_vector(fcos_sign);
  
end arch;




