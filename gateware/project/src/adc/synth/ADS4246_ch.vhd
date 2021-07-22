-- ----------------------------------------------------------------------------	
-- FILE: 	ADS4246.vhd
-- DESCRIPTION:	Samples one channel data from ADC, in LVDS mode
-- DATE:	Apr 25, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;


-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ADS4246_ch is
   generic( dev_family	: string := "Cyclone V"
   );
  port (
      --input ports 
      clk         : in std_logic;
      reset_n     : in std_logic;
      dd_in       : in std_logic_vector(6 downto 0); 	--Input to DDR cells from pins
      --output ports 
      data        : out std_logic_vector(13 downto 0) --Sampled data
      
        );
end ADS4246_ch;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ADS4246_ch is
--declare signals,  components here

signal reset_p             : std_logic;
signal data_out_h          : std_logic_vector(6 downto 0);
signal data_out_l          : std_logic_vector(6 downto 0);
signal data_h_reg          : std_logic_vector(6 downto 0);
signal data_l_reg          : std_logic_vector(6 downto 0);
signal captured_data       : std_logic_vector(13 downto 0); 
signal captured_data_reg   : std_logic_vector(13 downto 0);


begin

reset_p<= not reset_n;

--Altera DDR input component
   ALTDDIO_IN_component : ALTDDIO_IN
   GENERIC MAP (
      intended_device_family  => dev_family,
      invert_input_clocks     => "OFF",
      lpm_hint                => "UNUSED",
      lpm_type                => "altddio_in",
      power_up_high           => "OFF",
      width                   => 7
   )
   PORT MAP (
      aclr        => reset_p,
      datain      => dd_in,
      inclock     => clk,
      dataout_h   => data_out_h,
      dataout_l   => data_out_l
   );


--register for even  ADC bits 
   process(reset_n, clk)
   begin
      if reset_n='0' then
         data_h_reg<=(others=>'0');
      elsif (clk'event and clk = '1') then
         data_h_reg<=data_out_h;
      end if;
   end process;
   
--register for all ADC bits 
      process(reset_n, clk)
   begin
      if reset_n='0' then
         captured_data<=(others=>'0');
      elsif (clk'event and clk = '1') then
         captured_data <=  data_out_l (6) & data_h_reg (6) & 
                           data_out_l (5) & data_h_reg (5) & 
                           data_out_l (4) & data_h_reg (4) & 
                           data_out_l (3) & data_h_reg (3) &
                           data_out_l (2) & data_h_reg (2) & 
                           data_out_l (1) & data_h_reg (1) &
                           data_out_l (0) & data_h_reg (0);
      end if;
   end process;
                                       
                     
   data <= captured_data;
  
end arch;





