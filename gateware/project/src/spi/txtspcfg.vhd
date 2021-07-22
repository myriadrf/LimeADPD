-- ----------------------------------------------------------------------------	
-- FILE:	spitx.vhd
-- DESCRIPTION:	Serial configuration interface to control TX modules
-- DATE:	2007.06.07
-- AUTHOR(s):	
-- REVISIONS:	
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.txtspcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txtspcfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       : in std_logic_vector(9 downto 0);
      mimo_en        : in std_logic; -- MIMO enable, from TOP SPI
   
      -- Serial port IOs
      sdin           : in std_logic;  -- Data in
      sclk           : in std_logic;  -- Data clock
      sen            : in std_logic;   -- Enable signal (active low)
      sdout          : out std_logic;   -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset         : in std_logic;   -- Logic reset signal, resets logic cells only
      mreset         : in std_logic;   -- Memory reset signal, resets configuration memory only
     
      oen            : out std_logic;
      stateo         : out std_logic_vector(5 downto 0);
      
      to_txtspcfg    : in t_TO_TXTSPCFG;
      from_txtspcfg  : out t_FROM_TXTSPCFG

   );
end txtspcfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture txtspcfg_arch of txtspcfg is
   signal inst_reg: std_logic_vector(15 downto 0); -- Instruction register
   signal inst_reg_en: std_logic;
   
   signal din_reg: std_logic_vector(15 downto 0);  -- Data in register
   signal din_reg_en: std_logic;
   
   signal dout_reg: std_logic_vector(15 downto 0); -- Data out register
   signal dout_reg_sen, dout_reg_len: std_logic;
   
   signal mem: marray16x16;         -- Config memory
   signal mem_we: std_logic;
   
   signal oe: std_logic;            -- Tri state buffers control 
   
   -- Components
   use work.mcfg_components.mcfg32wm_fsm;
   for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);

begin
   -- ---------------------------------------------------------------------------------------------
   -- Finite state machines
   -- ---------------------------------------------------------------------------------------------
   fsm: mcfg32wm_fsm port map( 
      address => maddress, mimo_en => mimo_en, inst_reg => inst_reg, sclk => sclk, sen => sen, reset => lreset,
      inst_reg_en => inst_reg_en, din_reg_en => din_reg_en, dout_reg_sen => dout_reg_sen,
      dout_reg_len => dout_reg_len, mem_we => mem_we, oe => oe, stateo => stateo);
      
   -- ---------------------------------------------------------------------------------------------
   -- Instruction register
   -- ---------------------------------------------------------------------------------------------
   inst_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '0' then
         inst_reg <= (others => '0');
      elsif sclk'event and sclk = '1' then
         if inst_reg_en = '1' then
            for i in 15 downto 1 loop
               inst_reg(i) <= inst_reg(i-1);
            end loop;
            inst_reg(0) <= sdin;
         end if;
      end if;
   end process inst_reg_proc;

   -- ---------------------------------------------------------------------------------------------
   -- Data input register
   -- ---------------------------------------------------------------------------------------------
   din_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '0' then
         din_reg <= (others => '0');
      elsif sclk'event and sclk = '1' then
         if din_reg_en = '1' then
            for i in 15 downto 1 loop
               din_reg(i) <= din_reg(i-1);
            end loop;
            din_reg(0) <= sdin;
         end if;
      end if;
   end process din_reg_proc;

   -- ---------------------------------------------------------------------------------------------
   -- Data output register
   -- ---------------------------------------------------------------------------------------------
   dout_reg_proc: process(sclk, lreset)
      variable i: integer;
   begin
      if lreset = '0' then
         dout_reg <= (others => '0');
      elsif sclk'event and sclk = '0' then
         -- Shift operation
         if dout_reg_sen = '1' then
            for i in 15 downto 1 loop
               dout_reg(i) <= dout_reg(i-1);
            end loop;
            dout_reg(0) <= dout_reg(15);
         -- Load operation
         elsif dout_reg_len = '1' then
            dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
         end if;
      end if;
   end process dout_reg_proc;
   
   -- Tri state buffer to connect multiple serial interfaces in parallel
   --sdout <= dout_reg(7) when oe = '1' else 'Z';

-- sdout <= dout_reg(7);
-- oen <= oe;

   sdout <= dout_reg(15) and oe;
   oen <= oe;

   -- ---------------------------------------------------------------------------------------------
   -- Configuration memory
   -- --------------------------------------------------------------------------------------------- 
   ram: process(sclk, mreset)
   begin
      -- Defaults
      if mreset = '0' then
         mem(0)  <= "0000000010000001"; --  6 free, UNUSED[5:0], TSGFC, TSGFCW[1:0], TSGDCLDQ, TSGDCLDI, TSGSWAPIQ, TSGMODE, INSEL, BSTART, EN
         mem(1)  <= "0000011111111111"; --  5 free, UNUSED[4:0], gcorrQ[10:0]
         mem(2)  <= "0000011111111111"; --  5 free, UNUSED[4:0], gcorrI[10:0]
         mem(3)  <= "0000000000000000"; --  0 free, INSEL, HBI_OVR[2:0], IQcorr[11:0]
         mem(4)  <= "0000000000000000"; --  0 free, dccorrI[7:0], dccorrQ[7:0]
         mem(5)  <= "0000000000000000"; --  5 free, UNUSED[4:0], GFIR1_L[2:0] (def. 1) (Length of PHEQ - 1), GFIR1_N[7:0] (def. 1) (PHEQ Clock division ratio. Must be HBI interpolation ratio - 1)
         mem(6)  <= "0000000000000000"; --  5 free, UNUSED[4:0], GFIR2_L[2:0], GFIR2_N[7:0]
         mem(7)  <= "0000000000000000"; --  5 free, UNUSED[4:0], GFIR3_L[2:0], GFIR3_N[7:0]
         mem(8)  <= "0000000000000000"; --  3 free, CMIX_GAIN[1:0], CMIX_SC, CMIX_GAIN[2], UNUSED[2:0], CMIX_BYP, ISINC_BYP, GFIR3_BYP, GFIR2_BYP, GFIR1_BYP, DC_BYP, UNUSED, GC_BYP, PH_BYP
         mem(9)   <= "0000000000000000"; --  0 free, BSIGI(LSB)[14:0], BSTATE {READ ONLY}
         mem(10)  <= "0000000000000000"; --  0 free, BSIGQ[7:0](LSB), BSIGI(MSB)[22:15], {READ ONLY}
         mem(11)  <= "0000000000000000"; --  1 free, BSIGQ[22:8](MSB), {READ ONLY}
         mem(12)  <= "0000000000000000"; --  0 free, DC_REG[15:0]
         mem(13)	<= "0000000000000000"; -- 16 free, UNUSED[15:0]
--       mem(14)  <= "0000000000000000"; -- 16 free, UNUSED[15:0]
--       mem(15)	<= "0000000000000000"; -- 16 free, UNUSED[15:0] 
         mem(14)  <= x"0855"; --  0 free, TNCOF MSB --1MHz, When Fclk = 30.72MHz
         mem(15)  <= x"5555"; --  0 free, TNCOF LSB
--       mem(14)  <= x"042A"; --  0 free, TNCOF MSB --0.25MHz, When Fclk = 30.72MHz
--       mem(15)  <= x"AAAB"; --  0 free, TNCOF LSB
      elsif sclk'event and sclk = '1' then
            if mem_we = '1' then
               mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
            end if;
            
            if dout_reg_len = '0' then
               mem(9)  <= to_txtspcfg.bsigi(14 downto 0) & to_txtspcfg.bstate;
               mem(10) <= to_txtspcfg.bsigq(7 downto 0) & to_txtspcfg.bsigi(22 downto 15);
               mem(11)(14 downto 0) <= to_txtspcfg.bsigq(22 downto 8);
            end if;
            
      end if;
   end process ram;
   
   -- ---------------------------------------------------------------------------------------------
   -- Decoding logic
   -- ---------------------------------------------------------------------------------------------
   
   
   --0x0
   from_txtspcfg.tsgfc       <= mem(0)(9);
   from_txtspcfg.tsgfcw      <= mem(0)(8 downto 7);
   from_txtspcfg.tsgdcldq    <= mem(0)(6);
   from_txtspcfg.tsgdcldi    <= mem(0)(5);
   from_txtspcfg.tsgswapiq   <= mem(0)(4);
   from_txtspcfg.tsgmode     <= mem(0)(3);
   from_txtspcfg.insel       <= mem(0)(2);
   from_txtspcfg.bstart      <= mem(0)(1);
   from_txtspcfg.en          <= mem(0)(0) and to_txtspcfg.txen;
   
   --0x1, 0x2
   from_txtspcfg.gcorrq      <= mem(1)(10 downto 0);
   from_txtspcfg.gcorri      <= mem(2)(10 downto 0);
   
   --0x3
   from_txtspcfg.iqcorr      <= mem(3)(11 downto 0);
   from_txtspcfg.ovr         <= mem(3)(14 downto 12);
   
   --0x4
   from_txtspcfg.dccorri     <= mem(4)(15 downto 8);
   from_txtspcfg.dccorrq     <= mem(4)(7 downto 0);
   
   --0x5
   from_txtspcfg.gfir1l      <= mem(5)(10 downto 8);
   from_txtspcfg.gfir1n      <= mem(5)(7 downto 0);
   
   --0x6
   from_txtspcfg.gfir2l      <= mem(6)(10 downto 8);
   from_txtspcfg.gfir2n      <= mem(6)(7 downto 0);
   
   --0x7
   from_txtspcfg.gfir3l      <= mem(7)(10 downto 8);
   from_txtspcfg.gfir3n      <= mem(7)(7 downto 0);
   
   --0x8
   from_txtspcfg.ph_byp      <= mem(8)(0);
   from_txtspcfg.gc_byp      <= mem(8)(1);
   from_txtspcfg.dc_byp      <= mem(8)(3);
   from_txtspcfg.gfir1_byp   <= mem(8)(4);
   from_txtspcfg.gfir2_byp   <= mem(8)(5);
   from_txtspcfg.gfir3_byp   <= mem(8)(6);
   from_txtspcfg.isinc_byp   <= mem(8)(7);
   from_txtspcfg.cmix_byp    <= mem(8)(8);
   from_txtspcfg.cmix_sc     <= mem(8)(13);
   from_txtspcfg.cmix_gain   <= mem(8)(12) & mem(8)(15 downto 14);
   
   --0x9, 0xA, 0xB
   -- Read only signatures
   
   --0xC
   from_txtspcfg.dc_reg      <= mem(12);
   
   from_txtspcfg.nco_fcv     <= mem(14) & mem(15); 
   
end txtspcfg_arch;
