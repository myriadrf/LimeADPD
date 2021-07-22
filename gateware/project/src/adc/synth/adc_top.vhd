-- ----------------------------------------------------------------------------	
-- FILE        : adc_top.vhd
-- DESCRIPTION : Top ADC module
-- DATE        : Jan 27, 2016
-- AUTHOR(s)   : Lime Microsystems
-- REVISIONS   :
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rxtspcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity adc_top is
   generic( 
      dev_family           : string := "Cyclone V";
      data_width           : integer := 7;
      smpls_to_capture     : integer := 4 -- 2,4,6,8...
      );
   port (
   
      

      clk               : in std_logic;
      reset_n           : in std_logic;
      en                : in std_logic;
      
      ch_a              : in std_logic_vector(data_width-1 downto 0); 	--Input to DDR cells from pins
      ch_b              : in std_logic_vector(data_width-1 downto 0); 	--Input to DDR cells from pins
      
      --SDR parallel output data
      data_ch_a         : out std_logic_vector(data_width*2-1 downto 0); --Sampled data ch A
      data_ch_b         : out std_logic_vector(data_width*2-1 downto 0); --Sampled data ch B 
      --Interleaved samples of both channels
      data_ch_ab        : out std_logic_vector(data_width*2*smpls_to_capture-1 downto 0); -- ... B1 A1 B0 A0 
      data_ch_ab_valid  : out std_logic;
      test_out          : out std_logic_vector(55 downto 0);
      to_rxtspcfg       : out t_TO_RXTSPCFG;
      from_rxtspcfg     : in  t_FROM_RXTSPCFG

        );
end adc_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of adc_top is
--declare signals,  components here
signal inst0_data_ch_a  : std_logic_vector (data_width*2-1 downto 0); 
signal inst0_data_ch_b  : std_logic_vector (data_width*2-1 downto 0);

--inst1 signals
signal inst1_RXI        : std_logic_vector(17 downto 0);
signal inst1_RXQ        : std_logic_vector(17 downto 0);
signal inst1_RYI        : std_logic_vector (17 downto 0);
signal inst1_RYQ        : std_logic_vector (17 downto 0);

type reg_chain_type is array (0 to smpls_to_capture/2-1) of std_logic_vector(data_width*4-1 downto 0);

signal reg_chain        : reg_chain_type;

signal valid_cnt        : unsigned(7 downto 0);
signal valid_cnt_ovrfl  : std_logic;

signal reset_n_sync     : std_logic;
  
begin

sync_reg0 : entity work.sync_reg 
port map(clk, reset_n, en, reset_n_sync);
   
-- ----------------------------------------------------------------------------
-- ADC instance
-- ----------------------------------------------------------------------------   
   ADS4246_inst0 : entity work.ADS4246
   generic map( 
      dev_family  =>  dev_family
   )
   port map(
      clk         => clk,
      reset_n     => reset_n_sync,
      ch_a        => ch_a,
      ch_b        => ch_b,
      data_ch_a   => inst0_data_ch_a,
      data_ch_b   => inst0_data_ch_b  
        );


inst1_RXI <= inst0_data_ch_a & "0000";
inst1_RXQ <= inst0_data_ch_b & "0000";       
        
rx_chain_inst1 : entity work.rx_chain 
   port map
   (
      clk            => clk,
      nrst           => reset_n_sync,
      HBD_ratio      => (others=>'0'),
      RXI            => inst1_RXI,
      RXQ            => inst1_RXQ,
      xen            => open,
      RYI            => inst1_RYI,
      RYQ            => inst1_RYQ,
      to_rxtspcfg    => to_rxtspcfg,
      from_rxtspcfg  => from_rxtspcfg
   );

--for testing rx_chain is bypassed
--inst1_RYI <= inst1_RXI;
--inst1_RYQ <= inst1_RXQ;

        
-- ----------------------------------------------------------------------------
-- Chain of registers for storing samples
-- ----------------------------------------------------------------------------
process(clk, reset_n_sync)
begin
   if reset_n_sync = '0' then 
      reg_chain <= (others=>(others=>'0'));
   elsif (clk'event AND clk='1') then 
      for i in 0 to smpls_to_capture/2-1 loop
         if i = 0 then 
            reg_chain(0) <= inst1_RYI(17 downto 18-data_width*2) & inst1_RYQ(17 downto 18-data_width*2);
         else 
            reg_chain(i) <= reg_chain(i-1);
         end if;
      end loop;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- Reg chain to output port
-- ----------------------------------------------------------------------------
process(reg_chain)
   begin
      for i in 0 to smpls_to_capture/2-1 loop
         data_ch_ab(i*data_width*4 + data_width*4-1 downto i*data_width*4) <= reg_chain(smpls_to_capture/2-1-i);
      end loop;
end process;

test_out <= "00000000000000111111111111110000000000000011111111111111";


process(clk, reset_n_sync)
begin
   if reset_n_sync = '0' then 
      valid_cnt <= (others=>'0');
      data_ch_ab_valid <= '0';
      valid_cnt_ovrfl <= '0';
   elsif (clk'event AND clk='1') then 
      if valid_cnt < smpls_to_capture/2-1 then 
         valid_cnt <= valid_cnt+1;
         valid_cnt_ovrfl <= '0';
      else 
         valid_cnt <= (others=>'0');
         valid_cnt_ovrfl <= '1';
      end if;
      data_ch_ab_valid <= valid_cnt_ovrfl;
   end if;
end process;
        
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------        
data_ch_a <= inst0_data_ch_a;
data_ch_b <= inst0_data_ch_b;

  
end arch;   


