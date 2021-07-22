-- ----------------------------------------------------------------------------
-- FILE:          gnsscfg.vhd
-- DESCRIPTION:   SPI configuration registers 
-- DATE:          2:58 PM Thursday, February 22, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mem_package.all;
use work.gnsscfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity gnsscfg is
   port (
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       : in  std_logic_vector(9 downto 0);
      mimo_en        : in  std_logic; -- MIMO enable, from TOP SPI (always 1)
   
      -- Serial port IOs
      sdin           : in  std_logic;   -- Data in
      sclk           : in  std_logic;   -- Data clock
      sen            : in  std_logic;   -- Enable signal (active low)
      sdout          : out std_logic;   -- Data out
   
      -- Signals coming from the pins or top level serial interface
      lreset         : in  std_logic;   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset         : in  std_logic;   -- Memory reset signal, resets configuration memory only (use only one reset)
      
      oen            : out std_logic;  --nc
      stateo         : out std_logic_vector(5 downto 0);
      
      to_gnsscfg     : in  t_TO_GNSSCFG;
      from_gnsscfg   : out t_FROM_GNSSCFG
      
   );
end gnsscfg;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of gnsscfg is

   signal inst_reg: std_logic_vector(15 downto 0);    -- Instruction register
   signal inst_reg_en: std_logic;
   
   signal din_reg: std_logic_vector(15 downto 0);     -- Data in register
   signal din_reg_en: std_logic;
   
   signal dout_reg: std_logic_vector(15 downto 0);    -- Data out register
   signal dout_reg_sen, dout_reg_len: std_logic;
   
   signal mem: marray32x16;                           -- Config memory
   signal mem_we: std_logic;
   
   signal oe: std_logic;                              -- Tri state buffers control
   signal spi_config_data_rev : std_logic_vector(143 downto 0);
   
   -- Components
   use work.mcfg_components.mcfg32wm_fsm;
   for all: mcfg32wm_fsm use entity work.mcfg32wm_fsm(mcfg32wm_fsm_arch);
   
   signal gprmc_utc_sss0      : std_logic_vector(11 downto 0);
   signal gprmc_utc_ss1       : std_logic_vector(7 downto 0);
   signal gprmc_utc_mm        : std_logic_vector(7 downto 0);
   signal gprmc_utc_hh        : std_logic_vector(7 downto 0);
         
   signal gprmc_lat_ll0       : std_logic_vector(7 downto 0);
   signal gprmc_lat_ll1       : std_logic_vector(7 downto 0);
   signal gprmc_lat_ll2       : std_logic_vector(7 downto 0);
   signal gprmc_lat_ll3       : std_logic_vector(7 downto 0);
   signal gprmc_lat_n_s       : std_logic;
         
   signal gprmc_long_yy0      : std_logic_vector(7 downto 0);
   signal gprmc_long_yy1      : std_logic_vector(7 downto 0);
   signal gprmc_long_yy2      : std_logic_vector(7 downto 0);
   signal gprmc_long_yy3      : std_logic_vector(7 downto 0);
   signal gprmc_long_y4       : std_logic_vector(3 downto 0);
   signal gprmc_long_e_w      : std_logic;
   
   signal gprmc_speed_xx0     : std_logic_vector(7 downto 0);
   signal gprmc_speed_xx1     : std_logic_vector(7 downto 0);
   signal gprmc_speed_xx2     : std_logic_vector(7 downto 0);
   
   signal gprmc_course_xx0    : std_logic_vector(7 downto 0);
   signal gprmc_course_xx1    : std_logic_vector(7 downto 0);
   signal gprmc_course_x2     : std_logic_vector(3 downto 0);
   
   signal gprmc_date_yy       : std_logic_vector(7 downto 0);
   signal gprmc_date_mm       : std_logic_vector(7 downto 0);
   signal gprmc_date_dd       : std_logic_vector(7 downto 0);

begin

--UTC of position fix (BCD format). HH-MM-SS1.SSS0 
gprmc_utc_sss0      <= to_gnsscfg.gprmc_utc(11 downto 0);
gprmc_utc_ss1       <= to_gnsscfg.gprmc_utc(19 downto 12);
gprmc_utc_mm        <= to_gnsscfg.gprmc_utc(27 downto 20);
gprmc_utc_hh        <= to_gnsscfg.gprmc_utc(35 downto 28);
--Latitude,  LL3-LL2.LL1-LL0
gprmc_lat_ll0       <= to_gnsscfg.gprmc_lat(7 downto 0);
gprmc_lat_ll1       <= to_gnsscfg.gprmc_lat(15 downto 8);
gprmc_lat_ll2       <= to_gnsscfg.gprmc_lat(23 downto 16);
gprmc_lat_ll3       <= to_gnsscfg.gprmc_lat(31 downto 24);
gprmc_lat_n_s       <= to_gnsscfg.gprmc_lat(32); -- Latitude 0 – N, 1 – S

--Longitude, Y4-YY3-YY2.YY1-YY0
gprmc_long_yy0      <= to_gnsscfg.gprmc_long(7 downto 0);
gprmc_long_yy1      <= to_gnsscfg.gprmc_long(15 downto 8);
gprmc_long_yy2      <= to_gnsscfg.gprmc_long(23 downto 16);
gprmc_long_yy3      <= to_gnsscfg.gprmc_long(31 downto 24);
gprmc_long_y4       <= to_gnsscfg.gprmc_long(35 downto 32);
gprmc_long_e_w      <= to_gnsscfg.gprmc_long(36); -- Longitude, 0 – E, 1 – W

--Speed over ground, knots, XX2-XX1.XX0
gprmc_speed_xx0     <= to_gnsscfg.gprmc_speed(7 downto 0);
gprmc_speed_xx1     <= to_gnsscfg.gprmc_speed(15 downto 8);
gprmc_speed_xx2     <= to_gnsscfg.gprmc_speed(23 downto 16);

--Course Over Ground, degrees True, X2-XX1.XX0 
gprmc_course_xx0    <= to_gnsscfg.gprmc_course(7 downto 0);
gprmc_course_xx1    <= to_gnsscfg.gprmc_course(15 downto 8);
gprmc_course_x2     <= to_gnsscfg.gprmc_course(19 downto 16);

--Date: DD-MM-YY
gprmc_date_yy       <= to_gnsscfg.gprmc_date(7 downto 0);
gprmc_date_mm       <= to_gnsscfg.gprmc_date(15 downto 8);
gprmc_date_dd       <= to_gnsscfg.gprmc_date(23 downto 16);

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
            case inst_reg(4 downto 0) is -- mux read-only outputs
               -- inst_reg=1
               when "00001" => dout_reg <= x"0" & gprmc_utc_sss0;
               -- inst_reg=2
               when "00010" => dout_reg <= gprmc_utc_mm & gprmc_utc_ss1;
               -- inst_reg=3
               when "00011" => dout_reg <= x"00" & gprmc_utc_hh;
               -- inst_reg=4
               when "00100" => dout_reg <= x"00" & "0000000" & to_gnsscfg.gprmc_status;              
               -- inst_reg=5
               when "00101" => dout_reg <= gprmc_lat_ll1 & gprmc_lat_ll0;               
               -- inst_reg=6
               when "00110" => dout_reg <= gprmc_lat_ll3 & gprmc_lat_ll2;                
               -- inst_reg=7
               when "00111" => dout_reg <= x"00" & "0000000" & gprmc_lat_n_s; 
               -- inst_reg=8
               when "01000" => dout_reg <= gprmc_long_yy1 & gprmc_long_yy0;              
               -- inst_reg=9;
               when "01001" => dout_reg <= gprmc_long_yy3 & gprmc_long_yy2; 
               -- inst_reg=10;
               when "01010" => dout_reg <= x"000" & gprmc_long_y4;
               -- inst_reg=11;
               when "01011" => dout_reg <= x"00" & "0000000" & gprmc_long_e_w;
               -- inst_reg=12;
               when "01100" => dout_reg <= gprmc_speed_xx1 & gprmc_speed_xx0;
               -- inst_reg=13;
               when "01101" => dout_reg <= x"00" & gprmc_speed_xx2;
               -- inst_reg=14;
               when "01110" => dout_reg <= gprmc_course_xx1 & gprmc_course_xx0;
               -- inst_reg=15;
               when "01111" => dout_reg <= x"000" & gprmc_course_x2;
               -- inst_reg=16;
               when "10000" => dout_reg <= gprmc_date_mm & gprmc_date_yy;
               -- inst_reg=17;
               when "10001" => dout_reg <= x"00" & gprmc_date_dd;
               -- inst_reg=20;
               when "10100" => dout_reg <= x"00" & to_gnsscfg.gpgsa_fix & x"0";
               
               when others  => dout_reg <= mem(to_integer(unsigned(inst_reg(4 downto 0))));
            end case;
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
         mem(0)   <= "0000000000000000"; --  0 free, EN
         mem(1)   <= "0000000000000000"; --  0 free, Reserved[3:0], GPRMC_UTC_SSS0[11:0]
         mem(2)   <= "0000000000000000"; --  0 free, GPRMC_UTC_MM[7:0],GPRMC_UTC_SS1[7:0]
         mem(3)   <= "0000000000000011"; --  0 free, Reserved[3:0],GPRMC_UTC_HH[7:0]
         mem(4)   <= "0000000000000000"; --  0 free, Reserved[14:0],GPRMC_STATUS
         mem(5)   <= "0000000000100010"; --  0 free, GPRMC_LAT_LL1[7:0],GPRMC_LAT_LL0[7:0]
         mem(6)   <= "0000000000000000"; --  0 free, GPRMC_LAT_LL3[7:0],GPRMC_LAT_LL2[7:0]
         mem(7)   <= "0000000101100100"; --  0 free, Reserved[14:0],GPRMC_LAT_N_S
         mem(8)   <= "0000000000000000"; --  0 free, GPRMC_LONG_YY1[7:0], GPRMC_LONG_YY0[7:0]
         mem(9)   <= "0000000000000000"; --  0 free, GPRMC_LONG_YY3[7:0], GPRMC_LONG_YY2[7:0]
         mem(10)  <= "0000000000000000"; --  0 free, Reserved[11:0], GPRMC_LONG_Y4[3:0]
         mem(11)  <= "0000000000000000"; --  0 free, Reserved[14:0], GPRMC_LONG_E_W			
         mem(12)  <= "0000000000000000"; --  0 free, GPRMC_SPEED_XX1[7:0], GPRMC_SPEED_XX0[7:0]
         mem(13)  <= "0000000000000000"; --  0 free, Reserved[7:0], GPRMC_SPEED_XX2[7:0]
         mem(14)  <= "0000000000000000"; --  0 free, GPRMC_COURSE_XX1[7:0], GPRMC_COURSE_XX0[7:0]
         mem(15)  <= "0000000000000000"; --  0 free, Reserved[11:0], GPRMC_COURSE_XX2[3:0]
         mem(16)  <= "0000000000000000"; --  0 free, GPRMC_DATE_MM[7:0],GPRMC_DATE_YY[7:0]
         mem(17)  <= "0000000000000000"; --  0 free, Reserved[7:0], GPRMC_DATE_DD[7:0]
         mem(18)  <= "0000000000000000"; --  0 free, Reserved
         mem(19)  <= "0000000000000000"; --  0 free, Reserved
         mem(20)  <= "0000000000000000"; --  0 free, Reserved[3:0], GPGSA_FIX[3:0], Reserved[3:0]
         mem(21)  <= "0000000000000000"; --  0 free, Reserved
         mem(22)  <= "0000000000000000"; --  0 free, Reserved
         mem(23)  <= "0000000000000000"; --  0 free, Reserved
         mem(24)  <= "0000000000000000"; --  0 free, Reserved
         mem(25)  <= "0000000000000000"; --  0 free, Reserved
         mem(26)  <= "0000000000000000"; --  0 free, Reserved
         mem(27)  <= "0000000000000000"; --  0 free, Reserved
         mem(28)  <= "0000000000000000"; --  0 free, Reserved
         mem(29)  <= "0000000000000000"; --  0 free, Reserved
         mem(30)  <= "0000000000000000"; --  0 free, Reserved
         mem(31)  <= "0000000000000000"; --  0 free, Reserved
            
      elsif sclk'event and sclk = '1' then
            if mem_we = '1' then
               mem(to_integer(unsigned(inst_reg(4 downto 0)))) <= din_reg(14 downto 0) & sdin;
            end if;
            
            if dout_reg_len = '0' then

            end if;
            
      end if;
   end process ram;
   
   -- ---------------------------------------------------------------------------------------------
   -- Decoding logic
   -- ---------------------------------------------------------------------------------------------
   from_gnsscfg.en  <= mem( 0) (0);


      
      
end arch;
