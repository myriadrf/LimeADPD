-- ----------------------------------------------------------------------------
-- FILE:          limegnss_gpio_top.vhd
-- DESCRIPTION:   describe file
-- DATE:          Jan 27, 2016
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity limegnss_gpio_top is
   generic ( 
      UART_BAUD_RATE          : positive := 9600;
      VCTCXO_CLOCK_FREQUENCY  : positive := 30720000
   );
   port (
      areset_n          : in std_logic;
      -- SPI interface
      -- Address and location of SPI memory module
      -- Will be hard wired at the top level
      tamercfg_maddress : in  std_logic_vector(9 downto 0);
      gnsscfg_maddress  : in  std_logic_vector(9 downto 0);
      -- Serial port IOs
      sdin              : in  std_logic;   -- Data in
      sclk              : in  std_logic;   -- Data clock
      sen               : in  std_logic;   -- Enable signal (active low)
      sdout             : out std_logic;   -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset            : in  std_logic;   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset            : in  std_logic;   -- Memory reset signal, resets configuration memory only (use only one reset)
   
      vctcxo_clk        : in std_logic;    -- Clock from VCTCXO 
      
      --LimeGNSS-GPIO pins
      gnss_tx           : out std_logic;  -- GPIO0
      gnss_rx           : in  std_logic;  -- GPIO1
      gnss_tpulse       : in  std_logic;  -- GPIO2
      gnss_fix          : in  std_logic;  -- GPIO3
      fpga_led_g        : out std_logic;  -- GPIO4 
      fpga_led_r        : out std_logic;  -- GPIO5
      
      -- NIOS PIO
      en                : out std_logic;
      
      -- NIOs  Avalon-MM Interface (External master)
      mm_clock          : in  std_logic;
      mm_reset          : in  std_logic;
      mm_rd_req         : in  std_logic;
      mm_wr_req         : in  std_logic;
      mm_addr           : in  std_logic_vector(7 downto 0);
      mm_wr_data        : in  std_logic_vector(7 downto 0);
      mm_rd_data        : out std_logic_vector(7 downto 0);
      mm_rd_datav       : out std_logic;
      mm_wait_req       : out std_logic := '0';
      
      -- Avalon Interrupts
      mm_irq            : out std_logic := '0'
      
      
      );
end limegnss_gpio_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of limegnss_gpio_top is
--declare signals,  components here
signal areset                       : std_logic;

--inst0
signal inst0_sdout                  : std_logic; 
signal inst0_vctcxo_tune_accuracy   : std_logic_vector(3 downto 0);
signal inst0_en                     : std_logic;
--inst1
signal inst1_sdout                  : std_logic;
signal inst1_gpgsa_fix              : std_logic;

--inst3
signal inst3_data_out               : std_logic_vector(7 downto 0);
signal inst3_data_out_stb           : std_logic;
signal inst3_data_out_ack           : std_logic;

signal uart_data_valid              : std_logic;
signal uart_data_reg                : std_logic_vector(7 downto 0);
  
begin

areset <= not areset_n;

-- ----------------------------------------------------------------------------
-- VCTCXO tamer instance
-- ----------------------------------------------------------------------------   
vctcxo_tamer_top_inst0 : entity work.vctcxo_tamer_top
   port map(
      maddress             => tamercfg_maddress,
      sdin                 => sdin,
      sclk                 => sclk,
      sen                  => sen,
      sdout                => inst0_sdout,
      lreset               => lreset,
      mreset               => mreset,
      -- NIOS PIO 
      en                   => inst0_en,
      -- Physical VCXO tamer Interface
      tune_ref             => gnss_tpulse,
      vctcxo_clock         => vctcxo_clk,
      vctcxo_tune_accuracy => inst0_vctcxo_tune_accuracy,
      -- Avalon-MM Interface (External master)
      mm_clock             => mm_clock,
      mm_reset             => mm_reset,
      mm_rd_req            => mm_rd_req,
      mm_wr_req            => mm_wr_req,
      mm_addr              => mm_addr,
      mm_wr_data           => mm_wr_data,
      mm_rd_data           => mm_rd_data,
      mm_rd_datav          => mm_rd_datav,
      mm_wait_req          => mm_wait_req,      
      -- Avalon Interrupts
      mm_irq               => mm_irq
   );
   
   
gnss_top_inst1 : entity work.gnss_top
   port map(
      maddress             => gnsscfg_maddress,  
      sdin                 => sdin,
      sclk                 => sclk,
      sen                  => sen,
      sdout                => inst1_sdout,
      lreset               => lreset,
      mreset               => mreset,
      clk                  => vctcxo_clk,
      reset_n              => areset_n,
      data                 => uart_data_reg,
      data_v               => uart_data_valid,
      gpgsa_fix            => inst1_gpgsa_fix
     );   
-- ----------------------------------------------------------------------------
-- Led module
-- ----------------------------------------------------------------------------   
   gnss_led_inst2 : entity work.gnss_led
   port map(

      clk                     => vctcxo_clk,
      reset_n                 => areset_n,
      
      --
      vctcxo_tune_en          => inst0_en, 
      vctcxo_tune_accuracy    => inst0_vctcxo_tune_accuracy,
      
      --gnss module ports
      gnss_fix                => inst1_gpgsa_fix,
      gnss_tpulse             => gnss_tpulse,
      gnss_led_r              => fpga_led_r,
      gnss_led_g              => fpga_led_g
      );

-- ----------------------------------------------------------------------------
-- UART module
-- ----------------------------------------------------------------------------
UART_inst3 : entity work.UART
   generic map(
      BAUD_RATE            => UART_BAUD_RATE,
      CLOCK_FREQUENCY      => VCTCXO_CLOCK_FREQUENCY
   )
    port map(     
      CLOCK                => vctcxo_clk,   
      RESET                => areset,
      DATA_STREAM_IN       => (others => '0'),
      DATA_STREAM_IN_STB   => '0',
      DATA_STREAM_IN_ACK   => open,
      DATA_STREAM_OUT      => inst3_data_out,
      DATA_STREAM_OUT_STB  => inst3_data_out_stb,
      DATA_STREAM_OUT_ACK  => inst3_data_out_ack,
      TX                   => open,
      RX                   => gnss_rx
   );
   
 --uart ack formation
 process(areset_n, vctcxo_clk)
   begin
      if areset_n='0' then
         inst3_data_out_ack <= '0';
      elsif (vctcxo_clk'event and vctcxo_clk = '1') then
         if inst3_data_out_stb = '1' AND inst3_data_out_ack = '0' then 
            inst3_data_out_ack <= '1';
         else 
            inst3_data_out_ack <= '0';
         end if;
      end if;
   end process;

--gnss uart data capture register   
process(vctcxo_clk, areset_n)
   begin
      if areset_n = '0' then 
         uart_data_valid   <= '0';
         uart_data_reg     <= (others=> '0');
      elsif (vctcxo_clk'event AND vctcxo_clk = '1') then
         if inst3_data_out_stb = '1' AND inst3_data_out_ack = '1' then 
            uart_data_valid   <= '1';
            uart_data_reg     <= inst3_data_out;
         else 
            uart_data_valid   <= '0';
            uart_data_reg     <= uart_data_reg;
         end if;
      end if;
   end process;
    
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
sdout    <= inst0_sdout OR inst1_sdout;
en       <= inst0_en;
  
end arch;   


