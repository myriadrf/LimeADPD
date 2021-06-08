-- ----------------------------------------------------------------------------	
-- FILE: 	compress_48_to_64.vhd
-- DESCRIPTION:	packs data from 48 samples to 64 bit data
-- DATE:	Dec 9, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity comprlaration
-- ----------------------------------------------------------------------------
entity compress_48_to_64 is

  port (
        --input ports 
        clk             : in std_logic;
        reset_n         : in std_logic;
        data_in         : in std_logic_vector(47 downto 0);
        data_in_valid   : in std_logic;
        sample_width    : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
        --output ports 
        data_out        : out std_logic_vector(63 downto 0);
        data_out_valid  : out std_logic;
        compressing     : out std_logic       
        );
end compress_48_to_64;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of compress_48_to_64 is
--Declare signals,  components here

--data registers
signal data_in_reg  : std_logic_vector (47 downto 0);
signal d_out, d_out_reg : std_logic_vector(63 downto 0);
signal smpl_cnt : unsigned (7 downto 0);
signal smpl_cnt_max : unsigned (3 downto 0);
signal compr_array   : std_logic_vector(191 downto 0);
signal compr_array_reg   : std_logic_vector(127 downto 0);
signal tst_out      : std_logic_vector(63 downto 0);
signal tst_msb      : integer;
signal tst_lsb      : integer;
signal  wreq_sig    : std_logic;
signal wreq_cnt : unsigned (3 downto 0);
signal wreq_cnt_max : unsigned (3 downto 0);
signal data_in_valid_reg  : std_logic;
  
begin
  smpl_cnt_max<="0011" when sample_width="10" else 
                "0111" when sample_width="01" else
                "0000";
   
  tst_out<= compr_array(63 downto 0) when wreq_cnt=0 else 
   	        compr_array(127 downto 64) when wreq_cnt=1 else
   	        compr_array(191 downto 128);                      
  
-- ----------------------------------------------------------------------------
-- Sample counter
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			smpl_cnt<=(others=>'0');
			data_in_valid_reg<='0';
		elsif (clk'event and clk = '1') then
		  data_in_valid_reg<=data_in_valid;
        if data_in_valid='1' then
          if smpl_cnt<smpl_cnt_max then  
            smpl_cnt<=smpl_cnt+1;
          else 
            smpl_cnt<=(others=>'0');
          end if;
        else 
          smpl_cnt<=smpl_cnt;
        end if;
		end if;
	end process;
	
	
-- ----------------------------------------------------------------------------
-- wreq counter
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			wreq_cnt<=(others=>'0');
		elsif (clk'event and clk = '1') then
        if wreq_sig='1' then
          if wreq_cnt<smpl_cnt_max-1 then  
            wreq_cnt<=wreq_cnt+1;
          else 
            wreq_cnt<=(others=>'0');
          end if;
        else 
          wreq_cnt<=wreq_cnt;
        end if;
		end if;
	end process;
	
-- ----------------------------------------------------------------------------
-- Sample counter
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			wreq_sig<='0';
		elsif (clk'event and clk = '1') then
        if data_in_valid='1' and smpl_cnt>=1 then
          wreq_sig<='1'; 
        else 
          wreq_sig<='0'; 
        end if;
		end if;
	end process;	
	
	
	
-- ----------------------------------------------------------------------------
-- shift reg
-- ----------------------------------------------------------------------------
-- process (clk, reset_n)
--	begin
--		--
--		if (reset_n = '0') then
--				compr_array_reg<=(others=>'0');
--		elsif (clk'event and clk = '1') then
--        if data_in_valid='1' and smpl_cnt>1 then
--          compr_array_reg<=std_logic_vector(unsigned(compr_array) srl 16);
--        else 
--          compr_array_reg<=compr_array;
--        end if;
--		end if;
--	end process;	
	
  
-- ----------------------------------------------------------------------------
-- Sample compression
-- ----------------------------------------------------------------------------
 process (clk, reset_n)
	begin
		--
		if (reset_n = '0') then
			compr_array<=(others=>'0');
		elsif (clk'event and clk = '1') then		  
        if data_in_valid='1' then
            --if sample_width="10" then 
              compr_array(to_integer(smpl_cnt*48+47) downto to_integer(smpl_cnt*48)) <=data_in(47 downto 0);
            --elsif sample_width="01" then
              --compr_array(to_integer(smpl_cnt*14+13) downto to_integer(smpl_cnt*13)) <= data_in(13 downto 0);
            --else
             -- compr_array(63 downto 0)<= (others=>'0');
          --end if;
        else 
          compr_array<=compr_array;
        end if;
		end if;
	end process;
	
	tst_msb<=to_integer(smpl_cnt*48+47);
	tst_lsb<=to_integer(smpl_cnt*48);

data_out_valid<=data_in_valid_reg when sample_width="00" else wreq_sig;
data_out<=tst_out;

compressing<='0' when wreq_cnt=0 else '1';
  
end arch;   




