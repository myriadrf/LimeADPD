-- ----------------------------------------------------------------------------	
-- FILE: 	txiq_par.vhd
-- DESCRIPTION:	TXIQ modes: 
-- DATE:	Jan 20, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity txiq_par is
   generic( 
      dev_family	         : string := "Cyclone IV E";
      iq_width		         : integer := 12;
      fifo_q_valid_latency : integer := 1 --  fifo_q_valid signal latency cycles after fifo_rdreq
   );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      en          : in std_logic;
      --Mode settings
		ch_en			: in std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.  
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Tx interface data 
      DIQ0		   : out std_logic_vector(iq_width downto 0);
		DIQ1	 	   : out std_logic_vector(iq_width downto 0);
      DIQ2		   : out std_logic_vector(iq_width downto 0);
		DIQ3	 	   : out std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_rdempty: in std_logic;
      fifo_rdreq  : out std_logic;
      fifo_q_valid: in std_logic;
      fifo_q      : in std_logic_vector(iq_width*4-1 downto 0)        
        );
end txiq_par;

-- ----------------------------------------------------------------------------
--Truth table for mode selection
-- ----------------------------------------------------------------------------
-- Mode       | MIMO       | MIMO      | MIMO      |
--            |  all ch.   |  1 ch.    |  2 ch.    |
-- ch_en      |     HH     |   LH      |    HL     |

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of txiq_par is
--declare signals,  components here
signal int_fifo_rdreq         : std_logic;
signal int_fifo_q_valid       : std_logic;
signal en_pipe                : std_logic_vector(fifo_q_valid_latency+1 downto 0);

signal DIQ0_reg_reset_n       : std_logic;
signal DIQ1_reg_reset_n       : std_logic;
signal DIQ2_reg_reset_n       : std_logic;
signal DIQ3_reg_reset_n       : std_logic;

signal DIQ0_mux_0, DIQ0_mux_1 : std_logic_vector(iq_width-1 downto 0);
signal DIQ1_mux_0, DIQ1_mux_1 : std_logic_vector(iq_width-1 downto 0);
signal DIQ2_mux_0, DIQ2_mux_1 : std_logic_vector(iq_width-1 downto 0);
signal DIQ3_mux_0, DIQ3_mux_1 : std_logic_vector(iq_width-1 downto 0);

signal DIQ0_reg_0, DIQ0_reg_1 : std_logic_vector(iq_width downto 0);
signal DIQ1_reg_0, DIQ1_reg_1 : std_logic_vector(iq_width downto 0);
signal DIQ2_reg_0, DIQ2_reg_1 : std_logic_vector(iq_width downto 0);
signal DIQ3_reg_0, DIQ3_reg_1 : std_logic_vector(iq_width downto 0);

signal diq_smpl_0             : std_logic_vector(iq_width-1 downto 0);
signal diq_smpl_1             : std_logic_vector(iq_width-1 downto 0);
signal diq_smpl_2             : std_logic_vector(iq_width-1 downto 0);
signal diq_smpl_3             : std_logic_vector(iq_width-1 downto 0);
   
signal mux_fsync_A            : std_logic;
signal mux_fsync_B            : std_logic;
   
signal int_mode               : std_logic_vector(1 downto 0);

type state_type is (idle, rd_samples, wait_rd_cycles);
signal current_state, next_state : state_type;
  
begin
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         en_pipe <= (others=> '0');
      elsif (clk'event AND clk='1') then 
         en_pipe <= en_pipe(fifo_q_valid_latency downto 0) & en;
      end if;
   end process;
   
-- ----------------------------------------------------------------------------
-- DIQ samples from fifo
-- ----------------------------------------------------------------------------
diq_smpl_3 <= fifo_q(4*iq_width-1 downto 3*iq_width);
diq_smpl_2 <= fifo_q(3*iq_width-1 downto 2*iq_width);
diq_smpl_1 <= fifo_q(2*iq_width-1 downto 1*iq_width);
diq_smpl_0 <= fifo_q(1*iq_width-1 downto 0*iq_width);

-- ----------------------------------------------------------------------------
--Internal mode selection for DIQ position
-- "00" - MIMO, both channels enabled
-- "01" - MIMO, first channel enabled
-- "10" - MIMO, second channel enabled
-- "11" -  
-- ----------------------------------------------------------------------------
int_mode <= "00" when ch_en="00" else 
            "01" when ch_en="01" else
            "10" when ch_en="10" else
            "11";
             
-- ----------------------------------------------------------------------------
--Muxes for fsync signal
-- ----------------------------------------------------------------------------
mux_fsync_A <= fidm;
mux_fsync_B <= not fidm;

-- ----------------------------------------------------------------------------
--Muxes for DIQx_mux_0 positions
-- ----------------------------------------------------------------------------            
DIQ0_mux_0 <=  diq_smpl_0;
                  
DIQ1_mux_0 <=  diq_smpl_1;
               
DIQ2_mux_0 <=  diq_smpl_2 when int_mode = "11" else 
               diq_smpl_0;               
                  
DIQ3_mux_0 <=  diq_smpl_3 when int_mode = "11" else 
               diq_smpl_1;
-- ----------------------------------------------------------------------------               
-- Muxes for diq  L positions
-- ----------------------------------------------------------------------------
DIQ0_mux_1 <=  diq_smpl_2;
                  
DIQ1_mux_1 <=  diq_smpl_3;
               
DIQ2_mux_1 <=  diq_smpl_2;               
                  
DIQ3_mux_1 <=  diq_smpl_3;  

-- ----------------------------------------------------------------------------
--state machine to control when to read from FIFO
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
      if en = '1' then 
         current_state <= next_state;
      else 
         current_state <= current_state;
      end if;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, en, fifo_rdempty) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state
         if fifo_rdempty = '0' AND en = '1' then 
            next_state <= rd_samples;
         else 
            next_state <= idle;
         end if;
         
      when rd_samples => 
         if ch_en /= "11" then 
            next_state <= wait_rd_cycles;
         else 
            next_state <= rd_samples;
         end if;
      
      when wait_rd_cycles =>
         if en = '1' then
            if fifo_rdempty = '0' then
               next_state <= rd_samples;
            else 
               next_state <= idle;
            end if;
         else 
            next_state <= wait_rd_cycles;
         end if;
                  
		when others => 
			next_state<=idle;
	end case;
end process;

-- ----------------------------------------------------------------------------
-- FIFO read signal
-- ----------------------------------------------------------------------------
process(current_state, en)
begin
   if current_state = rd_samples AND en = '1' then 
      int_fifo_rdreq <= '1';
   else 
      int_fifo_rdreq <= '0';
   end if;
end process;

--To avoid reading from empty FIFO
fifo_rdreq <= int_fifo_rdreq AND NOT fifo_rdempty;


DIQ0_reg_reset_n <= ch_en(0);
-- ----------------------------------------------------------------------------
-- Shift reg array with synchronous load 
-- ----------------------------------------------------------------------------
diq_L_reg_x_proc : process(DIQ0_reg_reset_n, clk)
begin
   if DIQ0_reg_reset_n='0' then
      DIQ0_reg_0 <= (others=>'0');
      DIQ0_reg_1 <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if fifo_q_valid ='1' then 
         DIQ0_reg_0 <= mux_fsync_A & DIQ0_mux_0;
         DIQ0_reg_1 <= mux_fsync_A & DIQ0_mux_1;
      elsif en_pipe(fifo_q_valid_latency) = '1' then   
         DIQ0_reg_0 <= DIQ0_reg_1;
         DIQ0_reg_1 <= (others=>'0');
      else 
         DIQ0_reg_0 <= DIQ0_reg_0;
         DIQ0_reg_1 <= DIQ0_reg_1;
      end if; 
   end if;
end process;
    

DIQ1_reg_reset_n <= ch_en(0);
-- ----------------------------------------------------------------------------
-- Shift reg array with synchronous load 
-- ----------------------------------------------------------------------------
process(DIQ1_reg_reset_n, clk)
begin
   if DIQ1_reg_reset_n='0' then
      DIQ1_reg_0 <= (others=>'0');
      DIQ1_reg_1 <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if fifo_q_valid ='1' then 
         DIQ1_reg_0 <= mux_fsync_A & DIQ1_mux_0;
         DIQ1_reg_1 <= mux_fsync_A & DIQ1_mux_1;
      elsif en_pipe(fifo_q_valid_latency) = '1' then   
         DIQ1_reg_0 <= DIQ1_reg_1;
         DIQ1_reg_1 <= (others=>'0');
      else 
         DIQ1_reg_0 <= DIQ1_reg_0;
         DIQ1_reg_1 <= DIQ1_reg_1;
      end if; 
   end if;
end process;
    

    
DIQ2_reg_reset_n <= ch_en(1);
-- ----------------------------------------------------------------------------
-- Shift reg array with synchronous load 
-- ----------------------------------------------------------------------------
process(DIQ2_reg_reset_n, clk)
begin
   if DIQ2_reg_reset_n = '0' then
      DIQ2_reg_0 <= (others=>'0');
      DIQ2_reg_1 <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if fifo_q_valid ='1' then 
         DIQ2_reg_0 <= mux_fsync_B & DIQ2_mux_0;
         DIQ2_reg_1 <= mux_fsync_B & DIQ2_mux_1;
      elsif en_pipe(fifo_q_valid_latency) = '1' then   
         DIQ2_reg_0 <= DIQ2_reg_1;
         DIQ2_reg_1 <= (others=>'0');
      else 
         DIQ2_reg_0 <= DIQ2_reg_0;
         DIQ2_reg_1 <= DIQ2_reg_1;
      end if; 
   end if;
end process;
    
DIQ3_reg_reset_n <= ch_en(1);
-- ----------------------------------------------------------------------------
-- Shift reg array with synchronous load 
-- ----------------------------------------------------------------------------
process(DIQ3_reg_reset_n, clk)
begin
   if DIQ3_reg_reset_n='0' then
      DIQ3_reg_0 <= (others=>'0');
      DIQ3_reg_1 <= (others=>'0');
   elsif (clk'event and clk = '1') then
      if fifo_q_valid ='1' then 
         DIQ3_reg_0 <= mux_fsync_B & DIQ3_mux_0;
         DIQ3_reg_1 <= mux_fsync_B & DIQ3_mux_1;
      elsif en_pipe(fifo_q_valid_latency) = '1' then   
         DIQ3_reg_0 <= DIQ3_reg_1;
         DIQ3_reg_1 <= (others=>'0');
      else 
         DIQ3_reg_0 <= DIQ3_reg_0;
         DIQ3_reg_1 <= DIQ3_reg_1;
      end if; 
   end if;
end process;
   
   DIQ0 <= DIQ0_reg_0;
   DIQ1 <= DIQ1_reg_0;
   DIQ2 <= DIQ2_reg_0;
   DIQ3 <= DIQ3_reg_0;
 
end arch;   






