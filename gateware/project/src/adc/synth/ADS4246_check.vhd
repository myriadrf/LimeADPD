-- ----------------------------------------------------------------------------	
-- FILE: 	ADS4246_check.vhd
-- DESCRIPTION:	Checks test pattern from ADS4246 
-- DATE:	Mar 24, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity ADS4246_check is
  port (
      --input ports 
      clk               : in std_logic;
      reset_n           : in std_logic;
      en                : in std_logic;
      rst_error         : in std_logic;
      data_l            : in std_logic_vector(6 downto 0);
      data_h            : in std_logic_vector(6 downto 0);
      data_out          : out std_logic_vector(13 downto 0);
      data_out_swpd     : out std_logic_vector(13 downto 0);
      error_out         : out std_logic;
      error_cap         : out std_logic

        --output ports 
        
        );
end ADS4246_check;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of ADS4246_check is
--declare signals,  components here
signal cap_data         : std_logic_vector (13 downto 0); 
signal cap_data_swpd    : std_logic_vector (13 downto 0);
signal begin_check      : std_logic;
signal adc_cnt          : unsigned(13 downto 0);
signal en_reg0, en_reg1 : std_logic;
type state_type is (idle, s0, s1);
signal current_state, next_state : state_type;
signal err_current_state, err_next_state : state_type;
signal error_out_sig    : std_logic;
signal data_h_reg, data_l_reg : std_logic_vector(6 downto 0);

begin


-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      current_state <= idle;
      en_reg0<='0';
      en_reg1<='1';
      data_h_reg<=(others=>'0');
      data_l_reg<=(others=>'0');
   elsif(clk'event and clk = '1')then 
      data_h_reg<=data_h;
      data_l_reg<=data_l;
      current_state <= next_state;
      en_reg0<=en;
      en_reg1<=en_reg0;
   end if;	
end process;


-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, en_reg1, cap_data) begin
   next_state <= current_state;
   case current_state is  
      when idle => --idle state, wait for enable
            if en_reg1='1' then 
               next_state<=s0;
            else
               next_state<=idle;
            end if;
      when s0 => 
            if cap_data="11111111111111" then --wait for counter end
               next_state<=s1;
            else 
               next_state<=s0;
            end if;
      when s1 =>  --count
            if en_reg1='0' then 
               next_state<=idle;
            else 
               next_state<=s1;
            end if;
      when others => 
         next_state<=idle;
   end case;
end process;


--check counter 
   process(reset_n, clk)
   begin
      if reset_n='0' then
         adc_cnt<=(others=>'0');
      elsif (clk'event and clk = '1') then
         if current_state=s1 then 
            adc_cnt<=adc_cnt+1;
         else 
            adc_cnt<=(others=>'0');
         end if;
      end if;
   end process;
   
   
   --data checking procces
   process(reset_n, clk)
   begin
      if reset_n='0' then
         error_out_sig<='0';
         elsif (clk'event and clk = '1') then
         if cap_data=std_logic_vector(adc_cnt) then 
            error_out_sig<='0';
         else 
            error_out_sig<='1';
         end if;
      end if;
   end process; 

error_out<=error_out_sig;




-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------

err_fsm_f : process(clk, reset_n)begin
   if(reset_n = '0')then
      err_current_state <= idle;
   elsif(clk'event and clk = '1')then 
      err_current_state <= err_next_state;
   end if;	
end process;



-- ----------------------------------------------------------------------------
--state machine combo for capturing error
-- ----------------------------------------------------------------------------
err_fsm : process(err_current_state, error_out_sig, rst_error) begin
   err_next_state <= err_current_state;
   case err_current_state is
   
      when idle => --idle state 
         if error_out_sig='1' then 
            err_next_state<=s0;
         else 
            err_next_state<=idle;
         end if;
      
      when s0 => 
         if rst_error='1' then 
            err_next_state<=idle;
         else 
            err_next_state<=s0;
         end if;
         
      when others => 
         err_next_state<=idle;
   end case;
end process;



process(err_current_state) begin
   if(err_current_state = s0 ) then
      error_cap<='1';
   else
      error_cap<='0';
   end if;
end process; 

--swapped captured data (for testing)
   cap_data_swpd<=   data_l_reg (6) & data_h_reg(6) & 
                     data_l_reg (5) & data_h_reg(5) & 
                     data_l_reg (4) & data_h_reg(4) & 
                     data_l_reg (3) & data_h_reg(3) &
                     data_l_reg (2) & data_h_reg(2) & 
                     data_l_reg (1) & data_h_reg(1) &
                     data_l_reg (0) & data_h_reg(0);

-- captured data
   cap_data<=        data_h_reg (6) & data_l_reg(6) & 
                     data_h_reg (5) & data_l_reg(5) & 
                     data_h_reg (4) & data_l_reg(4) & 
                     data_h_reg (3) & data_l_reg(3) &
                     data_h_reg (2) & data_l_reg(2) & 
                     data_h_reg (1) & data_l_reg(1) &
                     data_h_reg (0) & data_l_reg(0);
               
  data_out<=cap_data;
  data_out_swpd<=cap_data_swpd;
  
  
end arch;




