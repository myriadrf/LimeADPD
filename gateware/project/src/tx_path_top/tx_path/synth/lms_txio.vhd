-- ----------------------------------------------------------------------------
-- FILE:          lms_txio.vhd
-- DESCRIPTION:   describe file
-- DATE:          10:51 AM Thursday, November 16, 2017
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
entity lms_txio is
   generic(
      dev_family              : string  := "Cyclone V";
      diq_width               : integer := 12;
      lbfifo_wrusedw_witdth   : integer := 2
   );
   port (

      rx_clk      : in std_logic;
      rx_reset_n  : in std_logic;
      rx_diq_h    : in std_logic_vector(diq_width downto 0);
      rx_diq_l    : in std_logic_vector(diq_width downto 0);
      
      tx_clk      : in std_logic;
      tx_reset_n  : in std_logic;
      rx2tx_en    : in std_logic;
      tx_path_sel : in std_logic;      
      tx0_diq_h   : in std_logic_vector(diq_width downto 0);
      tx0_diq_l   : in std_logic_vector(diq_width downto 0);
      tx1_diq_h   : in std_logic_vector(diq_width downto 0);
      tx1_diq_l   : in std_logic_vector(diq_width downto 0);
      
      diq         : out std_logic_vector(diq_width-1 downto 0);
      diq_iqsel   : out std_logic


        );
end lms_txio;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms_txio is
--declare signals,  components here
signal i0_data             : std_logic_vector((diq_width+1)*2-1 downto 0);
signal i0_wrfull           : std_logic;
signal i0_wrreq            : std_logic;
signal i0_rdempty          : std_logic;
signal i0_rdreq            : std_logic;
signal i0_q                : std_logic_vector((diq_width+1)*2-1 downto 0);
      
signal mux0_diq_h          : std_logic_vector(diq_width downto 0);
signal mux0_diq_l          : std_logic_vector(diq_width downto 0);
      
signal mux1_diq_h          : std_logic_vector(diq_width downto 0);
signal mux1_diq_l          : std_logic_vector(diq_width downto 0);

signal rx2tx_en_sync       : std_logic;
signal tx_path_sel_sync    : std_logic;

  
begin
   
-- ----------------------------------------------------------------------------
-- Loopback FIFO
-- ----------------------------------------------------------------------------
   i0_data  <= rx_diq_h & rx_diq_l;
   i0_wrreq <= not i0_wrfull AND rx_reset_n;
   
   i0_rdreq <= not i0_rdempty;
   
fifo_inst_i0 : entity work.fifo_inst
generic map(
   dev_family        => dev_family,
   wrwidth           => (diq_width+1)*2,
   wrusedw_witdth    => lbfifo_wrusedw_witdth, 
   rdwidth           => (diq_width+1)*2,
   rdusedw_width     => lbfifo_wrusedw_witdth,
   show_ahead        => "OFF"
)
port map(
   reset_n       => rx_reset_n,
   wrclk         => rx_clk,
   wrreq         => i0_wrreq,
   data          => i0_data,
   wrfull        => i0_wrfull,
   wrempty		  => open,
   wrusedw       => open,
   rdclk 	     => tx_clk,
   rdreq         => i0_rdreq,
   q             => i0_q,
   rdempty       => i0_rdempty,
   rdusedw       => open   
   );
   
   
   sync_reg_i1 : entity work.sync_reg
   port map(
      clk         => tx_clk,
      reset_n     => '1',
      async_in    => rx2tx_en, 
      sync_out    => rx2tx_en_sync
        );
        
   sync_reg_i2 : entity work.sync_reg
   port map(
      clk         => tx_clk,
      reset_n     => '1',
      async_in    => tx_path_sel, 
      sync_out    => tx_path_sel_sync
        );

-- ----------------------------------------------------------------------------
-- MUX 0
-- ----------------------------------------------------------------------------
 process(tx_reset_n, tx_clk)
    begin
      if tx_reset_n='0' then
         mux0_diq_h <= (others=>'0');
         mux0_diq_l <= (others=>'0');
      elsif (rising_edge(tx_clk)) then
         if tx_path_sel_sync = '1' then 
            mux0_diq_h <= tx1_diq_h;
            mux0_diq_l <= tx1_diq_l;
         else 
            mux0_diq_h <= tx0_diq_h;
            mux0_diq_l <= tx0_diq_l;
         end if;
      end if;
    end process;
    
-- ----------------------------------------------------------------------------
-- MUX 1
-- ----------------------------------------------------------------------------
 process(tx_reset_n, tx_clk)
    begin
      if tx_reset_n='0' then
         mux1_diq_h <= (others=>'0');
         mux1_diq_l <= (others=>'0');
      elsif (rising_edge(tx_clk)) then
         if rx2tx_en_sync = '1' then 
            mux1_diq_h <= i0_q(diq_width downto 0);
            mux1_diq_l <= i0_q((diq_width+1)*2-1 downto diq_width+1);           
         else 
            mux1_diq_h <= mux0_diq_h;
            mux1_diq_l <= mux0_diq_l;
         end if;
      end if;
    end process;
    
lms7002_ddout_i3 : entity work.lms7002_ddout
	generic map(
      dev_family	=> dev_family,
      iq_width		=> diq_width
	)
	port map(
      clk       	=> tx_clk,
      reset_n   	=> tx_reset_n,
		data_in_h	=> mux1_diq_h,
		data_in_l	=> mux1_diq_l,
		txiq		 	=> diq,
		txiqsel	 	=> diq_iqsel
      );
  
end arch;   


