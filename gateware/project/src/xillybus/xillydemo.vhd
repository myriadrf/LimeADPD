library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

entity xillydemo is
  port (
    pcie_perstn : IN std_logic;
    pcie_refclk : IN std_logic;
    pcie_rx : IN std_logic_vector(3 DOWNTO 0);
    pcie_tx : OUT std_logic_vector(3 DOWNTO 0);
    user_led : OUT std_logic_vector(3 DOWNTO 0));
end xillydemo;
  
architecture sample_arch of xillydemo is
  component xillybus
    port (
--      pcie_perstn : IN std_logic;
--      pcie_refclk : IN std_logic;
--      pcie_rx : IN std_logic_vector(3 DOWNTO 0);
--      bus_clk : OUT std_logic;
--      pcie_tx : OUT std_logic_vector(3 DOWNTO 0);
--      quiesce : OUT std_logic;
--      user_led : OUT std_logic_vector(3 DOWNTO 0);
--      user_r_mem_8_rden : OUT std_logic;
--      user_r_mem_8_empty : IN std_logic;
--      user_r_mem_8_data : IN std_logic_vector(7 DOWNTO 0);
--      user_r_mem_8_eof : IN std_logic;
--      user_r_mem_8_open : OUT std_logic;
--      user_w_mem_8_wren : OUT std_logic;
--      user_w_mem_8_full : IN std_logic;
--      user_w_mem_8_data : OUT std_logic_vector(7 DOWNTO 0);
--      user_w_mem_8_open : OUT std_logic;
--      user_mem_8_addr : OUT std_logic_vector(4 DOWNTO 0);
--      user_mem_8_addr_update : OUT std_logic;
--      user_r_read_32_rden : OUT std_logic;
--      user_r_read_32_empty : IN std_logic;
--      user_r_read_32_data : IN std_logic_vector(31 DOWNTO 0);
--      user_r_read_32_eof : IN std_logic;
--      user_r_read_32_open : OUT std_logic;
--      user_r_read_8_rden : OUT std_logic;
--      user_r_read_8_empty : IN std_logic;
--      user_r_read_8_data : IN std_logic_vector(7 DOWNTO 0);
--      user_r_read_8_eof : IN std_logic;
--      user_r_read_8_open : OUT std_logic;
--      user_w_write_32_wren : OUT std_logic;
--      user_w_write_32_full : IN std_logic;
--      user_w_write_32_data : OUT std_logic_vector(31 DOWNTO 0);
--      user_w_write_32_open : OUT std_logic;
--      user_w_write_8_wren : OUT std_logic;
--      user_w_write_8_full : IN std_logic;
--      user_w_write_8_data : OUT std_logic_vector(7 DOWNTO 0);
--      user_w_write_8_open : OUT std_logic
		
		pcie_perstn 						: IN std_logic;
      pcie_refclk 						: IN std_logic;
      pcie_rx 								: IN std_logic_vector(3 DOWNTO 0);
      bus_clk 								: OUT std_logic;
      pcie_tx 								: OUT std_logic_vector(3 DOWNTO 0);
      quiesce 								: OUT std_logic;
      user_led 							: OUT std_logic_vector(3 DOWNTO 0);
      user_r_control0_read_32_rden 	: OUT std_logic;
      user_r_control0_read_32_empty : IN std_logic;
      user_r_control0_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_control0_read_32_eof 	: IN std_logic;
      user_r_control0_read_32_open 	: OUT std_logic;
      user_w_control0_write_32_wren : OUT std_logic;
      user_w_control0_write_32_full : IN std_logic;
      user_w_control0_write_32_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_control0_write_32_open : OUT std_logic;
      user_r_mem_8_rden	 				: OUT std_logic;
      user_r_mem_8_empty 				: IN std_logic;
      user_r_mem_8_data 				: IN std_logic_vector(7 DOWNTO 0);
      user_r_mem_8_eof 					: IN std_logic;
      user_r_mem_8_open 				: OUT std_logic;
      user_w_mem_8_wren 				: OUT std_logic;
      user_w_mem_8_full 				: IN std_logic;
      user_w_mem_8_data 				: OUT std_logic_vector(7 DOWNTO 0);
      user_w_mem_8_open 				: OUT std_logic;
      user_mem_8_addr 					: OUT std_logic_vector(4 DOWNTO 0);
      user_mem_8_addr_update 			: OUT std_logic;
      user_r_stream0_read_32_rden 	: OUT std_logic;
      user_r_stream0_read_32_empty 	: IN std_logic;
      user_r_stream0_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_stream0_read_32_eof 	: IN std_logic;
      user_r_stream0_read_32_open 	: OUT std_logic;
      user_w_stream0_write_32_wren 	: OUT std_logic;
      user_w_stream0_write_32_full 	: IN std_logic;
      user_w_stream0_write_32_data 	: OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream0_write_32_open 	: OUT std_logic;
      user_r_stream1_read_32_rden 	: OUT std_logic;
      user_r_stream1_read_32_empty 	: IN std_logic;
      user_r_stream1_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_stream1_read_32_eof 	: IN std_logic;
      user_r_stream1_read_32_open 	: OUT std_logic;
      user_w_stream1_write_32_wren 	: OUT std_logic;
      user_w_stream1_write_32_full 	: IN std_logic;
      user_w_stream1_write_32_data 	: OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream1_write_32_open 	: OUT std_logic	
		);
  end component;

  COMPONENT scfifo
    GENERIC (
      add_ram_output_register	: STRING;
      intended_device_family	: STRING;
      lpm_numwords		: NATURAL;
      lpm_showahead		: STRING;
      lpm_type		        : STRING;
      lpm_width		        : NATURAL;
      lpm_widthu		: NATURAL;
      overflow_checking		: STRING;
      underflow_checking	: STRING;
      use_eab		        : STRING
      );
    PORT (
      clock	: IN STD_LOGIC ;
      data	: IN STD_LOGIC_VECTOR ( (lpm_width - 1) DOWNTO 0);
      rdreq	: IN STD_LOGIC ;
      sclr	: IN STD_LOGIC ;
      empty	: OUT STD_LOGIC ;
      full	: OUT STD_LOGIC ;
      q	: OUT STD_LOGIC_VECTOR ( (lpm_width - 1) DOWNTO 0);
      wrreq	: IN STD_LOGIC 
      );
  END COMPONENT;

  type demo_mem is array(0 TO 31) of std_logic_vector(7 DOWNTO 0);
  signal demoarray : demo_mem;
  
  signal bus_clk :  std_logic;
  signal quiesce : std_logic;

  signal control0_reset_32 : std_logic;
  signal stream0_reset_32 : std_logic;
  signal stream1_reset_32 : std_logic;

  signal ram_addr : integer range 0 to 31;
  
--  signal user_r_mem_8_rden :  std_logic;
--  signal user_r_mem_8_empty :  std_logic;
--  signal user_r_mem_8_data :  std_logic_vector(7 DOWNTO 0);
--  signal user_r_mem_8_eof :  std_logic;
--  signal user_r_mem_8_open :  std_logic;
--  signal user_w_mem_8_wren :  std_logic;
--  signal user_w_mem_8_full :  std_logic;
--  signal user_w_mem_8_data :  std_logic_vector(7 DOWNTO 0);
--  signal user_w_mem_8_open :  std_logic;
--  signal user_mem_8_addr :  std_logic_vector(4 DOWNTO 0);
--  signal user_mem_8_addr_update :  std_logic;
--  signal user_r_read_32_rden :  std_logic;
--  signal user_r_read_32_empty :  std_logic;
--  signal user_r_read_32_data :  std_logic_vector(31 DOWNTO 0);
--  signal user_r_read_32_eof :  std_logic;
--  signal user_r_read_32_open :  std_logic;
--  signal user_r_read_8_rden :  std_logic;
--  signal user_r_read_8_empty :  std_logic;
--  signal user_r_read_8_data :  std_logic_vector(7 DOWNTO 0);
--  signal user_r_read_8_eof :  std_logic;
--  signal user_r_read_8_open :  std_logic;
--  signal user_w_write_32_wren :  std_logic;
--  signal user_w_write_32_full :  std_logic;
--  signal user_w_write_32_data :  std_logic_vector(31 DOWNTO 0);
--  signal user_w_write_32_open :  std_logic;
--  signal user_w_write_8_wren :  std_logic;
--  signal user_w_write_8_full :  std_logic;
--  signal user_w_write_8_data :  std_logic_vector(7 DOWNTO 0);
--  signal user_w_write_8_open :  std_logic;

  signal user_r_control0_read_32_rden 		:  std_logic;
  signal user_r_control0_read_32_empty 	:  std_logic;
  signal user_r_control0_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_r_control0_read_32_eof 		:  std_logic;
  signal user_r_control0_read_32_open 		:  std_logic;
  signal user_w_control0_write_32_wren 	:  std_logic;
  signal user_w_control0_write_32_full 	:  std_logic;
  signal user_w_control0_write_32_data 	:  std_logic_vector(31 DOWNTO 0);
  signal user_w_control0_write_32_open 	:  std_logic;
  signal user_r_mem_8_rden 					:  std_logic;
  signal user_r_mem_8_empty 					:  std_logic;
  signal user_r_mem_8_data 					:  std_logic_vector(7 DOWNTO 0);
  signal user_r_mem_8_eof 						:  std_logic;
  signal user_r_mem_8_open 					:  std_logic;
  signal user_w_mem_8_wren 					:  std_logic;
  signal user_w_mem_8_full 					:  std_logic;
  signal user_w_mem_8_data 					:  std_logic_vector(7 DOWNTO 0);
  signal user_w_mem_8_open 					:  std_logic;
  signal user_mem_8_addr 						:  std_logic_vector(4 DOWNTO 0);
  signal user_mem_8_addr_update 				:  std_logic;
  signal user_r_stream0_read_32_rden 		:  std_logic;
  signal user_r_stream0_read_32_empty 		:  std_logic;
  signal user_r_stream0_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_r_stream0_read_32_eof 		:  std_logic;
  signal user_r_stream0_read_32_open 		:  std_logic;
  signal user_w_stream0_write_32_wren 		:  std_logic;
  signal user_w_stream0_write_32_full 		:  std_logic;
  signal user_w_stream0_write_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_w_stream0_write_32_open 		:  std_logic;
  signal user_r_stream1_read_32_rden 		:  std_logic;
  signal user_r_stream1_read_32_empty 		:  std_logic;
  signal user_r_stream1_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_r_stream1_read_32_eof 		:  std_logic;
  signal user_r_stream1_read_32_open 		:  std_logic;
  signal user_w_stream1_write_32_wren 		:  std_logic;
  signal user_w_stream1_write_32_full 		:  std_logic;
  signal user_w_stream1_write_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_w_stream1_write_32_open 		:  std_logic;

  signal user_led_sign			: std_logic_vector(3 downto 0);

begin  
  
  xillybus_ins : xillybus
    port map (
	 
      -- Ports related to /dev/xillybus_control0_read_32
      -- FPGA to CPU signals:
      user_r_control0_read_32_rden => user_r_control0_read_32_rden,
      user_r_control0_read_32_empty => user_r_control0_read_32_empty,
      user_r_control0_read_32_data => user_r_control0_read_32_data,
      user_r_control0_read_32_eof => user_r_control0_read_32_eof,
      user_r_control0_read_32_open => user_r_control0_read_32_open,

      -- Ports related to /dev/xillybus_control0_write_32
      -- CPU to FPGA signals:
      user_w_control0_write_32_wren => user_w_control0_write_32_wren,
      user_w_control0_write_32_full => user_w_control0_write_32_full,
      user_w_control0_write_32_data => user_w_control0_write_32_data,
      user_w_control0_write_32_open => user_w_control0_write_32_open,

      -- Ports related to /dev/xillybus_mem_8
      -- FPGA to CPU signals:
      user_r_mem_8_rden => user_r_mem_8_rden,
      user_r_mem_8_empty => user_r_mem_8_empty,
      user_r_mem_8_data => user_r_mem_8_data,
      user_r_mem_8_eof => user_r_mem_8_eof,
      user_r_mem_8_open => user_r_mem_8_open,
      -- CPU to FPGA signals:
      user_w_mem_8_wren => user_w_mem_8_wren,
      user_w_mem_8_full => user_w_mem_8_full,
      user_w_mem_8_data => user_w_mem_8_data,
      user_w_mem_8_open => user_w_mem_8_open,
      -- Address signals:
      user_mem_8_addr => user_mem_8_addr,
      user_mem_8_addr_update => user_mem_8_addr_update,

      -- Ports related to /dev/xillybus_stream0_read_32
      -- FPGA to CPU signals:
      user_r_stream0_read_32_rden => user_r_stream0_read_32_rden,
      user_r_stream0_read_32_empty => user_r_stream0_read_32_empty,
      user_r_stream0_read_32_data => user_r_stream0_read_32_data,
      user_r_stream0_read_32_eof => user_r_stream0_read_32_eof,
      user_r_stream0_read_32_open => user_r_stream0_read_32_open,

      -- Ports related to /dev/xillybus_stream0_write_32
      -- CPU to FPGA signals:
      user_w_stream0_write_32_wren => user_w_stream0_write_32_wren,
      user_w_stream0_write_32_full => user_w_stream0_write_32_full,
      user_w_stream0_write_32_data => user_w_stream0_write_32_data,
      user_w_stream0_write_32_open => user_w_stream0_write_32_open,

      -- Ports related to /dev/xillybus_stream1_read_32
      -- FPGA to CPU signals:
      user_r_stream1_read_32_rden => user_r_stream1_read_32_rden,
      user_r_stream1_read_32_empty => user_r_stream1_read_32_empty,
      user_r_stream1_read_32_data => user_r_stream1_read_32_data,
      user_r_stream1_read_32_eof => user_r_stream1_read_32_eof,
      user_r_stream1_read_32_open => user_r_stream1_read_32_open,

      -- Ports related to /dev/xillybus_stream1_write_32
      -- CPU to FPGA signals:
      user_w_stream1_write_32_wren => user_w_stream1_write_32_wren,
      user_w_stream1_write_32_full => user_w_stream1_write_32_full,
      user_w_stream1_write_32_data => user_w_stream1_write_32_data,
      user_w_stream1_write_32_open => user_w_stream1_write_32_open,
		
--      -- Ports related to /dev/xillybus_mem_8
--      -- FPGA to CPU signals:
--      user_r_mem_8_rden => user_r_mem_8_rden,
--      user_r_mem_8_empty => user_r_mem_8_empty,
--      user_r_mem_8_data => user_r_mem_8_data,
--      user_r_mem_8_eof => user_r_mem_8_eof,
--      user_r_mem_8_open => user_r_mem_8_open,
--      -- CPU to FPGA signals:
--      user_w_mem_8_wren => user_w_mem_8_wren,
--      user_w_mem_8_full => user_w_mem_8_full,
--      user_w_mem_8_data => user_w_mem_8_data,
--      user_w_mem_8_open => user_w_mem_8_open,
--      -- Address signals:
--      user_mem_8_addr => user_mem_8_addr,
--      user_mem_8_addr_update => user_mem_8_addr_update,
--
--      -- Ports related to /dev/xillybus_read_32
--      -- FPGA to CPU signals:
--      user_r_read_32_rden => user_r_read_32_rden,
--      user_r_read_32_empty => user_r_read_32_empty,
--      user_r_read_32_data => user_r_read_32_data,
--      user_r_read_32_eof => user_r_read_32_eof,
--      user_r_read_32_open => user_r_read_32_open,
--
--      -- Ports related to /dev/xillybus_read_8
--      -- FPGA to CPU signals:
--      user_r_read_8_rden => user_r_read_8_rden,
--      user_r_read_8_empty => user_r_read_8_empty,
--      user_r_read_8_data => user_r_read_8_data,
--      user_r_read_8_eof => user_r_read_8_eof,
--      user_r_read_8_open => user_r_read_8_open,
--
--      -- Ports related to /dev/xillybus_write_32
--      -- CPU to FPGA signals:
--      user_w_write_32_wren => user_w_write_32_wren,
--      user_w_write_32_full => user_w_write_32_full,
--      user_w_write_32_data => user_w_write_32_data,
--      user_w_write_32_open => user_w_write_32_open,
--
--      -- Ports related to /dev/xillybus_write_8
--      -- CPU to FPGA signals:
--      user_w_write_8_wren => user_w_write_8_wren,
--      user_w_write_8_full => user_w_write_8_full,
--      user_w_write_8_data => user_w_write_8_data,
--      user_w_write_8_open => user_w_write_8_open,

      -- General signals
      pcie_perstn => pcie_perstn,
      pcie_refclk => pcie_refclk,
      pcie_rx => pcie_rx,
      bus_clk => bus_clk,
      pcie_tx => pcie_tx,
      quiesce => quiesce,
      user_led => user_led_sign 
      );
		
		user_led(0) <= '0' when user_led_sign(0)='0' else  'Z';
		user_led(1) <= '0' when user_led_sign(1)='0' else  'Z';
		user_led(2) <= '0' when user_led_sign(2)='0' else  'Z';
		user_led(3) <= '0' when user_led_sign(3)='0' else  'Z';
        
--  A simple inferred RAM

  ram_addr <= conv_integer(user_mem_8_addr);
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_w_mem_8_wren = '1') then 
        demoarray(ram_addr) <= user_w_mem_8_data;
      end if;
      if (user_r_mem_8_rden = '1') then
        user_r_mem_8_data <= demoarray(ram_addr);
      end if;
    end if;
  end process;

  user_r_mem_8_empty <= '0';
  user_r_mem_8_eof <= '0';
  user_w_mem_8_full <= '0';

--  32-bit stream0 loopback
  
  stream0_fifo_32 : scfifo
    GENERIC MAP (
      add_ram_output_register 	=> "OFF",
      intended_device_family 		=> "Stratix IV",
      lpm_numwords 					=> 512,
      lpm_showahead 					=> "OFF",
      lpm_type 						=> "scfifo",
      lpm_width 						=> 32,
      lpm_widthu 						=> 9,
      overflow_checking 			=> "ON",
      underflow_checking 			=> "ON",
      use_eab 							=> "ON"
      )
    PORT MAP (
      clock 	=> bus_clk,
      data 		=> user_w_stream0_write_32_data,
      rdreq 	=> user_r_stream0_read_32_rden,
      sclr 		=> stream0_reset_32,
      wrreq 	=> user_w_stream0_write_32_wren,
      empty 	=> user_r_stream0_read_32_empty,
      full 		=> user_w_stream0_write_32_full,
      q 			=> user_r_stream0_read_32_data
    );  
  
    stream0_reset_32 <= not (user_w_stream0_write_32_open or user_r_stream0_read_32_open);

    user_r_stream0_read_32_eof <= '0';
	 
--  32-bit stream1 loopback
  
  stream1_fifo_32 : scfifo
    GENERIC MAP (
      add_ram_output_register 	=> "OFF",
      intended_device_family 		=> "Stratix IV",
      lpm_numwords 					=> 512,
      lpm_showahead 					=> "OFF",
      lpm_type 						=> "scfifo",
      lpm_width 						=> 32,
      lpm_widthu 						=> 9,
      overflow_checking 			=> "ON",
      underflow_checking 			=> "ON",
      use_eab 							=> "ON"
      )
    PORT MAP (
      clock 	=> bus_clk,
      data 		=> user_w_stream1_write_32_data,
      rdreq 	=> user_r_stream1_read_32_rden,
      sclr 		=> stream1_reset_32,
      wrreq 	=> user_w_stream1_write_32_wren,
      empty 	=> user_r_stream1_read_32_empty,
      full 		=> user_w_stream1_write_32_full,
      q 			=> user_r_stream1_read_32_data
    );  
  
    stream1_reset_32 <= not (user_w_stream1_write_32_open or user_r_stream1_read_32_open);

    user_r_stream1_read_32_eof <= '0';

--  32-bit control0 loopback
  control0_fifo_32 : scfifo
    GENERIC MAP (
      add_ram_output_register 	=> "OFF",
      intended_device_family 		=> "Stratix IV",
      lpm_numwords 					=> 512,
      lpm_showahead 					=> "OFF",
      lpm_type 						=> "scfifo",
      lpm_width 						=> 32,
      lpm_widthu 						=> 9,
      overflow_checking 			=> "ON",
      underflow_checking 			=> "ON",
      use_eab 							=> "ON"
      )
    PORT MAP (
      clock 	=> bus_clk,
      data 		=> user_w_control0_write_32_data,
      rdreq 	=> user_r_control0_read_32_rden,
      sclr 		=> control0_reset_32,
      wrreq 	=> user_w_control0_write_32_wren,
      empty 	=> user_r_control0_read_32_empty,
      full 		=> user_w_control0_write_32_full,
      q 			=> user_r_control0_read_32_data
    );  
  
    control0_reset_32 <= not (user_w_control0_write_32_open or user_r_control0_read_32_open);

    user_r_control0_read_32_eof <= '0';	 
  
--  8-bit loopback

--  fifo_8 : scfifo
--    GENERIC MAP (
--      add_ram_output_register => "OFF",
--      intended_device_family => "Stratix IV",
--      lpm_numwords => 2048,
--      lpm_showahead => "OFF",
--      lpm_type => "scfifo",
--      lpm_width => 8,
--      lpm_widthu => 11,
--      overflow_checking => "ON",
--      underflow_checking => "ON",
--      use_eab => "ON"
--      )
--    PORT MAP (
--      clock => bus_clk,
--      data => user_w_write_8_data,
--      rdreq => user_r_read_8_rden,
--      sclr => reset_8,
--      wrreq => user_w_write_8_wren,
--      empty => user_r_read_8_empty,
--      full => user_w_write_8_full,
--      q => user_r_read_8_data
--    );  
--  
--    reset_8 <= not (user_w_write_8_open or user_r_read_8_open);
--
--    user_r_read_8_eof <= '0';
  
end sample_arch;
