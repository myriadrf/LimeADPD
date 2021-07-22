-- ----------------------------------------------------------------------------	
-- FILE: tx_chain.vhd
-- DESCRIPTION:   TX chain with correctors and nco
-- DATE: May 24, 2017
-- AUTHOR(s):  Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.txtspcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity tx_chain is 
   port
   (
      clk            : in  std_logic;
      nrst           : in  std_logic;
      TXI            : in  std_logic_vector(17 downto 0);
      TXQ            : in  std_logic_vector(17 downto 0);
      TYI            : out std_logic_vector(13 downto 0);
      TYQ            : out std_logic_vector(13 downto 0);
      from_txtspcfg  : in  t_FROM_TXTSPCFG;
      to_txtspcfg    : out t_TO_TXTSPCFG
      
   );
end tx_chain;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of tx_chain is

signal sen_int : std_logic; 
   
--inst0 signals
signal inst0_dc_byp     : std_logic;
signal inst0_dccorri    : std_logic_vector(7 downto 0);
signal inst0_dccorrq    : std_logic_vector(7 downto 0);
signal inst0_gc_byp     : std_logic;
signal inst0_gcorri     : std_logic_vector(10 downto 0);
signal inst0_gcorrq     : std_logic_vector(10 downto 0);
signal inst0_insel      : std_logic;
signal inst0_iqcorr     : std_logic_vector(11 downto 0);
signal inst0_en         : std_logic;
signal inst0_ph_byp     : std_logic;
signal inst0_bsigi      : std_logic_vector(0 to 22);
signal inst0_bsigq      : std_logic_vector(0 to 22);
signal inst0_maddress   : std_logic_vector(9 downto 0);
signal inst0_nco_fcv    : std_logic_vector(31 downto 0);

--inst1
signal inst0_sin        : std_logic_vector(13 downto 0);
signal inst0_cos        : std_logic_vector(13 downto 0);

signal in_mux_i         : std_logic_vector(17 downto 0);
signal in_mux_q         : std_logic_vector(17 downto 0);

--inst2 
signal inst2_y          :  std_logic_vector(17 downto 0);

--inst3
signal inst3_y          :  std_logic_vector(17 downto 0);

--inst4 
signal inst4_yi         : std_logic_vector(17 downto 0);
signal inst4_yq         : std_logic_vector(17 downto 0);

--inst5 
signal inst5_y          : std_logic_vector(13 downto 0);

--inst6
signal inst6_y          : std_logic_vector(13 downto 0);


component nco is
    port (
      fcw      : in std_logic_vector (31 downto 0); -- Frequency control word
      -- fmi      : in std_logic_vector (31 downto 0); -- FM input
      -- fmcin    : in std_logic; -- FM carry in
      -- pho      : in std_logic_vector (15 downto 0); -- Phase offset
      ofc      : in std_logic; -- Output format control signal
      spc      : in std_logic; -- Sine phase control signal
      sleep    : in std_logic; -- Sleep signal
      clk      : in std_logic; -- Clock
      nrst     : in std_logic; -- Reset
      sin      : out std_logic_vector (13 downto 0); -- Sine ouput
      cos      : out std_logic_vector (13 downto 0) -- Cosine ouput
    );
end component;

component gcorr
   port(                
      clk      : in std_logic;
      nrst     : in std_logic;
      en       : in std_logic;
      byp      : in std_logic;
      gc       : in std_logic_vector(10 downto 0);
      x        : in std_logic_vector(17 downto 0);
      y        : out std_logic_vector(17 downto 0)
   );
end component;

component iqcorr
   port(
      clk   : in std_logic;
      nrst  : in std_logic;
      en    : in std_logic;
      byp   : in std_logic;
      pcw   : in std_logic_vector(11 downto 0);
      xi    : in std_logic_vector(17 downto 0);
      xq    : in std_logic_vector(17 downto 0);
      yi    : out std_logic_vector(17 downto 0);
      yq    : out std_logic_vector(17 downto 0)
   );
end component;

component dccorr
   port(
      clk   : in std_logic;
      nrst  : in std_logic;
      en    : in std_logic;
      byp   : in std_logic;
      dc    : in std_logic_vector(7 downto 0);
      x     : in std_logic_vector(13 downto 0);
      y     : out std_logic_vector(13 downto 0)
   );
end component;

component pulse_gen
   port(
      clk         : in std_logic;
      reset_n     : in std_logic;
      n           : in std_logic_vector(7 downto 0);
      pulse_out   : out std_logic
   );
end component;

component txtspcfg
   port(
      mimo_en     : in std_logic;
      sdin        : in std_logic;
      sclk        : in std_logic;
      sen         : in std_logic;
      lreset      : in std_logic;
      mreset      : in std_logic;
      txen        : in std_logic;
      bstate      : in std_logic;
      bsigi       : in std_logic_vector(22 downto 0);
      bsigq       : in std_logic_vector(22 downto 0);
      maddress    : in std_logic_vector(9 downto 0);
      sdout       : out std_logic;
      oen         : out std_logic;
      en          : out std_logic;
      insel       : out std_logic;
      ph_byp      : out std_logic;
      gc_byp      : out std_logic;
      gfir1_byp   : out std_logic;
      gfir2_byp   : out std_logic;
      gfir3_byp   : out std_logic;
      dc_byp      : out std_logic;
      isinc_byp   : out std_logic;
      cmix_sc     : out std_logic;
      cmix_byp    : out std_logic;
      bstart      : out std_logic;
      tsgdcldq    : out std_logic;
      tsgdcldi    : out std_logic;
      tsgswapiq   : out std_logic;
      tsgmode     : out std_logic;
      tsgfc       : out std_logic;
      cmix_gain   : out std_logic_vector(2 downto 0);
      dc_reg      : out std_logic_vector(15 downto 0);
      dccorri     : out std_logic_vector(7 downto 0);
      dccorrq     : out std_logic_vector(7 downto 0);
      gcorri      : out std_logic_vector(10 downto 0);
      gcorrq      : out std_logic_vector(10 downto 0);
      gfir1l      : out std_logic_vector(2 downto 0);
      gfir1n      : out std_logic_vector(7 downto 0);
      gfir2l      : out std_logic_vector(2 downto 0);
      gfir2n      : out std_logic_vector(7 downto 0);
      gfir3l      : out std_logic_vector(2 downto 0);
      gfir3n      : out std_logic_vector(7 downto 0);
      iqcorr      : out std_logic_vector(11 downto 0);
      nco_fcv     : out std_logic_vector(31 downto 0);
      ovr         : out std_logic_vector(2 downto 0);
      stateo      : out std_logic_vector(5 downto 0);
      tsgfcw      : out std_logic_vector(8 downto 7)
   );
end component;

begin 


   --sen_int <= sen when mac_en = '1' else '1';

-- ----------------------------------------------------------------------------
-- SPI control registers
-- ----------------------------------------------------------------------------
-- txtspcfg_inst0 : txtspcfg
-- port map(
   -- mimo_en     => '1',
   -- sdin        => sdin,
   -- sclk        => sclk,
   -- sen         => sen_int,
   -- lreset      => memrstn,
   -- mreset      => memrstn,
   -- txen        => '1',
   -- bstate      => '0',
   -- bsigi       => inst0_bsigi,
   -- bsigq       => inst0_bsigq,
   -- maddress    => maddress,
   -- sdout       => sdout,
   -- en          => inst0_en,
   -- insel       => inst0_insel,
   -- ph_byp      => inst0_ph_byp,
   -- gc_byp      => inst0_gc_byp,
   -- dc_byp      => inst0_dc_byp,
   -- dccorri     => inst0_dccorri,
   -- dccorrq     => inst0_dccorrq,
   -- gcorri      => inst0_gcorri,
   -- gcorrq      => inst0_gcorrq,
   -- iqcorr      => inst0_iqcorr,
   -- nco_fcv     => inst0_nco_fcv
   -- );
   
   to_txtspcfg.txen        <= '1';
   to_txtspcfg.bstate      <= '0';
   to_txtspcfg.bsigi       <= inst0_bsigi;
   to_txtspcfg.bsigq       <= inst0_bsigq;
   
   inst0_en       <= from_txtspcfg.en;     
   inst0_insel    <= from_txtspcfg.insel;  
   inst0_ph_byp   <= from_txtspcfg.ph_byp; 
   inst0_gc_byp   <= from_txtspcfg.gc_byp ;
   inst0_dc_byp   <= from_txtspcfg.dc_byp ;
   inst0_dccorri  <= from_txtspcfg.dccorri;
   inst0_dccorrq  <= from_txtspcfg.dccorrq;
   inst0_gcorri   <= from_txtspcfg.gcorri ;
   inst0_gcorrq   <= from_txtspcfg.gcorrq ;
   inst0_iqcorr   <= from_txtspcfg.iqcorr ;
   inst0_nco_fcv  <= from_txtspcfg.nco_fcv;
   
   
-- ----------------------------------------------------------------------------
-- NCO
-- ----------------------------------------------------------------------------
nco_inst1 : nco
    port map (
      fcw      => inst0_nco_fcv,
    	ofc      => '1',
      spc      => '0',
      sleep    => '0',
      clk      => clk,
      nrst     => nrst,
      sin      => inst0_sin,
      cos      => inst0_cos
    );
       
inmux_i_reg : process(clk, nrst)
begin
   if nrst = '0' then 
      in_mux_i <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if inst0_insel = '0' then 
         in_mux_i <= TXI;
         in_mux_q <= TXQ;
      else 
         in_mux_i <= inst0_cos & "0000";
         in_mux_q <= inst0_sin & "0000";
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- Gain correctors 
-- ----------------------------------------------------------------------------
gcorr_inst2 : gcorr
port map(
   clk   => clk,
   nrst  => nrst,
   en    => inst0_en,
   byp   => inst0_gc_byp,
   gc    => inst0_gcorri,
   x     => in_mux_i,
   y     => inst2_y
   );

gcorr_inst3 : gcorr
port map(
   clk   => clk,
   nrst  => nrst,
   en    => inst0_en,
   byp   => inst0_gc_byp,
   gc    => inst0_gcorrq,
   x     => in_mux_q,
   y     => inst3_y
   );
-- ----------------------------------------------------------------------------
-- IQ correctors 
-- ----------------------------------------------------------------------------
iqcorr_inst4 : iqcorr
port map(
   clk      => clk,
   nrst     => nrst,
   en       => inst0_en,
   byp      => inst0_ph_byp,
   pcw      => inst0_iqcorr,
   xi       => inst2_y,
   xq       => inst3_y,
   yi       => inst4_yi,
   yq       => inst4_yq
   );

-- ----------------------------------------------------------------------------
-- DC correctors 
-- ----------------------------------------------------------------------------
dccorr_inst5 : dccorr
port map(
   clk   => clk,
   nrst  => nrst,
   en    => inst0_en,
   byp   => inst0_dc_byp,
   dc    => inst0_dccorri,
   x     => inst4_yi(17 downto 4),
   y     => inst5_y
   );


dccorr_inst6 : dccorr
port map(
   clk   => clk,
   nrst  => nrst,
   en    => inst0_en,
   byp   => inst0_dc_byp,
   dc    => inst0_dccorrq,
   x     => inst4_yq(17 downto 4),
   y     => inst6_y
   );


-- ----------------------------------------------------------------------------
-- To output ports
-- ----------------------------------------------------------------------------
TYI <= inst5_y;
TYQ <= inst6_y;

END arch;